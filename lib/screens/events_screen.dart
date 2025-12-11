import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/event_provider.dart';
import 'package:psits_nexus_mobile/models/event_model.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await eventProvider.loadEvents(authProvider.token!);
    }
  }

  Future<void> _handleRegistration(BuildContext context, EventModel event) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.token == null) return;

    if (event.isRegistered) {
      // Cancel registration
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Registration'),
          content: Text('Are you sure you want to cancel your registration for "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final result = await eventProvider.cancelEventRegistration(
          authProvider.token!,
          event.id,
        );

        if (result['success'] == true) {
          _showSnackBar(context, 'Registration cancelled successfully', true);
        } else {
          _showSnackBar(context, result['message'], false);
        }
      }
    } else {
      // Register for event
      if (event.isFull) {
        _showSnackBar(context, 'This event is already full', false);
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Register for Event'),
          content: Text('Register for "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Register'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final result = await eventProvider.registerForEvent(
          authProvider.token!,
          event.id,
        );

        if (result['success'] == true) {
          _showSnackBar(context, 'Successfully registered for event', true);
        } else {
          _showSnackBar(context, result['message'], false);
        }
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final upcomingEvents = eventProvider.upcomingEvents;
    final ongoingEvents = eventProvider.ongoingEvents;
    final pastEvents = eventProvider.pastEvents;

    return DefaultTabController(
      length: 3, // Changed from 2 to 3
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Past'),
            ],
            indicatorColor: AppTheme.secondaryColor,
            labelColor: AppTheme.surfaceColor,
            unselectedLabelColor: AppTheme.surfaceColor.withValues(alpha: 0.4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEvents,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildEventsList(upcomingEvents, eventProvider),
            _buildEventsList(ongoingEvents, eventProvider),
            _buildEventsList(pastEvents, eventProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(
    List<EventModel> events,
    EventProvider provider,
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
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: 64,
              color: AppTheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(
                color: AppTheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
                            event.title,
                            style: const TextStyle(
                              fontSize: 18,
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
                            color: _getEventColor(event.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getEventColor(event.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Registration status badge
                    if (event.isRegistered)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'REGISTERED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                            if (event.registeredAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Registered on ${_formatDate(event.registeredAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    
                    if (event.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          event.description,
                          style: TextStyle(
                            color: AppTheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    
                    // Event details
                    _buildEventDetailRow(
                      Icons.calendar_today,
                      'Date: ${event.formattedDate}',
                    ),
                    const SizedBox(height: 8),
                    _buildEventDetailRow(
                      Icons.access_time,
                      'Time: ${event.time}',
                    ),
                    const SizedBox(height: 8),
                    _buildEventDetailRow(
                      Icons.location_on,
                      'Location: ${event.location}',
                    ),
                    
                    if (event.category.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildEventDetailRow(
                            _getEventIcon(event.category),
                            'Category: ${event.category}',
                          ),
                        ],
                      ),
                    
                    if (event.capacity != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: AppTheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Capacity: ${event.registered ?? '0'}/${event.capacity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: event.isFull
                                      ? AppTheme.errorColor
                                      : AppTheme.onBackground,
                                ),
                              ),
                              if (event.isFull)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'FULL',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    
                    // Registration/Cancellation button
                    const SizedBox(height: 16),
                    if (event.status.toLowerCase() == 'upcoming' || 
                        event.status.toLowerCase() == 'ongoing')
                      _buildRegistrationButton(context, event, provider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationButton(BuildContext context, EventModel event, EventProvider provider) {
    if (provider.isRegistering) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (event.isRegistered) {
      // Show cancel button if event is in future
      if (event.canCancelRegistration) {
        return ElevatedButton.icon(
          onPressed: () => _handleRegistration(context, event),
          icon: const Icon(Icons.cancel, size: 20),
          label: const Text('Cancel Registration'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
            foregroundColor: AppTheme.errorColor,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            event.status.toLowerCase() == 'ongoing' 
                ? 'Event is ongoing - registration closed'
                : 'Registration cannot be cancelled (event has passed)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        );
      }
    } else {
      // Show register button if event is not full and not past
      if (event.canRegister) {
        return ElevatedButton.icon(
          onPressed: () => _handleRegistration(context, event),
          icon: const Icon(Icons.event_available, size: 20),
          label: const Text('Register Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      } else if (event.isFull) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Event is full',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Registration closed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getEventColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'ongoing':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.onSurface.withValues(alpha: 0.5);
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getEventIcon(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return Icons.workspaces_outlined;
      case 'seminar':
        return Icons.speaker_notes_outlined;
      case 'meeting':
        return Icons.groups_outlined;
      case 'social':
        return Icons.celebration_outlined;
      default:
        return Icons.event_outlined;
    }
  }
}