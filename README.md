# Bike Rental Management App

A Flutter application for managing bike rentals with QR code generation, offline database support, and rental tracking.

## Features

- **Add Bike Screen**: Input bike name and number, generate QR codes, save to gallery
- **Scan Screen**: Scan QR codes to fetch bike details
- **Rent Process**: Capture customer info and start rental timer
- **History Screen**: View all past rental records
- **Offline Database**: SQLite database for all data persistence

## Project Structure

```
lib/
├── main.dart              # App entry point
├── helpers/
│   └── db_helper.dart     # SQLite database operations
├── models/
│   ├── bike.dart          # Bike model
│   └── rental_record.dart # Rental record model
├── screens/               # UI screens (to be implemented)
└── widgets/               # Reusable widgets (to be implemented)
```

## Required Packages

- **sqflite**: SQLite database for Flutter
- **path**: Path provider utilities
- **qr_flutter**: QR code generation
- **mobile_scanner**: QR code scanning
- **path_provider**: App file paths
- **gallery_saver**: Save images to gallery
- **intl**: Internationalization and date formatting

## Database Schema

### Bikes Table
- `id` (INTEGER PRIMARY KEY)
- `name` (TEXT)
- `bikeNumber` (TEXT UNIQUE)
- `qrCodePath` (TEXT)
- `createdAt` (TEXT)

### Rental Records Table
- `id` (INTEGER PRIMARY KEY)
- `bikeId` (INTEGER FOREIGN KEY)
- `bikeName` (TEXT)
- `bikeNumber` (TEXT)
- `customerName` (TEXT)
- `customerPhone` (TEXT)
- `rentalStartTime` (TEXT)
- `rentalEndTime` (TEXT)
- `rentalDurationMinutes` (INTEGER)
- `rentalCost` (REAL)
- `isActive` (INTEGER)

## Database Helper Methods

### Bike Operations
- `insertBike(Bike)` - Add new bike
- `getAllBikes()` - Get all bikes
- `getBikeById(int)` - Get bike by ID
- `getBikeByNumber(String)` - Get bike by number
- `updateBike(Bike)` - Update bike info
- `deleteBike(int)` - Delete bike

### Rental Operations
- `insertRentalRecord(RentalRecord)` - Start rental
- `getAllRentalRecords()` - Get all rentals
- `getActiveRentals()` - Get active rentals
- `getRentalHistoryByBikeId(int)` - Get bike rental history
- `endRental(int)` - End rental and calculate duration
- `updateRentalRecord(RentalRecord)` - Update rental
- `getRentalStatistics()` - Get statistics

## Setup Instructions

1. **Clone/Navigate to project directory**
   ```bash
   cd app
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Implementation Roadmap

- [ ] **Add Bike Screen** - Form input with QR generation
- [ ] **Scan Screen** - Mobile scanner integration
- [ ] **Rent Process Screen** - Customer info + rental timer
- [ ] **History Screen** - Display rental records
- [ ] **State Management** - Add Provider or Riverpod
- [ ] **Error Handling** - User feedback and error states
- [ ] **Testing** - Unit and widget tests

## Notes

- All data is stored locally using SQLite
- QR codes are generated using the bike number
- Rental duration is automatically calculated when rental ends
- The app requires camera permissions for QR scanning
- Gallery save requires storage permissions
