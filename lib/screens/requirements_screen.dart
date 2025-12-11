import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/requirement_provider.dart';
import 'package:psits_nexus_mobile/models/requirement_model.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:intl/intl.dart';

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requirementProvider = Provider.of<RequirementProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await requirementProvider.loadRequirements(authProvider.token!);
    }
    
    setState(() => _isLoading = false);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildRequirementsList(
    List<RequirementModel> requirements,
    RequirementProvider provider,
    String listType, // 'all', 'paid', 'pending', or 'overdue'
  ) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequirements,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
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
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listType == 'all' 
                ? 'You don\'t have any requirements'
                : 'No ${listType} requirements',
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate totals for this list
    final totalAmount = requirements.fold(0.0, (sum, req) => sum + req.amount);
    final paidAmount = requirements
        .where((req) => req.isPaid)
        .fold(0.0, (sum, req) => sum + (req.amountPaid ?? req.amount));

    return RefreshIndicator(
      onRefresh: _loadRequirements,
      child: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listType == 'all' 
                              ? 'Total Requirements'
                              : '${listType[0].toUpperCase()}${listType.substring(1)} Requirements',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onBackground,
                            ),
                          ),
                          if (listType == 'all' && paidAmount > 0)
                            Text(
                              'Paid: \$${paidAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          '${requirements.length} ${requirements.length == 1 ? 'Item' : 'Items'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: listType == 'paid'
                            ? AppTheme.successColor
                            : listType == 'pending'
                                ? AppTheme.warningColor
                                : listType == 'overdue'
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: requirements.length,
              itemBuilder: (context, index) {
                final requirement = requirements[index];
                return _buildRequirementCard(requirement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(RequirementModel requirement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      border: Border.all(
                        color: requirement.isPaid
                            ? AppTheme.successColor.withOpacity(0.3)
                            : requirement.isOverdue
                                ? AppTheme.errorColor.withOpacity(0.3)
                                : AppTheme.warningColor.withOpacity(0.3),
                        width: 1,
                      ),
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
              const SizedBox(height: 12),
              
              // Description
              if (requirement.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    requirement.description,
                    style: TextStyle(
                      color: AppTheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              
              // Amount
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: requirement.isPaid
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      requirement.isPaid 
                          ? Icons.check_circle 
                          : requirement.isOverdue 
                              ? Icons.warning 
                              : Icons.schedule,
                      color: requirement.isPaid
                          ? AppTheme.successColor
                          : requirement.isOverdue
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${requirement.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Deadline
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Deadline',
                value: requirement.formattedDeadline,
                valueColor: requirement.isOverdue 
                    ? AppTheme.errorColor 
                    : requirement.isPaid
                        ? AppTheme.successColor
                        : null,
              ),
              
              // Status details
              if (requirement.isPaid && requirement.paidAt != null)
                _buildDetailRow(
                  icon: Icons.check_circle,
                  label: 'Paid Date',
                  value: _formatDate(requirement.paidAt),
                  valueColor: AppTheme.successColor,
                ),
              
              if (requirement.isPaid && requirement.amountPaid != null)
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: 'Amount Paid',
                  value: '\$${requirement.amountPaid!.toStringAsFixed(2)}',
                  valueColor: AppTheme.successColor,
                ),
              
              if (requirement.isOverdue)
                _buildDetailRow(
                  icon: Icons.warning,
                  label: 'Status',
                  value: 'Overdue by ${requirement.daysUntilDeadline.abs()} days',
                  valueColor: AppTheme.errorColor,
                ),
              
              if (requirement.isPending)
                _buildDetailRow(
                  icon: Icons.schedule,
                  label: 'Due In',
                  value: '${requirement.daysUntilDeadline} days',
                  valueColor: AppTheme.warningColor,
                ),
              
              // Requirement ID
              _buildDetailRow(
                icon: Icons.numbers,
                label: 'Requirement ID',
                value: '#${requirement.id.toString().padLeft(3, '0')}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppTheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requirementProvider = Provider.of<RequirementProvider>(context);

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
            unselectedLabelColor: AppTheme.surfaceColor.withOpacity(0.4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRequirements,
            ),
          ],
        ),
        body: _isLoading || requirementProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  _buildRequirementsList(requirementProvider.requirements, requirementProvider, 'all'),
                  _buildRequirementsList(requirementProvider.paidRequirements, requirementProvider, 'paid'),
                  _buildRequirementsList(requirementProvider.unpaidRequirements, requirementProvider, 'pending'),
                  _buildRequirementsList(requirementProvider.overdueRequirements, requirementProvider, 'overdue'),
                ],
              ),
      ),
    );
  }
}