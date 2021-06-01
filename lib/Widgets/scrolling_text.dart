import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class AutoScrollController extends ChangeNotifier {
  bool _started;
  bool _animationRunning = false;
  final bool autoStart;

  bool get started => _started;

  AutoScrollController({this.autoStart = false}) : _started = autoStart;

  void startScroll() {
    _started = true;
    _animationRunning = true;
    notifyListeners();
  }

  void stopScroll() {
    _started = false;
    _animationRunning = false;
    notifyListeners();
  }
}

class ScrollingText extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;

  /// Speed at which the text scrolls in pixels per second.
  /// Has to be greater than zero.
  final int speed;
  final Duration backDuration, startPauseDuration;
  final Duration? endPauseDuration;
  final AutoScrollController? controller;

  const ScrollingText({
    required this.child,
    this.scrollDirection: Axis.horizontal,
    this.backDuration: const Duration(milliseconds: 800),
    this.startPauseDuration: const Duration(seconds: 10),
    this.speed = 20,
    this.endPauseDuration,
    this.controller,
  }) : assert(speed > 0, "Speed has to be greater than zero");

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  late final ScrollController scrollController;
  late final AutoScrollController _autoScrollController;

  double get _scrollDistance => scrollController.position.maxScrollExtent;
  Duration get scrollDuration => Duration(
        milliseconds: ((_scrollDistance / widget.speed) * 1000).toInt(),
      );

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: 0.0);
    _autoScrollController =
        widget.controller ?? AutoScrollController(autoStart: true);

    if (_autoScrollController.autoStart)
      WidgetsBinding.instance?.addPostFrameCallback((_) => _scroll());
    else
      _autoScrollController.addListener(_scroll);

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: widget.child,
        scrollDirection: widget.scrollDirection,
        controller: scrollController,
      ),
    );
  }

  void _scroll() async {
    while (scrollController.hasClients && _autoScrollController.started) {
      await Future.delayed(widget.startPauseDuration);
      if (scrollController.hasClients && _autoScrollController.started) {
        await scrollController.animateTo(
          _scrollDistance,
          duration: scrollDuration,
          curve: Curves.linear,
        );
      }
      await Future.delayed(
        widget.endPauseDuration ?? widget.startPauseDuration,
      );

      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.easeOut,
        );
      }
    }
  }
}
