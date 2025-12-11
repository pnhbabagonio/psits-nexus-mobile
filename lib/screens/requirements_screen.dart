import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/requirement_provider.dart';
import 'package:psits_nexus_mobile/models/requirement_model.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requirementProvider = Provider.of<RequirementProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await requirementProvider.loadRequirements(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requirementProvider = Provider.of<RequirementProvider>(context);
    final requirements = requirementProvider.requirements;
    final paidRequirements = requirementProvider.paidRequirements;
    final unpaidRequirements = requirementProvider.unpaidRequirements;
    final overdueRequirements = requirementProvider.overdueRequirements;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requirements'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Paid'),
              Tab(text: 'Pending'),
              Tab(text: 'Overdue'),
            ],
            indicatorColor: AppTheme.secondaryColor,
            labelColor: AppTheme.surfaceColor,
            unselectedLabelColor: AppTheme.surfaceColor.withValues(alpha: 0.4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRequirements,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildRequirementsList(requirements, requirementProvider),
            _buildRequirementsList(paidRequirements, requirementProvider),
            _buildRequirementsList(unpaidRequirements, requirementProvider),
            _buildRequirementsList(overdueRequirements, requirementProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsList(
    List<RequirementModel> requirements,
    RequirementProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequirements,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (requirements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: AppTheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No requirements found',
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequirements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requirements.length,
        itemBuilder: (context, index) {
          final requirement = requirements[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            requirement.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onBackground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: requirement.isPaid
                                ? AppTheme.successColor.withOpacity(0.1)
                                : requirement.isOverdue
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            requirement.calculatedStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: requirement.isPaid
                                  ? AppTheme.successColor
                                  : requirement.isOverdue
                                      ? AppTheme.errorColor
                                      : AppTheme.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (requirement.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          requirement.description,
                          style: TextStyle(
                            color: AppTheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: AppTheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Amount: \$${requirement.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${requirement.formattedDeadline}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (requirement.paidAt != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Paid on: ${requirement.paidAt!.day}/${requirement.paidAt!.month}/${requirement.paidAt!.year}',
                                style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (requirement.isOverdue)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.warning,
                                size: 16,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Overdue by ${requirement.daysUntilDeadline.abs()} days',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (requirement.isPending && !requirement.isOverdue)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: AppTheme.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due in ${requirement.daysUntilDeadline} days',
                                style: TextStyle(
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}