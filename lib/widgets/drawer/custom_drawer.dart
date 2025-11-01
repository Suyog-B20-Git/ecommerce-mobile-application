// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../controller/app_controller.dart';
// import '../../routes/routes.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_enums.dart';
// import '../../utils/storage_config.dart';
// import '../../utils/text_styles.dart';
// import '../constant_widgets.dart';
// import '../custom_buttons.dart';
//
// class CustomDrawer extends StatefulWidget {
//   const CustomDrawer({super.key});
//
//   @override
//   State<CustomDrawer> createState() => _CustomDrawerState();
// }
//
// class _CustomDrawerState extends State<CustomDrawer> with TickerProviderStateMixin {
//   dynamic controller;
//   AppController appController = Get.find();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   String userRole = '';
//   bool isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart));
//     _animationController.forward();
//     _initializeController();
//   }
//
//   void _initializeController() async {
//     try {
//       // Fetch user role from storage
//       userRole = await LocalStorage.fetchValue(StorageKey.role) ?? '';
//
//       // Initialize appropriate controller based on role
//
//       controller = Get.find<DashboardController>();
//
//       isInitialized = true;
//
//       // Force rebuild to update drawer items
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       // If there's an error, default to admin controller
//       controller = Get.find<DashboardController>();
//       isInitialized = true;
//       if (mounted) {
//         setState(() {});
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.stop();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Container(
//           width: 70.w,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
//             boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.1 * 255).toInt()), blurRadius: 20, offset: const Offset(5, 0))],
//           ),
//           child: Column(
//             children: [
//               _buildHeaderSection(),
//               Expanded(child: _buildNavigationSection()),
//               _buildLogoutSection(),
//               height(2.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h, top: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
//         border: Border.all(color: ColorsForApp.primaryColor.withAlpha((0.2 * 255).toInt())),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(2.w),
//             decoration: BoxDecoration(
//               color: ColorsForApp.primaryColor.withAlpha((0.1 * 255).toInt()),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: ColorsForApp.primaryColor.withAlpha((0.3 * 255).toInt())),
//             ),
//             child: Icon(Icons.school_rounded, color: ColorsForApp.primaryColor, size: 5.w),
//           ),
//           width(3.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'IMS',
//                   style: TextHelper.size18(
//                     context,
//                   ).copyWith(color: ColorsForApp.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
//                 ),
//                 Text(
//                   'Institute Management System',
//                   style: TextHelper.size14(
//                     context,
//                   ).copyWith(color: ColorsForApp.primaryColor.withAlpha((0.8 * 255).toInt()), fontWeight: FontWeight.w400),
//                 ),
//                 if (userRole.isNotEmpty)
//                   Text(
//                     userRole.toUpperCase(),
//                     style: TextHelper.size12(
//                       context,
//                     ).copyWith(color: ColorsForApp.primaryColor.withAlpha((0.6 * 255).toInt()), fontWeight: FontWeight.w500),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavigationSection() {
//     // Check if controller is initialized
//     if (controller == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return ListView.builder(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       shrinkWrap: true,
//       itemCount: controller.drawerOperations.length,
//       itemBuilder: (context, index) {
//         return _buildNavigationItem(controller.drawerOperations[index], index);
//       },
//     );
//   }
//
//   Widget _buildNavigationItem(OperationInfo operation, int index) {
//     bool isSelected = controller.selectedDrawerIndex.value == index;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       margin: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
//       decoration: BoxDecoration(
//         color: isSelected ? ColorsForApp.primaryColor.withAlpha((0.1 * 255).toInt()) : Colors.transparent,
//         borderRadius: BorderRadius.circular(15),
//         border: isSelected ? Border.all(color: ColorsForApp.primaryColor.withAlpha((0.3 * 255).toInt())) : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: () {
//             controller.handleDrawerNavigation(context, index: index);
//           },
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
//             child: Row(
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: EdgeInsets.all(1.2.w),
//                   decoration: BoxDecoration(
//                     color: isSelected ? ColorsForApp.primaryColor.withAlpha((0.15 * 255).toInt()) : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: isSelected
//                         ? Border.all(color: ColorsForApp.primaryColor.withAlpha((0.3 * 255).toInt()))
//                         : Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: _buildIcon(operation.icon, isSelected),
//                 ),
//                 width(3.w),
//                 Expanded(
//                   child: Text(
//                     operation.title,
//                     style: TextHelper.size15(context).copyWith(
//                       color: isSelected ? ColorsForApp.primaryColor : ColorsForApp.colorBlackShade,
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                     ),
//                   ),
//                 ),
//                 if (isSelected)
//                   Container(
//                     width: 0.4.w,
//                     height: 2.h,
//                     decoration: BoxDecoration(color: ColorsForApp.primaryColor, borderRadius: BorderRadius.circular(2)),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIcon(dynamic icon, bool isSelected) {
//     if (icon is IconData) {
//       return Icon(icon, size: 4.w, color: isSelected ? ColorsForApp.primaryColor : ColorsForApp.subTitleColor);
//     } else if (icon is Widget) {
//       return SizedBox(width: 4.w, height: 4.w, child: icon);
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
//
//   Widget _buildLogoutSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: () {
//             Get.back();
//             showLogoutConfirmationDialog(context);
//           },
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.red.shade50, Colors.red.shade100.withAlpha((0.5 * 255).toInt())],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: Colors.red.shade200, width: 1.5),
//               boxShadow: [
//                 BoxShadow(color: Colors.red.withAlpha((0.15 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4), spreadRadius: 1),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(1.5.w),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.red.shade200, width: 1.5),
//                   ),
//                   child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 4.5.w),
//                 ),
//                 width(3.w),
//                 Expanded(
//                   child: Text(
//                     "Logout",
//                     style: TextHelper.size15(context).copyWith(color: Colors.red.shade600, fontWeight: FontWeight.w600, letterSpacing: 0.5),
//                   ),
//                 ),
//                 Icon(Icons.arrow_forward_ios_rounded, color: Colors.red.shade400, size: 3.5.w),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void showLogoutConfirmationDialog(BuildContext context) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: Container(
//             padding: EdgeInsets.all(5.w),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(4.w),
//                   decoration: BoxDecoration(color: Colors.red.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
//                   child: Icon(Icons.logout_rounded, color: Colors.red, size: 8.w),
//                 ),
//                 height(3.h),
//                 Text(
//                   "Logout Confirmation",
//                   style: TextHelper.size18(context).copyWith(fontWeight: FontWeight.bold, color: ColorsForApp.colorBlackShade),
//                 ),
//                 height(2.h),
//                 Text(
//                   "Are you sure you want to log out?",
//                   textAlign: TextAlign.center,
//                   style: TextHelper.size14(context).copyWith(color: ColorsForApp.subTitleColor, fontWeight: FontWeight.w400),
//                 ),
//                 height(4.h),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomButton(
//                         onPressed: () => Get.back(),
//                         label: "Cancel",
//                         buttonColor: ColorsForApp.tertiaryColor,
//                         textColor: Colors.white,
//                       ),
//                     ),
//                     width(3.w),
//                     Expanded(
//                       child: CustomButton(
//                         onPressed: () {
//                           Get.back();
//                           appController.removeToken();
//                           Get.offAllNamed(Routes.LOGIN_SCREEN);
//                         },
//                         label: "Logout",
//                         buttonColor: Colors.red,
//                         textColor: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
