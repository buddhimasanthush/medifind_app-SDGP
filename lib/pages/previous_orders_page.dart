import 'package:flutter/material.dart';

class PreviousOrdersPage extends StatelessWidget {
  const PreviousOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data - replace with actual data later
    final List<Map<String, dynamic>> orders = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Past Orders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No previous purchases',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF919191),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your order history will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Color(0xFF919191),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderItem(
                  orderId: order['id'],
                  date: order['date'],
                  items: order['items'],
                  total: order['total'],
                );
              },
            ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String orderId;
  final String date;
  final int items;
  final double total;

  const _OrderItem({
    required this.orderId,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        border: Border.all(
          width: 1,
          color: const Color(0xFFEFEFEF),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF919191),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$items items',
            style: const TextStyle(
              color: Color(0xFF919191),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Total: Rs. ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF0796DE),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
