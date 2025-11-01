import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class Loader {
  static final Loader _loader = Loader._init();
  Loader._init();

  bool isLoaderActive = false;

  static Loader get instance => _loader;

  late OverlayEntry _overlayEntry;

  void _createOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          const ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
          ),
          // Centered loader
          Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 12.w,
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry);
  }

  void showLoader(BuildContext context) {
    if (!isLoaderActive) {
      isLoaderActive = true;
      _createOverlay(context);
    }
  }

  void removeLoader() {
    if (isLoaderActive) {
      isLoaderActive = false;
      _overlayEntry.remove();
    }
  }
}
