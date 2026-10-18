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

  testWidgets('starts at zero and counts only after starting the task', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(961, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
    try {
      await viewModel.load();
      await tester.pumpWidget(
        MaterialApp(home: TrackerView(viewModel: viewModel)),
      );

      expect(viewModel.sessionDuration, Duration.zero);
      expect(viewModel.totalWorked, Duration.zero);
      expect(viewModel.isRunning, isFalse);
      expect(find.text('Iniciar'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      expect(viewModel.sessionDuration, Duration.zero);

      final startButton = find.text('Iniciar');
      await tester.ensureVisible(startButton);
      await tester.pump();
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(viewModel.sessionDuration, const Duration(seconds: 3));
      expect(viewModel.isRunning, isTrue);

      final completeButton = find.text('Concluir e Iniciar Nova Tarefa');
      await tester.ensureVisible(completeButton);
      await tester.pump();
      final completedDuration = viewModel.sessionDuration;
      await tester.tap(completeButton);
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Refatoração da camada de API do Flutter Web'),
        findsOneWidget,
      );
      expect(viewModel.entries, hasLength(1));
      expect(viewModel.entries.first.duration, completedDuration);
      expect(viewModel.totalWorked, completedDuration);
      expect(viewModel.sessionDuration, Duration.zero);
      expect(viewModel.isRunning, isTrue);
      expect(viewModel.currentTask, 'Nova tarefa');

      await tester.pump(const Duration(seconds: 1));
      expect(viewModel.sessionDuration, const Duration(seconds: 1));
      expect(
        viewModel.totalWorked,
        completedDuration + const Duration(seconds: 1),
      );
    } finally {
      viewModel.dispose();
    }
  });

  testWidgets('discard stops and resets the current task timer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(961, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
    try {
      await viewModel.load();
      await tester.pumpWidget(
        MaterialApp(home: TrackerView(viewModel: viewModel)),
      );

      final startButton = find.text('Iniciar');
      await tester.ensureVisible(startButton);
      await tester.pump();
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(viewModel.sessionDuration, const Duration(seconds: 3));

      final discardButton = find.text('Descartar');
      await tester.ensureVisible(discardButton);
      await tester.pump();
      await tester.tap(discardButton);
      await tester.pump();

      expect(viewModel.isRunning, isFalse);
      expect(viewModel.sessionDuration, Duration.zero);
      expect(viewModel.currentTask, isEmpty);
      expect(viewModel.entries, isEmpty);

      await tester.pump(const Duration(seconds: 3));
      expect(viewModel.sessionDuration, Duration.zero);
    } finally {
      viewModel.dispose();
    }
  });
}
