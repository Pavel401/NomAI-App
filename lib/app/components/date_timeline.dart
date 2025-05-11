// import 'package:flutter/material.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// class DateTimeline extends StatelessWidget {
//   final Map<DateTime, List<dynamic>> dateSchedules;
//   final ItemScrollController itemScrollController;
//   final DateTime selectedDate;
//   final void Function(DateTime) onDateSelected;
//   final Widget Function(BuildContext, DateTime, bool, bool, int) dayBuilder;

//   const DateTimeline({
//     Key? key,
//     required this.dateSchedules,
//     required this.itemScrollController,
//     required this.selectedDate,
//     required this.onDateSelected,
//     required this.dayBuilder,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100, // you can make this dynamic if you want
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//         color: Colors.white,
//       ),
//       child: ScrollablePositionedList.builder(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         itemCount: dateSchedules.length,
//         itemScrollController: itemScrollController,
//         itemBuilder: (context, index) {
//           DateTime date = dateSchedules.keys.elementAt(index);

//           bool isSunday = date.weekday == DateTime.sunday;
//           bool isSelected = selectedDate.year == date.year &&
//               selectedDate.month == date.month &&
//               selectedDate.day == date.day;

//           int noOfSchedules = dateSchedules[date]?.length ?? 0;

//           return GestureDetector(
//             onTap: () => onDateSelected(date),
//             child:
//                 dayBuilder(context, date, isSunday, isSelected, noOfSchedules),
//           );
//         },
//       ),
//     );
//   }
// }
