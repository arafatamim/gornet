import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class AutoScrollController extends ChangeNotifier {
  bool _started;
  final bool autoStart;

  bool get started => _started;

  AutoScrollController({this.autoStart = false}) : _started = autoStart;

  void startScroll() {
    _started = true;
    notifyListeners();
  }

  void stopScroll() {
    _started = false;
    notifyListeners();
  }
}

class ScrollingText extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;

  /// Speed at which the text scrolls in pixels per second.
  /// Has to be greater than zero.
  final int speed;

  /// How long it takes for text to scroll back up from the end.
  final Duration backDuration;

  /// How long it takes for text to begin scrolling.
  final Duration startPauseDuration;

  /// How long the scrolling pauses at the end before scrolling back up.
  /// If null, it is the same as `startPauseDuration`.
  final Duration? endPauseDuration;

  /// Controls the state of scrolling. If not provided, uses its default internal controller
  /// with `autoStart` enabled.
  final AutoScrollController? controller;

  final Curve primaryCurve;

  final Curve returnCurve;

  const ScrollingText({
    required this.child,
    this.scrollDirection = Axis.horizontal,
    this.backDuration = const Duration(milliseconds: 800),
    this.startPauseDuration = const Duration(seconds: 10),
    this.speed = 20,
    this.endPauseDuration,
    this.controller,
    this.primaryCurve = Curves.linear,
    this.returnCurve = Curves.easeOut,
  }) : assert(speed > 0, "Speed has to be greater than zero");

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  late final ScrollController _scrollController;
  late final AutoScrollController _autoScrollController;

  double get maxScrollDistance => _scrollController.position.maxScrollExtent;
  Duration get scrollDuration => Duration(
        milliseconds: ((maxScrollDistance / widget.speed) * 1000).toInt(),
      );

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _autoScrollController =
        widget.controller ?? AutoScrollController(autoStart: true);

    if (_autoScrollController.autoStart) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => _scroll());
    } else {
      _autoScrollController.addListener(_scroll);
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: widget.child,
        scrollDirection: widget.scrollDirection,
        controller: _scrollController,
      ),
    );
  }

  void _scroll() async {
    if (_scrollController.hasClients &&
        _scrollController.offset > 0 &&
        !_autoScrollController.started) {
      _scrollController.jumpTo(0);
      return;
    }
    while (_scrollController.hasClients && _autoScrollController.started) {
      // Run futures in succession
      await Future.delayed(widget.startPauseDuration).then((_) {
        if (_scrollController.hasClients &&
            _autoScrollController.started &&
            _scrollController.offset == 0) {
          return _scrollController.animateTo(
            maxScrollDistance,
            duration: scrollDuration,
            curve: widget.primaryCurve,
          );
        }
      }).then((_) {
        if (_scrollController.hasClients &&
            _autoScrollController.started &&
            _scrollController.offset == maxScrollDistance) {
          return Future.delayed(
            widget.endPauseDuration ?? widget.startPauseDuration,
          );
        }
      }).then((_) {
        if (_scrollController.hasClients &&
            _scrollController.offset == maxScrollDistance) {
          return _scrollController.animateTo(
            0.0,
            duration: widget.backDuration,
            curve: widget.returnCurve,
          );
        }
      });
    }
  }
}
