import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'package:intl/intl.dart';

class OperationalStatusCard extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  final List<Map<String, dynamic>> issues;
  final List<Map<String, dynamic>> proposedActions;

  const OperationalStatusCard({
    Key? key,
    required this.schedule,
    required this.issues,
    required this.proposedActions,
  }) : super(key: key);

  @override
  State<OperationalStatusCard> createState() => _OperationalStatusCardState();
}

class _OperationalStatusCardState extends State<OperationalStatusCard> {
  bool _isScheduleExpanded = true;
  bool _isIssuesExpanded = true;
  bool _isActionsExpanded = true;  // Add this line

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr.split(' (ID:')[0]);
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildScheduleSection() {
    return _buildExpandableSection(
      title: 'Schedule',
      icon: Icons.calendar_today,
      isExpanded: _isScheduleExpanded,
      onToggle: () => setState(() => _isScheduleExpanded = !_isScheduleExpanded),
      content: widget.schedule.isEmpty
          ? Center(child: Text('No scheduled events'))
          : Column(
              children: widget.schedule.map((event) => _buildEventTile(event)).toList(),
            ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    final time = _formatDateTime(event['time'] ?? '');
    final hasIssue = widget.issues.any(
      (issue) => issue['id'] == event['id']
    );

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasIssue ? Colors.red.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasIssue ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: hasIssue ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Explicitly set text color
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasIssue)
            Tooltip(
              message: 'Has Issues',
              child: Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildIssuesSection() {
    return _buildExpandableSection(
      title: 'Operational Issues',
      icon: Icons.warning_amber_rounded,
      isExpanded: _isIssuesExpanded,
      onToggle: () => setState(() => _isIssuesExpanded = !_isIssuesExpanded),
      content: widget.issues.isEmpty
          ? Center(child: Text('No current issues'))
          : Column(
              children: widget.issues.map((issue) => _buildIssueTile(issue)).toList(),
            ),
    );
  }

  Widget _buildIssueTile(Map<String, dynamic> issue) {
    final affectedOps = issue['affected_operations'] as List? ?? [];
    final actions = widget.proposedActions
        .where((action) => action['related_issue'] == issue['id'])
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${issue['type']}: ${issue['details']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (affectedOps.isNotEmpty) ...[
            Divider(height: 16),
            Text(
              'Affected Operations:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: affectedOps.map((op) => _buildOperationChip(op)).toList(),
            ),
          ],
          if (actions.isNotEmpty) ...[
          ],
        ],
      ),
    );
  }

  Widget _buildOperationChip(String operation) {
    return Chip(
      label: Text(
        operation,
        style: TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.orange.withOpacity(0.3)),
    );
  }



  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: defaultPadding),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: primaryColor),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: primaryColor,
              ),
              onPressed: onToggle,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: content,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Operational Status",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: defaultPadding),
          _buildScheduleSection(),
          _buildIssuesSection(),
        ],
      ),
    );
  }
}
