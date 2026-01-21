import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import '../helpers/db_helper.dart';
import '../models/bike.dart';

class AddBikeScreen extends StatefulWidget {
  const AddBikeScreen({Key? key}) : super(key: key);

  @override
  State<AddBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends State<AddBikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bikeNameController = TextEditingController();
  final _bikeNumberController = TextEditingController();
  bool _isLoading = false;

  Future<String?> _generateAndSaveQRCode(String bikeNumber) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final qrCodePath = '${directory.path}/qr_codes';
      final qrDir = Directory(qrCodePath);

      if (!await qrDir.exists()) {
        await qrDir.create(recursive: true);
      }

      // Generate QR code image
      final qrPainter = QrPainter(
        data: bikeNumber,
        version: QrVersions.auto,
        gapless: false,
      );

      final qrImage = await qrPainter.toImageData(300.0);
      final file = File('$qrCodePath/${bikeNumber}_qr.png');
      await file.writeAsBytes(qrImage!.buffer.asUint8List());

      // Save to gallery
      await GallerySaver.saveImage(file.path, albumName: 'Bike Rental QR Codes');

      return file.path;
    } catch (e) {
      debugPrint('Error generating QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QR code: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _addBike() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final qrCodePath =
          await _generateAndSaveQRCode(_bikeNumberController.text);

      final bike = Bike(
        name: _bikeNameController.text,
        bikeNumber: _bikeNumberController.text,
        qrCodePath: qrCodePath,
        createdAt: DateTime.now(),
      );

      await BikeDatabase.instance.insertBike(bike);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Bike added successfully! QR saved to gallery.'),
            backgroundColor: Color(0xFFFFD700),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait and then navigate back
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding bike: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bikeNameController.dispose();
    _bikeNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bike'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF000000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Illustration
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.two_wheeler,
                  size: 50,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Register Your Bike',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide bike details and generate QR code',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Bike Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: TextFormField(
                        controller: _bikeNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Bike Name',
                          labelStyle: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 14,
                          ),
                          hintText: 'e.g., Mountain Bike XL',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: const Icon(
                            Icons.directions_bike,
                            color: Color(0xFFFFD700),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter bike name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bike Number Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: TextFormField(
                        controller: _bikeNumberController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Bike Number (Unique ID)',
                          labelStyle: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 14,
                          ),
                          hintText: 'e.g., BIKE001',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xFFFFD700),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter bike number';
                          }
                          if (value!.length < 3) {
                            return 'Bike number must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Add Bike Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFD700),
                            const Color(0xFFFFD700).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _addBike,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black87,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _isLoading ? 'Adding Bike...' : 'Add Bike & Generate QR',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
