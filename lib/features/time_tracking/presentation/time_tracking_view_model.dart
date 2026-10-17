import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/time_entry_repository.dart';
import '../domain/time_entry.dart';

class TimeTrackingViewModel extends ChangeNotifier {
  TimeTrackingViewModel(this._repository) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        _sessionDuration += const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  final TimeEntryRepository _repository;
  late final Timer _ticker;
  List<TimeEntry> _entries = const [];
  Duration _sessionDuration = const Duration(hours: 1, minutes: 42, seconds: 19);
  bool _isRunning = true;
  bool _automaticLockEnabled = true;
  bool _isLoading = true;
  String _currentTask = 'Refatoração da camada de API do Flutter Web';
  String _selectedCategory = 'Desenvolvimento';

  List<TimeEntry> get entries => _entries;
  Duration get sessionDuration => _sessionDuration;
  bool get isRunning => _isRunning;
  bool get automaticLockEnabled => _automaticLockEnabled;
  bool get isLoading => _isLoading;
  String get currentTask => _currentTask;
  String get selectedCategory => _selectedCategory;
  Duration get totalWorked =>
      const Duration(hours: 5, minutes: 18) +
      (_sessionDuration - const Duration(hours: 1, minutes: 42, seconds: 19));
  Duration get dailyLimit => const Duration(hours: 8);
  Duration get remainingTime => dailyLimit - totalWorked;
  double get completion => (totalWorked.inSeconds / dailyLimit.inSeconds)
      .clamp(0.0, 1.0);
  Duration get registeredTime => const Duration(hours: 3, minutes: 36);

  List<TimeEntry> get recentEntries => entries.take(3).toList(growable: false);
  List<TimeEntry> get chronologicalEntries => List<TimeEntry>.of(entries)
    ..sort((first, second) => first.start.compareTo(second.start));

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _repository.getEntries();
    _isLoading = false;
    notifyListeners();
  }

  void toggleTimer() {
    _isRunning = !_isRunning;
    notifyListeners();
  }

  void toggleAutomaticLock() {
    _automaticLockEnabled = !_automaticLockEnabled;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateCurrentTask(String value) {
    _currentTask = value;
    notifyListeners();
  }

  Future<void> addManualEntry(String title, String category) async {
    final now = TimeOfDayLabel.now();
    final entry = TimeEntry(
      title: title,
      category: category,
      project: category == 'Reunião' ? 'Syncs' : 'Core App',
      start: now,
      end: now,
      duration: const Duration(minutes: 30),
    );
    await _repository.addEntry(entry);
    _entries = await _repository.getEntries();
    notifyListeners();
  }

  String buildSummary() {
    final lines = chronologicalEntries.map((entry) {
      final minutes = entry.duration.inMinutes;
      final hours = minutes ~/ 60;
      final remainder = minutes % 60;
      return '- ${entry.start} - ${entry.end} | ${entry.title} '
          '(${hours.toString().padLeft(2, '0')}h '
          '${remainder.toString().padLeft(2, '0')}m) [${entry.category}]';
    });
    return [
      'Data: 24/10/2024 | Total Trabalhado: ${_formatDuration(totalWorked)}',
      ...lines,
    ].join('\n');
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }
}

class TimeOfDayLabel {
  static String now() {
    final time = DateTime.now();
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}