import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/order_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../models/order_model.dart';
import '../orders/order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late ThemeController themeController;
  late OrderController orderController;
  String? selectedStatus;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    orderController = Get.find<OrderController>();

    // Load orders after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadOrders(context: context, refresh: true);
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        orderController.loadMoreOrders(
          context: context,
          status: selectedStatus,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.charcoal
            : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: Icon(
              Icons.filter_list,
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (orderController.isLoading.value && orderController.orders.isEmpty) {
          return _buildLoadingState();
        }

        if (orderController.orders.isEmpty) {
          return _buildEmptyState(context, themeController);
        }

        return RefreshIndicator(
          onRefresh: () => orderController.refreshOrders(
            context: context,
            status: selectedStatus,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            itemCount:
                orderController.orders.length +
                (orderController.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orderController.orders.length) {
                return _buildLoadingMoreIndicator();
              }

              final order = orderController.orders[index];
              return _buildOrderCard(context, themeController, order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Your orders will appear here once you make a purchase',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to products
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumColors.gold,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    ThemeController themeController,
    OrderModel order,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: TextHelper.size15(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeController.isDark
                        ? Colors.white
                        : PremiumColors.charcoal,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order.status,
                    ).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextHelper.size13(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Order Items
            Text(
              '${order.totalItems} item(s)',
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),

            SizedBox(height: 1.h),

            // Order Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextHelper.size14(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: themeController.isDark
                        ? Colors.white
                        : PremiumColors.charcoal,
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: TextHelper.size16(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: PremiumColors.gold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Order Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => OrderDetailsScreen(orderId: order.id));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: PremiumColors.gold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextHelper.size13(context).copyWith(
                        color: PremiumColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                if (order.status == 'delivered')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Reorder
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reorder',
                        style: TextHelper.size13(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
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
            'Loading orders...',
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.gold),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Orders'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              title: Text('Pending'),
              leading: Radio<String?>(
                value: 'pending',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              title: Text('Confirmed'),
              leading: Radio<String?>(
                value: 'confirmed',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              title: Text('Shipped'),
              leading: Radio<String?>(
                value: 'shipped',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              title: Text('Delivered'),
              leading: Radio<String?>(
                value: 'delivered',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              title: Text('Cancelled'),
              leading: Radio<String?>(
                value: 'cancelled',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context);
                  _applyFilter();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    orderController.loadOrders(
      context: context,
      refresh: true,
      status: selectedStatus,
    );
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
}
