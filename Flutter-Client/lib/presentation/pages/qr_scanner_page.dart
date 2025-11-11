import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../blocs/qr_scanner/qr_scanner_bloc.dart';
import '../blocs/qr_scanner/qr_scanner_event.dart';
import '../blocs/qr_scanner/qr_scanner_state.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';
import '../widgets/add_download_dialog.dart';

/// QR Scanner page for scanning video URLs
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController? _scannerController;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Only check camera permission on mobile platforms
    if (!kIsWeb) {
      context.read<QRScannerBloc>().add(const CheckCameraPermissionEvent());
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        // Process the scanned QR code
        context.read<QRScannerBloc>().add(ProcessQRResultEvent(rawValue));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.read<QRScannerBloc>().add(const LoadScanHistoryEvent());
              _showHistoryDialog(context);
            },
            tooltip: 'Scan History',
          ),
        ],
      ),
      body: BlocConsumer<QRScannerBloc, QRScannerState>(
        listener: (context, state) {
          if (state is QRScannerResultProcessed) {
            _showResultDialog(context, state);
          } else if (state is QRScannerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QRScannerPermissionStatus && !state.hasPermission) {
            _showPermissionDialog(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is QRScannerPermissionStatus && !state.hasPermission) {
            return _buildPermissionView(context);
          }

          if (state is QRScannerScanning || state is QRScannerProcessing) {
            return _buildScannerView(context);
          }

          if (state is QRScannerHistoryLoaded) {
            return _buildHistoryView(context, state);
          }

          return _buildInitialView(context);
        },
      ),
      floatingActionButton: kIsWeb
          ? null // Hide FAB on web since we have inline input
          : FloatingActionButton.extended(
              onPressed: () {
                _scannerController = MobileScannerController();
                context.read<QRScannerBloc>().add(const ScanQRCodeEvent());
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
            ),
    );
  }

  Widget _buildPermissionView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please grant camera permission to scan QR codes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<QRScannerBloc>()
                    .add(const RequestCameraPermissionEvent());
              },
              icon: const Icon(Icons.check),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    _scannerController ??= MobileScannerController();

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Scan a QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Point your camera at a QR code containing a video URL',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'toggle_flash',
                onPressed: () => _scannerController?.toggleTorch(),
                child: const Icon(Icons.flash_on),
              ),
              FloatingActionButton(
                heroTag: 'switch_camera',
                onPressed: () => _scannerController?.switchCamera(),
                child: const Icon(Icons.cameraswitch),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView(BuildContext context, QRScannerHistoryLoaded state) {
    if (state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scan History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your scanned QR codes will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final scan = state.history[index];
        return ListTile(
          leading: Icon(
            scan.isValidUrl ? Icons.check_circle : Icons.error,
            color: scan.isValidUrl ? Colors.green : Colors.red,
          ),
          title: Text(scan.extractedUrl ?? scan.rawValue),
          subtitle: Text(
            'Scanned: ${scan.scannedAt.toString()}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final scanId = scan.scannedAt.millisecondsSinceEpoch.toString();
              context
                  .read<QRScannerBloc>()
                  .add(DeleteScanResultEvent(scanId));
            },
          ),
        );
      },
    );
  }

  Widget _buildInitialView(BuildContext context) {
    if (kIsWeb) {
      // Web-friendly manual URL input
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link,
                  size: 120,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Video URL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Paste a video URL from YouTube or other supported sites',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Video URL',
                    hintText: 'https://www.youtube.com/watch?v=...',
                    prefixIcon: const Icon(Icons.link),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (url) => _processManualUrl(url),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _processManualUrl(_urlController.text),
                    icon: const Icon(Icons.download),
                    label: const Text('Add Download'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile QR scanner view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to Scan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the button below to start scanning QR codes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _processManualUrl(String url) {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a URL'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate and show add download dialog
    context.read<QRScannerBloc>().add(ValidateUrlEvent(url.trim()));

    // Show the add download dialog directly
    showDialog(
      context: context,
      builder: (context) => AddDownloadDialog(initialUrl: url.trim()),
    );
  }

  void _showResultDialog(BuildContext context, QRScannerResultProcessed state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(state.isValidUrl ? 'Valid URL Found' : 'Invalid URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.extractedUrl != null) ...[
              const Text(
                'URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(state.extractedUrl!),
              const SizedBox(height: 16),
            ],
            const Text(
              'Raw Value:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.result.rawValue),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (state.isValidUrl && state.extractedUrl != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Show add download dialog with the extracted URL
                showDialog(
                  context: context,
                  builder: (dialogContext) => AddDownloadDialog(
                    initialUrl: state.extractedUrl!,
                  ),
                );
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan History'),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<QRScannerBloc, QRScannerState>(
            builder: (context, state) {
              if (state is QRScannerHistoryLoaded) {
                return _buildHistoryView(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<QRScannerBloc>().add(const ClearScanHistoryEvent());
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: Text(
          errorMessage ?? 'Camera permission is required to scan QR codes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<QRScannerBloc>()
                  .add(const RequestCameraPermissionEvent());
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}
