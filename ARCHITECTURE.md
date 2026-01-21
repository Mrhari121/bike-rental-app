# Bike Rental Management App - Architecture Overview

## Application Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     MAIN SCREEN (TabBar)                         │
│  Dashboard | Rent | Status | History                             │
└─────────────────────────────────────────────────────────────────┘
       ↓              ↓         ↓          ↓
   ┌────────┐  ┌──────────┐ ┌────────┐ ┌───────────┐
   │Dashboard│  │Rent Flow │ │Status  │ │ History   │
   │  Tab 0  │  │ Tab 1    │ │ Tab 2  │ │ Tab 3     │
   └────────┘  └──────────┘ └────────┘ └───────────┘
       │            │           │           │
       ↓            ↓           ↓           ↓
   [Dashboard]  [Step 1]    [Live List]  [Bike List]
                 [Step 2]    [Timers]     [Details]
                 [Step 3]    [End BTN]    [Photos]
                 [Step 4]

```

## Screen Navigation Graph

```
                        ┌─ Add Bike ◄─────┐
                        │                  │
                        ↓                  │
    ┌──────────────────────────────────────┴─────────┐
    │           Main Dashboard (Tab: 0)                │
    │  ┌────────────────────────────────────────────┐ │
    │  │   Logo + Statistics (3 Cards)              │ │
    │  │   • Total Bikes                            │ │
    │  │   • Active Rentals                         │ │
    │  │   • Total Rentals                          │ │
    │  └────────────────────────────────────────────┘ │
    │  ┌────────────────────────────────────────────┐ │
    │  │   4 Action Buttons                         │ │
    │  │   ┌──────────────┐                         │ │
    │  │   │ Add Bike     │                         │ │
    │  │   └──────┬───────┘                         │ │
    │  │   ┌──────▼───────┐ ┌──────────┐            │ │
    │  │   │ Rent Bikes   │─┤ Scan     │            │ │
    │  │   └──────────────┘ │ Step 1   │            │ │
    │  │   ┌──────────────┐ ├──────────┤            │ │
    │  │   │ Status       │ │ Upload   │            │ │
    │  │   └──────────────┘ │ Step 2   │            │ │
    │  │   ┌──────────────┐ ├──────────┤            │ │
    │  │   │ History      │ │ Finalize │            │ │
    │  │   └──────────────┘ │ Step 3   │            │ │
    │  │                    └────┬─────┘            │ │
    │  │                         ↓                  │ │
    │  │                    [Create                 │ │
    │  │                     Rentals]               │ │
    │  └────────────────────────────────────────────┘ │
    └──────────────────────────────────────────────────┘
         │                    │                    │
    Tab 0│                Tab 1│                Tab 2│ 
         │                    │                    │
         └────────┬───────────┴────────┬──────────┘
                  │                    │
            Other Tabs            [Bottom Nav]
                  │                    │
              (Direct)            (Sync Update)
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   SQLite Database (Local)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ bikes (id, name, bikeNumber, qrCodePath, createdAt) │   │
│  │   ↓ ↓ ↓                                              │   │
│  │ rental_sessions (id, bikeId, bikeName, bikeNumber,  │   │
│  │   rentalStartTime, rentalEndTime, duration,         │   │
│  │   proofImagePath, isActive, createdAt)              │   │
│  │   ↓ ↓ ↓                                              │   │
│  │ proof_images (id, rentalSessionId, imagePath,       │   │
│  │   uploadedAt)                                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
     ↑                                              ↓
     │                                              │
     │                                              │
┌────┴──────────────────────────────────────────────┴──────┐
│            BikeDatabase Helper Class                      │
│  ┌────────────────────────────────────────────────────┐  │
│  │ BIKE OPERATIONS                                    │  │
│  │  • insertBike()      • getAllBikes()              │  │
│  │  • getBikeById()     • getBikeByNumber()          │  │
│  │  • updateBike()      • deleteBike()               │  │
│  │                                                    │  │
│  │ RENTAL OPERATIONS                                │  │
│  │  • insertRentalSession()   • getActiveRentals()  │  │
│  │  • endRentalSession()      • getRentalHistory()  │  │
│  │  • updateRentalSession()                         │  │
│  │                                                    │  │
│  │ PROOF OPERATIONS                                 │  │
│  │  • addProofImage()    • getProofImages()         │  │
│  │  • deleteProofImage()                            │  │
│  │                                                    │  │
│  │ ANALYTICS                                        │  │
│  │  • getRentalStatistics()                         │  │
│  └────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
     ↑                                              ↓
     │                                              │
     │ Read/Write                              Database I/O
     │                                              │
