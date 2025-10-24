#!/usr/bin/env python3
# Embedded Python server for Flutter-Client
# Based on Web-Client/app/main.py with modifications for embedded use

import os
import sys
import asyncio
from pathlib import Path
from aiohttp import web
import socketio
import logging
import json
from watchfiles import awatch

from .ytdl import DownloadQueueNotifier, DownloadQueue

log = logging.getLogger('embedded_server')

class EmbeddedConfig:
    """Configuration for embedded Python server"""
    
    def __init__(self, download_dir=None, port=8081):
        self.DOWNLOAD_DIR = download_dir or str(Path.home() / 'Downloads' / 'GrabTube')
        self.AUDIO_DOWNLOAD_DIR = self.DOWNLOAD_DIR
        self.TEMP_DIR = self.DOWNLOAD_DIR
        self.DOWNLOAD_DIRS_INDEXABLE = False
        self.CUSTOM_DIRS = True
        self.CREATE_CUSTOM_DIRS = True
        self.CUSTOM_DIRS_EXCLUDE_REGEX = r'(^|/)[.@].*$'
        self.DELETE_FILE_ON_TRASHCAN = False
        self.STATE_DIR = str(Path(self.DOWNLOAD_DIR) / '.grabtube')
        self.URL_PREFIX = ''
        self.PUBLIC_HOST_URL = 'download/'
        self.PUBLIC_HOST_AUDIO_URL = 'audio_download/'
        self.OUTPUT_TEMPLATE = '%(title)s.%(ext)s'
        self.OUTPUT_TEMPLATE_CHAPTER = '%(title)s - %(section_number)s %(section_title)s.%(ext)s'
        self.OUTPUT_TEMPLATE_PLAYLIST = '%(playlist_title)s/%(title)s.%(ext)s'
        self.DEFAULT_OPTION_PLAYLIST_STRICT_MODE = False
        self.DEFAULT_OPTION_PLAYLIST_ITEM_LIMIT = 0
        self.YTDL_OPTIONS = {}
        self.YTDL_OPTIONS_FILE = ''
        self.ROBOTS_TXT = ''
        self.HOST = '127.0.0.1'
        self.PORT = port
        self.HTTPS = False
        self.CERTFILE = ''
        self.KEYFILE = ''
        self.BASE_DIR = ''
        self.DEFAULT_THEME = 'auto'
        self.DOWNLOAD_MODE = 'limited'
        self.MAX_CONCURRENT_DOWNLOADS = 3
        self.LOGLEVEL = 'INFO'
        self.ENABLE_ACCESSLOG = False
        
        # Ensure download directory exists
        os.makedirs(self.DOWNLOAD_DIR, exist_ok=True)
        os.makedirs(self.STATE_DIR, exist_ok=True)

