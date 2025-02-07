class DeliveryStats {
  final int inTransit;
  final int delivered;
  final int returned;
  final int pending;
  final double revenue;
  final List<ChartData> monthlyDeliveries;

  DeliveryStats({
    required this.inTransit,
    required this.delivered,
    required this.returned,
    required this.pending,
    required this.revenue,
    required this.monthlyDeliveries,
  });
}

class ChartData {
  final String month;
  final double deliveries;
  final double returns;

  ChartData({
    required this.month,
    required this.deliveries,
    required this.returns,
  });
}
