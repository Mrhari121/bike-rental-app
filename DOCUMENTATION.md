# Bike Rental Management App - Professional Edition

## Project Overview

A complete, professional-grade **Bike Rental Management System** built with Flutter and SQLite, featuring a striking **Yellow (#FFD700) and Black (#000000)** executive theme.

### ✅ Implementation Status: COMPLETE

---

## 🎯 Key Features Implemented

### 1. **Main Dashboard (Executive Style)**
- **Logo Display**: Centered bike icon (100px x 100px)
- **Live Statistics**: Total Bikes, Active Rentals, All-Time Rentals
- **Four Main Action Buttons**:
  - Add Bike
  - Rent Bikes (Multi-selection Cart)
  - Active Status (Live Monitoring)
  - Rental History

### 2. **Add Bike Screen**
- Bike Name & Number input fields
- **QR Code Generation** (using qr_flutter)
- **Auto-Save to Gallery** (using gallery_saver)
- Form validation
- Automatic navigation after successful addition

### 3. **Rent Process (4-Step Flow)**

#### Step 1: Scan & Cart Screen
- **QR Code Scanner** (using mobile_scanner)
- Multi-bike selection cart
- Cart summary with bike count
- Duplicate bike prevention
- Camera controls (torch, flip camera)
- Floating cart FAB

#### Step 2: Proof Upload Screen
- License/ID photo upload
- Image picker (camera or gallery)
- Real-time preview
- Bikes to rent display

#### Step 3: Finalize Rental Screen
- Rental summary confirmation
- Proof image preview
- Bike list verification
- Information box about rental activation

#### Step 4: Rental Session Creation
- Multi-bike batch rental start
- Proof image storage
- Active rental session creation
- Success confirmation dialog

### 4. **Status Screen (Live Monitoring)**
- **Active Rentals List** with live stopwatch
- Duration updates every second (HH:MM:SS format)
- Start time display
- One-click rental ending
- Confirmation dialog with duration details
- Real-time refresh capability

### 5. **History Screen (Detailed Records)**
- All bikes with rental history
- Expandable bike cards
- Per-bike rental history
- Status indicators (Active 🔴 / Completed 🟢)
- Rental details: Start, End, Duration
- **License Proof Gallery**: Multi-image display & full-screen viewer
- Error handling for missing images

---

## 🏗️ Architecture & Structure

### Database Schema (SQLite)

#### **bikes** Table
```sql
- id (PRIMARY KEY)
- name (TEXT)
- bikeNumber (UNIQUE TEXT)
- qrCodePath (TEXT)
- createdAt (TEXT)
```

#### **rental_sessions** Table
```sql
- id (PRIMARY KEY)
- bikeId (FOREIGN KEY → bikes.id)
- bikeName (TEXT)
- bikeNumber (TEXT)
- rentalStartTime (TEXT)
- rentalEndTime (TEXT)
- rentalDurationMinutes (INTEGER)
- proofImagePath (TEXT)
- isActive (INTEGER 0/1)
- createdAt (TEXT)
```

#### **proof_images** Table
```sql
- id (PRIMARY KEY)
- rentalSessionId (FOREIGN KEY → rental_sessions.id)
- imagePath (TEXT)
- uploadedAt (TEXT)
```

### Project Structure

```
lib/
├── main.dart                           # App entry & routing
├── helpers/
│   └── db_helper.dart                  # SQLite database operations
├── models/
│   ├── bike.dart                       # Bike model
│   └── rental_record.dart              # Rental session model
└── screens/
    ├── main_dashboard.dart             # Executive dashboard
    ├── add_bike_screen.dart            # Add bike + QR generation
    ├── scan_and_cart_screen.dart       # QR scanner + multi-select
    ├── proof_upload_screen.dart        # License upload
    ├── finalize_rental_screen.dart     # Rental confirmation
    ├── status_screen.dart              # Live rental monitoring
    └── history_screen.dart             # Rental history + proofs
```

---

## 🎨 UI/UX Theme

### Color Scheme
- **Primary**: Golden Yellow `#FFD700` (Premium, Executive)
- **Background**: Deep Black `#000000` (Professional, Modern)
- **Surfaces**: Dark Gray `Colors.grey[900]`
- **Accents**: Green (Success), Orange (Active), Red (Error)

### Typography
- **Fonts**: Clean, bold, professional Sans-serif
- **Sizes**: Hierarchical (32, 24, 20, 16, 14, 12px)
- **Letter Spacing**: Enhanced for premium feel
- **Font Weight**: Bold (600+) for headings

### Components
- **Cards**: Rounded corners (12-16px), gradient overlays
- **Buttons**: Gradient fill, shadow effects, ripple feedback
- **Icons**: Material Design 3 with consistent sizing
- **Spacing**: Consistent 8, 12, 16, 20, 24, 32px grid

---

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  sqflite: ^2.3.0              # SQLite database
  path: ^1.8.3                 # File path utilities
  qr_flutter: ^4.1.0           # QR code generation
  mobile_scanner: ^3.5.0       # QR code scanning
  path_provider: ^2.1.1        # App documents directory
  gallery_saver: ^2.3.2        # Save images to gallery
  image_picker: ^1.0.4         # Photo capture/upload
  cupertino_icons: ^1.0.6      # iOS icons
  intl: ^0.19.0                # Internationalization
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android/iOS SDK or Web platform

### Installation

1. **Clone/Download Project**
   ```bash
   cd d:\app
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on Device/Emulator**
   ```bash
   flutter run          # Auto-selects device
   flutter run -d android          # Android
   flutter run -d ios              # iOS
   flutter run -d chrome           # Web
   ```

### First-Time Setup
1. App initializes SQLite database automatically
2. Grant camera permissions (for QR scanning)
3. Grant storage permissions (for proof images)
4. Grant photo gallery access (for license uploads)

---

## 📋 Usage Guide

### Adding a Bike
1. Tap **"Add Bike"** button on dashboard
2. Enter Bike Name (e.g., "Mountain Bike XL")
3. Enter Unique Bike Number (e.g., "BIKE001")
4. Tap **"Add Bike & Generate QR"**
5. QR code auto-saves to gallery
6. Auto-returns to dashboard

### Starting a Rental
1. Tap **"Rent Bikes"** from dashboard
2. Position QR codes in front of camera
3. Scan multiple bikes (cart updates)
4. Tap **"Proceed"** when done scanning
5. Upload License/ID photo (camera or gallery)
6. Review rental summary
7. Tap **"Start Rental"** to activate
8. Rental now appears in Status screen

### Monitoring Active Rentals
1. Tap **"Active Status"** from dashboard
2. View all active rentals with live timers
3. Duration updates in real-time (HH:MM:SS)
4. Tap **"End Rental"** to stop any bike rental
5. Confirm end with duration display

### Viewing Rental History
1. Tap **"Rental History"** from dashboard
2. Tap any bike to expand rental records
3. View each rental session:
   - Start/end times
   - Total duration
   - Rental status (Active/Completed)
   - License proof photos
4. Tap proof photos for full-screen viewing

---

## 🔐 Database Operations

### BikeDatabase Methods

#### Bike Operations
```dart
insertBike(Bike bike)                  // Add new bike
getAllBikes()                          // Fetch all bikes
getBikeById(int id)                    // Get specific bike
getBikeByNumber(String number)         // Get by unique number
updateBike(Bike bike)                  // Update bike info
deleteBike(int id)                     // Remove bike
```

#### Rental Session Operations
```dart
insertRentalSession(RentalRecord)      // Create rental
getActiveRentals()                     // Get live rentals
getRentalHistoryByBikeId(int bikeId)   // Get bike history
getRentalSessionById(int id)           // Get specific rental
updateRentalSession(RentalRecord)      // Update rental
endRentalSession(int rentalId)         // Stop rental
```

#### Proof Image Operations
```dart
addProofImage(int rentalId, String path)    // Store proof
getProofImages(int rentalId)                // Retrieve proofs
deleteProofImage(int proofId)               // Remove proof
```

#### Statistics
```dart
getRentalStatistics()                  // Get dashboard stats
```

---

## 🎯 Technical Highlights

### State Management
- Provider Pattern ready (can be integrated)
- StatefulWidget with setState for simple state
- Future-based async operations

### Offline-First
- Complete SQLite local database
- Works without internet
- Sync-ready architecture

### Real-Time Features
- Live stopwatch timer (1-second updates)
- Live rental monitoring
- Instant cart updates

### Security & Validation
- Form validation on all inputs
- Duplicate bike prevention
- File path security
- Database transactions support

### UI/UX Excellence
- Material Design 3
- Responsive layouts
- Smooth animations
- Loading indicators
- Error handling with snackbars
- Empty state displays
- Gradient overlays
- Shadow effects

---

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (13.0+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (10+)
- ✅ **macOS** (10.14+)
- ✅ **Linux** (GTK 3.0+)

---

## 🐛 Known Limitations

- Rental pricing calculation (ready for implementation)
- Multi-language support (i18n ready)
- User authentication (can be integrated)
- Cloud sync (architecture supports it)
- Export to CSV/PDF (helper methods ready)

---

## 🔄 Future Enhancements

1. **Payment Integration** (Stripe/PayPal)
2. **User Authentication** (Firebase Auth)
3. **Cloud Sync** (Firebase Firestore)
4. **Analytics** (Firebase Analytics)
5. **Push Notifications** (Firebase Cloud Messaging)
6. **Multi-language** (Localization package)
7. **Advanced Filtering** (Rental history)
8. **Reports Generation** (PDF export)

---

## 📄 License

Professional Commercial Use

---

## 👨‍💻 Technical Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **Database**: SQLite 3
- **QR Code**: qr_flutter, mobile_scanner
- **Image Handling**: image_picker, gallery_saver
- **UI**: Material Design 3
- **Architecture**: MVC/Provider-ready

---

## 📞 Support

For issues, feature requests, or modifications, contact your development team.

---

**Project Status**: ✅ PRODUCTION READY
**Build Date**: January 2026
**Version**: 1.0.0

