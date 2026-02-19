import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

/// Service that records call audio to local files.
class AudioRecordingService {
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  AudioRecorder? _recorder;
  String? _currentFilePath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;

  /// Start recording audio for a call.
  /// Returns the file path where recording will be saved.
  Future<String?> startRecording(String phoneNumber) async {
    try {
      _recorder ??= AudioRecorder();

      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        debugPrint('AudioRecordingService: Microphone permission not granted');
        return null;
      }

      final dir = await _getRecordingsDirectory();
      final sanitized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${sanitized}_$timestamp.m4a';
      _currentFilePath = p.join(dir.path, fileName);

      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentFilePath!,
      );

      _isRecording = true;
      debugPrint('AudioRecordingService: Recording started → $_currentFilePath');
      return _currentFilePath;
    } catch (e) {
      debugPrint('AudioRecordingService: Failed to start recording: $e');
      _isRecording = false;
      _currentFilePath = null;
      return null;
    }
  }

  /// Stop recording and return the file path.
  /// Returns null if no recording was in progress or file is invalid.
  Future<String?> stopRecording() async {
    if (!_isRecording || _recorder == null) {
      debugPrint('AudioRecordingService: No recording in progress');
      return null;
    }

    try {
      final path = await _recorder!.stop();
      _isRecording = false;

      if (path == null || path.isEmpty) {
        debugPrint('AudioRecordingService: Recorder returned no path');
        _currentFilePath = null;
        return null;
      }

      // Validate the file exists and has content
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('AudioRecordingService: Recording file does not exist');
        _currentFilePath = null;
        return null;
      }

      final fileSize = await file.length();
      if (fileSize < 100) {
        debugPrint('AudioRecordingService: Recording file too small ($fileSize bytes), deleting');
        await file.delete();
        _currentFilePath = null;
        return null;
      }

      debugPrint('AudioRecordingService: Recording stopped → $path ($fileSize bytes)');
      final result = _currentFilePath;
      _currentFilePath = null;
      return result;
    } catch (e) {
      debugPrint('AudioRecordingService: Failed to stop recording: $e');
      _isRecording = false;
      _currentFilePath = null;
      return null;
    }
  }

  /// Delete a recording file.
  static Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('AudioRecordingService: Deleted recording $path');
      }
    } catch (e) {
      debugPrint('AudioRecordingService: Failed to delete recording: $e');
    }
  }

  /// Remove recordings older than 30 days.
  static Future<void> cleanupOldRecordings() async {
    try {
      final dir = await _getRecordingsDirectoryStatic();
      if (!await dir.exists()) return;

      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final entries = dir.listSync();
      int deleted = 0;

      for (final entry in entries) {
        if (entry is File) {
          final stat = await entry.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entry.delete();
            deleted++;
          }
        }
      }

      if (deleted > 0) {
        debugPrint('AudioRecordingService: Cleaned up $deleted old recordings');
      }
    } catch (e) {
      debugPrint('AudioRecordingService: Cleanup error: $e');
    }
  }

  Future<Directory> _getRecordingsDirectory() async {
    return _getRecordingsDirectoryStatic();
  }

  static Future<Directory> _getRecordingsDirectoryStatic() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(appDir.path, 'recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir;
  }

  void dispose() {
    _recorder?.dispose();
    _recorder = null;
    _isRecording = false;
    _currentFilePath = null;
  }
}
