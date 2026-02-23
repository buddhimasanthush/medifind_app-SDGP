import 'package:flutter/material.dart';
import '../pages/upload_prescription_page.dart';
import '../pages/reminder_page.dart';
import '../pages/previous_orders_page.dart';
import '../pages/health_profile_page.dart';

class ServicesCarousel extends StatelessWidget {
  const ServicesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'Upload\nprescription',
        'icon': Icons.upload_file,
        'page': const UploadPrescriptionPage(),
      },
      {
        'name': 'reminder',
        'icon': Icons.alarm,
        'page': const ReminderPage(),
      },
      {
        'name': 'past\norders',
        'icon': Icons.history,
        'page': const PreviousOrdersPage(),
      },
      {
        'name': 'view your\naccount',
        'icon': Icons.account_circle,
        'page': const HealthProfilePage(),
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == services.length - 1 ? 0 : 15,
            ),
            child: _ServiceItem(
              name: service['name'] as String,
              icon: service['icon'] as IconData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => service['page'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 125,
            height: 95,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              border: Border.all(
                width: 1,
                color: const Color(0xFFEFEFEF),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0796DE),
              size: 48,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 125,
            height: 40,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
