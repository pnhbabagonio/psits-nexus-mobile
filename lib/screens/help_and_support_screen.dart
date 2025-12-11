// screens/help_and_support_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/support_ticket_provider.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:psits_nexus_mobile/models/support_ticket_model.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'technical';
  String _selectedPriority = 'medium';

  final List<Map<String, String>> categories = [
    {'value': 'technical', 'label': 'Technical Issue'},
    {'value': 'billing', 'label': 'Billing/Payment'},
    {'value': 'account', 'label': 'Account Issue'},
    {'value': 'feature', 'label': 'Feature Request'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> priorities = [
    {'value': 'low', 'label': 'Low'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'high', 'label': 'High'},
    {'value': 'urgent', 'label': 'Urgent'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<SupportTicketProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await ticketProvider.loadTickets(authProvider.token!);
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<SupportTicketProvider>(context, listen: false);
    
    if (authProvider.token == null) return;

    final result = await ticketProvider.createTicket(
      token: authProvider.token!,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
    );

    if (result['success'] == true) {
      // Clear form
      _subjectController.clear();
      _messageController.clear();
      _selectedCategory = 'technical';
      _selectedPriority = 'medium';
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Support ticket submitted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit ticket: ${result['message']}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<SupportTicketProvider>(context);
    final openTickets = ticketProvider.openTickets;
    final inProgressTickets = ticketProvider.inProgressTickets;
    final resolvedTickets = ticketProvider.resolvedTickets;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help & Support'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'New Ticket'),
              Tab(text: 'Open'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
            ],
            indicatorColor: AppTheme.secondaryColor,
            labelColor: AppTheme.surfaceColor,
            unselectedLabelColor: AppTheme.surfaceColor.withOpacity(0.4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTickets,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // New Ticket Tab
            _buildNewTicketForm(ticketProvider),
            // Open Tickets Tab
            _buildTicketsList(openTickets, ticketProvider, 'Open'),
            // In Progress Tickets Tab
            _buildTicketsList(inProgressTickets, ticketProvider, 'In Progress'),
            // Resolved Tickets Tab
            _buildTicketsList(resolvedTickets, ticketProvider, 'Resolved'),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTicketForm(SupportTicketProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a New Support Ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe your issue and we\'ll get back to you as soon as possible.',
              style: TextStyle(
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            
            // Subject
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'Brief description of your issue',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                if (value.length < 10) {
                  return 'Subject must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['value'],
                  child: Text(category['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority['value'],
                  child: Text(priority['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a priority';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue in detail...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                if (value.length < 20) {
                  return 'Message must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isSubmitting ? null : _submitTicket,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(provider.isSubmitting ? 'Submitting...' : 'Submit Ticket'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Help Tips
            const Text(
              'Tips for Getting Help Faster:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            _buildHelpTip(
              icon: Icons.description,
              text: 'Be specific about your issue',
            ),
            _buildHelpTip(
              icon: Icons.screenshot,
              text: 'Include screenshots if possible',
            ),
            _buildHelpTip(
              icon: Icons.error,
              text: 'Mention error messages if any',
            ),
            _buildHelpTip(
              icon: Icons.access_time,
              text: 'Response time is usually within 24 hours',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTip({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(
    List<SupportTicket> tickets,
    SupportTicketProvider provider,
    String status,
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
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: AppTheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No $status tickets',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Text(
              status == 'Open' 
                ? 'All your support requests have been addressed'
                : 'You don\'t have any $status tickets',
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _buildTicketCard(ticket);
        },
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    ticket.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ticket.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ticket.statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ticket.statusIcon,
                        size: 12,
                        color: ticket.statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ticket.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ticket.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ticket.priorityIcon,
                        size: 12,
                        color: ticket.priorityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ticket.priorityColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Created: ${ticket.formattedCreatedAt}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
            if (ticket.updatedAt != ticket.createdAt)
              Text(
                'Updated: ${ticket.formattedUpdatedAt}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}