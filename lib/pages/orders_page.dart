// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/date.dart';
import '../services/read_local.dart';
import '../widgets/order_search_filter_widget.dart';
import '../widgets/order_timeline_widget.dart';
import 'booking_view_full.dart';
import 'home_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    var max = size.height * 0.9;
    var dashWidth = 5;
    var dashSpace = 5;
    double startY = 0;
    while (startY < max) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> ordersFuture;
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load orders data based on email when widget initializes
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> orders = await fetchOrdersByEmail();

      setState(() {
        allOrders = orders;
        filteredOrders =
            List.from(orders); // Initialize filtered list with all orders
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading orders: $e");
      setState(() {
        allOrders = [];
        filteredOrders = [];
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByEmail() async {
    try {
      final DatabaseService databaseService = DatabaseService();

      String? email = await getEmailFromLocal();

      if (email == null) {
        return [];
      }

      return await databaseService.readDataByEmail("booking", email);
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  void _handleFilterChanged(List<Map<String, dynamic>> newFilteredOrders) {
    setState(() {
      filteredOrders = newFilteredOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.orders,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrders,
              tooltip: AppLocalizations.of(context)?.refresh ?? 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and filter widget
            if (!isLoading && allOrders.isNotEmpty)
              OrderSearchFilter(
                allOrders: allOrders,
                onFilterChanged: _handleFilterChanged,
              ),

            // Order list or loading/empty states
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : allOrders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noOrders,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)
                          ?.noOrdersDescription ??
                          'You haven\'t made any bookings yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : filteredOrders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)
                          ?.noMatchingOrders ??
                          'No matching orders',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)
                          ?.tryAdjustingFilters ??
                          'Try adjusting your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> order =
                    filteredOrders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order ID and status
                    LayoutBuilder(builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final isSmallScreen = availableWidth < 340;
                      final isVerySmallScreen = availableWidth < 260;

                      // Adjust font sizes based on available width
                      final titleFontSize = isSmallScreen ? 16.0 : 18.0;
                      final statusFontSize = isSmallScreen ? 11.0 : 12.0;

                      // Handle extremely narrow screens by using a column layout
                      if (isVerySmallScreen) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)?.order ?? 'Order'} #${_truncateOrderId(order['paymentId'], isSmallScreen ? 6 : 8)}',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['booking_status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                order['booking_status'] ?? 'Unknown',
                                style: TextStyle(
                                  color:
                                  _getStatusColor(order['booking_status']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: statusFontSize,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // For normal and small screens, use a row with adjusted spacing
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.order ?? 'Order'} #${_truncateOrderId(order['paymentId'], isSmallScreen ? 6 : 8)}',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10,
                                vertical: isSmallScreen ? 2 : 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['booking_status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 16 : 20),
                            ),
                            child: Text(
                              order['booking_status'] ?? 'Unknown',
                              style: TextStyle(
                                color: _getStatusColor(order['booking_status']),
                                fontWeight: FontWeight.bold,
                                fontSize: statusFontSize,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Route visualization
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.green, size: 16),
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.grey,
                              ),
                              if (order["stop1"].length > 0) ...[
                                const Icon(Icons.circle,
                                    color: Colors.blue, size: 16),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey,
                                ),
                              ],
                              if (order["stop2"].length > 0) ...[
                                const Icon(Icons.circle,
                                    color: Colors.blue, size: 16),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey,
                                ),
                              ],
                              if (order["stop3"].length > 0) ...[
                                const Icon(Icons.circle,
                                    color: Colors.blue, size: 16),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey,
                                ),
                              ],
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 20),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['pickupDescription'] ??
                                      'Pickup Location',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (order["stop1"].length > 0) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    order['stop1'] ?? 'Stop 1',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                                if (order["stop2"].length > 0) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    order['stop2'] ?? 'Stop 2',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                                if (order["stop3"].length > 0) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    order['stop3'] ?? 'Stop 3',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                Text(
                                  order['dropDescription'] ?? 'Drop Location',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Order details
                    _buildOrderDetailRow(
                        AppLocalizations.of(context)?.orderType ?? 'Order Type',
                        order['type'] ?? 'Standard'),
                    _buildOrderDetailRow(
                        AppLocalizations.of(context)?.vehicleType ??
                            'Vehicle Type',
                        order['vehicleSelected'] ?? 'Not specified'),
                    _buildOrderDetailRow(
                        AppLocalizations.of(context)?.estimatedTime ??
                            'Estimated Price',
                        '₹${order['estPrice'] ?? '0'}'),
                    _buildOrderDetailRow(
                        AppLocalizations.of(context)?.paymentMethod ??
                            'Payment Method',
                        order['paymentStatus'] == 'Unpaid' ? 'Cash' : 'Online'),

                    if (order['assignedAt'] == null) ...[
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.date ?? 'Date',
                          formatDate(order['date'])),
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.time ?? 'Time',
                          formatTime(order['date'])),
                    ] else ...[
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.date ?? 'Date',
                          formatDate(order['assignedAt'])),
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.time ?? 'Time',
                          formatTime(order['assignedAt'])),
                    ],

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Driver details (if assigned)
                    if (order['driverEmail'] != null) ...[
                      Text(
                        AppLocalizations.of(context)?.driverInformation ??
                            'Driver Information',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.driverName ??
                              'Driver Name',
                          order['driverName'] ?? 'Not assigned'),
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.vehicleNumber ??
                              'Vehicle Number',
                          order['driverVehicleNumber'] ?? 'N/A'),
                      _buildOrderDetailRow(
                          AppLocalizations.of(context)?.driverContact ??
                              'Driver Phone',
                          order['driverPhoneNum'] ?? 'N/A'),
                    ],

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Implement contact driver
                            final String phoneNumber =
                                order['driverPhoneNum'] ?? '';
                            final String url = 'tel:$phoneNumber';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.phone),
                          label: Text(
                              AppLocalizations.of(context)?.call ?? 'Contact'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to truncate order ID if needed
  String _truncateOrderId(dynamic orderId, int maxLength) {
    if (orderId == null) return '';
    final idString = orderId.toString();
    if (idString.length <= maxLength) return idString;
    return '${idString.substring(0, maxLength)}...';
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'trip ended':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'driver assigned':
        return Colors.blue;
      case 'Searching':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    var stop = 0;
    if (order['stop1'] != "") {
      stop = 1;
    }
    if (order['stop2'] != "") {
      stop = 2;
    }
    if (order['stop3'] != "") {
      stop = 3;
    }

    DateTime dateTime = (order['date'] as Timestamp).toDate();

    // Format the date
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

    // Color getColorForBookingStatus(String bookingStatus) {
    //   switch (bookingStatus.toLowerCase()) {
    //     case 'cancelled':
    //       return Colors.red;
    //     case 'finished':
    //     case 'trip ended':
    //       return const Color.fromARGB(255, 119, 193, 9);
    //     case 'driver assigned':
    //       return const Color.fromARGB(255, 119, 193, 9);
    //     default:
    //       return const Color.fromARGB(255, 227, 163, 15);
    //   }
    // }

    // Color statusColor = getColorForBookingStatus(order['booking_status']);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.only(top: 16, right: 10, left: 10),
      child: Column(
        children: [
          const SizedBox(height: 4),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Image.asset(
                'assets/vehicles/${order['vehicleSelected']}.png',
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            title: Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              order['vehicleSelected'],
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '₹ ${order['estPrice']}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 242, 242),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 14),
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 102, 214, 10),
                      radius: 4.0,
                    ),
                    const SizedBox(height: 3),
                    const SizedBox(height: 5),
                    CustomPaint(
                      painter: DottedLinePainter(),
                      child: const SizedBox(
                        height: 30,
                        width: 0.8,
                      ),
                    ),
                    if (order["stop1"] != "") const SizedBox(height: 4),
                    if (order["stop1"] != "")
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 3.0,
                      ),
                    const SizedBox(height: 3),
                    if (order["stop1"] != "")
                      CustomPaint(
                        painter: DottedLinePainter(),
                        child: const SizedBox(
                          height: 30,
                          width: 0.8,
                        ),
                      ),
                    if (order["stop2"] != "") const SizedBox(height: 4),
                    if (order["stop2"] != "")
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 3.0,
                      ),
                    const SizedBox(height: 3),
                    if (order["stop2"] != "")
                      CustomPaint(
                        painter: DottedLinePainter(),
                        child: const SizedBox(
                          height: 30,
                          width: 0.8,
                        ),
                      ),
                    if (order["stop3"] != "") const SizedBox(height: 4),
                    if (order["stop3"] != "")
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 3.0,
                      ),
                    const SizedBox(height: 3),
                    if (order["stop3"] != "")
                      CustomPaint(
                        painter: DottedLinePainter(),
                        child: const SizedBox(
                          height: 30,
                          width: 0.8,
                        ),
                      ),
                    const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 4.0,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ListTile(
                        horizontalTitleGap: 3,
                        minTileHeight: 45,
                        visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: const EdgeInsets.only(left: 4),
                        title: Text(
                          order['pickupDescription'],
                          style: const TextStyle(fontSize: 11),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(
                        height: 0.1,
                        color: Color.fromARGB(255, 216, 216, 216),
                      ),
                      if (order['stop1'] != "")
                        ListTile(
                          horizontalTitleGap: 3,
                          minTileHeight: 45,
                          visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -4),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            order['stop1'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Divider(
                        height: 0.1,
                        color: Color.fromARGB(255, 216, 216, 216),
                      ),
                      if (order['stop2'] != "")
                        ListTile(
                          horizontalTitleGap: 3,
                          minTileHeight: 45,
                          visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -4),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            order['stop2'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Divider(
                        height: 0.1,
                        color: Color.fromARGB(255, 216, 216, 216),
                      ),
                      if (order['stop3'] != "")
                        ListTile(
                          horizontalTitleGap: 3,
                          minTileHeight: 45,
                          visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -4),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            order['stop3'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Divider(
                        height: 0.1,
                        color: Color.fromARGB(255, 216, 216, 216),
                      ),
                      ListTile(
                        horizontalTitleGap: 3,
                        minTileHeight: 45,
                        visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          order['dropDescription'],
                          style: const TextStyle(fontSize: 11),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                // Track Order Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showOrderStatusDialog(context, order['booking_status'],
                          numberOfStops: stop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.trackOrder ?? 'Track',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // View Button (main action)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showOrderDetails(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.viewBooking ?? 'View',
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
