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
          title: 'Error',
          message: 'Order not found',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar.SnackBar.error(
        title: 'Error',
        message: 'Failed to load order details',
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
          'Order Details',
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
            'Loading order details...',
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
            'Order not found',
            style: TextHelper.size16(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 1.h),
          Text(
            'The order you are looking for does not exist.',
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
              'Go Back',
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
                'Order #${order!.orderNumber}',
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '${order!.totalItems} items',
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Placed on ${_formatDate(order!.createdAt)}',
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
            'Order Status',
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
                'Cancellation Note',
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
                : 'This order was cancelled.',
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
                'Shipping Address',
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
            'Order Items',
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
                      'Qty: ${item.quantity}',
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
            'Order Summary',
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
            'Subtotal',
            '₹${order!.subtotal.toStringAsFixed(0)}',
          ),
          _buildSummaryRow(
            'Shipping',
            '₹${order!.shippingCost.toStringAsFixed(0)}',
          ),
          _buildSummaryRow('Tax', '₹${order!.taxAmount.toStringAsFixed(0)}'),
          if (order!.discountAmount > 0)
            _buildSummaryRow(
              'Discount',
              '-₹${order!.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          Divider(color: Colors.grey[300]),
          _buildSummaryRow(
            'Total',
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
                'Tracking Information',
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
              'Tracking Number: ${order!.trackingNumber}',
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
              'Notes: ${order!.notes}',
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
        'label': 'Order Confirmed',
        'time': confirmedAt,
        'active': confirmedAt != null,
      },
      {'label': 'Shipped', 'time': shippedAt, 'active': shippedAt != null},
      {
        'label': 'Delivered',
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
                      time != null ? _formatDate(time) : 'Pending',
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
                  'Cancel Order',
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
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for cancellation.'),
            SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason (required)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                CustomSnackBar.SnackBar.error(
                  title: 'Reason required',
                  message: 'Please enter a cancellation reason.',
                );
                return;
              }
              Navigator.pop(context);
              _cancelOrder(reason: reason);
            },
            child: Text('Yes'),
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
        return 'Your order is being processed';
      case 'confirmed':
        return 'Your order has been confirmed';
      case 'shipped':
        return 'Your order has been shipped';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return 'Unknown status';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
