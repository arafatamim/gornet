import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:provider/provider.dart';

class UserSelector extends StatefulWidget {
  final List<User> users;
  final User? currentUser;
  final void Function([User]) onChange;
  final void Function()? onOpen;
  final void Function()? onClose;

  const UserSelector({
    Key? key,
    required this.users,
    required this.currentUser,
    required this.onChange,
    this.onClose,
    this.onOpen,
  }) : super(key: key);

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector>
    with TickerProviderStateMixin {
  bool dropped = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      /* height: 100, */
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          children: [
            RawMaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.currentUser?.username ?? "Select a profile",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: dropped
                        ? const Icon(FeatherIcons.chevronUp)
                        : const Icon(FeatherIcons.chevronDown),
                  ),
                ],
              ),
              onPressed: () {
                if (dropped) {
                  widget.onClose?.call();
                } else {
                  widget.onOpen?.call();
                }
                setState(() {
                  dropped = !dropped;
                });
                /* showUsersDialog(context, widget.users); */
              },
            ),
            const SizedBox(height: 10),
            Focus(
              canRequestFocus: dropped ? true : false,
              child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 350),
                constraints: BoxConstraints(maxHeight: dropped ? 250 : 0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    key: ValueKey(widget.currentUser),
                    children: [
                      ..._buildOptions(),
                      RawMaterialButton(
                        onPressed: () {
                          _showCreateUserDialog();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FeatherIcons.plusCircle),
                            const SizedBox(width: 10),
                            Text(
                              "Add new profile",
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    return widget.users.map((user) {
      return RawMaterialButton(
        onPressed: () {
          Provider.of<UserService>(context, listen: false).setUser(user);
          widget.onChange(user);
          widget.onClose?.call();
          setState(() {
            dropped = false;
          });
        },
        child: Text(
          user.username,
          style: Theme.of(context).textTheme.headline3,
        ),
      );
    }).toList();
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create profile"),
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
              widget.onChange();
            },
          ),
        );
      },
    );
  }
}
