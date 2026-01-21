import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bike.dart';
import '../models/rental_record.dart';

class BikeDatabase {
  static final BikeDatabase instance = BikeDatabase._init();
  static Database? _database;

  BikeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bike_rental.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Bikes table
    await db.execute('''
      CREATE TABLE bikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bikeNumber TEXT UNIQUE NOT NULL,
        qrCodePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create Rental Sessions table
    await db.execute('''
      CREATE TABLE rental_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bikeId INTEGER NOT NULL,
        bikeName TEXT NOT NULL,
        bikeNumber TEXT NOT NULL,
        rentalStartTime TEXT NOT NULL,
        rentalEndTime TEXT,
        rentalDurationMinutes INTEGER,
        proofImagePath TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bikeId) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Create Proof Images table for storing license photos
    await db.execute('''
      CREATE TABLE proof_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rentalSessionId INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY (rentalSessionId) REFERENCES rental_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_rental_bikeId ON rental_sessions (bikeId)');
    await db.execute(
        'CREATE INDEX idx_rental_isActive ON rental_sessions (isActive)');
    await db.execute(
        'CREATE INDEX idx_bike_bikeNumber ON bikes (bikeNumber)');
    await db.execute(
        'CREATE INDEX idx_proof_rentalSessionId ON proof_images (rentalSessionId)');
  }

  // ==================== BIKE OPERATIONS ====================

  /// Insert a new bike into the database
  Future<int> insertBike(Bike bike) async {
    final db = await database;
    try {
      return await db.insert(
        'bikes',
        bike.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting bike: $e');
    }
  }

  /// Get all bikes
  Future<List<Bike>> getAllBikes() async {
    final db = await database;
    final result = await db.query('bikes', orderBy: 'createdAt DESC');
    return result.map((map) => Bike.fromMap(map)).toList();
  }

  /// Get a bike by ID
  Future<Bike?> getBikeById(int id) async {
    final db = await database;
    final result = await db.query(
      'bikes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return Bike.fromMap(result.first);
  }

  /// Get a bike by bike number
  Future<Bike?> getBikeByNumber(String bikeNumber) async {
    final db = await database;
    final result = await db.query(
      'bikes',
      where: 'bikeNumber = ?',
      whereArgs: [bikeNumber],
    );

    if (result.isEmpty) return null;
    return Bike.fromMap(result.first);
  }

  /// Update bike information
  Future<int> updateBike(Bike bike) async {
    final db = await database;
    try {
      return await db.update(
        'bikes',
        bike.toMap(),
        where: 'id = ?',
        whereArgs: [bike.id],
      );
    } catch (e) {
      throw Exception('Error updating bike: $e');
    }
  }

  /// Delete a bike by ID
  Future<int> deleteBike(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'bikes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting bike: $e');
    }
  }

  // ==================== RENTAL OPERATIONS ====================

  /// Insert a new rental session
  Future<int> insertRentalSession(RentalRecord record) async {
    final db = await database;
    try {
      return await db.insert(
        'rental_sessions',
        {
          'bikeId': record.bikeId,
          'bikeName': record.bikeName,
          'bikeNumber': record.bikeNumber,
          'rentalStartTime': record.rentalStartTime.toIso8601String(),
          'rentalEndTime': record.rentalEndTime?.toIso8601String(),
          'rentalDurationMinutes': record.rentalDurationMinutes,
          'proofImagePath': record.proofImagePath,
          'isActive': 1,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error inserting rental session: $e');
    }
  }

  /// Get all rental sessions
  Future<List<RentalRecord>> getAllRentalSessions() async {
    final db = await database;
    final result = await db.query(
      'rental_sessions',
      orderBy: 'rentalStartTime DESC',
    );
    return result.map((map) => RentalRecord.fromMap(map)).toList();
  }

  /// Get rental session by ID
  Future<RentalRecord?> getRentalSessionById(int id) async {
    final db = await database;
    final result = await db.query(
      'rental_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return RentalRecord.fromMap(result.first);
  }

  /// Get active rental for a bike
  Future<RentalRecord?> getActiveRentalByBikeId(int bikeId) async {
    final db = await database;
    final result = await db.query(
      'rental_sessions',
      where: 'bikeId = ? AND isActive = 1',
      whereArgs: [bikeId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return RentalRecord.fromMap(result.first);
  }

  /// Get all active rentals
  Future<List<RentalRecord>> getActiveRentals() async {
    final db = await database;
    final result = await db.query(
      'rental_sessions',
      where: 'isActive = 1',
      orderBy: 'rentalStartTime DESC',
    );
    return result.map((map) => RentalRecord.fromMap(map)).toList();
  }

  /// Get rental history for a specific bike
  Future<List<RentalRecord>> getRentalHistoryByBikeId(int bikeId) async {
    final db = await database;
    final result = await db.query(
      'rental_sessions',
      where: 'bikeId = ?',
      whereArgs: [bikeId],
      orderBy: 'rentalStartTime DESC',
    );
    return result.map((map) => RentalRecord.fromMap(map)).toList();
  }

  /// Update rental session
  Future<int> updateRentalSession(RentalRecord record) async {
    final db = await database;
    try {
      return await db.update(
        'rental_sessions',
        {
          'bikeId': record.bikeId,
          'bikeName': record.bikeName,
          'bikeNumber': record.bikeNumber,
          'rentalStartTime': record.rentalStartTime.toIso8601String(),
          'rentalEndTime': record.rentalEndTime?.toIso8601String(),
          'rentalDurationMinutes': record.rentalDurationMinutes,
          'proofImagePath': record.proofImagePath,
          'isActive': record.isActive ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      throw Exception('Error updating rental session: $e');
    }
  }

  /// End a rental session
  Future<int> endRentalSession(int rentalId) async {
    final db = await database;
    final record = await getRentalSessionById(rentalId);
    
    if (record == null) {
      throw Exception('Rental session not found');
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(record.rentalStartTime).inMinutes;

    try {
      return await db.update(
        'rental_sessions',
        {
          'rentalEndTime': endTime.toIso8601String(),
          'rentalDurationMinutes': duration,
          'isActive': 0,
        },
        where: 'id = ?',
        whereArgs: [rentalId],
      );
    } catch (e) {
      throw Exception('Error ending rental session: $e');
    }
  }

  /// Delete a rental session
  Future<int> deleteRentalSession(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'rental_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting rental session: $e');
    }
  }

  // ==================== PROOF IMAGE OPERATIONS ====================

  /// Add proof image for a rental session
  Future<int> addProofImage(int rentalSessionId, String imagePath) async {
    final db = await database;
    try {
      return await db.insert(
        'proof_images',
        {
          'rentalSessionId': rentalSessionId,
          'imagePath': imagePath,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error adding proof image: $e');
    }
  }

  /// Get proof images for a rental session
  Future<List<String>> getProofImages(int rentalSessionId) async {
    final db = await database;
    final result = await db.query(
      'proof_images',
      where: 'rentalSessionId = ?',
      whereArgs: [rentalSessionId],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => map['imagePath'] as String).toList();
  }

  /// Delete proof image
  Future<int> deleteProofImage(int proofImageId) async {
    final db = await database;
    try {
      return await db.delete(
        'proof_images',
        where: 'id = ?',
        whereArgs: [proofImageId],
      );
    } catch (e) {
      throw Exception('Error deleting proof image: $e');
    }
  }

  /// Get rental statistics
  Future<Map<String, dynamic>> getRentalStatistics() async {
    final db = await database;
    
    final totalRentals = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rental_sessions'
    );
    
    final activeRentals = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rental_sessions WHERE isActive = 1'
    );
    
    final totalBikes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bikes'
    );

    return {
      'totalRentals': totalRentals.first['count'],
      'activeRentals': activeRentals.first['count'],
      'totalBikes': totalBikes.first['count'],
    };
  }

  // ==================== DATABASE OPERATIONS ====================

  /// Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  /// Delete entire database (for testing/reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bike_rental.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
