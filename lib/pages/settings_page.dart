import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/scaffold_with_button.dart';
import 'package:goribernetflix/widgets/settings/trakt_selector.dart';
import 'package:goribernetflix/widgets/settings/user_selector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? currentUser;
  late final Future<SharedPreferences> _preferences;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithButton(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Settings"),
      ),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            FutureBuilder2<List<User>>(
              future: Provider.of<UserService>(context).getUsers(),
              builder: (context, result) => result.maybeWhen(
                success: (users) {
                  return UserSelector(
                    users: users,
                    currentUser: currentUser,
                    onChange: ([User? user]) {
                      if (user != null) {
                        setState(() {
                          currentUser = user;
                        });
                      }
                    },
                  );
                },
                error: (error, _stack) {
                  if (currentUser != null) {
                    Provider.of<UserService>(context)
                        .clearUser(currentUser!.id);
                    setState(() {});
                  }
                  return ErrorMessage(error);
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            if (currentUser != null)
              FutureBuilder2<bool>(
                future: Provider.of<UserService>(context)
                    .isTraktActivated(currentUser!.id),
                builder: (context, state) {
                  return state.maybeWhen(
                    success: (activated) {
                      return TraktSelector(
                        activated: activated,
                        userId: currentUser!.id,
                        onChange: () => setState(() {}),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
          ],
        ).toList(),
      ),
    );
  }

  @override
  void initState() {
    _preferences = SharedPreferences.getInstance();
    setUserId();
    super.initState();
  }

  void setUserId() async {
    final instance = await _preferences;
    final userId = instance.getInt("userId");
    if (userId != null) {
      Provider.of<UserService>(context, listen: false)
          .getUserDetails(userId)
          .then((user) {
        setState(() {
          currentUser = user;
        });
      });
    }
  }
}
