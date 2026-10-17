import 'package:flutter/material.dart';

import '../features/reports/presentation/report_view.dart';
import '../features/time_tracking/data/time_entry_repository.dart';
import '../features/time_tracking/presentation/time_tracking_view_model.dart';
import '../features/time_tracking/presentation/tracker_view.dart';

class ChronoTrackApp extends StatefulWidget {
  const ChronoTrackApp({super.key});

  @override
  State<ChronoTrackApp> createState() => _ChronoTrackAppState();
}

class _ChronoTrackAppState extends State<ChronoTrackApp> {
  late final TimeTrackingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TimeTrackingViewModel(InMemoryTimeEntryRepository());
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChronoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1426),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF5B4BEB),
          secondary: Color(0xFF42D6A3),
          surface: Color(0xFF171F33),
          error: Color(0xFFFF7B72),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF171F33),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF10182B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF303950)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF303950)),
          ),
        ),
      ),
      home: TrackerView(viewModel: _viewModel),
      onGenerateRoute: (settings) {
        if (settings.name == '/report') {
          return MaterialPageRoute<void>(
            builder: (_) => ReportView(viewModel: _viewModel),
          );
        }
        return null;
      },
    );
  }
}
