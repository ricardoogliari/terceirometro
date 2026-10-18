import 'package:flutter_test/flutter_test.dart';
import 'package:terceirometro/features/time_tracking/data/time_entry_repository.dart';
import 'package:terceirometro/features/time_tracking/presentation/time_tracking_view_model.dart';

void main() {
  test(
    'loads entries and updates the summary when a manual entry is added',
    () async {
      final viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
      addTearDown(viewModel.dispose);

      await viewModel.load();
      expect(viewModel.entries, isEmpty);
      expect(viewModel.totalWorked, Duration.zero);

      await viewModel.addManualEntry('Revisar documentação', 'Desenvolvimento');

      expect(viewModel.entries, hasLength(1));
      expect(viewModel.entries.first.title, 'Revisar documentação');
      expect(viewModel.registeredTime, const Duration(minutes: 30));
      expect(viewModel.buildSummary(), contains('Revisar documentação'));
    },
  );

  test('starts with zero counters and a paused timer', () async {
    final viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
    addTearDown(viewModel.dispose);

    await viewModel.load();
    expect(viewModel.sessionDuration, Duration.zero);
    expect(viewModel.totalWorked, Duration.zero);
    expect(viewModel.registeredTime, Duration.zero);
    expect(viewModel.completion, 0);
    expect(viewModel.isRunning, isFalse);

    viewModel.toggleTimer();
    expect(viewModel.isRunning, isTrue);
    expect(viewModel.sessionDuration, Duration.zero);
  });
}
