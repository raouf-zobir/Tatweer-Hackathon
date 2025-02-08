import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardStats {
  final int inTransit;
  final int delivered;
  final int returned;
  final int pending;
  final double revenue;
  final List<ChartData> monthlyDeliveries;

  DashboardStats({
    required this.inTransit,
    required this.delivered,
    required this.returned,
    required this.pending,
    required this.revenue,
    required this.monthlyDeliveries,
  });

  factory DashboardStats.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DashboardStats(
      inTransit: data['inTransit'] ?? 0,
      delivered: data['delivered'] ?? 0,
      returned: data['returned'] ?? 0,
      pending: data['pending'] ?? 0,
      revenue: (data['revenue'] ?? 0).toDouble(),
      monthlyDeliveries: (data['monthlyDeliveries'] as List? ?? [])
          .map((item) => ChartData.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inTransit': inTransit,
      'delivered': delivered,
      'returned': returned,
      'pending': pending,
      'revenue': revenue,
      'monthlyDeliveries': monthlyDeliveries.map((item) => item.toMap()).toList(),
    };
  }
}

class ChartData {
  final String month;
  final int deliveries;
  final int returns;

  ChartData({
    required this.month,
    required this.deliveries,
    required this.returns,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      month: map['month'] ?? '',
      deliveries: map['deliveries'] ?? 0,
      returns: map['returns'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'deliveries': deliveries,
      'returns': returns,
    };
  }
}
