// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../classes/transaction.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _filterType;
  SummaryPeriod _summaryPeriod = SummaryPeriod.week;

  // Group by option
  String _groupBy = 'day'; // Options: 'none', 'day', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<String?> getEmailFromLocal() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'email');
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final String? email = await getEmailFromLocal();
      if (email != null) {
        final transactions = await getTransactions(email);
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      setState(() => _isLoading = false);
    }
  }

  // Calculate summary statistics
  Map<String, double> _calculateSummary() {
    if (_transactions.isEmpty) return {};

    final now = DateTime.now();
    DateTime startDate;

    // Determine start date based on selected period
    switch (_summaryPeriod) {
      case SummaryPeriod.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case SummaryPeriod.week:
        // Go back to start of the week (assuming week starts on Monday)
        final weekday = now.weekday;
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        break;
      case SummaryPeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case SummaryPeriod.year:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    // Filter transactions within the period
    final List<TransactionModel> periodTransactions = _transactions
        .where((t) =>
            t.timestamp.isAfter(startDate) ||
            t.timestamp.isAtSameMomentAs(startDate))
        .toList();

    // Calculate totals by type
    double totalTopup = 0;
    double totalPayment = 0;

    for (final txn in periodTransactions) {
      if (txn.status != 'success') continue;

      switch (txn.type) {
        case 'topup':
          totalTopup += txn.amount;
          break;
        case 'payment':
        case 'booking':
          totalPayment += txn.amount;
          break;
      }
    }

    return {
      'totalTopup': totalTopup,
      'totalPayment': totalPayment,
      'netBalance': totalTopup - totalPayment,
    };
  }

  // Group transactions by date
  Map<String, List<TransactionModel>> _groupTransactionsByDate() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final txn in _filteredTransactions) {
      String key;

      switch (_groupBy) {
        case 'day':
          key = DateFormat('yyyy-MM-dd').format(txn.timestamp);
          break;
        case 'week':
          // First day of the week for this date
          final firstDayOfWeek =
              txn.timestamp.subtract(Duration(days: txn.timestamp.weekday - 1));
          key = 'Week of ${DateFormat('MMM dd').format(firstDayOfWeek)}';
          break;
        case 'month':
          key = DateFormat('MMMM yyyy').format(txn.timestamp);
          break;
        default: // No grouping
          key = 'All Transactions';
          break;
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(txn);
    }

    return grouped;
  }

  // Search functionality
  void _searchTransactions(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    final queryLower = query.toLowerCase();
    final results = _transactions.where((txn) {
      return txn.type.toLowerCase().contains(queryLower) ||
          txn.status.toLowerCase().contains(queryLower) ||
          txn.amount.toString().contains(queryLower) ||
          (txn.errorMessage?.toLowerCase().contains(queryLower) ?? false) ||
          (txn.paymentMethod?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = true;
    });
  }

  // Get filtered transactions
  List<TransactionModel> get _filteredTransactions {
    // First apply type filter
    List<TransactionModel> result =
        _isSearching ? _searchResults : _transactions;

    if (_filterType != null) {
      if (_filterType == 'refund') {
        // Special handling for refunds
        result = result.where((txn) => 
          txn.type == 'topup' && txn.paymentMethod == 'refund'
        ).toList();
      } else if (_filterType == 'topup') {
        // For topup filter, exclude refunds
        result = result.where((txn) => 
          txn.type == 'topup' && txn.paymentMethod != 'refund'
        ).toList();
      } else {
        // Standard filtering for other types
        result = result.where((txn) => txn.type == _filterType).toList();
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)?.transactionHistory ??
              'Transaction History',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(AppLocalizations.of(context)?.all ?? 'All'),
              ),
              PopupMenuItem(
                value: 'topup',
                child: Text(AppLocalizations.of(context)?.topUp ?? 'Top-up'),
              ),
              PopupMenuItem(
                value: 'refund',
                child: Text(AppLocalizations.of(context)?.refund ?? 'Refund'),
              ),
              // Users only have topup and booking payments
              PopupMenuItem(
                value: 'booking',
                child: Text(AppLocalizations.of(context)?.booking ?? 'Booking'),
              ),
              PopupMenuItem(
                value: 'payment',
                child: Text(AppLocalizations.of(context)?.payment ?? 'Payment'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: Column(
                children: [
                  // Summary widget
                  _buildSummaryCard(),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      onChanged: (value) => _searchTransactions(value),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.searchTransaction ?? 'Search transactions...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                  // Group by selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)?.groupBy ?? 'Group by:'),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _groupBy,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _groupBy = value);
                            }
                          },
                          items: [
                            DropdownMenuItem(
                                value: 'none',
                                child: Text(
                                    AppLocalizations.of(context)?.none ??
                                        'None')),
                            DropdownMenuItem(
                                value: 'day',
                                child: Text(AppLocalizations.of(context)?.day ??
                                    'Day')),
                            DropdownMenuItem(
                                value: 'week',
                                child: Text(
                                    AppLocalizations.of(context)?.week ??
                                        'Week')),
                            DropdownMenuItem(
                                value: 'month',
                                child: Text(
                                    AppLocalizations.of(context)?.month ??
                                        'Month')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Transaction list
                  Expanded(
                    child: _filteredTransactions.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.noTransactionFound ??
                                  'No transactions found',
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        : _buildGroupedTransactionsList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _calculateSummary();

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.summary ?? 'Summary',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<SummaryPeriod>(
                  value: _summaryPeriod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _summaryPeriod = value);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                        value: SummaryPeriod.day,
                        child: Text(
                            AppLocalizations.of(context)?.today ?? 'Today')),
                    DropdownMenuItem(
                        value: SummaryPeriod.week,
                        child: Text(AppLocalizations.of(context)?.thisWeek ??
                            'This Week')),
                    DropdownMenuItem(
                        value: SummaryPeriod.month,
                        child: Text(AppLocalizations.of(context)?.thisMonth ??
                            'This Month')),
                    DropdownMenuItem(
                        value: SummaryPeriod.year,
                        child: Text(AppLocalizations.of(context)?.thisYear ??
                            'This Year')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(
                    Icons.arrow_circle_down,
                    Colors.green,
                    AppLocalizations.of(context)?.added ?? 'Added',
                    summary['totalTopup']?.toStringAsFixed(2) ?? '0.00'),
                _summaryItem(
                    Icons.arrow_circle_up,
                    Colors.red,
                    AppLocalizations.of(context)?.sent ?? 'Sent',
                    summary['totalPayment']?.toStringAsFixed(2) ?? '0.00'),
                _summaryItem(
                    Icons.account_balance_wallet,
                    Colors.blue,
                    AppLocalizations.of(context)?.balance ?? 'Balance',
                    summary['netBalance']?.toStringAsFixed(2) ?? '0.00'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '₹$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedTransactionsList() {
    final groupedTransactions = _groupTransactionsByDate();
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${transactions.length} ${AppLocalizations.of(context)?.transactions ?? 'transactions'}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Transactions for this date
            ...transactions
                .map((transaction) => _buildTransactionCard(transaction))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    Color statusColor;
    IconData statusIcon;

    // Check if it's a refund transaction
    bool isRefund = transaction.type == 'topup' && 
                    transaction.paymentMethod == 'refund';

    // Set colors and icons based on transaction status and type
    if (transaction.status == 'success') {
      if (transaction.type == 'topup') {
        if (isRefund) {
          // Special color and icon for refunds
          statusColor = Colors.purple;
          statusIcon = Icons.loop;
        } else {
          // Regular topup
          statusColor = Colors.green;
          statusIcon = Icons.arrow_downward;
        }
      } else if (transaction.type == 'payment' || transaction.type == 'booking') {
        statusColor = Colors.orange;
        statusIcon = Icons.arrow_upward;
      } else {
        // Default for any other transaction types
        statusColor = Colors.blue;
        statusIcon = Icons.swap_horiz;
      }
    } else if (transaction.status == 'pending') {
      statusColor = Colors.amber;
      statusIcon = Icons.hourglass_empty;
    } else {
      // Failed or unknown status
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    }

    final DateFormat dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final String formattedDate = dateFormat.format(transaction.timestamp);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(statusIcon, color: statusColor, size: 18),
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      isRefund 
                      ? AppLocalizations.of(context)?.refund ?? 'Refund'
                      : _getTransactionTypeText(transaction.type, context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${transaction.type == 'topup' ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    _getStatusText(transaction.status, context),
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (transaction.paymentMethod != null &&
                transaction.paymentMethod!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)?.paymentMethod ?? 'Payment Method'}: ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      transaction.paymentMethod == 'refund'
                          ? AppLocalizations.of(context)?.refund ?? 'Refund'
                          : transaction.paymentMethod!,
                      style: TextStyle(
                        color: isRefund ? Colors.purple : Colors.grey[700],
                        fontSize: 12.0,
                        fontWeight: isRefund ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            if (transaction.errorMessage != null &&
                transaction.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  transaction.errorMessage!,
                  style: TextStyle(
                    color: isRefund ? Colors.purple[700] : Colors.red[700],
                    fontSize: 12.0,
                    fontStyle: isRefund ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            if (transaction.transactionId != null &&
                transaction.transactionId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'ID: ${transaction.transactionId}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTypeText(String type, BuildContext context) {
    switch (type) {
      case 'topup':
        // Check if it's a refund (based on paymentMethod)
        return AppLocalizations.of(context)?.topUpWallet ?? 'Wallet Top-up';
      case 'payment':
        return AppLocalizations.of(context)?.payment ?? 'Payment';
      case 'booking':
        return AppLocalizations.of(context)?.booking ?? 'Booking';
      default:
        return type.capitalize();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, BuildContext context) {
    switch (status) {
      case 'success':
        return AppLocalizations.of(context)?.success ?? 'Success';
      case 'failed':
        return AppLocalizations.of(context)?.failed ?? 'Failed';
      case 'pending':
        return AppLocalizations.of(context)?.pending ?? 'Pending';
      default:
        return status.capitalize();
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
  }
}

enum SummaryPeriod { day, week, month, year }