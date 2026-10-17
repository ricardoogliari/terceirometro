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
      expect(viewModel.entries, hasLength(6));

      await viewModel.addManualEntry('Revisar documentação', 'Desenvolvimento');

      expect(viewModel.entries, hasLength(7));
      expect(viewModel.entries.first.title, 'Revisar documentação');
      expect(viewModel.buildSummary(), contains('Revisar documentação'));
    },
  );
}
