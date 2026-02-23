import 'package:flutter/material.dart';
import '../pages/medicine_form_page.dart';

class MedicineFormCarousel extends StatelessWidget {
  const MedicineFormCarousel({super.key});

  final List<Map<String, dynamic>> forms = const [
    {'name': 'Liquid', 'icon': Icons.water_drop},
    {'name': 'Capsule', 'icon': Icons.medication},
    {'name': 'Tablet', 'icon': Icons.circle},
    {'name': 'Syringe', 'icon': Icons.vaccines},
    {'name': 'Pills', 'icon': Icons.medication_liquid},
    {'name': 'Suspension', 'icon': Icons.opacity},
    {'name': 'Drops', 'icon': Icons.water},
    {'name': 'Infusion', 'icon': Icons.local_hospital},
    {'name': 'Cream', 'icon': Icons.wash},
    {'name': 'Ointment', 'icon': Icons.healing},
    {'name': 'Spray', 'icon': Icons.air},
    {'name': 'Nebulizer', 'icon': Icons.cloud},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: forms.length,
        itemBuilder: (context, index) {
          final form = forms[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == forms.length - 1 ? 0 : 12,
            ),
            child: _MedicineFormItem(
              name: form['name'],
              icon: form['icon'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineFormPage(
                      formName: form['name'],
                    ),
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

class _MedicineFormItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _MedicineFormItem({
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
            width: 64,
            height: 66,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(0.66, 1.00),
                colors: [Color(0xFFE68E2D), Color(0xFFF09E43)],
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            name,
            textAlign: TextAlign.center,
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
