import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/search_parameters.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../models/search_parameters_model.dart';
import '../models/search_result_model.dart';

/// Implementation of SearchRepository using API client and Hive
@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(
    this._dio,
    this._searchHistoryBox,
  );

  final Dio _dio;
  final Box<SearchParametersModel> _searchHistoryBox;

  @override
  Future<SearchResult> searchDownloads(SearchParameters parameters) async {
    try {
      final model = SearchParametersModel.fromEntity(parameters);
      final response = await _dio.post<Map<String, dynamic>>(
        '/search',
        data: model.toJson(),
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final resultModel = SearchResultModel.fromJson(response.data!);
      return resultModel.toEntity();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search downloads: ${e.toString()}');
    }
  }

  @override
  Future<List<SearchParameters>> getSearchHistory() async {
    try {
      final models = _searchHistoryBox.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveSearchHistory(SearchParameters parameters) async {
    try {
      final model = SearchParametersModel.fromEntity(parameters);
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _searchHistoryBox.put(key, model);

      // Keep only last 50 searches
      if (_searchHistoryBox.length > 50) {
        final oldestKey = _searchHistoryBox.keys.first as String;
        await _searchHistoryBox.delete(oldestKey);
      }
    } catch (e) {
      throw Exception('Failed to save search history: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await _searchHistoryBox.clear();
    } catch (e) {
      throw Exception('Failed to clear search history: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSearchHistory(int index) async {
    try {
      if (index < 0 || index >= _searchHistoryBox.length) {
        throw Exception('Invalid index: $index');
      }

      final key = _searchHistoryBox.keys.elementAt(index);
      await _searchHistoryBox.delete(key);
    } catch (e) {
      throw Exception('Failed to delete search history: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSuggestedSearches(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final history = await getSearchHistory();
      final suggestions = <String>{};

      for (final params in history) {
        // Add query matches
        if (params.query != null &&
            params.query!.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(params.query!);
        }

        // Add extractor matches
        if (params.extractor != null) {
          for (final extractor in params.extractor!) {
            if (extractor.toLowerCase().contains(query.toLowerCase())) {
              suggestions.add(extractor);
            }
          }
        }

        // Add uploader matches
        if (params.uploader != null) {
          for (final uploader in params.uploader!) {
            if (uploader.toLowerCase().contains(query.toLowerCase())) {
              suggestions.add(uploader);
            }
          }
        }
      }

      return suggestions.take(10).toList();
    } catch (e) {
      return [];
    }
  }
}
