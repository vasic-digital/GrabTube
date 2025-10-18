import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';

class AddDownloadDialog extends StatefulWidget {
  const AddDownloadDialog({super.key});

  @override
  State<AddDownloadDialog> createState() => _AddDownloadDialogState();
}

class _AddDownloadDialogState extends State<AddDownloadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String _selectedQuality = AppConstants.defaultQuality;
  String _selectedFormat = AppConstants.defaultFormat;
  bool _autoStart = AppConstants.defaultAutoStart;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline),
          SizedBox(width: 12),
          Text('Add Download'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL input
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'https://youtube.com/watch?v=...',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
                autofocus: true,
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // Quality selector
              Text(
                'Quality',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedQuality,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.high_quality),
                ),
                items: AppConstants.qualityOptions.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Format selector
              Text(
                'Format',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFormat,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.video_file),
                ),
                items: AppConstants.formatOptions.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Auto-start switch
              SwitchListTile(
                title: const Text('Auto-start download'),
                subtitle: const Text('Start downloading immediately'),
                value: _autoStart,
                onChanged: (value) {
                  setState(() {
                    _autoStart = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _handleSubmit,
          icon: const Icon(Icons.download),
          label: const Text('Add'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<DownloadBloc>().add(
            AddDownload(
              url: _urlController.text.trim(),
              quality: _selectedQuality,
              format: _selectedFormat,
              autoStart: _autoStart,
            ),
          );
      Navigator.of(context).pop();
    }
  }
}
