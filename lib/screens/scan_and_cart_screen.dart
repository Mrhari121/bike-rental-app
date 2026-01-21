import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../helpers/db_helper.dart';
import '../models/bike.dart';
import 'proof_upload_screen.dart';

class ScanAndCartScreen extends StatefulWidget {
  const ScanAndCartScreen({Key? key}) : super(key: key);

  @override
  State<ScanAndCartScreen> createState() => _ScanAndCartScreenState();
}

class _ScanAndCartScreenState extends State<ScanAndCartScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  List<Bike> _selectedBikes = [];
  Set<String> _scannedBikeNumbers = {};

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if already scanned
      if (_scannedBikeNumbers.contains(code)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bike already added to cart'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Search for bike by QR code (bike number)
      final bike = await BikeDatabase.instance.getBikeByNumber(code);

      if (bike != null) {
        setState(() {
          _selectedBikes.add(bike);
          _scannedBikeNumbers.add(code);
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Added: ${bike.name}'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFFFFD700),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Bike not found'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removeBike(int index) {
    setState(() {
      final bike = _selectedBikes[index];
      _scannedBikeNumbers.remove(bike.bikeNumber);
      _selectedBikes.removeAt(index);
    });
  }

  void _proceedToProof() {
    if (_selectedBikes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan at least one bike')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProofUploadScreen(
          selectedBikes: _selectedBikes,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScannedCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Text(
                      'Scan QR Codes',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position QR codes to add bikes to cart',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Cart Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bikes in Cart',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _selectedBikes.length.toString(),
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          _selectedBikes.isNotEmpty
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _selectedBikes
                                          .take(3)
                                          .map(
                                            (bike) => Padding(
                                              padding:
                                                  const EdgeInsets.only(left: 8.0),
                                              child: Chip(
                                                label: Text(
                                                  bike.bikeNumber,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    const Color(0xFFFFD700),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                )
                              : const Expanded(
                                  child: Text(
                                    'No bikes selected',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _selectedBikes.isEmpty ? null : _proceedToProof,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Proceed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black87,
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await cameraController.toggleTorch();
                            },
                            icon: const Icon(Icons.flashlight_on),
                            label: const Text('Torch'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await cameraController.switchCamera();
                            },
                            icon: const Icon(Icons.flip_camera_ios),
                            label: const Text('Switch'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Floating Cart Button
      floatingActionButton: _selectedBikes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _proceedToProof,
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                'Cart (${_selectedBikes.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          : null,

      // Side Cart Panel (for larger screens)
      endDrawer: _selectedBikes.isNotEmpty
          ? Drawer(
              backgroundColor: const Color(0xFF000000),
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Shopping Cart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_selectedBikes.length} bikes',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedBikes.length,
                      itemBuilder: (context, index) {
                        final bike = _selectedBikes[index];
                        return ListTile(
                          leading: Icon(
                            Icons.two_wheeler,
                            color: const Color(0xFFFFD700),
                          ),
                          title: Text(
                            bike.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            bike.bikeNumber,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeBike(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
