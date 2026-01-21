class RentalRecord {
  int? id;
  int bikeId;
  String bikeName;
  String bikeNumber;
  DateTime rentalStartTime;
  DateTime? rentalEndTime;
  int? rentalDurationMinutes;
  String? proofImagePath;
  bool isActive;

  RentalRecord({
    this.id,
    required this.bikeId,
    required this.bikeName,
    required this.bikeNumber,
    required this.rentalStartTime,
    this.rentalEndTime,
    this.rentalDurationMinutes,
    this.proofImagePath,
    this.isActive = true,
  });

  // Convert RentalRecord to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bikeId': bikeId,
      'bikeName': bikeName,
      'bikeNumber': bikeNumber,
      'rentalStartTime': rentalStartTime.toIso8601String(),
      'rentalEndTime': rentalEndTime?.toIso8601String(),
      'rentalDurationMinutes': rentalDurationMinutes,
      'proofImagePath': proofImagePath,
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create RentalRecord from JSON
  factory RentalRecord.fromMap(Map<String, dynamic> map) {
    return RentalRecord(
      id: map['id'],
      bikeId: map['bikeId'],
      bikeName: map['bikeName'],
      bikeNumber: map['bikeNumber'],
      rentalStartTime: DateTime.parse(map['rentalStartTime']),
      rentalEndTime: map['rentalEndTime'] != null 
          ? DateTime.parse(map['rentalEndTime'])
          : null,
      rentalDurationMinutes: map['rentalDurationMinutes'],
      proofImagePath: map['proofImagePath'],
      isActive: map['isActive'] == 1,
    );
  }
}
