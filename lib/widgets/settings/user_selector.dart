import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:provider/provider.dart';

class UserSelector extends StatelessWidget {
  final List<User> users;
  final User? currentUser;
  final void Function([User]) onChange;

  const UserSelector({
    Key? key,
    required this.users,
    required this.currentUser,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentUser?.username ?? "Select a user",
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(width: 10),
            const Icon(FeatherIcons.chevronDown)
          ],
        ),
        onTap: () => showUsersDialog(context, users),
      ),
    );
  }

  void showUsersDialog(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            for (final user in users)
              ListTile(
                title: Text(user.username),
                onTap: () {
                  Provider.of<UserService>(context, listen: false)
                      .setUser(user.id);
                  onChange(user);
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
                          Navigator.of(context)
                            ..pop()
                            ..pop();
                          onChange();
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
