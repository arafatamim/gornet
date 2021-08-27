import 'package:cached_network_image/cached_network_image.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Widgets/error.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:goribernetflix/Widgets/shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ticker_text/ticker_text.dart';

class CoverListViewBuilder extends StatelessWidget {
  final Future<List<SearchResult>> results;
  final bool showIcon;
  final bool separator;
  final ScrollController? controller;

  const CoverListViewBuilder({
    required this.results,
    this.showIcon = false,
    this.separator = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<List<SearchResult>>(
      future: results,
      builder: (context, result) => result.where(
        onInProgress: () => const ShimmerList(
          itemCount: 6,
        ),
        onSuccess: (items) {
          return CoverListView(
            items,
            controller: controller,
            separator: separator,
          );
        },
        onError: (error, stackTrace) => Center(child: ErrorMessage(error)),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class CoverListView extends StatelessWidget {
  final List<SearchResult> items;
  final bool showIcon;
  final bool separator;
  final ScrollController? controller;

  const CoverListView(
    this.items, {
    this.showIcon = false,
    this.separator = true,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      scrollDirection: Axis.horizontal,
      addAutomaticKeepAlives: true,
      itemCount: items.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(width: separator ? 12 : 0),
      itemBuilder: (BuildContext context, int index) {
        SearchResult item = items[index];
        return AspectRatio(
          aspectRatio: 0.55,
          child: Cover(
            title: item.name,
            subtitle: (item.year ?? "").toString(),
            image: item.imageUris?.primary,
            icon: showIcon
                ? (item.isMovie ? FeatherIcons.film : FeatherIcons.tv)
                : null,
            style: CustomTouchableStyle(
              primaryColor: Colors.transparent,
              textColor: Colors.grey.shade300,
              focusTextColor: Colors.white,
              mutedTextColor: Colors.grey.shade400,
              focusMutedTextColor: Colors.grey.shade300,
            ),
            onTap: () {
              Navigator.pushNamed(context, "/detail", arguments: item);
            },
          ),
        );
      },
    );
  }
}

class Cover extends StatefulWidget {
  final String? image;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final CustomTouchableStyle style;
  final Function onTap;
  final Function? onFocus;

  const Cover({
    Key? key,
    this.image,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.style = const CustomTouchableStyle(),
    this.onFocus,
  }) : super(key: key);

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _animationController;
  late TickerTextController _autoScrollController;
  late Animation<double> _animation;
  late Color _primaryColor;
  late Color _textColor;
  late Color _mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: ValueKey(
        widget.key,
      ), // Necessary otherwise image doesn't change
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
        child: Column(
          children: <Widget>[
            Container(
              child: AspectRatio(aspectRatio: 0.66, child: buildPosterImage()),
              decoration: BoxDecoration(
                border: Border.all(width: 4, color: _primaryColor),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 15,
                    offset: const Offset(2, 10),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TickerText(
                          scrollDirection: Axis.horizontal,
                          speed: 20,
                          startPauseDuration: const Duration(milliseconds: 500),
                          endPauseDuration: const Duration(seconds: 2),
                          controller: _autoScrollController,
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style:
                                Theme.of(context).textTheme.bodyText2?.copyWith(
                                      color: _textColor,
                                      fontSize: 20,
                                    ),
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!.toString(),
                            style:
                                Theme.of(context).textTheme.bodyText2?.copyWith(
                                      color: _mutedTextColor,
                                      fontSize: 18,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const Spacer(),
                    Icon(
                      widget.icon!,
                      color: _mutedTextColor,
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPosterImage() {
    if (widget.image != null) {
      return CachedNetworkImage(
        key: Key(widget.image!),
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (_context, _uri) => AspectRatio(
          aspectRatio: 0.6,
          child: Icon(
            widget.icon ?? FeatherIcons.video,
            color: Colors.grey,
          ),
        ),
        imageUrl: widget.image!,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            focal: const Alignment(0, 0),
            focalRadius: 1,
            radius: 0.5,
            center: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '${widget.title} (${widget.subtitle})'.toUpperCase(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyText1?.apply(
                      color: Colors.grey.shade400,
                      fontSizeFactor: 1.3,
                      heightFactor: 0.7,
                    ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _node.dispose();
    _autoScrollController.dispose();
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
    _mutedTextColor = widget.style.mutedTextColor;
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _autoScrollController = TickerTextController();

    super.initState();
  }

  void _onFocusChange() {
    // if (_node.context != null)
    //   Scrollable.ensureVisible(
    //     _node.context!,
    //     alignment: 1.0,
    //     duration: Duration(milliseconds: 300),
    //     alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    //   );

    if (_node.hasFocus) {
      _animationController.forward();
      _autoScrollController.startScroll();
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
        _mutedTextColor = widget.style.focusMutedTextColor;
      });
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _animationController.reverse();
      _autoScrollController.stopScroll();
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
        _mutedTextColor = widget.style.mutedTextColor;
      });
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap();
  }
}
