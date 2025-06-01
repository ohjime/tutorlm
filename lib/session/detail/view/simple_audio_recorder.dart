import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';

/// Simple in-memory audio recorder using the `record` package.
/// Stores the last recorded audio as bytes in memory.
class SimpleAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  List<int>? _lastRecording;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  List<int>? get lastRecording => _lastRecording;

  Future<void> start() async {
    if (await _recorder.hasPermission()) {
      final tempDir = Directory.systemTemp;
      final filePath =
          '${tempDir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: filePath);
      _isRecording = true;
    }
  }

  Future<void> stop() async {
    if (!_isRecording) return;
    final path = await _recorder.stop();
    _isRecording = false;
    if (path != null) {
      final file = File(path);
      _lastRecording = await file.readAsBytes();
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  /// Allows the user to save the last recorded audio to a file of their choice.
  /// Returns true if the file was saved successfully, false otherwise.
  Future<bool> saveToFile() async {
    if (_lastRecording == null) return false;

    try {
      // Let the user choose where to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Audio Recording',
        fileName: 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
        type: FileType.custom,
        allowedExtensions: ['m4a', 'mp3', 'wav'],
        bytes: _lastRecording != null
            ? Uint8List.fromList(_lastRecording!)
            : null,
      );

      if (outputPath != null) {
        // On desktop platforms, we still need to write the file manually
        final file = File(outputPath);
        await file.writeAsBytes(_lastRecording!);
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving audio file: $e');
      return false;
    }
  }
}
