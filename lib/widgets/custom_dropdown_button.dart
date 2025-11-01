import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../utils/text_styles.dart';
import 'constant_widgets.dart';

typedef ValidatorCallBack = String? Function(String? value)?;
typedef ItemTapCallback = void Function(String value);

class CustomTypeAheadHelper extends StatefulWidget {
  final String? labelName;
  final bool? recommend;
  final bool readOnly;
  final String hintText;
  final TextEditingController controller;
  final ValidatorCallBack? validatorCallBack;
  final Future<List<String>> Function(String search) suggestionsCallback;
  final ItemTapCallback? onSelected;
  final void Function(String)? onChanged;
  final VoidCallback? onAddNewTap;

  const CustomTypeAheadHelper({
    super.key,
    this.labelName,
    this.recommend = false,
    this.readOnly = false,
    required this.hintText,
    required this.controller,
    this.validatorCallBack,
    required this.suggestionsCallback,
    this.onSelected,
    this.onChanged,
    this.onAddNewTap,
  });

  @override
  State<CustomTypeAheadHelper> createState() => _SuggestionTextFieldHelperState();
}

class _SuggestionTextFieldHelperState extends State<CustomTypeAheadHelper> with WidgetsBindingObserver {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _keyboardWasVisible = false;
  int _lastRequestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _fetchSuggestions(widget.controller.text);
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0.0;

    if (_keyboardWasVisible && !isKeyboardVisible) {
      _removeOverlay();
      FocusScope.of(context).unfocus();
    }

    _keyboardWasVisible = isKeyboardVisible;
  }

  void _fetchSuggestions(String value) async {
    final int requestId = ++_lastRequestId;
    final suggestions = await widget.suggestionsCallback(value);
    if (requestId == _lastRequestId && mounted) {
      setState(() {
        _suggestions = suggestions;
      });
      if (_focusNode.hasFocus) {
        if (_overlayEntry == null) {
          _showOverlay();
        } else {
          _overlayEntry?.markNeedsBuild();
        }
      }
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: MediaQuery.of(context).size.width - 8.w,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, 6.h),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10),
                child:
                    _suggestions.isEmpty
                        ? GestureDetector(
                          onTap: () {
                            _removeOverlay();
                            widget.onAddNewTap?.call();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("+ Add New", style: TextHelper.size14(context).copyWith(color: Colors.blue)),
                          ),
                        )
                        : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: (_suggestions.length * 4.2).h + 6.h > 30.h ? 30.h : (_suggestions.length * 4.2).h + 6.5.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: ListView.separated(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  itemCount: _suggestions.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 0.8.h),
                                  itemBuilder: (context, index) {
                                    final item = _suggestions[index];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        widget.controller.text = item;
                                        widget.onSelected?.call(item);
                                        _removeOverlay();
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                                        child: Text(item, style: TextStyle(fontSize: 15.sp)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(height: 1.sp),
                              GestureDetector(
                                onTap: () {
                                  _removeOverlay();
                                  widget.onAddNewTap?.call();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text("+ Add New", style: TextHelper.size14(context).copyWith(color: Colors.blue)),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelName != null && widget.labelName!.isNotEmpty)
          Text.rich(
            TextSpan(
              text: widget.labelName,
              style: TextHelper.size15(context).copyWith(fontWeight: FontWeight.w500),
              children: [if (widget.recommend == true) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
            ),
          ),
        height(0.5.h),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            readOnly: widget.readOnly,
            style: TextHelper.size16(context),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt())),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha((0.5 * 255).toInt()), width: 1.5),
              ),
              hintText: widget.hintText,
              hintStyle: TextHelper.size14(context).copyWith(color: Colors.grey.withAlpha((0.75 * 255).toInt())),
              suffixIcon: Icon(Icons.keyboard_arrow_down, size: 19.sp, color: Colors.black),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              _fetchSuggestions(value);
            },
            validator: (value) => widget.validatorCallBack?.call(value),
          ),
        ),
      ],
    );
  }
}
