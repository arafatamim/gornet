import 'package:async/async.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/trakt_code.dart';
import 'package:goribernetflix/models/trakt_token.dart';
import 'package:goribernetflix/services/trakt.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:provider/provider.dart';

class TraktSelector extends StatelessWidget {
  final bool activated;
  final int userId;
  final void Function() onChange;

  TraktSelector({
    Key? key,
    required this.activated,
    required this.userId,
    required this.onChange,
  }) : super(key: key);

  late final CancelableCompleter<TraktToken> tokenOperation;
  final traktIcon = Image.asset("assets/trakt-icon-red-white.png");

  void pollToken(BuildContext context, TraktCode code) {
    tokenOperation = Provider.of<TraktService>(
      context,
      listen: false,
    ).fetchToken(code);

    // Save token on receive
    tokenOperation.operation.value.then((token) async {
      Navigator.of(context).pop();
      await Provider.of<UserService>(context, listen: false).saveTraktToken(
        userId,
        token,
      );
      onChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (activated) {
      return ListTile(
        title: const Text("Trakt account is connected"),
        subtitle: const Text("Tap to logout"),
        onTap: () async {
          await Provider.of<UserService>(context, listen: false)
              .deleteTraktToken(userId);
          onChange();
        },
        leading: const Icon(FeatherIcons.userCheck),
      );
    } else {
      return ListTile(
        title: const Text("Connect your Trakt account"),
        subtitle: const Text(
          "To keep track of watched media, view watchlist, and more",
        ),
        leading: traktIcon,
        onTap: () => _startTraktAuth(context),
      );
    }
  }

  Future<void> _startTraktAuth(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder2<TraktCode>(
            future: Provider.of<TraktService>(context).generateDeviceCodes(),
            builder: (context, state) {
              return state.where(
                onSuccess: (code) {
                  pollToken(context, code);

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Go to"),
                          Text(
                            code.verificationUrl,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const Text("on your phone and enter the code below:"),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            code.userCode,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 10),
                          const LinearProgressIndicator()
                        ],
                      ),
                    ),
                  );
                },
                onError: (error, stackTrace) {
                  print(error);
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    ).then((_) => tokenOperation.operation.cancel());
  }
}
