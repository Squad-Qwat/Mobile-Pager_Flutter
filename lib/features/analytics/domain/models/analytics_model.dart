class AnalyticsModel {
  final int todayPagers;
  final int weeklyPagers;
  final int averageWaitSeconds; // Changed to seconds for better precision
  final double completionRate;

  AnalyticsModel({
    required this.todayPagers,
    required this.weeklyPagers,
    required this.averageWaitSeconds,
    required this.completionRate,
  });

  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      todayPagers: 0,
      weeklyPagers: 0,
      averageWaitSeconds: 0,
      completionRate: 0.0,
    );
  }

  /// Get formatted wait time string (e.g., "45 detik", "2 menit 30 detik")
  String get formattedWaitTime {
    if (averageWaitSeconds < 60) {
      return '$averageWaitSeconds dtk';
    } else {
      final minutes = averageWaitSeconds ~/ 60;
      final seconds = averageWaitSeconds % 60;
      if (seconds == 0) {
        return '$minutes Mnt';
      }
      return '$minutes:${seconds.toString().padLeft(2, '0')} Mnt';
    }
  }
}
