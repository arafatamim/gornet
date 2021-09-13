import 'package:flutter/material.dart';
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';
import 'package:goribernetflix/widgets/dialogs/tv_dialog.dart';

Future<dynamic> showAdaptiveDialog(
  BuildContext context, {
  required List<ResponsiveButton> buttons,
  required String title,
}) {
  final size = MediaQuery.of(context).size;
  if (size.width > 720) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return TvDialog(
          message: title,
          buttons: buttons,
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            for (final button in buttons)
              TextButton.icon(
                key: button.key,
                onPressed: button.onPressed,
                icon: Icon(button.icon),
                label: Text(button.label),
              )
          ],
        );
      },
    );
  }
}
