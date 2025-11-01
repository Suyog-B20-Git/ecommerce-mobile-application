import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CustomDropdownController extends GetxController {
  var selectedValue = RxnString();

  void updateValue(String value) {
    selectedValue.value = value;
  }
}

class CustomDropdownWithoutDecoration extends StatelessWidget {
  final List<String> items;
  final String hint;
  final Function(String) onChanged;
  final String? initialValue;

  final CustomDropdownController controller = Get.put(CustomDropdownController());

  CustomDropdownWithoutDecoration({
    Key? key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key) {
    if (initialValue != null) {
      controller.selectedValue.value = initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                ),
                items: items
                    .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                value: controller.selectedValue.value,
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateValue(value);
                    onChanged(value);
                  }
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  height: 3.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 4.h,
                ),
              ),
            )),
      ],
    );
  }
}
