import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/qr_scan_result.dart';
import '../../../domain/usecases/scan_qr_code_usecase.dart';
import '../../../domain/usecases/qr_scanner/scan_qr_from_image_usecase.dart';
import '../../../domain/usecases/qr_scanner/validate_qr_url_usecase.dart';
import '../../../domain/repositories/qr_scanner_repository.dart';
import 'qr_scanner_event.dart';
import 'qr_scanner_state.dart';

/// BLoC for managing QR scanner functionality
@injectable
class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  QRScannerBloc(
    this._scanQRCodeUseCase,
    this._scanQRFromImageUseCase,
    this._validateQRUrlUseCase,
    this._repository,
  ) : super(const QRScannerInitial()) {
    on<ScanQRCodeEvent>(_onScanQRCode);
    on<ScanFromImageEvent>(_onScanFromImage);
    on<ValidateUrlEvent>(_onValidateUrl);
    on<LoadScanHistoryEvent>(_onLoadScanHistory);
    on<ClearScanHistoryEvent>(_onClearScanHistory);
    on<DeleteScanResultEvent>(_onDeleteScanResult);
    on<RequestCameraPermissionEvent>(_onRequestCameraPermission);
    on<CheckCameraPermissionEvent>(_onCheckCameraPermission);
    on<ProcessQRResultEvent>(_onProcessQRResult);
    on<ResetScannerEvent>(_onResetScanner);
  }

  final ScanQRCodeUseCase _scanQRCodeUseCase;
  final ScanQRFromImageUseCase _scanQRFromImageUseCase;
  final ValidateQRUrlUseCase _validateQRUrlUseCase;
  final QRScannerRepository _repository;

  Future<void> _onScanQRCode(
    ScanQRCodeEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerScanning());

    final result = await _scanQRCodeUseCase();

    result.fold(
      (error) => emit(QRScannerFailure(error)),
      (scanResult) => emit(QRScannerSuccess(scanResult)),
    );
  }

  Future<void> _onScanFromImage(
    ScanFromImageEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerScanning());

    final result = await _scanQRFromImageUseCase(event.imagePath);

    result.fold(
      (error) => emit(QRScannerFailure(error)),
      (scanResult) => emit(QRScannerSuccess(scanResult)),
    );
  }

  Future<void> _onValidateUrl(
    ValidateUrlEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    final result = await _validateQRUrlUseCase(event.url);

    result.fold(
      (error) => emit(QRScannerUrlValidated(url: event.url, isValid: false)),
      (isValid) => emit(QRScannerUrlValidated(url: event.url, isValid: isValid)),
    );
  }

  Future<void> _onLoadScanHistory(
    LoadScanHistoryEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerHistoryLoading());

    try {
      final history = await _repository.getScanHistory();
      emit(QRScannerHistoryLoaded(history));
    } catch (e) {
      emit(QRScannerFailure('Failed to load scan history: ${e.toString()}'));
    }
  }

  Future<void> _onClearScanHistory(
    ClearScanHistoryEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _repository.clearScanHistory();
      emit(const QRScannerHistoryLoaded([]));
    } catch (e) {
      emit(QRScannerFailure('Failed to clear scan history: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteScanResult(
    DeleteScanResultEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _repository.deleteScanResult(event.scanId);

      // Reload history after deletion
      final history = await _repository.getScanHistory();
      emit(QRScannerHistoryLoaded(history));
    } catch (e) {
      emit(QRScannerFailure('Failed to delete scan result: ${e.toString()}'));
    }
  }

  Future<void> _onRequestCameraPermission(
    RequestCameraPermissionEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerPermissionChecking());

    final result = await _repository.requestCameraPermission();

    result.fold(
      (error) => emit(QRScannerPermissionStatus(
        hasPermission: false,
        errorMessage: error,
      )),
      (_) => emit(const QRScannerPermissionStatus(hasPermission: true)),
    );
  }

  Future<void> _onCheckCameraPermission(
    CheckCameraPermissionEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerPermissionChecking());

    try {
      final hasPermission = await _repository.hasCameraPermission();
      emit(QRScannerPermissionStatus(hasPermission: hasPermission));
    } catch (e) {
      emit(QRScannerPermissionStatus(
        hasPermission: false,
        errorMessage: 'Failed to check permission: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProcessQRResult(
    ProcessQRResultEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerProcessing());

    try {
      // Validate and extract URL
      final isValid = await _repository.validateUrl(event.rawValue);
      final extractedUrl = await _repository.extractUrl(event.rawValue);

      // Create scan result
      final scanResult = QRScanResult(
        rawValue: event.rawValue,
        extractedUrl: extractedUrl,
        scannedAt: DateTime.now(),
        isValidUrl: isValid,
      );

      // Save to history
      await _repository.saveScanResult(scanResult);

      emit(QRScannerResultProcessed(
        result: scanResult,
        isValidUrl: isValid,
        extractedUrl: extractedUrl,
      ));
    } catch (e) {
      emit(QRScannerFailure('Failed to process QR result: ${e.toString()}'));
    }
  }

  Future<void> _onResetScanner(
    ResetScannerEvent event,
    Emitter<QRScannerState> emit,
  ) async {
    emit(const QRScannerInitial());
  }
}
