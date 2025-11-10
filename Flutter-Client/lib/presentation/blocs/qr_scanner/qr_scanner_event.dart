import 'package:equatable/equatable.dart';

/// Base class for QR Scanner events
abstract class QRScannerEvent extends Equatable {
  const QRScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initiate QR code scanning from camera
class ScanQRCodeEvent extends QRScannerEvent {
  const ScanQRCodeEvent();
}

/// Event to scan QR code from image file
class ScanFromImageEvent extends QRScannerEvent {
  const ScanFromImageEvent(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Event to validate a scanned URL
class ValidateUrlEvent extends QRScannerEvent {
  const ValidateUrlEvent(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

/// Event to load scan history
class LoadScanHistoryEvent extends QRScannerEvent {
  const LoadScanHistoryEvent();
}

/// Event to clear scan history
class ClearScanHistoryEvent extends QRScannerEvent {
  const ClearScanHistoryEvent();
}

/// Event to delete a specific scan result
class DeleteScanResultEvent extends QRScannerEvent {
  const DeleteScanResultEvent(this.scanId);

  final String scanId;

  @override
  List<Object?> get props => [scanId];
}

/// Event to request camera permission
class RequestCameraPermissionEvent extends QRScannerEvent {
  const RequestCameraPermissionEvent();
}

/// Event to check camera permission status
class CheckCameraPermissionEvent extends QRScannerEvent {
  const CheckCameraPermissionEvent();
}

/// Event to process a scanned QR code result
class ProcessQRResultEvent extends QRScannerEvent {
  const ProcessQRResultEvent(this.rawValue);

  final String rawValue;

  @override
  List<Object?> get props => [rawValue];
}

/// Event to reset the scanner state
class ResetScannerEvent extends QRScannerEvent {
  const ResetScannerEvent();
}
