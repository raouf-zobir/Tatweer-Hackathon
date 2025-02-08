class Disruption {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String status;
  final List<String> proposedSolutions;

  Disruption({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.proposedSolutions,
  });

  factory Disruption.fromJson(Map<String, dynamic> json) {
    return Disruption(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      proposedSolutions: List<String>.from(json['proposedSolutions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'proposedSolutions': proposedSolutions,
    };
  }
}
