import 'package:flutter/material.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onStatusChange,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.activity.status);
    final priorityColor = _getPriorityColor(widget.activity.priority);
    final isNew = widget.activity.isNew;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: _isHovered ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: statusColor.withOpacity(isNew ? 0.5 : 0.3),
              width: isNew ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Status Icon
                  IconButton(
                    icon: Icon(
                      _getStatusIcon(widget.activity.status),
                      color: statusColor.withOpacity(isNew ? 0.7 : 1.0),
                      size: 20,
                    ),
                    onPressed: isNew ? null : widget.onStatusChange,
                    tooltip: isNew 
                        ? 'Status is fixed to Active for new activities'
                        : 'Change Status',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (isNew) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: statusColor.withOpacity(0.7),
                    ),
                  ],
                  const SizedBox(width: 8),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Priority Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPriorityIcon(widget.activity.priority),
                                    size: 14,
                                    color: priorityColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.activity.priority.toString().split('.').last,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: priorityColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Category
                            Icon(
                              widget.activity.categoryIcon,
                              size: 14,
                              color: widget.activity.categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.activity.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: widget.activity.categoryColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Title
                        Text(
                          widget.activity.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.activity.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.activity.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: widget.onEdit,
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: widget.onDelete,
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Icons.play_circle_outline;
      case ActivityStatus.completed:
        return Icons.check_circle_outline;
      case ActivityStatus.archived:
        return Icons.archive_outlined;
    }
  }

  Color _getPriorityColor(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Colors.green;
      case ActivityPriority.regular:
        return Colors.blue;
      case ActivityPriority.high:
        return Colors.orange;
      case ActivityPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Icons.arrow_downward;
      case ActivityPriority.regular:
        return Icons.remove;
      case ActivityPriority.high:
        return Icons.arrow_upward;
      case ActivityPriority.urgent:
        return Icons.priority_high;
    }
  }
} 