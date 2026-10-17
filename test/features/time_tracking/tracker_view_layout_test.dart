import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terceirometro/features/time_tracking/data/time_entry_repository.dart';
import 'package:terceirometro/features/time_tracking/presentation/time_tracking_view_model.dart';
import 'package:terceirometro/features/time_tracking/presentation/tracker_view.dart';

void main() {
  testWidgets('renders the intermediate-width overview without layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(961, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
    try {
      await tester.pumpWidget(
        MaterialApp(home: TrackerView(viewModel: viewModel)),
      );

      expect(tester.takeException(), isNull);
    } finally {
      viewModel.dispose();
    }
  });
}
