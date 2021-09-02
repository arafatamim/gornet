import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ticker_text/ticker_text.dart';

class RoundedCard extends StatefulWidget {
  const RoundedCard({
    Key? key,
    this.title,
    this.subtitle,
    this.leading,
    this.scrollAxis = Axis.vertical,
    this.onTap,
    this.color,
    this.height = 80,
    this.foregroundColor,
    this.mutedForegroundColor,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Axis scrollAxis;
  final void Function()? onTap;
  final MaterialStateProperty<Color>? color;
  final MaterialStateProperty<Color>? foregroundColor;
  final MaterialStateProperty<Color>? mutedForegroundColor;
  final double? height;

  @override
  _RoundedCardState createState() => _RoundedCardState();
}

class _RoundedCardState extends State<RoundedCard>
    with SingleTickerProviderStateMixin {
  late final FocusNode _node;
  late final AnimationController _controller;
  late final TickerTextController _tickerTextController;
  late final CurvedAnimation _animation;

  bool get focused => _node.hasFocus;
  MaterialStateProperty<Color> get color =>
      widget.color ??
      MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.white.withAlpha(250)
            : Colors.black.withAlpha(200),
      );
  MaterialStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ??
      MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.black
            : Colors.white.withAlpha(200),
      );
  MaterialStateProperty<Color> get mutedForegroundColor =>
      widget.mutedForegroundColor ??
      MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? Colors.grey.shade600
            : Colors.grey.shade500,
      );

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _tickerTextController = TickerTextController();

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      _tickerTextController.startScroll();
      setState(() {});
    } else {
      _controller.reverse();
      _tickerTextController.stopScroll();
      setState(() {});
    }
  }

  void _onTap() {
    _node.requestFocus();
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    _tickerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildWide();
    } else {
      return _buildMobile();
    }
  }

  Widget _buildMobile() {
    return ListTile(
      title: Text(widget.title ?? ""),
      subtitle: Text(widget.subtitle ?? ""),
      leading: widget.leading,
      onTap: widget.onTap,
      tileColor: Colors.white.withAlpha(15),
    );
  }

  Widget _buildWide() {
    final buildTitle = Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title ?? "",
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.bodyText2?.copyWith(
              fontWeight: FontWeight.w400,
              color: focused
                  ? foregroundColor.resolve({MaterialState.focused})
                  : foregroundColor.resolve({}),
              fontSize: 20,
            ),
      ),
    );
    final buildSubtitle = Align(
      alignment: Alignment.topLeft,
      child: TickerText(
        speed: 16,
        scrollDirection: widget.scrollAxis,
        controller: _tickerTextController,
        startPauseDuration: const Duration(seconds: 2),
        endPauseDuration: const Duration(seconds: 4),
        child: Text(
          widget.subtitle ?? "",
          // maxLines: widget.style.subtitleMaxLines,
          softWrap: true,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: focused
                    ? mutedForegroundColor.resolve({MaterialState.focused})
                    : mutedForegroundColor.resolve({}),
                fontSize: 16,
              ),
        ),
      ),
    );

    return RawMaterialButton(
      focusNode: _node,
      onPressed: _onTap,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: ScaleTransition(
        scale: _animation,
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: focused
                ? color.resolve({MaterialState.focused})
                : color.resolve({}),
            boxShadow: [
              if (focused)
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 7,
                  offset: const Offset(1, 5),
                )
            ],
          ),
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Horizontal items
              Expanded(
                flex: 2,
                child: Center(
                  child: widget.leading != null
                      ? widget.leading!
                      : Icon(FeatherIcons.playCircle,
                          color: focused
                              ? foregroundColor.resolve({MaterialState.focused})
                              : foregroundColor.resolve({})),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  padding: const EdgeInsets.only(
                    right: 12,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Vertical items
                      buildTitle,
                      widget.scrollAxis == Axis.horizontal
                          ? buildSubtitle
                          : Expanded(child: buildSubtitle)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
