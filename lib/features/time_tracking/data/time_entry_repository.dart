import '../domain/time_entry.dart';

abstract interface class TimeEntryRepository {
  Future<List<TimeEntry>> getEntries();

  Future<void> addEntry(TimeEntry entry);
}

class InMemoryTimeEntryRepository implements TimeEntryRepository {
  final List<TimeEntry> _entries = [
    const TimeEntry(
      title: 'Alinhamento com cliente & escopo sprint 14',
      category: 'Reunião',
      project: 'Syncs',
      start: '09:00',
      end: '09:48',
      duration: Duration(minutes: 48, seconds: 12),
    ),
    const TimeEntry(
      title: 'Correção de bug de autenticação OAuth2 no Safari',
      category: 'Desenvolvimento',
      project: 'Core App',
      start: '10:00',
      end: '11:32',
      duration: Duration(hours: 1, minutes: 32, seconds: 40),
    ),
    const TimeEntry(
      title: 'Revisão de PR #104: Sistema de cache local Hive',
      category: 'Code Review',
      project: 'Core App',
      start: '11:45',
      end: '13:00',
      duration: Duration(hours: 1, minutes: 15, seconds: 8),
    ),
    const TimeEntry(
      title: 'Refatoração de State Management com Riverpod 2.0',
      category: 'Engenharia',
      project: 'Core App',
      start: '08:00',
      end: '09:15',
      duration: Duration(hours: 1, minutes: 15),
    ),
    const TimeEntry(
      title: 'Design Tokens M3 no Flutter e componentes Figma',
      category: 'Design System',
      project: 'Design System',
      start: '09:30',
      end: '11:15',
      duration: Duration(hours: 1, minutes: 45),
    ),
    const TimeEntry(
      title: 'Alinhamento Diário da Equipe (Standup)',
      category: 'Reuniões',
      project: 'Syncs',
      start: '11:15',
      end: '11:30',
      duration: Duration(minutes: 15),
    ),
  ];

  @override
  Future<List<TimeEntry>> getEntries() async => List.unmodifiable(_entries);

  @override
  Future<void> addEntry(TimeEntry entry) async {
    _entries.insert(0, entry);
  }
}
