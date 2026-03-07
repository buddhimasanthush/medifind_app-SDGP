import 'package:flutter/material.dart';
import 'reminder_store.dart';
import 'add_medicine_name_page.dart';

class MedicalReminderPage extends StatefulWidget {
  const MedicalReminderPage({super.key});

  @override
  State<MedicalReminderPage> createState() => _MedicalReminderPageState();
}

class _MedicalReminderPageState extends State<MedicalReminderPage> {
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday % 7; // 0=Sun

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Get week starting Sunday for selected date
  List<DateTime> _getWeekDays() {
    final now = _selectedDate;
    final weekday = now.weekday % 7; // Sun=0
    final sunday = now.subtract(Duration(days: weekday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  // Get reminders for selected day
  List<ReminderModel> _getRemindersForDay() {
    return ReminderStore.instance.reminders.where((r) {
      final dayIndex = _selectedDate.weekday % 7;
      return r.days[dayIndex];
    }).toList();
  }

  // Group reminders by time
  Map<String, List<ReminderModel>> _groupByTime(List<ReminderModel> reminders) {
    final Map<String, List<ReminderModel>> map = {};
    for (final r in reminders) {
      for (final t in r.times) {
        map.putIfAbsent(t, () => []).add(r);
      }
    }
    // Sort by time
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => _compareTime(a.key, b.key)),
    );
    return sorted;
  }

  int _compareTime(String a, String b) {
    int toMinutes(String t) {
      final parts = t.replaceAll(' ', '').split(':');
      int h = int.tryParse(parts[0]) ?? 0;
      final rest = parts[1];
      final isPm = rest.contains('PM');
      final m = int.tryParse(rest.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return h * 60 + m;
    }

    return toMinutes(a).compareTo(toMinutes(b));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final dayReminders = _getRemindersForDay();
    final grouped = _groupByTime(dayReminders);

    return Scaffold(
      backgroundColor: const Color(0xFF0796DE),
      body: Column(
        children: [
          // ── Blue header ──────────────────────────────────
          Container(
            color: const Color(0xFF0796DE),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + month
                    const Text(
                      'Medical Reminder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // ── White bottom sheet ───────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0796DE).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Day selector row ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        final date = weekDays[i];
                        final isSelected = i == _selectedDayIndex;
                        final isToday = date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDayIndex = i;
                            _selectedDate = date;
                          }),
                          child: Column(
                            children: [
                              // Dot indicator
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF0796DE)
                                      : Colors.transparent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF0796DE)
                                          .withOpacity(0.15)
                                      : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: const Color(0xFF0796DE),
                                          width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _dayLetters[i],
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF0796DE)
                                          : isToday
                                              ? const Color(0xFF0796DE)
                                              : const Color(0xFF9F9EA5),
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Reminder list ─────────────────────────
                  Expanded(
                    child: dayReminders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none,
                                    size: 60,
                                    color: const Color(0xFF0796DE)
                                        .withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text(
                                  'No reminders for this day',
                                  style: TextStyle(
                                    color: const Color(0xFF0796DE)
                                        .withOpacity(0.5),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            children: grouped.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time label with line
                                  Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Color(0xFF0796DE),
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: const Color(0xFF0796DE)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Reminder cards for this time
                                  ...entry.value
                                      .map((r) => _buildReminderCard(r)),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB: + add reminder ───────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineNamePage()),
          ).then((_) => setState(() {})); // refresh on return
        },
        backgroundColor: const Color(0xFF0796DE),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildReminderCard(ReminderModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EFFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Days label
                Text(
                  r.daysLabel,
                  style: const TextStyle(
                    color: Color(0xFF7CC8E8),
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                // Medicine name
                Text(
                  r.name,
                  style: const TextStyle(
                    color: Color(0xFF0796DE),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                // Description badge
                if (r.description.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0796DE).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.description,
                      style: const TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Done badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0796DE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('O ',
                    style: TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins')),
                Text('Done',
                    style: TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
