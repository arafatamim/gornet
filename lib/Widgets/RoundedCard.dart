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
  final double cardHeight;
  final int subtitleMaxLines;
  final bool subtitleSoftWrap;
  const RoundedCardStyle({
    this.textColor = Colors.white,
    this.focusTextColor = Colors.black,
    this.mutedTextColor = const Color(0xFFE0E0E0),
    this.focusMutedTextColor = const Color(0xFF757575),
    this.primaryColor = const Color(0x66000000),
    this.focusPrimaryColor = Colors.white,
    this.cardHeight = 75,
    this.subtitleMaxLines = 1,
    this.subtitleSoftWrap = false,
  });
}

class RoundedCard extends StatefulWidget {
  const RoundedCard(
      {Key? key,
      this.title,
      this.subtitle,
      this.leading,
      this.onTap,
      this.style = const RoundedCardStyle()})
      : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Function? onTap;
  final RoundedCardStyle style;

  @override
  _RoundedCardState createState() => _RoundedCardState();
}

class _RoundedCardState extends State<RoundedCard>
    with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late CurvedAnimation _animation;
  late Color _primaryColor;
  late Color _textColor;
  late Color _mutedTextColor;

  @override
  void initState() {
    _primaryColor = widget.style.primaryColor;
    _textColor = widget.style.textColor;
    _mutedTextColor = widget.style.mutedTextColor;

    _node = FocusNode();
    _node.addListener(_onFocusChange);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
        _mutedTextColor = widget.style.focusMutedTextColor;
      });
    } else {
      _controller.reverse();
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
        _mutedTextColor = widget.style.mutedTextColor;
      });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            color: _primaryColor,
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Horizontal items
              Expanded(
                flex: 2,
                child: Center(
                  child: widget.leading != null
                      ? widget.leading
                      : Icon(
                          FeatherIcons.playCircle,
                          color: _textColor,
                        ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Vertical items
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.title ?? "",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.sourceSansPro(
                            fontWeight: FontWeight.w400,
                            color: _textColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.subtitle ?? "",
                          maxLines: widget.style.subtitleMaxLines,
                          softWrap: widget.style.subtitleSoftWrap,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sourceSansPro(
                            color: _mutedTextColor,
                            fontSize: 13,
                          ),
                        ),
                      )
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
