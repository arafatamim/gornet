import "package:flutter/material.dart";
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';

class TvDialog extends StatefulWidget {
  final String message;
  final List<ResponsiveButton> buttons;

  const TvDialog({
    Key? key,
    required this.message,
    required this.buttons,
  })  : assert(buttons.length > 0),
        super(key: key);
  @override
  State<TvDialog> createState() => _TvDialogState();
}

class _TvDialogState extends State<TvDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          transform: const GradientRotation(90 * 3.14 / 180), // turn 90 degrees
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(96.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 36),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.buttons.length; ++i)
                  ResponsiveButton(
                    key: widget.buttons[i].key,
                    icon: widget.buttons[i].icon,
                    color: widget.buttons[i].color,
                    tooltip: widget.buttons[i].tooltip,
                    autofocus: widget.buttons[i].autofocus,
                    foregroundColor: widget.buttons[i].foregroundColor,
                    label: widget.buttons[i].label,
                    onPressed: widget.buttons[i].onPressed,
                    borders: i == 0
                        ? {Borders.topLeft, Borders.bottomLeft}
                        : i == widget.buttons.length - 1
                            ? {Borders.topRight, Borders.bottomRight}
                            : {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
