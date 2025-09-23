// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class OrderSearchFilter extends StatefulWidget {
  final List<Map<String, dynamic>> allOrders;
  final Function(List<Map<String, dynamic>>) onFilterChanged;
  
  const OrderSearchFilter({
    super.key, 
    required this.allOrders, 
    required this.onFilterChanged
  });

  @override
  _OrderSearchFilterState createState() => _OrderSearchFilterState();
}

class _OrderSearchFilterState extends State<OrderSearchFilter> {
  // Search & Filter state
  String _searchQuery = '';
  String? _selectedStatus;
  DateTimeRange? _dateRange;
  double? _minPrice;
  double? _maxPrice;
  bool _showFilters = false;

  // Status options for the filter
  final List<String> _statusOptions = [
    'Searching',
    'Driver Assigned',
    'Trip Started',
    'Reached Pickup Location',
    'Reached Drop Location',
    'Trip Ended',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // Find min/max price ranges from all orders
    if (widget.allOrders.isNotEmpty) {
      List<double> prices = widget.allOrders
          .map((order) => (order['estPrice'] is int) 
              ? (order['estPrice'] as int).toDouble() 
              : (order['estPrice'] as double? ?? 0.0))
          .toList();
      
      _minPrice = prices.reduce((curr, next) => curr < next ? curr : next);
      _maxPrice = prices.reduce((curr, next) => curr > next ? curr : next);
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filteredOrders = List.from(widget.allOrders);
    
    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        // Search in vehicle type
        final bool matchesVehicle = order['vehicleSelected']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        
        // Search in pickup and drop locations
        final bool matchesPickup = order['pickupDescription']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final bool matchesDrop = order['dropDescription']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        
        return matchesVehicle || matchesPickup || matchesDrop;
      }).toList();
    }
    
    // Apply status filter
    if (_selectedStatus != null) {
      filteredOrders = filteredOrders.where((order) {
        return order['booking_status']?.toString().toLowerCase() == _selectedStatus?.toLowerCase();
      }).toList();
    }
    
    // Apply date range filter
    if (_dateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        final DateTime orderDate = (order['date'] as Timestamp).toDate();
        return orderDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && 
               orderDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Apply price range filter
    if (_minPrice != null && _maxPrice != null) {
      filteredOrders = filteredOrders.where((order) {
        final double orderPrice = (order['estPrice'] is int) 
          ? (order['estPrice'] as int).toDouble() 
          : (order['estPrice'] as double? ?? 0.0);
        
        return orderPrice >= _minPrice! && orderPrice <= _maxPrice!;
      }).toList();
    }
    
    // Notify parent about the filtered results
    widget.onFilterChanged(filteredOrders);
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _dateRange = null;
      // Don't reset min/max price, just reset the range selector to the original range
    });
    widget.onFilterChanged(widget.allOrders);
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 255, 102, 0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _dateRange = newDateRange;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar with filter toggle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.searchOrders ?? 'Search orders...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: const Color.fromARGB(255, 255, 102, 0),
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Filters section (expandable)
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter header with reset button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.filters ?? 'Filters',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
                        onPressed: _resetFilters,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status filter
                  Text(
                    AppLocalizations.of(context)?.status ?? 'Status',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" option
                        FilterChip(
                          label: Text(AppLocalizations.of(context)?.all ?? 'All'),
                          selected: _selectedStatus == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = null;
                            });
                            _applyFilters();
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color.fromARGB(255, 255, 102, 0).withOpacity(0.2),
                          checkmarkColor: const Color.fromARGB(255, 255, 102, 0),
                        ),
                        const SizedBox(width: 8),
                        ..._statusOptions.map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(_getShortStatus(status)),
                              selected: _selectedStatus == status,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStatus = selected ? status : null;
                                });
                                _applyFilters();
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color.fromARGB(255, 255, 102, 0).withOpacity(0.2),
                              checkmarkColor: const Color.fromARGB(255, 255, 102, 0),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date range filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.dateRange ?? 'Date Range',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          _dateRange != null
                              ? '${DateFormat('MMM d, y').format(_dateRange!.start)} - ${DateFormat('MMM d, y').format(_dateRange!.end)}'
                              : AppLocalizations.of(context)?.selectedDates ?? 'Select Dates',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: _selectDateRange,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 16),
                  
                  // Price Range filter (if we have min and max prices)
                  if (_minPrice != null && _maxPrice != null && _minPrice! < _maxPrice!)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.priceRange ?? 'Price Range',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₹${_minPrice!.round()} - ₹${_maxPrice!.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 102, 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: RangeValues(_minPrice!, _maxPrice!),
                          min: widget.allOrders.isEmpty 
                            ? 0 
                            : widget.allOrders
                                .map((order) => (order['estPrice'] is int) 
                                   ? (order['estPrice'] as int).toDouble() 
                                   : (order['estPrice'] as double? ?? 0.0))
                                .reduce((curr, next) => curr < next ? curr : next),
                          max: widget.allOrders.isEmpty 
                            ? 5000 
                            : widget.allOrders
                                .map((order) => (order['estPrice'] is int) 
                                   ? (order['estPrice'] as int).toDouble() 
                                   : (order['estPrice'] as double? ?? 0.0))
                                .reduce((curr, next) => curr > next ? curr : next),
                          divisions: 20,
                          activeColor: const Color.fromARGB(255, 255, 102, 0),
                          inactiveColor: Colors.grey[300],
                          labels: RangeLabels(
                            '₹${_minPrice!.round()}',
                            '₹${_maxPrice!.round()}',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                            });
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
          // Active filter chips display (when filters are applied)
          if (!_showFilters && (_selectedStatus != null || _dateRange != null || _searchQuery.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text('"$_searchQuery"'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            _applyFilters();
                          },
                          backgroundColor: Colors.blue[50],
                        ),
                      ),
                      
                    if (_selectedStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(_getShortStatus(_selectedStatus!)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedStatus = null;
                            });
                            _applyFilters();
                          },
                          backgroundColor: const Color.fromARGB(255, 255, 102, 0).withOpacity(0.2),
                        ),
                      ),
                      
                    if (_dateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                            '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _dateRange = null;
                            });
                            _applyFilters();
                          },
                          backgroundColor: Colors.green[50],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
          const Divider(height: 1),
        ],
      ),
    );
  }
  
  // Helper method to get shorter status labels
  String _getShortStatus(String status) {
    switch (status.toLowerCase()) {
      case 'searching':
        return AppLocalizations.of(context)?.searching ?? 'Searching';
      case 'driver assigned':
        return AppLocalizations.of(context)?.assigned ?? 'Assigned';
      case 'reached pickup location':
        return AppLocalizations.of(context)?.atPickup ?? 'At Pickup';
      case 'reached drop location':
        return AppLocalizations.of(context)?.atDrop ?? 'At Drop';
      case 'trip started':
        return AppLocalizations.of(context)?.started ?? 'Started';
      case 'trip ended':
        return AppLocalizations.of(context)?.ended ?? 'Completed';
      case 'cancelled':
        return AppLocalizations.of(context)?.cancelled ?? 'Cancelled';
      default:
        return status;
    }
  }
}