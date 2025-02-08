class MessageParser {
  static Map<String, List<Map<String, dynamic>>> parseStartupMessage(String message) {
    final Map<String, List<Map<String, dynamic>>> result = {
      'schedule': [],
      'issues': [],
      'actions': [],
    };

    try {
      // Extract all sections using flexible markers
      final sections = _extractSections(message);
      
      if (sections['schedule'] != null) {
        result['schedule'] = _parseSchedule(sections['schedule']!);
      }
      
      if (sections['issues'] != null) {
        result['issues'] = _parseIssues(sections['issues']!);
        
        // Parse actions within each issue block
        final issueActions = _parseActionsFromIssues(sections['issues']!);
        if (issueActions.isNotEmpty) {
          result['actions'] = issueActions;
        }
      }
      
      if (sections['actions'] != null) {
        // Merge with existing actions if any
        result['actions']?.addAll(_parseGeneralActions(sections['actions']!));
      }

    } catch (e) {
      print('Error parsing message: $e');
    }

    return result;
  }

  static Map<String, String> _extractSections(String message) {
    final Map<String, String> sections = {};
    final sectionMarkers = {
      'schedule': [
        'Current Schedule:',
        'Upcoming events:',
        'Schedule Overview:',
        'Today\'s Schedule:',
      ],
      'issues': [
        'Found operational issues:',
        'Detected Issues:',
        'Current Problems:',
        'System Issues:',
      ],
      'actions': [
        'Proposed actions:',
        'Recommended Actions:',
        'Action Items:',
        'Required Actions:',
      ],
    };

    for (var entry in sectionMarkers.entries) {
      for (var marker in entry.value) {
        final startIndex = message.indexOf(marker);
        if (startIndex != -1) {
          var endIndex = message.length;
          
          // Find the start of the next section
          for (var otherMarkers in sectionMarkers.values) {
            for (var otherMarker in otherMarkers) {
              if (otherMarker != marker) {
                final nextIndex = message.indexOf(otherMarker, startIndex + marker.length);
                if (nextIndex != -1 && nextIndex < endIndex) {
                  endIndex = nextIndex;
                }
              }
            }
          }
          
          sections[entry.key] = message.substring(startIndex, endIndex).trim();
          break;
        }
      }
    }

    return sections;
  }

  static List<Map<String, dynamic>> _parseSchedule(String scheduleSection) {
    final events = <Map<String, dynamic>>[];
    final lines = scheduleSection.split('\n');
    
    // Different date-time patterns to match
    final patterns = [
      RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}):\s*(.+?)(?:\s*\(ID:\s*(.*?)\))?$'),
      RegExp(r'(\d{2}:\d{2})\s*[-:]\s*(.+?)(?:\s*\(ID:\s*(.*?)\))?$'),
      RegExp(r'(\d{1,2}/\d{1,2}/\d{4}\s+\d{2}:\d{2})\s*[-:]\s*(.+?)(?:\s*\(ID:\s*(.*?)\))?$'),
    ];

    for (var line in lines) {
      if (line.trim().startsWith('-') || line.contains(':')) {
        line = line.replaceFirst('-', '').trim();
        
        for (var pattern in patterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            events.add({
              'time': match.group(1)?.trim() ?? '',
              'title': match.group(2)?.trim() ?? '',
              'id': match.group(3)?.trim() ?? '',
              'status': 'normal',
            });
            break;
          }
        }
      }
    }

    return events;
  }

  static List<Map<String, dynamic>> _parseIssues(String issuesSection) {
    final issues = <Map<String, dynamic>>[];
    final issueBlocks = issuesSection.split(RegExp(r'\n(?=-|\*)\s*'));
    
    for (var block in issueBlocks) {
      if (block.trim().isEmpty) continue;

      final Map<String, dynamic> issue = {};
      final lines = block.split('\n');
      
      // Parse issue header with flexible patterns
      final headerPatterns = [
        RegExp(r'(?:-)?\s*(.*?)\s+issue:\s*(.+)'),
        RegExp(r'(?:-)?\s*Issue:\s*(.*?)\s+at\s+(.+)'),
        RegExp(r'(?:-)?\s*(Problem|Error|Warning):\s*(.+)'),
      ];

      for (var pattern in headerPatterns) {
        final match = pattern.firstMatch(lines[0]);
        if (match != null) {
          issue['type'] = match.group(1)?.trim() ?? 'Unknown';
          issue['details'] = match.group(2)?.trim() ?? '';
          break;
        }
      }

      // Extract ID if present
      final idMatch = RegExp(r'(?:ID:|Reference):\s*([A-Z0-9_-]+)').firstMatch(block);
      issue['id'] = idMatch?.group(1) ?? '';

      // Parse affected operations
      final affectedOps = <String>[];
      var inAffectedSection = false;
      
      for (var line in lines) {
        if (line.contains('Affected Operations:')) {
          inAffectedSection = true;
          continue;
        }
        if (inAffectedSection && line.trim().startsWith('*')) {
          affectedOps.add(line.trim().substring(1).trim());
        }
      }
      
      issue['affected_operations'] = affectedOps;
      issues.add(issue);
    }

    return issues;
  }

  static List<Map<String, dynamic>> _parseActionsFromIssues(String issuesSection) {
    final actions = <Map<String, dynamic>>[];
    final issueBlocks = issuesSection.split(RegExp(r'\n(?=-)\s*'));
    
    for (var block in issueBlocks) {
      var currentIssueId = '';
      final idMatch = RegExp(r'(?:ID:|Reference):\s*([A-Z0-9_-]+)').firstMatch(block);
      if (idMatch != null) {
        currentIssueId = idMatch.group(1) ?? '';
      }

      // Find actions section within the issue block
      final actionLines = block
          .split('\n')
          .where((line) => 
              line.trim().startsWith('-') && 
              !line.contains('issue:') &&
              (line.contains('schedule') || 
               line.contains('update') || 
               line.contains('notify')))
          .toList();

      for (var line in actionLines) {
        actions.add({
          'description': line.substring(line.indexOf('-') + 1).trim(),
          'related_issue': currentIssueId,
          'priority': _determineActionPriority(line),
        });
      }
    }

    return actions;
  }

  static List<Map<String, dynamic>> _parseGeneralActions(String actionsSection) {
    final actions = <Map<String, dynamic>>[];
    final lines = actionsSection.split('\n');
    
    for (var line in lines) {
      if (line.trim().startsWith('-')) {
        final action = line.substring(line.indexOf('-') + 1).trim();
        if (action.isNotEmpty) {
          actions.add({
            'description': action,
            'related_issue': '',
            'priority': _determineActionPriority(action),
          });
        }
      }
    }

    return actions;
  }

  static String _determineActionPriority(String action) {
    final lowercaseAction = action.toLowerCase();
    if (lowercaseAction.contains('immediately') || 
        lowercaseAction.contains('urgent') ||
        lowercaseAction.contains('critical')) {
      return 'high';
    }
    if (lowercaseAction.contains('soon') || 
        lowercaseAction.contains('when possible')) {
      return 'medium';
    }
    return 'normal';
  }
}
