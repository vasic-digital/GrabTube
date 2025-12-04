import 'package:equatable/equatable.dart';
import '../../../domain/entities/qr_scan_result.dart';

/// Base class for QR Scanner states
abstract class QRScannerState extends Equatable {
  const QRScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class QRScannerInitial extends QRScannerState {
  const QRScannerInitial();
}

/// State when scanning is in progress
class QRScannerScanning extends QRScannerState {
  const QRScannerScanning();
}

/// State when a QR code has been successfully scanned
class QRScannerSuccess extends QRScannerState {
  const QRScannerSuccess(this.result);

  final QRScanResult result;

  @override
  List<Object?> get props => [result];
}

/// State when scanning fails
class QRScannerFailure extends QRScannerState {
  const QRScannerFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// State when scanning is loading
class QRScannerLoading extends QRScannerState {
  const QRScannerLoading();
}

/// State when camera permission is required
class QRScannerPermissionRequired extends QRScannerState {
  const QRScannerPermissionRequired();
}

/// State when scan history is loaded
class QRScannerHistoryLoaded extends QRScannerState {
  const QRScannerHistoryLoaded(this.history);

  final List<QRScanResult> history;

  @override
  List<Object?> get props => [history];
}

/// State when scan history is being loaded
class QRScannerHistoryLoading extends QRScannerState {
  const QRScannerHistoryLoading();
}

/// State when URL validation is complete
class QRScannerUrlValidated extends QRScannerState {
  const QRScannerUrlValidated({
    required this.url,
    required this.isValid,
  });

  final String url;
  final bool isValid;

  @override
  List<Object?> get props => [url, isValid];
}

/// State when checking or requesting camera permission
class QRScannerPermissionChecking extends QRScannerState {
  const QRScannerPermissionChecking();
}

/// State when camera permission status is known
class QRScannerPermissionStatus extends QRScannerState {
  const QRScannerPermissionStatus({
    required this.hasPermission,
    this.errorMessage,
  });

  final bool hasPermission;
  final String? errorMessage;

  @override
  List<Object?> get props => [hasPermission, errorMessage];
}

/// State when processing a scanned result
class QRScannerProcessing extends QRScannerState {
  const QRScannerProcessing();
}

/// State when a scanned result has been processed
class QRScannerResultProcessed extends QRScannerState {
  const QRScannerResultProcessed({
    required this.result,
    required this.isValidUrl,
    this.extractedUrl,
  });

  final QRScanResult result;
  final bool isValidUrl;
  final String? extractedUrl;

  @override
  List<Object?> get props => [result, isValidUrl, extractedUrl];
}
