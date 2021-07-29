import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Models/user.dart';
import 'package:goribernetflix/Services/user.dart';
import 'package:goribernetflix/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? userId;
  late final Future<SharedPreferences> _preferences;

  @override
  void initState() {
    _preferences = SharedPreferences.getInstance();
    getUserId();
    super.initState();
  }

  void getUserId() async {
    final instance = await _preferences;
    userId = instance.getInt("userId");
  }

  _setUser(int id) async {
    final instance = await _preferences;
    instance.setInt("userId", id);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      // needed for AndroidTV to be able to select
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              FutureBuilder<List<User>>(
                future: Provider.of<UserService>(context).getUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        final users = snapshot.data!;
                        if (userId != null) {
                          final currentUser =
                              users.firstWhere((u) => u.id == userId);

                          return ListTile(
                            title: const Text("Choose user"),
                            subtitle: Text(currentUser.username),
                            onTap: () => _showUsersDialog(context, users),
                          );
                        } else {
                          return ListTile(
                            title: const Text("Choose user"),
                            subtitle: const Text("No user chosen"),
                            onTap: () {
                              _showUsersDialog(context, users);
                            },
                          );
                        }
                      } else {
                        return buildErrorBox(snapshot.error);
                      }
                    default:
                      return const LinearProgressIndicator();
                  }
                },
              )
              // ListTile(
              //   title: const Text('Trakt'),
              //   subtitle: const Text('Login to Trakt'),
              //   onTap: () {},
              // ),
              // ListTile(
              //     title: const Text('RD'),
              //     subtitle: const Text('Login to RealDebrid'),
              //     onTap: () {}),
            ],
          ).toList(),
        ),
      ),
    );
  }

  void _showUsersDialog(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            for (final user in users)
              ListTile(
                title: Text(user.username),
                onTap: () {
                  _setUser(user.id);
                  setState(() {
                    userId = user.id;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              title: Row(children: [
                const Icon(FeatherIcons.plusCircle),
                const SizedBox(width: 10),
                const Text("Add new user")
              ]),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Create user"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        )
                      ],
                      content: TextField(
                        autofocus: true,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) async {
                          try {
                            await Provider.of<UserService>(
                              context,
                              listen: false,
                            ).createUser(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User has been created"),
                              ),
                            );
                          } on ServerError {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "There was an error creating user",
                                ),
                              ),
                            );
                          }
                          Navigator.of(context)..pop()..pop();
                          setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const ListTile(
              title: Text(
                "To remove a user, contact administrator.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        );
      },
    );
  }
}
