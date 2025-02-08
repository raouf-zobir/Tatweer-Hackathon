import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../components/page_title.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                PageTitle(
                  title: "Settings",
                  subtitle: "Customize your application preferences",
                  icon: Icons.settings_outlined,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.restore),
                      tooltip: 'Reset to Default',
                      onPressed: () {
                        // Reset settings functionality
                      },
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.dark_mode,
                        title: "Dark Mode",
                        subtitle: "Toggle dark/light theme",
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        ),
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Manage notification preferences",
                        trailing: Icon(Icons.chevron_right),
                      ),
                      _buildSettingItem(
                        icon: Icons.language,
                        title: "Language",
                        subtitle: "Change application language",
                        trailing: Icon(Icons.chevron_right),
                      ),
                      _buildSettingItem(
                        icon: Icons.security,
                        title: "Security",
                        subtitle: "Configure security settings",
                        trailing: Icon(Icons.chevron_right),
                      ),
                      _buildSettingItem(
                        icon: Icons.person,
                        title: "Account",
                        subtitle: "Manage your account",
                        trailing: Icon(Icons.chevron_right),
                      ),
                      _buildSettingItem(
                        icon: Icons.backup,
                        title: "Backup",
                        subtitle: "Configure backup settings",
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
