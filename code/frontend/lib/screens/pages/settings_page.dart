import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../providers/theme_provider.dart';
import '../components/dashboard_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _language = 'English';
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(title: "Settings"),
            const SizedBox(height: defaultPadding),
            _buildSettingsCard(
              title: "General Settings",
              children: [
                _buildSwitchTile(
                  title: "Email Notifications",
                  subtitle: "Receive email notifications",
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                  },
                ),
                _buildSwitchTile(
                  title: "Push Notifications",
                  subtitle: "Receive push notifications",
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                ),
                _buildDropdownTile(
                  title: "Theme Mode",
                  value: themeProvider.themeMode.toString().split('.').last,
                  items: ['light', 'dark', 'system'],
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(
                        ThemeMode.values.firstWhere(
                          (e) => e.toString().split('.').last == value,
                        ),
                      );
                    }
                  },
                ),
                _buildDropdownTile(
                  title: "Language",
                  value: _language,
                  items: ['English', 'Spanish', 'French', 'Arabic'],
                  onChanged: (value) {
                    setState(() => _language = value ?? 'English');
                  },
                ),
                _buildSliderTile(
                  title: "Font Size",
                  value: _fontSize,
                  min: 12.0,
                  max: 20.0,
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            _buildSettingsCard(
              title: "Account Settings",
              children: [
                ListTile(
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implement password change
                  },
                ),
                ListTile(
                  title: const Text("Privacy Settings"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implement privacy settings
                  },
                ),
                ListTile(
                  title: const Text("Export Data"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implement data export
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: ((max - min) * 2).toInt(),
        label: value.toStringAsFixed(1),
        onChanged: onChanged,
      ),
    );
  }
}
