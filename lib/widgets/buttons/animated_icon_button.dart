import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final Duration duration;
  final bool autofocus;
  const AnimatedIconButton({
    this.onPressed,
    required this.icon,
    required this.label,
    this.duration = const Duration(milliseconds: 150),
    this.autofocus = false,
  });
  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FocusNode _node;
  // late Color _primaryColor;
  // late Color _textColor;
  // late Color _mutedTextColor;

  final _borderRadius = BorderRadius.circular(150);

  bool get expanded => _node.hasFocus;

  @override
  void initState() {
    // _primaryColor = widget.style.primaryColor;
    // _textColor = widget.style.textColor;
    // _mutedTextColor = widget.style.mutedTextColor;

    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      // setState(() {
      //   _primaryColor = widget.style.focusPrimaryColor;
      //   _textColor = widget.style.focusTextColor;
      //   _mutedTextColor = widget.style.focusMutedTextColor;
      // });
    } else {
      _controller.reverse();
      // setState(() {
      //   _primaryColor = widget.style.primaryColor;
      //   _textColor = widget.style.textColor;
      //   _mutedTextColor = widget.style.mutedTextColor;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final curveValue = _controller.drive(CurveTween(curve: Curves.ease)).value;

    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        autofocus: widget.autofocus,
        focusNode: _node,
        borderRadius: _borderRadius,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          constraints: expanded
              ? BoxConstraints.loose(const Size(200, 65))
              : const BoxConstraints.tightFor(height: 65, width: 65),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(18),
          duration: widget.duration,
          decoration: BoxDecoration(
            // boxShadow: widget.shadow,
            border: Border.all(width: 1, color: Colors.white.withAlpha(50)),
            // border: widget.active!
            //     ? (widget.activeBorder ?? widget.border)
            //     : widget.border,
            // gradient: widget.gradient,
            // color: _expanded
            //     ? widget.color!.withOpacity(0)
            //     : widget.debug!
            //         ? Colors.red
            //         : widget.gradient != null
            //             ? Colors.white
            //             : widget.color,
            borderRadius: (_borderRadius),
          ),
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Builder(
              builder: (_) {
                return Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            widthFactor: curveValue,
                            child: Opacity(
                              opacity: expanded
                                  ? _controller
                                      .drive(CurveTween(curve: Curves.easeIn))
                                      .value
                                  : pow(_controller.value, 13) as double,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: widget.label,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: expanded ? 8 : 0),
                          child: widget.icon,
                        ),
                      ],
                    ),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: widget.icon,
                    // ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
