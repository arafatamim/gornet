import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      // needed for AndroidTV to be able to select
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: Scaffold(
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: const Text('Trakt'),
                subtitle: const Text('Login to Trakt'),
                onTap: () {},
              ),
              ListTile(
                  title: const Text('RD'),
                  subtitle: const Text('Login to RealDebrid'),
                  onTap: () {}),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
