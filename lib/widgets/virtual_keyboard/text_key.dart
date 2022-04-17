import 'package:flutter/material.dart';

class TextKey extends StatefulWidget {
  const TextKey({
    Key? key,
    this.text,
    this.icon,
    this.onTap,
    this.flex = 1,
    this.color,
    this.foregroundColor,
  })  : assert(
          icon != null || text != null,
          "Either icon or text must be specified",
        ),
        super(key: key);

  final String? text;
  final IconData? icon;
  final ValueSetter<String?>? onTap;
  final int flex;
  final MaterialStateColor? color;
  final MaterialStateColor? foregroundColor;

  @override
  TextKeyState createState() => TextKeyState();
}

class TextKeyState extends State<TextKey> with TickerProviderStateMixin {
  late FocusNode _node;
  late Color _primaryColor;
  late Color _textColor;

  MaterialStateColor get color =>
      widget.color ??
      MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.white
            : Colors.black.withAlpha(100),
      );
  MaterialStateColor get foregroundColor =>
      widget.foregroundColor ??
      MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.black
            : Colors.white,
      );

  @override
  void initState() {
    _primaryColor = color.resolve({});
    _textColor = foregroundColor.resolve({});

    _node = FocusNode();
    _node.addListener(_onFocusChange);

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      setState(() {
        _primaryColor = color.resolve({MaterialState.focused});
        _textColor = foregroundColor.resolve({MaterialState.focused});
      });
    } else {
      setState(() {
        _primaryColor = color.resolve({});
        _textColor = foregroundColor.resolve({});
      });
    }
  }

  void _onTap() {
    _node.requestFocus();
    if (widget.onTap != null) widget.onTap!(widget.text);
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: RawMaterialButton(
          focusNode: _node,
          onPressed: _onTap,
          focusColor: Colors.transparent,
          focusElevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: widget.text != null
                  ? Text(
                      widget.text!,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: _textColor,
                            fontSize: 20.0,
                          ),
                    )
                  : Icon(
                      widget.icon,
                      color: _textColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
