import 'package:goribernetflix/widgets/rounded_card.dart';
import 'package:flutter/material.dart';

class TextKey extends StatefulWidget {
  const TextKey({
    Key? key,
    this.text,
    this.icon,
    this.onTap,
    this.flex = 1,
    this.style = const CustomTouchableStyle(textColor: Color(0xFFD6D6D6)),
  })  : assert(
          icon != null || text != null,
          "Either icon or text must be specified",
        ),
        super(key: key);

  final String? text;
  final IconData? icon;
  final ValueSetter<String?>? onTap;
  final int flex;
  final CustomTouchableStyle style;

  @override
  _TextKeyState createState() => _TextKeyState();
}

class _TextKeyState extends State<TextKey> with TickerProviderStateMixin {
  late FocusNode _node;
  late Color _primaryColor;
  late Color _textColor;
  // late Color _mutedTextColor;

  @override
  void initState() {
    _primaryColor = widget.style.primaryColor;
    _textColor = widget.style.textColor;
    // _mutedTextColor = widget.style.mutedTextColor;

    _node = FocusNode();
    _node.addListener(_onFocusChange);

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
        // _mutedTextColor = widget.style.focusMutedTextColor;
      });
    } else {
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
        // _mutedTextColor = widget.style.mutedTextColor;
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
