class DateUtility {
  static String getTimeFromDateTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12 == 0 ? 12 : hour % 12;

    String minuteStr = minute.toString().padLeft(2, '0');

    return "$hour12:$minuteStr $amPm";
  }
}
