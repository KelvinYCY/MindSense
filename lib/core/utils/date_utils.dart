import 'package:intl/intl.dart';

class DateUtils {
 static String formatDate(DateTime date) {
   return DateFormat('MMM d, y').format(date);
 }

 static String formatTime(DateTime time) {
   return DateFormat('h:mm a').format(time);
 }

 static String formatDateTime(DateTime dateTime) {
   return DateFormat('MMM d, y h:mm a').format(dateTime);
 }

 static String getTimeAgo(DateTime dateTime) {
   final difference = DateTime.now().difference(dateTime);
   
   if (difference.inDays > 7) {
     return DateFormat('MMM d, y').format(dateTime);
   } else if (difference.inDays > 0) {
     return '${difference.inDays}d ago';
   } else if (difference.inHours > 0) {
     return '${difference.inHours}h ago';
   } else if (difference.inMinutes > 0) {
     return '${difference.inMinutes}m ago';
   } else {
     return 'Just now';
   }
 }

 static String formatDuration(int minutes) {
   if (minutes < 60) {
     return '$minutes min';
   }
   final hours = minutes ~/ 60;
   final remainingMinutes = minutes % 60;
   if (remainingMinutes == 0) {
     return '$hours h';
   }
   return '$hours h $remainingMinutes min';
 }

 static String getDayOfWeek(DateTime date) {
   return DateFormat('EEEE').format(date);
 }

 static String getShortDayOfWeek(DateTime date) {
   return DateFormat('EEE').format(date);
 }

 static String getMonthYear(DateTime date) {
   return DateFormat('MMMM y').format(date);
 }

 static String getShortMonthYear(DateTime date) {
   return DateFormat('MMM y').format(date);
 }

 static bool isSameDay(DateTime date1, DateTime date2) {
   return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
 }
}