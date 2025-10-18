import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/download_model.dart';

part 'download_api_client.g.dart';

/// REST API client for download operations
@RestApi()
abstract class DownloadApiClient {
  factory DownloadApiClient(Dio dio, {String baseUrl}) = _DownloadApiClient;

  /// Get all active downloads (queue)
  @GET('/queue')
  Future<List<DownloadModel>> getQueue();

  /// Get all completed downloads
  @GET('/done')
  Future<List<DownloadModel>> getCompleted();

  /// Get all pending downloads
  @GET('/pending')
  Future<List<DownloadModel>> getPending();

  /// Add a new download
  @POST('/add')
  Future<AddDownloadResponse> addDownload(@Body() AddDownloadRequest request);

  /// Start a pending download
  @POST('/start/{id}')
  Future<void> startDownload(@Path('id') String id);

  /// Cancel an active download
  @POST('/cancel/{id}')
  Future<void> cancelDownload(@Path('id') String id);

  /// Delete a download
  @DELETE('/delete/{id}')
  Future<void> deleteDownload(@Path('id') String id);

  /// Clear all completed downloads
  @POST('/clear')
  Future<void> clearCompleted();
}
