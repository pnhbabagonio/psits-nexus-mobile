import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/member_provider.dart';
import 'package:psits_nexus_mobile/providers/event_provider.dart';
import 'package:psits_nexus_mobile/providers/payment_provider.dart';
import 'package:psits_nexus_mobile/providers/requirement_provider.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:psits_nexus_mobile/widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.token == null) {
      setState(() => _isInitialLoading = false);
      return;
    }

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final requirementProvider = Provider.of<RequirementProvider>(context, listen: false);

    try {
      // Load all data in parallel
      await Future.wait([
        memberProvider.loadProfile(authProvider.token!),
        memberProvider.loadDashboard(authProvider.token!),
        eventProvider.loadEvents(authProvider.token!),
        paymentProvider.loadPayments(authProvider.token!),
        requirementProvider.loadRequirements(authProvider.token!),
      ]);
    } catch (e) {
      // Handle error
      print('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final requirementProvider = Provider.of<RequirementProvider>(context);
    
    final user = authProvider.user;
    final upcomingEvents = eventProvider.upcomingEvents;
    final pendingPayments = paymentProvider.pendingPayments;
    final unpaidRequirements = requirementProvider.unpaidRequirements;
    final dashboardData = memberProvider.dashboardData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isInitialLoading || memberProvider.isDashboardLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Use dashboard data if available, otherwise fallback to provider counts
    final upcomingEventsCount = dashboardData?.upcomingEvents ?? upcomingEvents.length;
    final pendingPaymentsCount = dashboardData?.pendingPayments ?? pendingPayments.length;
    final memberSince = dashboardData?.memberSince ?? '';
    final totalPaid = paymentProvider.totalPaid;

    // Get student ID from either auth provider or member provider
    final studentId = user?['student_id'] ?? memberProvider.profile?.studentId;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryDark,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          user?['name']?.substring(0, 1).toUpperCase() ?? 
                          memberProvider.profile?.firstName?.substring(0, 1).toUpperCase() ?? 'M',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?['name']?.split(' ').first ?? 
                              memberProvider.profile?.firstName ?? 'Member',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // Show student ID if available
                            if (studentId != null)
                              Text(
                                studentId,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.school,
                        text: user?['program'] ?? 
                             memberProvider.profile?.program ?? 'Student',
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      if (memberSince.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.person_add,
                          text: memberSince,
                          color: Colors.black,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final stats = [
                    {
                      'title': 'Upcoming Events',
                      'value': upcomingEventsCount.toString(),
                      'icon': Icons.event,
                      'color': AppTheme.secondaryColor,
                    },
                    {
                      'title': 'Pending Payments',
                      'value': pendingPaymentsCount.toString(),
                      'icon': Icons.pending_actions,
                      'color': AppTheme.warningColor,
                    },
                    {
                      'title': 'Requirements Due',
                      'value': unpaidRequirements.length.toString(),
                      'icon': Icons.assignment,
                      'color': AppTheme.errorColor,
                    },
                    {
                      'title': 'Total Paid',
                      'value': 'P${totalPaid.toStringAsFixed(2)}',
                      'icon': Icons.attach_money,
                      'color': AppTheme.successColor,
                    },
                  ];
                  
                  final stat = stats[index];
                  return DashboardCard(
                    title: stat['title']! as String,
                    value: stat['value']! as String,
                    icon: stat['icon'] as IconData,
                    color: stat['color'] as Color,
                  );
                },
                childCount: 4,
              ),
            ),
          ),

          // Recent Payment if available
          if (dashboardData?.recentPayment != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payment,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recent Payment',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                            ),
                          ),
                          title: Text(
                            dashboardData!.recentPayment!.requirement,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Amount: P${dashboardData.recentPayment!.amount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Date: ${dashboardData.recentPayment!.date}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
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
                ),
              ),
            ),

          // Upcoming Events Section
          if (upcomingEvents.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to events
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

          if (upcomingEvents.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = upcomingEvents[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.event,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              event.description.length > 60
                                  ? '${event.description.substring(0, 60)}...'
                                  : event.description,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onTap: () {
                          // Navigate to event details
                        },
                      ),
                    );
                  },
                  childCount: upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
                ),
              ),
            ),

          // Requirements Section
          if (unpaidRequirements.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pending Requirements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to requirements
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

          if (unpaidRequirements.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final requirement = unpaidRequirements[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: requirement.isOverdue
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            requirement.isOverdue
                                ? Icons.warning
                                : Icons.assignment,
                            color: requirement.isOverdue
                                ? AppTheme.errorColor
                                : AppTheme.warningColor,
                          ),
                        ),
                        title: Text(
                          requirement.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '\$${requirement.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppTheme.onSurface.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Due: ${requirement.formattedDeadline}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: requirement.isOverdue
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            requirement.isOverdue
                                ? 'OVERDUE'
                                : '${requirement.daysUntilDeadline}d',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: requirement.isOverdue
                                  ? AppTheme.errorColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigate to requirement details
                        },
                      ),
                    );
                  },
                  childCount: unpaidRequirements.length > 2 ? 2 : unpaidRequirements.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
    );
  }
}