class TimeEntry {
  const TimeEntry({
    required this.title,
    required this.category,
    required this.project,
    required this.start,
    required this.end,
    required this.duration,
  });

  final String title;
  final String category;
  final String project;
  final String start;
  final String end;
  final Duration duration;
}