import '../domain/time_entry.dart';

abstract interface class TimeEntryRepository {
  Future<List<TimeEntry>> getEntries();

  Future<void> addEntry(TimeEntry entry);
}

class InMemoryTimeEntryRepository implements TimeEntryRepository {
  final List<TimeEntry> _entries = [];

  @override
  Future<List<TimeEntry>> getEntries() async => List.unmodifiable(_entries);

  @override
  Future<void> addEntry(TimeEntry entry) async {
    _entries.insert(0, entry);
  }
}
