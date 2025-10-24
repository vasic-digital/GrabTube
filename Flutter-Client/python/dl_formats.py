# Embedded dl_formats.py for Flutter-Client
# Based on Web-Client/app/dl_formats.py with modifications for embedded use

from typing import Optional

# Format definitions
FORMATS = {
    'audio': {
        'mp3': {
            'name': 'MP3',
            'ext': 'mp3',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }
            ]
        },
        'm4a': {
            'name': 'M4A',
            'ext': 'm4a',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'm4a',
                }
            ]
        },
        'flac': {
            'name': 'FLAC',
            'ext': 'flac',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'flac',
                }
            ]
        },
        'opus': {
            'name': 'Opus',
            'ext': 'opus',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'opus',
                }
            ]
        },
        'vorbis': {
            'name': 'Vorbis',
            'ext': 'ogg',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'vorbis',
                }
            ]
        },
        'wav': {
            'name': 'WAV',
            'ext': 'wav',
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'wav',
                }
            ]
        },
    },
    'video': {
        'mp4': {
            'name': 'MP4',
            'ext': 'mp4',
        },
        'webm': {
            'name': 'WebM',
            'ext': 'webm',
        },
        'mkv': {
            'name': 'MKV',
            'ext': 'mkv',
        },
        'avi': {
            'name': 'AVI',
            'ext': 'avi',
        },
        'mov': {
            'name': 'MOV',
            'ext': 'mov',
        },
    }
}

# Quality definitions
QUALITIES = {
    'audio': {
        'best': {'name': 'Best', 'format': 'bestaudio'},
        '320': {'name': '320k', 'format': 'bestaudio[abr<=320]'},
        '256': {'name': '256k', 'format': 'bestaudio[abr<=256]'},
        '192': {'name': '192k', 'format': 'bestaudio[abr<=192]'},
        '128': {'name': '128k', 'format': 'bestaudio[abr<=128]'},
    },
    'video': {
        'best': {'name': 'Best', 'format': 'bestvideo+bestaudio/best'},
        '4k': {'name': '4K', 'format': 'bestvideo[height<=2160]+bestaudio/best[height<=2160]'},
        '1440': {'name': '1440p', 'format': 'bestvideo[height<=1440]+bestaudio/best[height<=1440]'},
        '1080': {'name': '1080p', 'format': 'bestvideo[height<=1080]+bestaudio/best[height<=1080]'},
        '720': {'name': '720p', 'format': 'bestvideo[height<=720]+bestaudio/best[height<=720]'},
        '480': {'name': '480p', 'format': 'bestvideo[height<=480]+bestaudio/best[height<=480]'},
        '360': {'name': '360p', 'format': 'bestvideo[height<=360]+bestaudio/best[height<=360]'},
        '240': {'name': '240p', 'format': 'bestvideo[height<=240]+bestaudio/best[height<=240]'},
        '144': {'name': '144p', 'format': 'bestvideo[height<=144]+bestaudio/best[height<=144]'},
    }
}

def get_format_string(quality: Optional[str] = None, format_type: Optional[str] = None) -> str:
    """
    Generate yt-dlp format string based on quality and format selection
    """
    if not quality and not format_type:
        return 'bestvideo+bestaudio/best'
    
    # Audio-only formats
    if format_type in FORMATS['audio']:
        if quality and quality in QUALITIES['audio']:
            return QUALITIES['audio'][quality]['format']
        return 'bestaudio'
    
    # Video formats
    if format_type in FORMATS['video']:
        if quality and quality in QUALITIES['video']:
            return QUALITIES['video'][quality]['format']
        return 'bestvideo+bestaudio/best'
    
    # Quality-only selection
    if quality:
        if quality in QUALITIES['video']:
            return QUALITIES['video'][quality]['format']
        elif quality in QUALITIES['audio']:
            return QUALITIES['audio'][quality]['format']
    
    # Default fallback
    return 'bestvideo+bestaudio/best'

def get_postprocessors(format_type: Optional[str] = None) -> list:
    """
    Get postprocessors for the selected format
    """
    if not format_type:
        return []
    
    # Audio formats need extraction postprocessor
    if format_type in FORMATS['audio']:
        return FORMATS['audio'][format_type].get('postprocessors', [])
    
    return []

def get_available_formats() -> dict:
    """
    Get all available formats and qualities
    """
    return {
        'audio': {
            'formats': {k: v['name'] for k, v in FORMATS['audio'].items()},
            'qualities': {k: v['name'] for k, v in QUALITIES['audio'].items()}
        },
        'video': {
            'formats': {k: v['name'] for k, v in FORMATS['video'].items()},
            'qualities': {k: v['name'] for k, v in QUALITIES['video'].items()}
        }
    }

def get_ios_compatible_formats() -> list:
    """
    Get iOS-compatible formats
    """
    return ['mp4', 'm4a', 'mov']

def is_audio_format(format_type: str) -> bool:
    """
    Check if format is audio-only
    """
    return format_type in FORMATS['audio']

def is_video_format(format_type: str) -> bool:
    """
    Check if format is video
    """
    return format_type in FORMATS['video']