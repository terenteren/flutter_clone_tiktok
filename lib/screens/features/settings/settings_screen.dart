import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/constants/utils.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_Repo.dart';
import 'package:tiktok_clone/screens/features/videos/view_models/playback_config_vm.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            value: ref.watch(playbackConfigProvider).muted,
            onChanged: (value) => {
              ref.read(playbackConfigProvider.notifier).setMuted(value),
            },
            title: const Text('Mute Video'),
            subtitle: const Text('Videos will be muted by default.'),
          ),
          SwitchListTile.adaptive(
            value: ref.watch(playbackConfigProvider).autoplay,
            onChanged: (value) => {
              ref.read(playbackConfigProvider.notifier).setAutoplay(value),
            },
            title: const Text('Autoplay'),
            subtitle: const Text('Video will start playing automatically.'),
          ),
          SwitchListTile.adaptive(
            value: false,
            onChanged: (value) {},
            activeTrackColor: isDark ? Colors.teal : Colors.red.shade200,
            title: const Text('Enable Notifications'),
            secondary: const Icon(Icons.notifications),
            subtitle: const Text('Receive notifications from the app'),
          ),
          CheckboxListTile(
            activeColor: isDark ? Colors.teal : Colors.red,
            value: false,
            onChanged: (value) {},
            title: const Text('Enable Notifications'),
          ),
          ListTile(
            onTap: () async {
              await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1980),
                lastDate: DateTime(2030),
              );
              await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              await showDateRangePicker(
                context: context,
                firstDate: DateTime(1980),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData(
                      appBarTheme: AppBarTheme(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
            },
            title: const Text('What is your birthday?'),
          ),
          ListTile(
            title: Text("Log out (iOS)"),
            textColor: Colors.red,
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text("Are you sure?"),
                  content: Text("Do you want to log out?"),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("No"),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        ref.read(authRepo).signOut();
                        context.go("/");
                      },
                      isDestructiveAction: true,
                      child: Text("Yes"),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text("Log out (Android)"),
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text("Do you want to log out?"),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: FaIcon(FontAwesomeIcons.car),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Yes"),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text("Log out (iOS / Bottom)"),
            textColor: Colors.red,
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: Text("Are you sure?"),
                  message: Text("Do you want to log out?"),
                  actions: [
                    CupertinoActionSheetAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Not log out"),
                    ),
                    CupertinoActionSheetAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Yes plz."),
                    ),
                  ],
                ),
              );
            },
          ),
          AboutListTile(
            applicationVersion: "1.0.0",
            applicationLegalese: "Don't copy me.",
          ),
        ],
      ),
    );
  }
}
