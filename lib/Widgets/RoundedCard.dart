import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedCardStyle {
  final Color textColor;
  final Color focusTextColor;
  final Color mutedTextColor;
  final Color focusMutedTextColor;
  final Color primaryColor;
  final Color focusPrimaryColor;
  final double? cardHeight;
  const RoundedCardStyle({
    this.textColor = Colors.white,
    this.focusTextColor = Colors.black,
    this.mutedTextColor = const Color(0xFFE0E0E0),
    this.focusMutedTextColor = const Color(0xFF757575),
    this.primaryColor = const Color(0x66000000),
    this.focusPrimaryColor = Colors.white,
    this.cardHeight = 75,
  });
}

class RoundedCard extends StatefulWidget {
  const RoundedCard({
    Key? key,
    this.title,
    this.subtitle,
    this.leading,
    this.scrollAxis = Axis.vertical,
    this.onTap,
    this.style = const RoundedCardStyle(),
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Axis scrollAxis;
  final Function? onTap;
  final RoundedCardStyle style;

  @override
  _RoundedCardState createState() => _RoundedCardState();
}

class _RoundedCardState extends State<RoundedCard>
    with SingleTickerProviderStateMixin {
  late final FocusNode _node;
  late final AnimationController _controller;
  late final AutoScrollController _autoScrollController;
  late final CurvedAnimation _animation;

  bool get focused => _node.hasFocus;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _autoScrollController = AutoScrollController();

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      _autoScrollController.startScroll();
      setState(() {});
    } else {
      _controller.reverse();
      _autoScrollController.stopScroll();
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
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildTitle = Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title ?? "",
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: GoogleFonts.sourceSansPro(
          fontWeight: FontWeight.w400,
          color: focused ? widget.style.focusTextColor : widget.style.textColor,
          fontSize: 20,
        ),
      ),
    );
    final buildSubtitle = Align(
      alignment: Alignment.topLeft,
      child: ScrollingText(
        speed: 12,
        scrollDirection: widget.scrollAxis,
        controller: _autoScrollController,
        startPauseDuration: Duration(seconds: 7),
        endPauseDuration: Duration(seconds: 10),
        child: Text(
          widget.subtitle ?? "",
          // maxLines: widget.style.subtitleMaxLines,
          softWrap: true,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: focused
                    ? widget.style.focusMutedTextColor
                    : widget.style.mutedTextColor,
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
                ? widget.style.focusPrimaryColor
                : widget.style.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(150),
                blurRadius: 7,
                offset: Offset(1, 5),
              )
            ],
          ),
          height: widget.style.cardHeight,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      : Icon(
                          FeatherIcons.playCircle,
                          color: focused
                              ? widget.style.focusTextColor
                              : widget.style.textColor,
                        ),
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
