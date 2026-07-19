import 'dart:async';
import 'package:flutter/material.dart';
import 'package:product_inventory/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/core/widgets/premium_empty_state.dart';
import 'package:product_inventory/core/utils/app_snackbar.dart';
import 'package:product_inventory/core/widgets/premium_card.dart';
import 'package:product_inventory/core/widgets/premium_icon_button.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_event.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier<String>(
    'This Month',
  );

  @override
  void dispose() {
    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventoryEvent(isRefresh: true));
    context.read<InventoryBloc>().add(LoadDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSidebar(context),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<InventoryBloc>().add(
            LoadInventoryEvent(isRefresh: true),
          );
          context.read<InventoryBloc>().add(LoadDashboardDataEvent());
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 10),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              HeroCarousel(
                onViewAnalytics: () {
                  final filter = _selectedFilterNotifier.value;
                  String? timeFilter;
                  if (filter == 'This Month') {
                    timeFilter = 'this_month';
                  } else if (filter == 'This Year') {
                    timeFilter = 'this_year';
                  }
                  context.go('/products', extra: {'timeFilter': timeFilter});
                },
              ),
              SizedBox(height: 32),
              ValueListenableBuilder<String>(
                valueListenable: _selectedFilterNotifier,
                builder: (context, filter, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Overview', filter),
                      SizedBox(height: 16),
                      BlocBuilder<InventoryBloc, InventoryState>(
                        builder: (context, state) {
                          if (state.status == InventoryStatus.loading &&
                              state.allProducts.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state.status == InventoryStatus.success &&
                              state.allProducts.isEmpty) {
                            return PremiumEmptyState(
                              title: 'Your Dashboard is Empty',
                              subtitle:
                                  'It looks like you have no inventory data. Add some products to see your analytics here!',
                            );
                          }

                          final now = DateTime.now();
                          List<Product> filteredProducts = state.allProducts;
                          if (filter == 'This Month') {
                            filteredProducts = state.allProducts.where((p) {
                              if (p.addedOn == null) return false;
                              return p.addedOn!.year == now.year &&
                                  p.addedOn!.month == now.month;
                            }).toList();
                          } else if (filter == 'This Year') {
                            filteredProducts = state.allProducts.where((p) {
                              if (p.addedOn == null) return false;
                              return p.addedOn!.year == now.year;
                            }).toList();
                          }

                          final totalProducts = filteredProducts.length;
                          final totalValue = filteredProducts.fold<double>(
                            0,
                            (sum, item) => sum + (item.price * item.stock),
                          );
                          final lowStockItems = filteredProducts
                              .where((p) => p.stock < 20)
                              .length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                    children: [
                                      Expanded(
                                        child: _buildMiniKpiCard(
                                          'Total Products${filter != "All Time" ? " ($filter)" : ""}',
                                          totalProducts.toString(),
                                          'In your catalog',
                                          Icons.inventory_2_outlined,
                                          false,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildMiniKpiCard(
                                          'Low Stock${filter != "All Time" ? " ($filter)" : ""}',
                                          lowStockItems.toString(),
                                          'Needs attention',
                                          Icons.warning_amber_rounded,
                                          true,
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .fade(duration: 400.ms)
                                  .slideY(begin: 0.1, end: 0),
                              SizedBox(height: 16),
                              _buildWideKpiCard(
                                    'Total Inventory Value${filter != "All Time" ? " ($filter)" : ""}',
                                    '\$${totalValue.toStringAsFixed(2)}',
                                    'Total estimated value',
                                  )
                                  .animate()
                                  .fade(delay: 100.ms, duration: 400.ms)
                                  .slideY(begin: 0.1, end: 0),
                              SizedBox(height: 32),
                              _buildSectionHeader(
                                'Stock per Category',
                                'View Report >',
                              ),
                              SizedBox(height: 24),
                              _buildCategoryChart(filteredProducts),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PremiumIconButton(
          icon: Icons.menu_rounded,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        Column(
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _getDate(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 48),
      ].animate(interval: 50.ms).fade().slideY(begin: -0.2, end: 0),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  String _getDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final email = state.userSession?.email ?? 'Guest';
                      final name = email.split('@')[0];
                      final displayName = name.isNotEmpty
                          ? name[0].toUpperCase() + name.substring(1)
                          : 'User';

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              AppSnackBar.showInfo(context, 'Settings coming soon');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Help & Support',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              AppSnackBar.showInfo(context, 'Support coming soon');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            InkWell(
              onTap: () {
                if (actionText.contains('View Report')) {
                  final filter = _selectedFilterNotifier.value;
                  String? timeFilter;
                  if (filter == 'This Month') {
                    timeFilter = 'this_month';
                  } else if (filter == 'This Year') {
                    timeFilter = 'this_year';
                  }
                  context.go('/products', extra: {'timeFilter': timeFilter});
                } else {
                  _showFilterBottomSheet();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      actionText.contains('View Report')
                          ? Icons.chevron_right_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate()
        .fade(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['All Time', 'This Year', 'This Month'].map((f) {
                return ListTile(
                  title: Text(
                    f,
                    style: TextStyle(
                      fontWeight: _selectedFilterNotifier.value == f
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: _selectedFilterNotifier.value == f
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: _selectedFilterNotifier.value == f
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    _selectedFilterNotifier.value = f;
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    bool isAlert,
  ) {
    final color = isAlert
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final bgColor = isAlert
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return PremiumCard(
      height: 140,
      padding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      borderRadius: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              child: CustomPaint(painter: WavePainter(color)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    if (!isAlert)
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: AppTheme.success,
                        size: 12,
                      ),
                    if (!isAlert) SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isAlert
                              ? Theme.of(context).colorScheme.error
                              : AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.5), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.view_in_ar_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideKpiCard(String title, String value, String subtitle) {
    return PremiumCard(
      height: 120,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              child: CustomPaint(
                painter: WavePainter(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 20,
              bottom: 20,
              right: MediaQuery.of(context).size.width > 380 ? 180 : 20,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            color: AppTheme.success,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 380) ...[
            Positioned(
              top: 20,
              right: 130, // Move icon further left to make space for coin
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -10,
              top: -10,
              width: 120,
              child: Image.asset(
                'assets/images/premium_3d_coins.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<Product> products) {
    final Map<String, int> categoryCounts = {};
    for (var p in products) {
      categoryCounts[p.category] = (categoryCounts[p.category] ?? 0) + p.stock;
    }
    if (categoryCounts.isEmpty) return SizedBox.shrink();

    final spots = categoryCounts.entries.toList();
    final maxY =
        (spots
            .map((e) => e.value)
            .fold<int>(0, (max, v) => v > max ? v : max)
            .toDouble()) +
        10;

    return PremiumCard(
          padding: EdgeInsets.all(20),
          height: 320,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) =>
                      Theme.of(context).colorScheme.surface,
                  tooltipPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() >= 0 && value.toInt() < spots.length) {
                        final catName = spots[value.toInt()].key;
                        IconData icon;
                        switch (catName.toLowerCase()) {
                          case 'electronics':
                            icon = Icons.computer_rounded;
                            break;
                          case 'clothing':
                            icon = Icons.checkroom_rounded;
                            break;
                          case 'home':
                            icon = Icons.home_rounded;
                            break;
                          case 'books':
                            icon = Icons.menu_book_rounded;
                            break;
                          case 'beauty':
                            icon = Icons.face_retouching_natural_rounded;
                            break;
                          default:
                            icon = Icons.more_horiz_rounded;
                            break;
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                catName,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Text('');
                    },
                    reservedSize: 60,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  strokeWidth: 1.5,
                  dashArray: [6, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: spots.asMap().entries.map((entry) {
                final yValue = entry.value.value.toDouble();
                return BarChartGroupData(
                  x: entry.key,
                  showingTooltipIndicators: [0],
                  barRods: [
                    BarChartRodData(
                      toY: yValue > 0 ? yValue : 1, // Minimum height
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 28,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        )
        .animate()
        .fade(delay: 300.ms, duration: 500.ms)
        .scale(begin: Offset(0.95, 0.95));
  }
}

class HeroCarousel extends StatefulWidget {
  final VoidCallback? onViewAnalytics;

  const HeroCarousel({super.key, this.onViewAnalytics});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        final nextPage = (_currentIndex.value + 1) % 2; // 2 slides
        _controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              _currentIndex.value = index;
            },
            children: [
              _buildSlide(
                'Inventory\nPerformance',
                'Real-time overview\nof your business',
                'assets/images/premium_dashboard_banner.png',
              ),
              _buildSlide(
                'Revenue\nAnalytics',
                'Track your monthly\nincome and growth',
                'assets/images/premium_3d_coins.png',
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, currentIndex, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).scale(begin: Offset(0.95, 0.95));
  }

  Widget _buildSlide(String title, String subtitle, String imagePath) {
    return Stack(
      children: [
        Positioned(
          right: -10,
          bottom: 10,
          top: 10,
          width: 160,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: widget.onViewAnalytics,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Analytics',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.4,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.45,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.4,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.45,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