┌────┴──────────────────────────────────────────────┴────────┐
│                  UI Screens (Stateful)                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ • MainDashboard (Refresh stats)                     │  │
│  │ • AddBikeScreen (Save bike)                         │  │
│  │ • ScanAndCartScreen (Query bike by number)          │  │
│  │ • ProofUploadScreen (Store image)                   │  │
│  │ • FinalizeRentalScreen (Insert rental sessions)     │  │
│  │ • StatusScreen (Query active, update on end)        │  │
│  │ • HistoryScreen (Query history, fetch proofs)       │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────┐
│   Device Storage            │
│  ┌─────────────────────────┐│
│  │ QR Code Images          ││
│  │ License Photos          ││
│  │ (App Documents Dir)     ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ Device Gallery          ││
│  │ (Saved QR Codes)        ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

## UI Component Hierarchy

```
BikeRentalApp (MaterialApp)
├── Theme (Yellow #FFD700, Black #000000)
└── MainScreen (Scaffold with BottomNavigationBar)
    │
    ├── [Tab 0] MainDashboard
    │   ├── Logo Container
    │   │   └── Icon (Icons.two_wheeler)
    │   │
    │   ├── Statistics Section
    │   │   ├── Stat Card (Total Bikes)
    │   │   ├── Stat Card (Active Rentals)
    │   │   └── Stat Card (Total Rentals)
    │   │
    │   └── Action Buttons
    │       ├── Add Bike Button
    │       ├── Rent Bikes Button
    │       ├── Status Button
    │       └── History Button
    │
    ├── [Tab 1] ScanAndCartScreen
    │   ├── MobileScanner Widget
    │   ├── Header (Top Gradient)
    │   ├── Footer Controls
    │   │   ├── Cart Summary
    │   │   ├── Action Buttons
    │   │   └── Camera Controls
    │   ├── Processing Overlay
    │   └── End Drawer (Cart)
    │
    ├── [Tab 2] StatusScreen
    │   ├── App Bar
    │   └── Active Rentals List
    │       └── Rental Card (per rental)
    │           ├── Bike Info
    │           ├── Start Time
    │           ├── Live Duration (Stopwatch)
    │           └── End Rental Button
    │
    └── [Tab 3] HistoryScreen
        ├── App Bar
        └── Bikes List
            └── Bike History Card (expandable)
                ├── Bike Header
                └── Rental History List (per bike)
                    └── Rental Item
                        ├── Rental Details
                        ├── Proof Button
                        └── Proof Gallery (Modal)

Additional Screens (Navigated):

AddBikeScreen
├── App Bar
├── Form Section
│   ├── Bike Name Field
│   └── Bike Number Field
└── Add Button

ProofUploadScreen
├── App Bar
├── Image Preview Container
├── Action Buttons
│   ├── Take Photo Button
│   └── From Gallery Button
├── Bikes Info
└── Navigation Buttons

FinalizeRentalScreen
├── App Bar
├── Status Icon
├── Proof Image Preview
├── Rental Summary Card
├── Bikes Verification List
├── Info Box
└── Action Buttons
```

## State Management Flow

