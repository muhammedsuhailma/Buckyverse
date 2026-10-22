import 'dart:io';

import 'package:bucky_verse/models/update_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// ── Color constants matching BuckyVerse theme ─────────────────────────────────
const _kBg = Color(0xff0A0A1A);
const _kBorder = Color(0xffA855F7);
const _kPurple = Color(0xffA855F7);
const _kBlue = Color(0xff009DFF);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xffB0A8C8);

// ─────────────────────────────────────────────────────────────────────────────

/// Shows the BuckyVerse update dialog.
///
/// Displays the version, release notes, and a download+install flow.
/// Safe to call from any [BuildContext] — uses [showDialog] internally.
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .75),
    barrierDismissible: true,
    builder: (_) => _UpdateDialog(info: info),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.info});
  final UpdateInfo info;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

/// Manages the three visual states of the dialog:
///   [_Phase.idle]        — shows version, notes, Later/Update buttons
///   [_Phase.downloading] — shows progress bar
///   [_Phase.error]       — shows error message with Retry button
enum _Phase { idle, downloading, error }

class _UpdateDialogState extends State<_UpdateDialog> {
  _Phase _phase = _Phase.idle;

  double _progress = 0; // 0.0 → 1.0
  int _received = 0;    // bytes received
  int _total = 0;       // bytes total (0 = unknown)

  String _errorMessage = '';

  CancelToken? _cancelToken;

  // Singleton Dio reused for the download — separate from UpdateService's Dio
  // so progress callbacks and cancel tokens are isolated.
  final Dio _dio = Dio();

  @override
  void dispose() {
    // Cancel any in-flight download when the dialog is removed from the tree.
    _cancelToken?.cancel('Dialog disposed');
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double value = bytes.toDouble();
    while (value >= 1024 && i < units.length - 1) {
      value /= 1024;
      i++;
    }
    return '${value.toStringAsFixed(1)} ${units[i]}';
  }

  String get _progressLabel {
    final pct = (_progress * 100).toStringAsFixed(0);
    if (_total > 0) {
      return '$pct% · ${_formatBytes(_received)} / ${_formatBytes(_total)}';
    }
    return '$pct%';
  }

  // ── Download logic ────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    // Guard against duplicate taps while already downloading.
    if (_phase == _Phase.downloading) return;

    if (!mounted) return;
    setState(() {
      _phase = _Phase.downloading;
      _progress = 0;
      _received = 0;
      _total = 0;
      _errorMessage = '';
    });

    _cancelToken = CancelToken();

    try {
      // ── Resolve download path ─────────────────────────────────────────
      final dir = await getExternalStorageDirectory();
      final saveDir = dir ?? await getApplicationDocumentsDirectory();

      final filePath = '${saveDir.path}/${widget.info.apkFileName}';
      debugPrint('[UpdateDialog] Downloading to $filePath');

      // ── Download with progress ────────────────────────────────────────
      await _dio.download(
        widget.info.apkDownloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
            _progress = total > 0 ? received / total : 0;
          });
        },
      );

      if (!mounted) return;

      debugPrint('[UpdateDialog] Download complete → launching installer');

      // ── Launch installer ──────────────────────────────────────────────
      final result = await OpenFilex.open(filePath);
      debugPrint('[UpdateDialog] OpenFilex result: ${result.message}');

      // After handing off to the installer the dialog's job is done.
      // Close it so the user sees the system install sheet cleanly.
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('[UpdateDialog] Download cancelled.');
        return;
      }
      _setError(_friendlyDioError(e));
    } on FileSystemException catch (e) {
      _setError('Storage error: ${e.message}');
      debugPrint('[UpdateDialog] FileSystemException: $e');
    } catch (e) {
      _setError('Unexpected error. Please try again.');
      debugPrint('[UpdateDialog] Unexpected error: $e');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.error;
      _errorMessage = message;
    });
  }

  String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Check your internet and retry.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please reconnect and retry.';
      default:
        return 'Download failed (${e.response?.statusCode ?? 'unknown'}). Retry?';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Prevent the user from dismissing the dialog by tapping outside
    // while a download is in progress.
    return PopScope(
      canPop: _phase != _Phase.downloading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBorder.withValues(alpha: .6), width: 1),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withValues(alpha: .18),
                blurRadius: 40,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 6),
                _buildSubtitle(),
                const SizedBox(height: 20),
                _buildReleaseNotes(),
                const SizedBox(height: 24),
                _buildBottom(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_kPurple, _kBlue],
          ).createShader(bounds),
          child: Text(
            '🚀 Update Available',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Version ${widget.info.latestVersion} is available.',
      style: GoogleFonts.rajdhani(
        color: _kTextSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Release notes ─────────────────────────────────────────────────────────

  Widget _buildReleaseNotes() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: .07),
          width: 1,
        ),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Text(
            widget.info.releaseNotes,
            style: GoogleFonts.rajdhani(
              color: _kTextSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom section (buttons / progress / error) ───────────────────────────

  Widget _buildBottom() {
    return switch (_phase) {
      _Phase.idle       => _buildButtons(),
      _Phase.downloading => _buildProgress(),
      _Phase.error      => _buildError(),
    };
  }

  // ── Idle: Later + Update buttons ──────────────────────────────────────────

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(child: _buildLaterButton()),
        const SizedBox(width: 12),
        Expanded(child: _buildUpdateButton()),
      ],
    );
  }

  Widget _buildLaterButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: .18),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'Later',
          style: GoogleFonts.rajdhani(
            color: _kTextPrimary.withValues(alpha: .7),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: _startDownload,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_kPurple, _kBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withValues(alpha: .35),
              blurRadius: 18,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Update',
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Downloading: progress bar ─────────────────────────────────────────────

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloading…',
              style: GoogleFonts.rajdhani(
                color: _kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _progressLabel,
              style: GoogleFonts.rajdhani(
                color: _kPurple,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar container
        Container(
          height: 8,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final filledWidth = constraints.maxWidth * _progress;
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: filledWidth,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_kPurple, _kBlue],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Please keep the app open while downloading.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              color: Colors.white.withValues(alpha: .35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Error: message + Retry ────────────────────────────────────────────────

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: .25),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.rajdhani(
                    color: Colors.redAccent.shade100,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .15),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.rajdhani(
                      color: _kTextPrimary.withValues(alpha: .6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _startDownload,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [_kPurple, _kBlue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withValues(alpha: .28),
                        blurRadius: 14,
                        spreadRadius: -4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Retry',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
