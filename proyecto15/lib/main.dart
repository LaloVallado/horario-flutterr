import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 1. Definimos los estados posibles
enum DownloadStatus { notDownloaded, fetchingDownload, downloading, downloaded }

void main() => runApp(const MaterialApp(home: ExampleDownloadButton()));

class ExampleDownloadButton extends StatefulWidget {
  const ExampleDownloadButton({super.key});

  @override
  State<ExampleDownloadButton> createState() => _ExampleDownloadButtonState();
}

class _ExampleDownloadButtonState extends State<ExampleDownloadButton> {
  DownloadStatus _status = DownloadStatus.notDownloaded;
  double _progress = 0.0;

  // Simulación de la descarga
  void _simulateDownload() async {
    setState(() => _status = DownloadStatus.fetchingDownload);
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _status = DownloadStatus.downloading);
    for (var i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _progress = i / 100);
    }

    setState(() => _status = DownloadStatus.downloaded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botón Estilo App Store')),
      body: Center(
        child: SizedBox(
          width: 100,
          child: DownloadButton(
            status: _status,
            downloadProgress: _progress,
            onDownload: _simulateDownload,
            onCancel: () => setState(() => _status = DownloadStatus.notDownloaded),
            onOpen: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Abriendo app!'))),
          ),
        ),
      ),
    );
  }
}

// 2. El Widget del Botón (Stateless por rendimiento)
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isDownloading => status == DownloadStatus.downloading;
  bool get _isFetching => status == DownloadStatus.fetchingDownload;
  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded: onDownload(); break;
      case DownloadStatus.fetchingDownload: break;
      case DownloadStatus.downloading: onCancel(); break;
      case DownloadStatus.downloaded: onOpen(); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          ButtonShapeWidget(
            transitionDuration: transitionDuration,
            isDownloaded: _isDownloaded,
            isDownloading: _isDownloading,
            isFetching: _isFetching,
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.ease,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isFetching) const CircularProgressIndicator(strokeWidth: 2),
                  if (_isDownloading) CircularProgressIndicator(value: downloadProgress, strokeWidth: 2),
                  if (_isDownloading) const Icon(Icons.stop, size: 14, color: CupertinoColors.activeBlue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
  });

  final bool isDownloading, isDownloaded, isFetching;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: isDownloading || isFetching ? const CircleBorder() : const StadiumBorder(),
        color: isDownloading || isFetching ? Colors.transparent : CupertinoColors.lightBackgroundGray,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedOpacity(
          duration: transitionDuration,
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: const TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}