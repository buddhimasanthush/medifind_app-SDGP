import 'package:flutter/material.dart';

class PharmacyCard extends StatelessWidget {
  final String name;
  final String distance;
  final double rating;
  final VoidCallback onTap;

  const PharmacyCard({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 122,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              border: Border.all(
                width: 1,
                color: const Color(0xFFEFEFEF),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_pharmacy,
                  size: 48,
                  color: Color(0xFF0796DE),
                ),
                const SizedBox(height: 8),
                Text(
                  distance,
                  style: const TextStyle(
                    color: Color(0xFF919191),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
