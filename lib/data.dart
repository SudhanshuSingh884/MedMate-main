import 'package:medmate/enums.dart';
import 'package:medmate/menu_info.dart';
import 'package:medmate/alarm_info.dart';
import 'package:medmate/constrants/theme_data.dart';

List<MenuInfo> menuItems = [
  MenuInfo(MenuType.clock,
      title: 'Clock', imageSource: 'assets/clock_icon.png'),
  MenuInfo(MenuType.AddPill,
      title: 'Add Pill', imageSource: 'assets/add_alarm.png'),
  MenuInfo(MenuType.PreviousPills,
      title: 'Previous Pills', imageSource: 'assets/1cabinets.png'),
  MenuInfo(MenuType.Profile,
      title: 'Profile', imageSource: 'assets/profile.png')
];
List<AlarmInfo> alarms = [
  AlarmInfo(
      alarmDateTime: DateTime.now().add(Duration(hours: 1)),
      title: 'Office',
      gradientColorIndex: GradientColors.sky),
  AlarmInfo(
      alarmDateTime: DateTime.now().add(Duration(hours: 2)),
      title: 'Sport',
      gradientColorIndex: GradientColors.sea),
];
