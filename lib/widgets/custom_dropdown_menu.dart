import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

class CustomDropdownMenu extends StatelessWidget {
  final List<CustomMenuItem> items;
  final Function(String) onItemSelected;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const CustomDropdownMenu({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(icon ?? Icons.more_vert, color: iconColor ?? ColorsForApp.primaryColor, size: iconSize ?? 3.5.h),
      tooltip: tooltip,
      onSelected: onItemSelected,
      itemBuilder: (context) => items.map((item) => item.build(context)).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      offset: const Offset(0, 8),
      color: Colors.white,
    );
  }
}

class CustomMenuItem {
  final String value;
  final String label;
  final Color color;
  final bool isDestructive;

  const CustomMenuItem({required this.value, required this.label, required this.color, this.isDestructive = false});

  PopupMenuItem<String> build(BuildContext context) {
    return PopupMenuItem<String>(
      value: value,
      height: 3.h,
      child: Text(
        label,
        style: TextHelper.size15(context).copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Predefined menu items for common actions
class UserMenuItems {
  static List<CustomMenuItem> getUserMenuItems({required bool isUserActive, required String userName}) {
    return [
      CustomMenuItem(
        value: 'enable_disable',
        label: isUserActive ? 'Disable User' : 'Enable User',
        color: isUserActive ? Colors.red : Colors.green,
      ),
      CustomMenuItem(value: 'delete', label: 'Delete User', color: Colors.red, isDestructive: true),
    ];
  }

  static List<CustomMenuItem> getGeneralMenuItems() {
    return [
      CustomMenuItem(value: 'settings', label: 'Settings', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'help', label: 'Help & Support', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'about', label: 'About', color: ColorsForApp.primaryColor),
    ];
  }

  static List<CustomMenuItem> getDocumentMenuItems() {
    return [
      CustomMenuItem(value: 'download', label: 'Download', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'share', label: 'Share', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'print', label: 'Print', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'delete', label: 'Delete', color: Colors.red, isDestructive: true),
    ];
  }

  static List<CustomMenuItem> getConsellorStudentMenuItems() {
    return [
      CustomMenuItem(value: 'convert', label: 'Enroll Student', color: ColorsForApp.primaryColor),
      CustomMenuItem(value: 'followup', label: 'Set Followup', color: ColorsForApp.primaryColor,),
      CustomMenuItem(value: 'delete', label: 'Delete Student', color: Colors.red, isDestructive: true),
    ];
  }
}
