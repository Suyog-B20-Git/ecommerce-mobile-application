// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../generated/assets.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/text_styles.dart';
// import '../constant_widgets.dart';
//
// class NotificationDialog {
//   static void showNotificationDialog(BuildContext context) {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//         child: Container(
//           color: ColorsForApp.whiteColor,
//           width: 300.w,
//           padding: EdgeInsets.all(10.sp),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Get.back(),
//                 ),
//               ),
//               Image.asset(
//                 Assets.imagesNotification,
//                 height: 15.h,
//                 fit: BoxFit.cover,
//               ),
//               height(2.h),
//               Text(
//                 "No notification yet",
//                 style: TextHelper.size15(context).copyWith(color: ColorsForApp.colorGeryShade, fontWeight: FontWeight.w500),
//               ),
//               height(2.h),
//               Text(
//                 "Stay tuned! Notifications about your activity will show up here.",
//                 textAlign: TextAlign.center,
//                 style: TextHelper.size13(context).copyWith(color: ColorsForApp.colorGeryShade),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
