import 'package:flutter/material.dart';

enum Borders { left, middle, right, all }

class IndicatorPainter extends CustomPainter {
  final Color color;

  const IndicatorPainter({
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // canvas.drawCircle(const Offset(0, 25), 6, paint);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(-32, 21, 64, 5),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        paint);
  }

  @override
  bool shouldRepaint(IndicatorPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(IndicatorPainter oldDelegate) => false;
}

class ResponsiveButton extends StatefulWidget {
  final MaterialStateProperty<Color>? color;
  final MaterialStateProperty<Color>? foregroundColor;
  final Borders? borders;
  final String label;
  final String? tooltip;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool active;

  const ResponsiveButton({
    Key? key,
    this.color,
    this.foregroundColor,
    this.tooltip,
    this.borders,
    required this.label,
    this.onPressed,
    this.icon,
    this.active = false,
  }) : super(key: key);

  @override
  ResponsiveButtonState createState() => ResponsiveButtonState();
}

class ResponsiveButtonState<T extends ResponsiveButton>
    extends State<ResponsiveButton> with TickerProviderStateMixin {
  MaterialStateProperty<Color> get color =>
      widget.color ??
      MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.white
            : Colors.black.withAlpha(150),
      );
  MaterialStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ??
      MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.black
            : Colors.white.withAlpha(200),
      );

  late Color primaryColor;
  late Color textColor;

  final FocusNode _focusNode = FocusNode();
  final _borderRadius = 6.0;

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    primaryColor = color.resolve({});
    textColor = foregroundColor.resolve({});
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        primaryColor = color.resolve({MaterialState.focused});
        textColor = foregroundColor.resolve({MaterialState.focused});
      });
    } else {
      setState(() {
        primaryColor = color.resolve({});
        textColor = foregroundColor.resolve({});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildTvButton();
    } else {
      return _buildMobileButton();
    }
  }

  Widget _buildTvButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        RawMaterialButton(
          focusNode: _focusNode,
          onPressed: widget.onPressed,
          splashColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: widget.borders == Borders.right
                  ? BorderRadius.only(
                      topRight: Radius.circular(_borderRadius),
                      bottomRight: Radius.circular(_borderRadius),
                    )
                  : widget.borders == Borders.left
                      ? BorderRadius.only(
                          topLeft: Radius.circular(_borderRadius),
                          bottomLeft: Radius.circular(_borderRadius))
                      : widget.borders == Borders.middle
                          ? const BorderRadius.only()
                          : BorderRadius.circular(_borderRadius),
              color: primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon!,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.apply(color: textColor),
                )
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: widget.active ? 1 : 0,
          child: CustomPaint(
            painter: IndicatorPainter(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButton() {
    if (widget.icon != null) {
      return IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon!),
        tooltip: widget.tooltip ?? widget.label,
      );
    } else {
      return TextButton(onPressed: widget.onPressed, child: Text(widget.label));
    }
  }
}
