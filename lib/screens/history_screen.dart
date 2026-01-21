import 'package:flutter/material.dart';
import 'dart:io';
import '../helpers/db_helper.dart';
import '../models/bike.dart';
import '../models/rental_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Bike> _bikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    try {
      final bikes = await BikeDatabase.instance.getAllBikes();
      setState(() {
        _bikes = bikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bikes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental History'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBikes,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF000000),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700),
                  ),
                ),
              )
            : _bikes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Bikes Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _bikes.length,
                    itemBuilder: (context, index) {
                      final bike = _bikes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _BikeHistoryCard(bike: bike),
                      );
                    },
                  ),
      ),
    );
  }
}

class _BikeHistoryCard extends StatefulWidget {
  final Bike bike;

  const _BikeHistoryCard({
    Key? key,
    required this.bike,
  }) : super(key: key);

  @override
  State<_BikeHistoryCard> createState() => _BikeHistoryCardState();
}

class _BikeHistoryCardState extends State<_BikeHistoryCard> {
  bool _isExpanded = false;
  List<RentalRecord> _rentalHistory = [];
  bool _isLoadingHistory = false;

  Future<void> _loadRentalHistory() async {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      return;
    }

    setState(() {
      _isExpanded = true;
      _isLoadingHistory = true;
    });

    try {
      final rentals = await BikeDatabase.instance
          .getRentalHistoryByBikeId(widget.bike.id ?? 0);
      setState(() {
        _rentalHistory = rentals;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: _loadRentalHistory,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.two_wheeler,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bike.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'ID: ${widget.bike.bikeNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFFFD700),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Divider(color: Color(0xFFFFD700), height: 1),
                  ),
                  if (_isLoadingHistory)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    )
                  else if (_rentalHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No rental history',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rentalHistory.length,
                      itemBuilder: (context, index) {
                        final rental = _rentalHistory[index];
                        return _RentalHistoryItem(rental: rental);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RentalHistoryItem extends StatefulWidget {
  final RentalRecord rental;

  const _RentalHistoryItem({
    Key? key,
    required this.rental,
  }) : super(key: key);

  @override
  State<_RentalHistoryItem> createState() => _RentalHistoryItemState();
}

class _RentalHistoryItemState extends State<_RentalHistoryItem> {
  List<String> _proofImages = [];
  bool _loadingProofs = false;

  Future<void> _loadProofImages() async {
    if (_loadingProofs) return;
    
    setState(() {
      _loadingProofs = true;
    });

    try {
      final images = await BikeDatabase.instance
          .getProofImages(widget.rental.id ?? 0);
      setState(() {
        _proofImages = images;
        _loadingProofs = false;
      });
    } catch (e) {
      setState(() {
        _loadingProofs = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading proofs: $e')),
        );
      }
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return 'Ongoing';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = widget.rental.rentalStartTime.toString().split('.')[0];
    final endTime = widget.rental.rentalEndTime?.toString().split('.')[0] ?? 'Ongoing';
    final duration = _formatDuration(widget.rental.rentalDurationMinutes);
    final status = widget.rental.isActive ? '🔴 Active' : '🟢 Completed';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.rental.isActive
                ? Colors.orange.withOpacity(0.5)
                : Colors.green.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rental #${widget.rental.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.rental.isActive
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            startTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'End',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            endTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadProofImages,
                      icon: const Icon(Icons.image),
                      label: const Text('View Proof'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loadingProofs)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFFD700).withOpacity(0.7),
                  ),
                ),
              )
            else if (_proofImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _proofImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = _proofImages[index];
                    return GestureDetector(
                      onTap: () => _showFullImage(imagePath),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: File(imagePath).existsSync()
                              ? Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
