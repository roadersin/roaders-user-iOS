// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../classes/offer.dart';

class OfferCard extends StatelessWidget {
  final Offer leftOffer;
  final Offer? rightOffer; // Make this nullable

  const OfferCard({
    super.key,
    required this.leftOffer,
    this.rightOffer, // Remove required since it's nullable
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: rightOffer != null
          ? Row(
              children: [
                // Left offer card
                Expanded(child: _buildOfferCard(leftOffer, context)),
                const SizedBox(width: 12), // Space between cards
                // Right offer card
                Expanded(child: _buildOfferCard(rightOffer!, context)),
              ],
            )
          : _buildOfferCard(leftOffer, context), // Full width for single card
    );
  }

  Widget _buildOfferCard(Offer offer, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: offer.code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer code "${offer.code}" copied to clipboard!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.grey.shade200,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
