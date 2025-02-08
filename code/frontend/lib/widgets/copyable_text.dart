import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/style.dart';

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CopyableText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  // Extract sections from the text
  Map<String, String> _extractSections() {
    final Map<String, String> sections = {};
    
    final scheduleMatch = RegExp(r'Current Schedule:(.*?)(?=\n\nChecking for|$)', dotAll: true)
        .firstMatch(text);
    if (scheduleMatch != null) {
      sections['schedule'] = scheduleMatch.group(1)?.trim() ?? '';
    }

    final issuesMatch = RegExp(r'Found operational issues:(.*?)(?=\n\nProposed actions:|$)', dotAll: true)
        .firstMatch(text);
    if (issuesMatch != null) {
      sections['issues'] = issuesMatch.group(1)?.trim() ?? '';
    }

    final actionsMatch = RegExp(r'Proposed actions:(.*?)(?=\n\n|$)', dotAll: true)
        .firstMatch(text);
    if (actionsMatch != null) {
      sections['actions'] = actionsMatch.group(1)?.trim() ?? '';
    }

    return sections;
  }

  void _copySection(BuildContext context, String sectionText) {
    Clipboard.setData(ClipboardData(text: sectionText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Section copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyFullText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Full text copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _extractSections();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Copy options row
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            spacing: 8,
            children: [
              _buildCopyButton(
                context,
                'Copy All',
                Icons.copy_all,
                () => _copyFullText(context),
              ),
              if (sections['schedule']?.isNotEmpty ?? false)
                _buildCopyButton(
                  context,
                  'Schedule',
                  Icons.event,
                  () => _copySection(context, sections['schedule']!),
                ),
              if (sections['issues']?.isNotEmpty ?? false)
                _buildCopyButton(
                  context,
                  'Issues',
                  Icons.warning,
                  () => _copySection(context, sections['issues']!),
                ),
              if (sections['actions']?.isNotEmpty ?? false)
                _buildCopyButton(
                  context,
                  'Actions',
                  Icons.play_arrow,
                  () => _copySection(context, sections['actions']!),
                ),
            ],
          ),
        ),
        // Selectable text with custom style
        SelectableText(
          text,
          style: style ?? TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
