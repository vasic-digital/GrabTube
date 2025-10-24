# Embedded ytdl.py for Flutter-Client
# Based on Web-Client/app/ytdl.py with modifications for embedded use

import asyncio
import os
import sys
import time
import uuid
import json
import shelve
import multiprocessing
from pathlib import Path
from typing import Optional, List, Dict, Any
import logging

from yt_dlp import YoutubeDL

log = logging.getLogger('ytdl')

class DownloadInfo:
    """Download information container"""
    
    def __init__(self, **kwargs):
        self.id = kwargs.get('id', str(uuid.uuid4()))
        self.url = kwargs.get('url', '')
        self.title = kwargs.get('title', '')
        self.status = kwargs.get('status', 'pending')
        self.progress = kwargs.get('progress', 0.0)
        self.speed = kwargs.get('speed', '')
        self.eta = kwargs.get('eta', '')
        self.filename = kwargs.get('filename', '')
        self.filesize = kwargs.get('filesize', 0)
        self.downloaded_bytes = kwargs.get('downloaded_bytes', 0)
        self.quality = kwargs.get('quality', '')
        self.format = kwargs.get('format', '')
        self.folder = kwargs.get('folder', '')
        self.auto_start = kwargs.get('auto_start', True)
        self.created_at = kwargs.get('created_at', time.time())
        self.completed_at = kwargs.get('completed_at', 0)
        self.error = kwargs.get('error', '')
    
    def to_dict(self):
        """Convert to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'url': self.url,
            'title': self.title,
            'status': self.status,
            'progress': self.progress,
            'speed': self.speed,
            'eta': self.eta,
            'filename': self.filename,
            'filesize': self.filesize,
            'downloaded_bytes': self.downloaded_bytes,
            'quality': self.quality,
            'format': self.format,
            'folder': self.folder,
            'auto_start': self.auto_start,
            'created_at': self.created_at,
            'completed_at': self.completed_at,
            'error': self.error
        }

class Download:
    """Individual download handler"""
    
    def __init__(self, download_info: DownloadInfo, download_dir: str, ytdl_options: Dict):
        self.info = download_info
        self.download_dir = download_dir
        self.ytdl_options = ytdl_options
        self.process: Optional[multiprocessing.Process] = None
        self._stop_event = multiprocessing.Event()
    
    def start(self):
        """Start download in separate process"""
        if self.process and self.process.is_alive():
            return
        
        self._stop_event.clear()
        self.process = multiprocessing.Process(
            target=self._download_worker,
            args=(self.info.to_dict(), self.download_dir, self.ytdl_options)
        )
        self.process.start()
    
    def stop(self):
        """Stop download"""
        if self.process and self.process.is_alive():
            self.process.terminate()
            self.process.join()
    
    @staticmethod
    def _download_worker(download_info: Dict, download_dir: str, ytdl_options: Dict):
        """Worker function for download process"""
        try:
            # Setup yt-dlp options
            options = {
                'outtmpl': os.path.join(download_dir, '%(title)s.%(ext)s'),
                'progress_hooks': [lambda d: Download._progress_hook(d, download_info['id'])],
                'logger': logging.getLogger('yt-dlp'),
                **ytdl_options
            }
            
            # Add format/quality options if specified
            if download_info.get('quality') or download_info.get('format'):
                from .dl_formats import get_format_string
                options['format'] = get_format_string(
                    download_info.get('quality'),
                    download_info.get('format')
                )
            
            # Custom folder
            if download_info.get('folder'):
                folder_path = os.path.join(download_dir, download_info['folder'])
                os.makedirs(folder_path, exist_ok=True)
                options['outtmpl'] = os.path.join(folder_path, '%(title)s.%(ext)s')
            
            with YoutubeDL(options) as ydl:
                ydl.download([download_info['url']])
                
        except Exception as e:
            log.error(f'Download worker error: {e}')
    
    @staticmethod
    def _progress_hook(d: Dict, download_id: str):
        """Progress hook for yt-dlp"""
        try:
            # Update download info in shared state
            # This would need to be implemented with proper IPC
            pass
        except Exception as e:
            log.error(f'Progress hook error: {e}')

class PersistentQueue:
    """Persistent queue using shelve"""
    
    def __init__(self, state_dir: str):
        self.state_dir = state_dir
        os.makedirs(state_dir, exist_ok=True)
        self.db_path = os.path.join(state_dir, 'queue.db')
    
    def load(self) -> Dict[str, List[Dict]]:
        """Load queue state"""
        try:
            with shelve.open(self.db_path) as db:
                return {
                    'queue': db.get('queue', []),
                    'done': db.get('done', []),
                    'pending': db.get('pending', [])
                }
        except Exception as e:
            log.error(f'Failed to load queue state: {e}')
            return {'queue': [], 'done': [], 'pending': []}
    
    def save(self, state: Dict[str, List[Dict]]):
        """Save queue state"""
        try:
            with shelve.open(self.db_path) as db:
                db['queue'] = state.get('queue', [])
                db['done'] = state.get('done', [])
                db['pending'] = state.get('pending', [])
        except Exception as e:
            log.error(f'Failed to save queue state: {e}')

class DownloadQueue:
    """Download queue manager"""
    
    def __init__(self, download_dir: str, state_dir: str, download_mode: str = 'limited', 
                 max_concurrent_downloads: int = 3):
        self.download_dir = download_dir
        self.state_dir = state_dir
        self.download_mode = download_mode
        self.max_concurrent_downloads = max_concurrent_downloads
        self.persistent_queue = PersistentQueue(state_dir)
        
        # Load state
        state = self.persistent_queue.load()
        self.queue: List[DownloadInfo] = [DownloadInfo(**d) for d in state.get('queue', [])]
        self.done: List[DownloadInfo] = [DownloadInfo(**d) for d in state.get('done', [])]
        self.pending: List[DownloadInfo] = [DownloadInfo(**d) for d in state.get('pending', [])]
        
        self.active_downloads: Dict[str, Download] = {}
        self.ytdl_options = {}
        
        # Ensure download directory exists
        os.makedirs(download_dir, exist_ok=True)
    
    async def add(self, url: str, quality: Optional[str] = None, format: Optional[str] = None,
                  folder: Optional[str] = None, auto_start: bool = True) -> DownloadInfo:
        """Add a new download"""
        try:
            # Get video info first
            video_info = await self.get_video_info(url)
            
            download_info = DownloadInfo(
                url=url,
                title=video_info.get('title', 'Unknown'),
                quality=quality,
                format=format,
                folder=folder,
                auto_start=auto_start
            )
            
            if auto_start:
                self.queue.append(download_info)
            else:
                self.pending.append(download_info)
            
            self._save_state()
            
            if auto_start:
                await self._start_download(download_info)
            
            return download_info
            
        except Exception as e:
            log.error(f'Failed to add download: {e}')
            raise
    
    async def get_queue(self) -> List[DownloadInfo]:
        """Get download queue"""
        return self.queue.copy()
    
    async def get_done(self) -> List[DownloadInfo]:
        """Get completed downloads"""
        return self.done.copy()
    
    async def get_pending(self) -> List[DownloadInfo]:
        """Get pending downloads"""
        return self.pending.copy()
    
    async def get_history(self) -> List[DownloadInfo]:
        """Get download history"""
        return self.done.copy()
    
    async def delete(self, ids: List[str], where: str = 'queue'):
        """Delete downloads"""
        target_list = getattr(self, where, self.queue)
        
        # Remove from target list
        setattr(self, where, [d for d in target_list if d.id not in ids])
        
        # Stop active downloads
        for download_id in ids:
            if download_id in self.active_downloads:
                self.active_downloads[download_id].stop()
                del self.active_downloads[download_id]
        
        self._save_state()
    
    async def start(self, ids: List[str]):
        """Start pending downloads"""
        for download_info in self.pending:
            if download_info.id in ids:
                self.pending.remove(download_info)
                self.queue.append(download_info)
                await self._start_download(download_info)
        
        self._save_state()
    
    async def clear_completed(self):
        """Clear completed downloads"""
        self.done.clear()
        self._save_state()
    
    async def get_video_info(self, url: str) -> Dict[str, Any]:
        """Get video info without downloading"""
        try:
            options = {
                'quiet': True,
                'no_warnings': True,
                'skip_download': True,
                **self.ytdl_options
            }
            
            with YoutubeDL(options) as ydl:
                info = ydl.extract_info(url, download=False)
                
                return {
                    'id': info.get('id', ''),
                    'title': info.get('title', 'Unknown'),
                    'thumbnail': info.get('thumbnail', ''),
                    'duration': info.get('duration', 0),
                    'uploader': info.get('uploader', ''),
                    'description': info.get('description', ''),
                    'view_count': info.get('view_count', 0)
                }
                
        except Exception as e:
            log.error(f'Failed to get video info: {e}')
            raise
    
    async def _start_download(self, download_info: DownloadInfo):
        """Start a download"""
        try:
            # Check concurrent download limit
            if (self.download_mode == 'limited' and 
                len(self.active_downloads) >= self.max_concurrent_downloads):
                return
            
            download = Download(download_info, self.download_dir, self.ytdl_options)
            self.active_downloads[download_info.id] = download
            download.start()
            
        except Exception as e:
            log.error(f'Failed to start download: {e}')
            download_info.status = 'error'
            download_info.error = str(e)
    
    def _save_state(self):
        """Save queue state"""
        state = {
            'queue': [d.to_dict() for d in self.queue],
            'done': [d.to_dict() for d in self.done],
            'pending': [d.to_dict() for d in self.pending]
        }
        self.persistent_queue.save(state)
    
    async def close(self):
        """Close the queue and stop all downloads"""
        for download in self.active_downloads.values():
            download.stop()
        self.active_downloads.clear()

class DownloadQueueNotifier:
    """Notifier for download queue events"""
    
    def __init__(self, queue: DownloadQueue, sio):
        self.queue = queue
        self.sio = sio
    
    async def notify_added(self, download_info: DownloadInfo):
        """Notify when download is added"""
        await self.sio.emit('added', download_info.to_dict())
    
    async def notify_updated(self, download_info: DownloadInfo):
        """Notify when download is updated"""
        await self.sio.emit('updated', download_info.to_dict())
    
    async def notify_completed(self, download_info: DownloadInfo):
        """Notify when download is completed"""
        await self.sio.emit('completed', download_info.to_dict())
    
    async def notify_canceled(self, download_id: str):
        """Notify when download is canceled"""
        await self.sio.emit('canceled', download_id)
    
    async def notify_cleared(self):
        """Notify when queue is cleared"""
        await self.sio.emit('cleared', {})