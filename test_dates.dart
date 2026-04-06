import 'package:intl/intl.dart';

void main() {
  final schedule = [
    {'id': 1, 'doctorId': 8, 'day': 'Monday', 'startTime': '9:00 AM', 'endTime': '5:00 PM', 'isBooked': false}, 
    {'id': 2, 'doctorId': 8, 'day': 'Thursday', 'startTime': '9:00 AM', 'endTime': '5:00 PM', 'isBooked': false}, 
    {'id': 3, 'doctorId': 8, 'day': 'Sunday', 'startTime': '3:36 PM', 'endTime': '5:00 PM', 'isBooked': false}, 
    {'id': 4, 'doctorId': 8, 'day': 'Saturday', 'startTime': '12:00 PM', 'endTime': '2:00 PM', 'isBooked': false}
  ];

  int _getWeekdayFromStr(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return -1;
    }
  }

  if (schedule.isEmpty) return;

  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);

  final availableDays = schedule
      .where((s) => (s['isBooked'] ?? false) == false)
      .map((s) => s['day'] as String)
      .toSet()
      .toList();

  List<DateTime> availableDates = [];

  for (String dayName in availableDays) {
    int targetWeekday = _getWeekdayFromStr(dayName);
    if (targetWeekday != -1) {
      int daysUntil = (targetWeekday - todayMidnight.weekday + 7) % 7;
      DateTime nextOccurrence = todayMidnight.add(Duration(days: daysUntil));
      availableDates.add(nextOccurrence);
      availableDates.add(nextOccurrence.add(const Duration(days: 7)));
    }
  }

  availableDates.sort((a, b) => a.compareTo(b));
  
  final formatted = <String, Map<String, String>>{};
  final formatter = DateFormat('yyyy-MM-dd');

  for (var date in availableDates) {
    final dateStr = formatter.format(date);
    if (!formatted.containsKey(dateStr)) {
       formatted[dateStr] = {
         'date': dateStr,
         'label': DateFormat('EEE, MMM d').format(date)
       };
    }
  }

  print(formatted.values.toList());
}
