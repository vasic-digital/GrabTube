import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/download_model.dart';

part 'api_client.g.dart';

@RestApi()
@singleton
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(@Named('main') Dio dio) = _ApiClient;

  /// Add a new download to the queue
  @POST('/add')
  Future<Map<String, dynamic>> addDownload({
    @Field('url') required String url,
    @Field('quality') String? quality,
    @Field('format') String? format,
    @Field('folder') String? folder,
    @Field('auto_start') bool? autoStart,
  });

  /// Get all downloads (queue + done)
  @GET('/downloads')
  Future<Map<String, dynamic>> getDownloads();

  /// Get download queue
  @GET('/queue')
  Future<List<DownloadModel>> getQueue();

  /// Get completed downloads
  @GET('/done')
  Future<List<DownloadModel>> getCompleted();

  /// Get pending downloads
  @GET('/pending')
  Future<List<DownloadModel>> getPending();

  /// Delete a download
  @POST('/delete')
  Future<Map<String, dynamic>> deleteDownload({
    @Field('ids') required List<String> ids,
    @Field('where') String where = 'queue',
  });

  /// Start a download
  @POST('/start')
  Future<Map<String, dynamic>> startDownload({
    @Field('ids') required List<String> ids,
  });

  /// Get download history
  @GET('/history')
  Future<List<DownloadModel>> getHistory();

  /// Re-download from history
  @POST('/redownload')
  Future<Map<String, dynamic>> redownload({
    @Field('url') required String url,
    @Field('quality') String? quality,
    @Field('format') String? format,
    @Field('folder') String? folder,
    @Field('custom_name_prefix') String? customNamePrefix,
    @Field('playlist_strict_mode') bool? playlistStrictMode,
    @Field('playlist_item_limit') int? playlistItemLimit,
    @Field('auto_start') bool? autoStart,
  });

  /// Clear completed downloads
  @POST('/clear')
  Future<Map<String, dynamic>> clearCompleted();

  /// Get video info
  @GET('/info')
  Future<Map<String, dynamic>> getVideoInfo({
    @Query('url') required String url,
  });

  /// Check server health
  @GET('/health')
  Future<Map<String, dynamic>> checkHealth();
}
