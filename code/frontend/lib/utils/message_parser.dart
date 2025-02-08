import 'dart:convert';

class MessageParser {
  static Map<String, List<Map<String, dynamic>>> parseStartupMessage(String message) {
    final Map<String, List<Map<String, dynamic>>> result = {
      'schedule': [],
      'issues': [],
      'actions': [],
    };

    try {
      // Parse schedule events
      if (message.contains("Current Schedule:")) {
        final scheduleSection = _extractSection(message, "Current Schedule:", "Checking for operational issues");
        result['schedule'] = _parseScheduleEvents(scheduleSection);
      }

      // Parse issues
      if (message.contains("Found operational issues:")) {
        final issuesSection = _extractSection(message, "Found operational issues:", "I'm ready");
        final List<Map<String, dynamic>> issues = [];
        
        // Split into individual issue blocks
        final issueBlocks = issuesSection.split(RegExp(r'\n(?=- \w+ issue:)'));
        
        for (var block in issueBlocks) {
          if (block.trim().isEmpty) continue;
          
          final issue = _parseIssueBlock(block);
          if (issue != null) {
            issues.add(issue);
          }
        }
        
        result['issues'] = issues;
      }

      // Parse changes from JSON part
      final changesMatch = RegExp(r"'changes':\s*(\[.*?\])", dotAll: true).firstMatch(message);
      if (changesMatch != null) {
        try {
          final changesJson = changesMatch.group(1)!
              .replaceAll("'", '"')
              .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');
          
          final List<dynamic> changes = json.decode(changesJson);
          result['actions']?.addAll(
            changes.map((c) {
              final change = c as Map<String, dynamic>;
              return {
                ...change,
                'type': 'change',
                'description': 'Delay by ${change['delay_hours']} hours',
              };
            }).toList(),
          );
        } catch (e) {
          print('Error parsing changes JSON: $e');
        }
      }
    } catch (e) {
      print('Error parsing startup message: $e');
    }

    return result;
  }

  static List<Map<String, dynamic>> _parseScheduleEvents(String scheduleSection) {
    final events = <Map<String, dynamic>>[];
    final eventPattern = RegExp(r'- (.*?):\s*(.*?)\s*\(ID:\s*(.*?)\)');
    
    for (var line in scheduleSection.split('\n')) {
      final match = eventPattern.firstMatch(line);
      if (match != null) {
        events.add({
          'time': match.group(1)?.trim() ?? '',
          'title': match.group(2)?.trim() ?? '',
          'id': match.group(3)?.trim() ?? '',
        });
      }
    }
    
    return events;
  }

  static Map<String, dynamic>? _parseIssueBlock(String block) {
    if (block.trim().isEmpty) return null;

    final typeMatch = RegExp(r'- (\w+) issue: (.+?)(?=\n|$)').firstMatch(block);
    if (typeMatch == null) return null;

    final idMatch = RegExp(r'Impact Analysis for ([^:]+):').firstMatch(block);
    final statusMatch = RegExp(r'Primary Issue: (\w+) at').firstMatch(block);
    
    final affectedOps = <String>[];
    final operationsRegex = RegExp(r'\* ([^\n]+)');
    for (var match in operationsRegex.allMatches(block)) {
      affectedOps.add(match.group(1)?.trim() ?? '');
    }

    final issueId = idMatch?.group(1)?.trim() ?? '';
    return {
      'id': issueId,
      'type': typeMatch.group(1)?.toLowerCase() ?? '',
      'details': typeMatch.group(2)?.trim() ?? '',
      'status': statusMatch?.group(1)?.toLowerCase() ?? 'unknown',
      'affected_operations': affectedOps,
    };
  }

  static String _extractSection(String message, String startMarker, String endMarker) {
    final startIndex = message.indexOf(startMarker);
    if (startIndex == -1) return '';
    
    final endIndex = message.indexOf(endMarker, startIndex + startMarker.length);
    return endIndex == -1 
        ? message.substring(startIndex + startMarker.length).trim()
        : message.substring(startIndex + startMarker.length, endIndex).trim();
  }
}
