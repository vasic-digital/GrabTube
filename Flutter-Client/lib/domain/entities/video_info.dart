import 'package:equatable/equatable.dart';

/// Video information entity
class VideoInfo extends Equatable {
  const VideoInfo({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    this.duration,
    this.uploader,
    this.description,
    this.viewCount,
    this.uploadDate,
    this.formats,
  });

  final String id;
  final String title;
  final String url;
  final String? thumbnail;
  final int? duration;
  final String? uploader;
  final String? description;
  final int? viewCount;
  final DateTime? uploadDate;
  final List<VideoFormat>? formats;

  /// Get formatted duration (HH:MM:SS)
  String get formattedDuration {
    if (duration == null) return 'Unknown';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get formatted view count
  String get formattedViewCount {
    if (viewCount == null) return 'Unknown';
    if (viewCount! >= 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount! >= 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        url,
        thumbnail,
        duration,
        uploader,
        description,
        viewCount,
        uploadDate,
        formats,
      ];
}

/// Video format information
class VideoFormat extends Equatable {
  const VideoFormat({
    required this.formatId,
    required this.ext,
    this.quality,
    this.width,
    this.height,
    this.fileSize,
    this.fps,
    this.vcodec,
    this.acodec,
  });

  final String formatId;
  final String ext;
  final String? quality;
  final int? width;
  final int? height;
  final int? fileSize;
  final int? fps;
  final String? vcodec;
  final String? acodec;

  /// Get resolution string (e.g., "1920x1080")
  String? get resolution {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return null;
  }

  /// Get formatted file size
  String? get formattedFileSize {
    if (fileSize == null) return null;
    if (fileSize! >= 1073741824) {
      return '${(fileSize! / 1073741824).toStringAsFixed(2)} GB';
    } else if (fileSize! >= 1048576) {
      return '${(fileSize! / 1048576).toStringAsFixed(2)} MB';
    } else if (fileSize! >= 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    }
    return '$fileSize B';
  }

  @override
  List<Object?> get props => [
        formatId,
        ext,
        quality,
        width,
        height,
        fileSize,
        fps,
        vcodec,
        acodec,
      ];
}
