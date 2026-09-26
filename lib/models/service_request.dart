class ServiceRequest {
  final int id;
  final int clientId;
  final int providerId;
  final String service;
  final String city;
  final String description;
  final String status;
  final String createdAt;
  final String scheduledDate;
  final String scheduledTime;
  final String address;
  final double budget;
  final String? providerName;
  final String? providerPhone;
  final String? clientName;
  final String? clientPhone;
  final String? paymentStatus;
  final double? paymentAmount;

  ServiceRequest({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.service,
    required this.city,
    required this.description,
    required this.status,
    required this.createdAt,
    this.scheduledDate = '',
    this.scheduledTime = '',
    this.address = '',
    this.budget = 0,
    this.providerName,
    this.providerPhone,
    this.clientName,
    this.clientPhone,
    this.paymentStatus,
    this.paymentAmount,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      clientId: json['client_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      service: json['service'] ?? '',
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      address: json['address'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      providerName: json['provider_name'],
      providerPhone: json['provider_phone'],
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      paymentStatus: json['payment_status'],
      paymentAmount: json['payment_amount'] != null ? (json['payment_amount']).toDouble() : null,
    );
  }

  static const statusLabels = {
    'pending': 'En attente',
    'accepted': 'Acceptée',
    'in_progress': 'En cours',
    'completed': 'Terminée',
    'rejected': 'Refusée',
  };

  String get statusLabel => statusLabels[status] ?? status;
}
