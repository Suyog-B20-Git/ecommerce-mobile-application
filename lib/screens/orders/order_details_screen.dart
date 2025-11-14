import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/order_controller.dart';
import '../../models/order_model.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../utils/color_helper.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late ThemeController themeController;
  late OrderController orderController;
  OrderModel? order;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    orderController = Get.find<OrderController>();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orderDetails = await orderController.getOrderById(
        widget.orderId,
        context: context,
      );
      if (orderDetails != null) {
        setState(() {
          order = orderDetails;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        CustomSnackBar.SnackBar.error(
          title: 'error.generic'.tr,
          message: 'orders.notFound'.tr,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar.SnackBar.error(
        title: 'error.generic'.tr,
        message: 'orders.loadFailed'.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.grey900
          : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'orders.orderDetails'.tr,
          style: TextHelper.size18(context).copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.grey800
            : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeController.isDark ? Colors.white : Colors.black,
        ),
      ),
      body: isLoading
          ? _buildLoadingState()
          : order == null
          ? _buildErrorState()
          : _buildOrderDetails(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.gold),
          ),
          SizedBox(height: 2.h),
          Text(
            'orders.loadingDetails'.tr,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 10.w, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'orders.notFound'.tr,
            style: TextHelper.size16(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 1.h),
          Text(
            'orders.notFoundMessage'.tr,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumColors.gold,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'common.back'.tr,
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(),
          SizedBox(height: 3.h),
          _buildOrderStatus(),
          if ((order!.notes != null && order!.notes!.isNotEmpty) || order!.status.toLowerCase() == 'cancelled') ...[
            SizedBox(height: 2.h),
            _buildCancellationNote(),
          ],
          SizedBox(height: 3.h),
          _buildShippingAddress(),
          SizedBox(height: 3.h),
          _buildOrderItems(),
          SizedBox(height: 3.h),
          _buildOrderSummary(),
          SizedBox(height: 3.h),
          _buildTrackingInfo(),
          SizedBox(height: 3.h),
          _buildOrderActions(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'orders.orderNumber'.tr} ${order!.orderNumber}',
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '${order!.totalItems} ${'orders.itemsCount'.tr}',
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${'orders.placedOn'.tr} ${_formatDate(order!.createdAt)}',
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.orderStatus'.tr,
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(order!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order!.status.toUpperCase(),
                  style: TextHelper.size14(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getStatusDescription(order!.status),
                  style: TextHelper.size14(
                    context,
                  ).copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationNote() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.red, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'orders.cancellationNote'.tr,
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            order!.notes?.isNotEmpty == true
                ? order!.notes!
                : 'orders.cancelledMessage'.tr,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: PremiumColors.gold, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'orders.shippingAddress'.tr,
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            order!.shippingAddress.name,
            style: TextHelper.size15(context).copyWith(
              fontWeight: FontWeight.w600,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            order!.shippingAddress.phone,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 0.5.h),
          Text(
            order!.shippingAddress.address,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${order!.shippingAddress.city}, ${order!.shippingAddress.state} - ${order!.shippingAddress.pincode}',
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.items'.tr,
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          ...order!.items.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey700 : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).toInt())),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: item.productImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey[400]);
                      },
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextHelper.size15(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: themeController.isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                if (item.variantAttributes.isNotEmpty)
                  Text(
                    '${ColorHelper.getColorName(item.variantAttributes['color']?.toString() ?? '')} - ${item.variantAttributes['size'] ?? ''}',
                    style: TextHelper.size14(
                      context,
                    ).copyWith(color: Colors.grey[600]),
                  ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'orders.quantity'.tr} ${item.quantity}',
                      style: TextHelper.size14(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: TextHelper.size15(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.orderSummary'.tr,
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
            'orders.subtotal'.tr,
            '₹${order!.subtotal.toStringAsFixed(0)}',
          ),
          _buildSummaryRow(
            'orders.shipping'.tr,
            '₹${order!.shippingCost.toStringAsFixed(0)}',
          ),
          _buildSummaryRow('orders.tax'.tr, '₹${order!.taxAmount.toStringAsFixed(0)}'),
          if (order!.discountAmount > 0)
            _buildSummaryRow(
              'orders.discount'.tr,
              '-₹${order!.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          Divider(color: Colors.grey[300]),
          _buildSummaryRow(
            'orders.total'.tr,
            '₹${order!.totalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextHelper.size14(context).copyWith(
              color: isDiscount ? Colors.green : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextHelper.size14(context).copyWith(
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? PremiumColors.gold : Colors.grey[600]),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: PremiumColors.gold, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'orders.trackingInfo'.tr,
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (order!.trackingNumber != null &&
              order!.trackingNumber!.isNotEmpty)
            Text(
              '${'orders.trackingNumber'.tr} ${order!.trackingNumber ?? ''}',
              style: TextHelper.size14(context).copyWith(
                fontWeight: FontWeight.w600,
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
            ),
          SizedBox(height: 1.5.h),
          _buildTrackingTimeline(),
          if (order!.notes != null && order!.notes!.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              '${'orders.notes'.tr} ${order!.notes ?? ''}',
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    // Steps with timestamps
    final DateTime? confirmedAt = order!.confirmedAt ?? order!.createdAt;
    final shippedAt = order!.shippedAt;
    final deliveredAt = order!.deliveredAt;

    final steps = [
      {
        'label': 'orders.timeline.confirmed'.tr,
        'time': confirmedAt,
        'active': confirmedAt != null,
      },
      {'label': 'orders.timeline.shipped'.tr, 'time': shippedAt, 'active': shippedAt != null},
      {
        'label': 'orders.timeline.delivered'.tr,
        'time': deliveredAt,
        'active': deliveredAt != null,
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final active = step['active'] as bool;
        final DateTime? time = step['time'] as DateTime?;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? PremiumColors.gold : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: active
                        ? PremiumColors.gold.withAlpha((0.6 * 255).toInt())
                        : (themeController.isDark
                              ? PremiumColors.grey700
                              : Colors.grey[300]),
                  ),
              ],
            ),
            SizedBox(width: 3.w),
            // Content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['label'] as String,
                      style: TextHelper.size15(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: themeController.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      time != null ? _formatDate(time) : 'orders.status.pending'.tr,
                      style: TextHelper.size14(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderActions() {
    if (order!.status == 'pending' || order!.status == 'confirmed') {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCancelOrderDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'orders.cancelOrder'.tr,
                  style: TextHelper.size14(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  void _showCancelOrderDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('orders.cancelOrder'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('orders.cancelReasonPrompt'.tr),
            SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'orders.cancelReasonHint'.tr,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.no'.tr),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                CustomSnackBar.SnackBar.error(
                  title: 'orders.reasonRequired'.tr,
                  message: 'orders.reasonRequiredMessage'.tr,
                );
                return;
              }
              Navigator.pop(context);
              _cancelOrder(reason: reason);
            },
            child: Text('common.yes'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder({required String reason}) async {
    final success = await orderController.cancelOrder(
      order!.id,
      reason: reason,
      context: context,
    );

    if (success) {
      _loadOrderDetails(); // Reload order details
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orders.statusDesc.pending'.tr;
      case 'confirmed':
        return 'orders.statusDesc.confirmed'.tr;
      case 'shipped':
        return 'orders.statusDesc.shipped'.tr;
      case 'delivered':
        return 'orders.statusDesc.delivered'.tr;
      case 'cancelled':
        return 'orders.statusDesc.cancelled'.tr;
      default:
        return 'orders.statusDesc.unknown'.tr;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
