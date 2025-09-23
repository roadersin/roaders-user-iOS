// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';


class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final bool showAsDialog;
  final int numberOfStops; // Number of intermediate stops (0-3)

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.showAsDialog = false,
    this.numberOfStops = 0, // Default to 0 stops
  });

  // Map the backend status string to a numeric position in the timeline
  int _getStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'searching':
        return 0;
      case 'driver assigned':
        return 1;
      case 'reached pickup location':
        return 2;
      case 'trip started':
        return 3;
      case 'reached stop 1':
        return numberOfStops >= 1 ? 4 : -1;
      case 'reached stop 2':
        return numberOfStops >= 2 ? 5 : -1;
      case 'reached stop 3':
        return numberOfStops >= 3 ? 6 : -1;
      case 'reached drop location':
        return 4 + numberOfStops;
      case 'trip ended':
      case 'finished':
        return 5 + numberOfStops;
      case 'cancelled':
        return -1; // Special case for cancelled orders
      default:
        return 0; // Default to the first status if unknown
    }
  }

  List<String> _getStatusLabels(BuildContext context) {
    List<String> labels = [
      AppLocalizations.of(context)?.searching ?? 'Searching',
      AppLocalizations.of(context)?.driverAssigned ?? 'Driver Assigned',
      AppLocalizations.of(context)?.reachedPickupLocation ?? 'Reached Pickup',
      AppLocalizations.of(context)?.tripStarted ?? 'Trip Started',
    ];

    // Add stop labels based on numberOfStops
    for (int i = 1; i <= numberOfStops; i++) {
      switch (i) {
        case 1:
          labels.add(
              AppLocalizations.of(context)?.reachedStop1 ?? 'Reached Stop 1');
          break;
        case 2:
          labels.add(
              AppLocalizations.of(context)?.reachedStop2 ?? 'Reached Stop 2');
          break;
        case 3:
          labels.add(
              AppLocalizations.of(context)?.reachedStop3 ?? 'Reached Stop 3');
          break;
      }
    }

    // Add final labels
    labels.addAll([
      AppLocalizations.of(context)?.reachedDropLocation ?? 'Reached Drop',
      AppLocalizations.of(context)?.tripEnded ?? 'Trip Ended',
    ]);

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getStatusIndex(currentStatus);
    final List<String> statusLabels = _getStatusLabels(context);

    // If it's cancelled, show a different UI
    if (currentIndex == -1) {
      return _buildCancelledTimeline(context);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: showAsDialog ? 24.0 : 16.0,
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAsDialog) ...[
              Center(
                child: Text(
                  AppLocalizations.of(context)?.orderStatus ?? 'Order Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Custom Timeline Implementation
            ...List.generate(statusLabels.length, (index) {
              return _buildTimelineItem(
                context,
                index,
                statusLabels[index],
                currentIndex,
                isLast: index == statusLabels.length - 1,
              );
            }),
            if (showAsDialog) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)?.close ?? 'Close',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, int index, String label, int currentIndex,
      {required bool isLast}) {
    final bool isCompleted = index < currentIndex;
    final bool isCurrent = index == currentIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator column
        SizedBox(
          width: 40,
          child: Column(
            children: [
              // Dot indicator
              Container(
                width: isCurrent ? 24.0 : 20.0,
                height: isCurrent ? 24.0 : 20.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? const Color.fromARGB(255, 255, 102, 0)
                      : Colors.grey.shade300,
                ),
                child: isCompleted || isCurrent
                    ? Icon(
                  isCurrent ? _getCurrentIcon(index) : Icons.check,
                  color: Colors.white,
                  size: isCurrent ? 14.0 : 12.0,
                )
                    : null,
              ),
              // Connector line
              if (!isLast)
                Container(
                  width: 2.0,
                  height: 32.0, // reduced height for tighter spacing
                  margin: const EdgeInsets.only(top: 2.0),
                  color: isCompleted
                      ? const Color.fromARGB(255, 255, 102, 0)
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isCurrent
                        ? Colors.black
                        : isCompleted
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.currentStatus ??
                        'Current Status',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCurrentIcon(int index) {
    // Return different icons based on the status type
    if (index == 0) return Icons.search; // Searching
    if (index == 1) return Icons.person; // Driver Assigned
    if (index == 2) return Icons.location_on; // Reached Pickup
    if (index == 3) return Icons.directions_car; // Trip Started
    if (index >= 4 && index < 4 + numberOfStops) return Icons.stop; // Stops
    if (index == 4 + numberOfStops) return Icons.location_on; // Drop Location
    return Icons.check_circle; // Trip Ended
  }

  Widget _buildCancelledTimeline(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: showAsDialog ? 24.0 : 16.0,
        horizontal: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAsDialog) ...[
            Center(
              child: Text(
                AppLocalizations.of(context)?.orderStatus ?? 'Order Status',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.red.shade700,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.orderCancelled ??
                      'Order Cancelled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.orderCancelledMsg ??
                      'This order has been cancelled and is no longer active.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
          if (showAsDialog) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)?.close ?? 'Close',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Updated functions to include numberOfStops parameter
void showOrderStatusTimeline(BuildContext context, String currentStatus,
    {int numberOfStops = 0}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: OrderStatusTimeline(
        currentStatus: currentStatus,
        showAsDialog: true,
        numberOfStops: numberOfStops,
      ),
    ),
  );
}

void showOrderStatusDialog(BuildContext context, String currentStatus,
    {int numberOfStops = 0}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: OrderStatusTimeline(
          currentStatus: currentStatus,
          showAsDialog: true,
          numberOfStops: numberOfStops,
        ),
      );
    },
  );
}