```
├─ MainScreen (Stateful)
│  └─ _selectedIndex (int) → Switches tabs
│
├─ AddBikeScreen (Stateful)
│  ├─ _formKey (GlobalKey<FormState>)
│  ├─ _bikeNameController (TextEditingController)
│  ├─ _bikeNumberController (TextEditingController)
│  ├─ _isLoading (bool)
│  └─ _addBike() → Async DB Operation
│
├─ ScanAndCartScreen (Stateful)
│  ├─ _selectedBikes (List<Bike>)
│  ├─ _scannedBikeNumbers (Set<String>)
│  ├─ _isProcessing (bool)
│  └─ _handleScannedCode() → Async DB Query
│
├─ ProofUploadScreen (Stateful)
│  ├─ _licenseImage (File?)
│  └─ _pickImage() → Image Picker
│
├─ FinalizeRentalScreen (Stateful)
│  ├─ _isProcessing (bool)
│  ├─ _rentalStarted (bool)
│  └─ _startRental() → Batch DB Insert
│
├─ StatusScreen (Stateful)
│  ├─ _activeRentals (List<RentalRecord>)
│  ├─ _durationMap (Map<int, String>)
│  ├─ _refreshTimer (Timer)
│  ├─ _loadActiveRentals() → Async DB Query
│  ├─ _updateDurations() → Timer Callback
│  └─ _endRental() → Async DB Update
│
└─ HistoryScreen (Stateful)
   ├─ _bikes (List<Bike>)
   ├─ _BikeHistoryCard (Stateful)
   │  ├─ _isExpanded (bool)
   │  ├─ _rentalHistory (List<RentalRecord>)
   │  └─ _loadRentalHistory() → Async DB Query
   │
   └─ _RentalHistoryItem (Stateful)
      ├─ _proofImages (List<String>)
      ├─ _loadingProofs (bool)
      ├─ _loadProofImages() → Async DB Query
      └─ _showFullImage() → Full-screen Dialog
```

## Async Operations Timeline

```
User Action → setState() → Build() → Display
     ↓
  Async DB Operation (Future)
     ↓
  Loading State (Spinner)
     ↓
  DB Response
     ↓
  setState()
     ↓
  Rebuild with Data
     ↓
  Display Result
```

## File Upload/Storage Flow

```
User Takes/Selects Photo
    ↓
ImagePicker (image_picker package)
    ↓
File Object Created
    ↓
Path Stored in ProofUploadScreen
    ↓
Pass to FinalizeRentalScreen
    ↓
Save Path to DB (proof_images table)
    ↓
File remains in Device Storage
    ↓
Query by rentalSessionId when needed
    ↓
Display in Gallery Grid
    ↓
Full-screen Viewer on Tap
```

## QR Code Lifecycle

```
Add Bike Screen
    ↓
Enter Bike Number
    ↓
Generate QR with qr_flutter
    ↓
Save QR PNG to App Documents Directory
    ↓
Save to Device Gallery with gallery_saver
    ↓
Store Path in Database (bikes.qrCodePath)
    ↓
    ├─ Scan with mobile_scanner
    │  ├─ Extract Bike Number (barcode.rawValue)
    │  ├─ Query Database (getBikeByNumber)
    │  └─ Add to Cart
    │
    └─ Display in History
       └─ Show in History Screen
```

## Theme System

```
main.dart → ThemeData
    ├─ Brightness: Dark
    ├─ Primary: #FFD700 (Golden Yellow)
    ├─ Background: #000000 (Deep Black)
    ├─ Surface: Colors.grey[900]
    │
    ├─ AppBarTheme
    │  ├─ backgroundColor: #FFD700
    │  ├─ foregroundColor: Colors.black87
    │  └─ elevation: 0
    │
    ├─ ElevatedButtonTheme
    │  ├─ backgroundColor: #FFD700
    │  ├─ foregroundColor: Colors.black87
    │  └─ borderRadius: 8px
    │
    ├─ TextTheme
    │  ├─ displayLarge: 32px, bold, yellow
    │  ├─ displayMedium: 24px, bold, yellow
    │  ├─ headlineSmall: 16px, bold, white
    │  └─ bodyMedium: 14px, white
    │
    └─ ColorScheme
       └─ Seed: #FFD700 (Generates complementary colors)
```

---

## Summary

This architecture provides:
✅ **Scalability** - Easy to add features
✅ **Maintainability** - Clear separation of concerns
✅ **Performance** - Optimized database queries
✅ **User Experience** - Smooth transitions and feedback
✅ **Professional Design** - Consistent theming throughout
