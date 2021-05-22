import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';

class SeasonTab extends StatefulWidget {
  final Season season;
  final RoundedCardStyle style;
  final Function? onTap;
  final Function? onFocus;

  const SeasonTab(
      {Key? key,
      required this.season,
      this.onTap,
      this.onFocus,
      this.style = const RoundedCardStyle()})
      : super(key: key);

  @override
  _SeasonTabState createState() => _SeasonTabState();
}

class _SeasonTabState extends State<SeasonTab>
    with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Color _primaryColor;
  late Color _textColor;
  // late Color _mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: ValueKey(widget.season.id),
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );

    // return Focus(
    //     focusNode: _node,
    //     onKey: _onKey,
    //     child: Builder(
    //       builder: (context) {
    //         return buildCover(context);
    //       }
    //     ),
    // );
  }

  Widget buildCover(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _primaryColor,
          ),
          child: Column(
            children: <Widget>[
              if (widget.season.imageUris?.primary != null) ...[
                Container(
                  child: buildPosterImage(context, widget.season.imageUris),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 15,
                        offset: Offset(5, 5),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
              Expanded(
                child: Text(
                  widget.season.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: GoogleFonts.sourceSansPro(
                    color: _textColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPosterImage(BuildContext context, ImageUris? imageUris) {
    return Container(
      child: (imageUris?.primary != null)
          ? FadeInImage.memoryNetwork(
              key: Key(imageUris!.primary!),
              placeholder: kTransparentImage,
              image: imageUris.primary!,
              fit: BoxFit.cover,
            )
          : ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Container(
                decoration: BoxDecoration(color: Colors.blue.shade900),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.season.name}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      height: 150.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  // void _openDetails() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.item)));
  // }

  // bool _onKey(FocusNode node, RawKeyEvent event) {
  //   if(event is RawKeyDownEvent) {
  //     if(event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       _onTap();
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  void initState() {
    _primaryColor = widget.style.primaryColor;
    _textColor = widget.style.textColor;
    // _mutedTextColor = widget.style.mutedTextColor;

    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
        lowerBound: 0.9,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }

  void _onFocusChange() {
    Scrollable.ensureVisible(
      _node.context!,
      alignment: 1.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );

    if (_node.hasFocus) {
      _controller.forward();
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
        // _mutedTextColor = widget.style.focusMutedTextColor;
      });
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _controller.reverse();
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
        // _mutedTextColor = widget.style.mutedTextColor;
      });
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap?.call();
  }
}
