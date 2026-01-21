class Bike {
  int? id;
  String name;
  String bikeNumber;
  String? qrCodePath;
  DateTime createdAt;

  Bike({
    this.id,
    required this.name,
    required this.bikeNumber,
    this.qrCodePath,
    required this.createdAt,
  });

  // Convert Bike to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bikeNumber': bikeNumber,
      'qrCodePath': qrCodePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Bike from JSON
  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      name: map['name'],
      bikeNumber: map['bikeNumber'],
      qrCodePath: map['qrCodePath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
