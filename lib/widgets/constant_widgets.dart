import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_colors.dart';

SizedBox height(double h) => SizedBox(height: h);

SizedBox width(double w) => SizedBox(width: w);

// Scaffold
class CustomScaffold extends StatelessWidget {
  final AppBar? appBar;
  final List<Widget>? appBarActions;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final bool? centerTitle;
  final bool? extendBody;
  final bool? extendBodyBehindAppBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool? resizeToAvoidBottomInset;
  final bool showLeadingIcon;
  final String? title;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final void Function()? onBack;
  final Widget? bottomSheet;
  final Color? appBarBackground;
  final double? drawerEdgeDragWidth;
  final Widget? stackedHeader;
  final double extendedHeight;
  final CrossAxisAlignment scaffoldCrossAxisAlignment;
  final bool canPop;
  final bool isDashboard;
  final void Function(dynamic result)? onPopPrevented;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  CustomScaffold({
    super.key,
    AppBar? appBar,
    this.appBarActions,
    this.body,
    this.bottomNavigationBar,
    this.centerTitle,
    this.extendBody,
    this.extendBodyBehindAppBar,
    this.drawer,
    this.floatingActionButton,
    this.leading,
    this.resizeToAvoidBottomInset,
    this.showLeadingIcon = false,
    this.title,
    this.titleStyle,
    this.backgroundColor,
    this.onBack,
    this.bottomSheet,
    this.appBarBackground,
    this.drawerEdgeDragWidth,
    this.stackedHeader,
    this.extendedHeight = 0,
    this.scaffoldCrossAxisAlignment = CrossAxisAlignment.center,
    this.canPop = true,
    this.isDashboard = false,
    this.onPopPrevented,
    this.floatingActionButtonLocation,
  }) : assert(title == null || appBar == null),
       appBar =
           appBar ??
           (title != null
               ? AppBar(
                   automaticallyImplyLeading: false,
                   leading: leading != null || showLeadingIcon
                       ? leading ??
                             IconButton(
                               onPressed:
                                   onBack ??
                                   () {
                                     Get.back();
                                   },
                               icon: leading ?? Icon(CupertinoIcons.back, color: Colors.black87, size: 18.sp),
                             )
                       : null,
                   actions: [...?appBarActions, width(3.w)],
                   centerTitle: centerTitle,
                   backgroundColor: appBarBackground ?? Colors.transparent,
                   title: Text(
                     title,
                     style: titleStyle ?? TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: ColorsForApp.colorBlackShade),
                   ),
                 )
               : null);

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (appBar != null)
            Container(
              clipBehavior: Clip.hardEdge,
              height: statusBarHeight + appBar!.preferredSize.height + extendedHeight + 2.h,
              decoration: BoxDecoration(
                color: appBarBackground ?? Colors.white,
                boxShadow: const [BoxShadow(offset: Offset(0, 2), blurRadius: 2, spreadRadius: 0, color: Color(0x1A000000))],
                borderRadius: isDashboard
                    ? const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
                    : null,
              ),
            ),
          Column(
            crossAxisAlignment: scaffoldCrossAxisAlignment,
            children: [
              if (appBar != null)
                Column(
                  crossAxisAlignment: scaffoldCrossAxisAlignment,
                  children: [height(3.h), appBar!, if (stackedHeader != null) stackedHeader!],
                ),
              if (body != null) Flexible(child: body!),
            ],
          ),
        ],
      ),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? false,
      bottomNavigationBar: bottomNavigationBar,
      extendBody: extendBody ?? false,
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
