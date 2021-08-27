import 'package:goribernetflix/widgets/rounded_card.dart';
import 'package:flutter/material.dart';

abstract class CustomTouchableStateProperty<T> {
  T resolve(Set<MaterialState> states);

  static T resolveAs<T>(T value, Set<MaterialState> states) {
    if (value is CustomTouchableStateProperty<T>) {
      final CustomTouchableStateProperty<T> property = value;
      return property.resolve(states);
    }
    return value;
  }

  static CustomTouchableStateProperty<T> resolveWith<T>(
          MaterialPropertyResolver<T> callback) =>
      _CustomTouchableStatePropertyWith<T>(callback);

  static CustomTouchableStateProperty<T> all<T>(T value) =>
      _MaterialStatePropertyAll<T>(value);
}

class _CustomTouchableStatePropertyWith<T>
    implements CustomTouchableStateProperty<T> {
  _CustomTouchableStatePropertyWith(this._resolve);

  final MaterialPropertyResolver<T> _resolve;

  @override
  T resolve(Set<MaterialState> states) => _resolve(states);
}

class _MaterialStatePropertyAll<T> implements CustomTouchableStateProperty<T> {
  _MaterialStatePropertyAll(this.value);

  final T value;

  @override
  T resolve(Set<MaterialState> states) => value;
}

class ResponsiveButton extends StatefulWidget {
  final CustomTouchableStyle style;
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const ResponsiveButton({
    this.style = const CustomTouchableStyle(),
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  ResponsiveButtonState createState() => ResponsiveButtonState();
}

class ResponsiveButtonState<T extends ResponsiveButton>
    extends State<ResponsiveButton> {
  late Color primaryColor;
  late Color textColor;
  final FocusNode _focusNode = FocusNode();
  final _borderRadius = 6.0;

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    primaryColor = widget.style.primaryColor;
    textColor = widget.style.textColor;
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
        primaryColor = widget.style.focusPrimaryColor;
        textColor = widget.style.focusTextColor;
      });
    } else {
      setState(() {
        primaryColor = widget.style.primaryColor;
        textColor = widget.style.textColor;
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
    return RawMaterialButton(
      focusNode: _focusNode,
      onPressed: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: widget.style.borders == Borders.right
              ? BorderRadius.only(
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                )
              : widget.style.borders == Borders.left
                  ? BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      bottomLeft: Radius.circular(_borderRadius))
                  : widget.style.borders == Borders.middle
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
    );
  }

  Widget _buildMobileButton() {
    if (widget.icon != null) {
      return IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon!),
        tooltip: "Add to list",
      );
    } else {
      return TextButton(onPressed: widget.onPressed, child: Text(widget.label));
    }
  }
}
