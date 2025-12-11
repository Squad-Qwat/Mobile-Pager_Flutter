class AnalyticsModel {
  final int todayPagers;
  final int weeklyPagers;
  final int averageWaitMinutes;
  final double completionRate;

  AnalyticsModel({
    required this.todayPagers,
    required this.weeklyPagers,
    required this.averageWaitMinutes,
    required this.completionRate,
  });

  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      todayPagers: 0,
      weeklyPagers: 0,
      averageWaitMinutes: 0,
      completionRate: 0.0,
    );
  }
}
