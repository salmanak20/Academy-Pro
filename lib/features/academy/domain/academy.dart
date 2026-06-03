enum AcademyStatus {
  active,
  disabled;

  static AcademyStatus fromString(String status) {
    return status == 'active' ? AcademyStatus.active : AcademyStatus.disabled;
  }

  String get toValue => this == AcademyStatus.active ? 'active' : 'disabled';
}

class Academy {
  final String id;
  final String name;
  final String address;
  final String contact;
  final AcademyStatus status;
  final String? principalId;
  final Map<String, dynamic> stats;

  const Academy({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    this.status = AcademyStatus.active,
    this.principalId,
    this.stats = const {},
  });

  Academy copyWith({
    String? id,
    String? name,
    String? address,
    String? contact,
    AcademyStatus? status,
    String? principalId,
    Map<String, dynamic>? stats,
  }) {
    return Academy(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      principalId: principalId ?? this.principalId,
      stats: stats ?? this.stats,
    );
  }

  factory Academy.fromMap(Map<String, dynamic> data, String id) {
    return Academy(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contact: data['contact'] ?? '',
      status: AcademyStatus.fromString(data['status'] ?? 'active'),
      principalId: data['principalId'],
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'academyId': id,
      'name': name,
      'address': address,
      'contact': contact,
      'status': status.toValue,
      'principalId': principalId,
      'stats': stats,
    };
  }
}
