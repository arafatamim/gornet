import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/widgets/buttons/animated_icon_button.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/scaffold_with_button.dart';
import 'package:goribernetflix/widgets/settings/user_selector.dart';
import 'package:goribernetflix/widgets/wave_widget.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  User? currentUser;

  void _setUser() async {
    Provider.of<UserService>(context, listen: false)
        .getCurrentUser()
        .then((user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  void initState() {
    _setUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithButton(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.primary,
            ],
            radius: 2,
            center: const Alignment(0, 1),
          ),
        ),
        child: Stack(
          children: [
            WaveWidget(
              size: MediaQuery.of(context).size,
              yOffset: 300,
              color: Colors.grey.shade900,
            ),
            Column(
              children: [
                const SizedBox(height: 64),
                Text(
                  "Who's watching?",
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: Colors.grey.shade300),
                ),
                const SizedBox(height: 16),
                FutureBuilder2<List<User>>(
                  future: Provider.of<UserService>(context).getUsers(),
                  builder: (context, state) => state.maybeWhen(
                    success: (users) => UserSelector(
                      users: users,
                      currentUser: currentUser,
                      onChange: ([User? user]) async {
                        if (user != null) {
                          setState(() {
                            currentUser = user;
                          });
                          await Future.delayed(const Duration(seconds: 1));

                          Navigator.of(context).pushReplacementNamed("/home");
                        }
                      },
                    ),
                    orElse: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => ErrorMessage(error),
                  ),
                ),
                const Spacer(),
                AnimatedIconButton(
                  autofocus: true,
                  icon: const Icon(FeatherIcons.arrowRight),
                  label: Text(
                    "Let's go!",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/home");
                  },
                ),
                const SizedBox(height: 64)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