class EmbeddedServer:
    """Embedded Python server for Flutter-Client"""
    
    def __init__(self, config=None):
        self.config = config or EmbeddedConfig()
        self.sio = socketio.AsyncServer(async_mode='aiohttp', cors_allowed_origins='*')
        self.app = web.Application()
        self.sio.attach(self.app)
        self.queue = None
        self.notifier = None
        self.runner = None
        self.site = None
        
        # Setup logging
        logging.basicConfig(
            level=getattr(logging, self.config.LOGLEVEL),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        self._setup_routes()
        self._setup_socket_events()
    
    def _setup_routes(self):
        """Setup HTTP routes"""
        self.app.router.add_post('/add', self.add_download)
        self.app.router.add_get('/downloads', self.get_downloads)
        self.app.router.add_get('/queue', self.get_queue)
        self.app.router.add_get('/done', self.get_done)
        self.app.router.add_get('/pending', self.get_pending)
        self.app.router.add_post('/delete', self.delete_download)
        self.app.router.add_post('/start', self.start_download)
        self.app.router.add_get('/history', self.get_history)
        self.app.router.add_post('/clear', self.clear_completed)
        self.app.router.add_get('/info', self.get_video_info)
        self.app.router.add_get('/health', self.health_check)
    
    def _setup_socket_events(self):
        """Setup Socket.IO events"""
        @self.sio.event
        async def connect(sid, environ):
            log.info(f'Client connected: {sid}')
            await self.sio.emit('connected', {'message': 'Connected to embedded server'}, room=sid)
        
        @self.sio.event
        async def disconnect(sid):
            log.info(f'Client disconnected: {sid}')
    
    async def add_download(self, request):
        """Add a new download"""
        try:
            data = await request.post()
            download = await self.queue.add(
                url=data['url'],
                quality=data.get('quality'),
                format=data.get('format'),
                folder=data.get('folder'),
                auto_start=data.get('auto_start', True)
            )
            return web.json_response({
                'success': True,
                'download': download.to_dict()
            })
        except Exception as e:
            log.error(f'Failed to add download: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=400)
    
    async def get_downloads(self, request):
        """Get all downloads"""
        try:
            queue = await self.queue.get_queue()
            done = await self.queue.get_done()
            pending = await self.queue.get_pending()
            
            return web.json_response({
                'queue': [d.to_dict() for d in queue],
                'done': [d.to_dict() for d in done],
                'pending': [d.to_dict() for d in pending]
            })
        except Exception as e:
            log.error(f'Failed to get downloads: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def get_queue(self, request):
        """Get download queue"""
        try:
            queue = await self.queue.get_queue()
            return web.json_response([d.to_dict() for d in queue])
        except Exception as e:
            log.error(f'Failed to get queue: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def get_done(self, request):
        """Get completed downloads"""
        try:
            done = await self.queue.get_done()
            return web.json_response([d.to_dict() for d in done])
        except Exception as e:
            log.error(f'Failed to get done: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def get_pending(self, request):
        """Get pending downloads"""
        try:
            pending = await self.queue.get_pending()
            return web.json_response([d.to_dict() for d in pending])
        except Exception as e:
            log.error(f'Failed to get pending: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def delete_download(self, request):
        """Delete a download"""
        try:
            data = await request.post()
            ids = data.get('ids', [])
            where = data.get('where', 'queue')
            
            await self.queue.delete(ids, where)
            return web.json_response({'success': True})
        except Exception as e:
            log.error(f'Failed to delete download: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=400)
    
    async def start_download(self, request):
        """Start a download"""
        try:
            data = await request.post()
            ids = data.get('ids', [])
            
            await self.queue.start(ids)
            return web.json_response({'success': True})
        except Exception as e:
            log.error(f'Failed to start download: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=400)
    
    async def get_history(self, request):
        """Get download history"""
        try:
            history = await self.queue.get_history()
            return web.json_response([d.to_dict() for d in history])
        except Exception as e:
            log.error(f'Failed to get history: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def clear_completed(self, request):
        """Clear completed downloads"""
        try:
            await self.queue.clear_completed()
            return web.json_response({'success': True})
        except Exception as e:
            log.error(f'Failed to clear completed: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=500)
    
    async def get_video_info(self, request):
        """Get video info without downloading"""
        try:
            url = request.query.get('url')
            if not url:
                return web.json_response({
                    'success': False,
                    'error': 'URL parameter required'
                }, status=400)
            
            info = await self.queue.get_video_info(url)
            return web.json_response(info)
        except Exception as e:
            log.error(f'Failed to get video info: {e}')
            return web.json_response({
                'success': False,
                'error': str(e)
            }, status=400)
    
    async def health_check(self, request):
        """Health check endpoint"""
        return web.json_response({
            'status': 'ok',
            'server': 'embedded',
            'version': '1.0.0'
        })
    
    async def start(self):
        """Start the embedded server"""
        try:
            # Initialize download queue
            self.queue = DownloadQueue(
                download_dir=self.config.DOWNLOAD_DIR,
                state_dir=self.config.STATE_DIR,
                download_mode=self.config.DOWNLOAD_MODE,
                max_concurrent_downloads=self.config.MAX_CONCURRENT_DOWNLOADS
            )
            
            self.notifier = DownloadQueueNotifier(self.queue, self.sio)
            
            # Start the server
            self.runner = web.AppRunner(self.app)
            await self.runner.setup()
            
            self.site = web.TCPSite(
                self.runner,
                self.config.HOST,
                self.config.PORT
            )
            
            await self.site.start()
            log.info(f'Embedded server started on http://{self.config.HOST}:{self.config.PORT}')
            
            return True
        except Exception as e:
            log.error(f'Failed to start embedded server: {e}')
            return False
    
    async def stop(self):
        """Stop the embedded server"""
        try:
            if self.site:
                await self.site.stop()
            if self.runner:
                await self.runner.cleanup()
            if self.queue:
                await self.queue.close()
            log.info('Embedded server stopped')
        except Exception as e:
            log.error(f'Error stopping embedded server: {e}')

async def main():
    """Main entry point for standalone execution"""
    server = EmbeddedServer()
    await server.start()
    
    try:
        # Keep server running
        while True:
            await asyncio.sleep(1)
    except KeyboardInterrupt:
        await server.stop()

if __name__ == '__main__':
    asyncio.run(main())