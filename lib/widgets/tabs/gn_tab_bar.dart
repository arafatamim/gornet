import 'package:flutter/material.dart';
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';

class GNTabBar extends StatefulWidget {
  const GNTabBar({
    Key? key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabChange,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.color,
    this.foregroundColor,
    this.controller,
  }) : super(key: key);

  final List<ResponsiveButton> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChange;
  final MainAxisAlignment mainAxisAlignment;
  final MaterialStateColor? color;
  final MaterialStateColor? foregroundColor;
  final TabController? controller;

  @override
  _GNTabBarState createState() => _GNTabBarState();
}

class _GNTabBarState extends State<GNTabBar> {
  late int selectedIndex;

  TabController get controller =>
      widget.controller ??
      DefaultTabController.of(context) ??
      (throw Exception("No controller attached!"));

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(GNTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        children: <Widget>[
          for (var i = 0; i < widget.tabs.length; i++)
            ResponsiveButton(
              key: ValueKey(widget.tabs[i].label),
              color: widget.color,
              foregroundColor: widget.foregroundColor,
              label: widget.tabs[i].label,
              onPressed: () {
                setState(() {
                  selectedIndex = i;
                });
                controller.animateTo(i);

                widget.tabs[i].onPressed?.call();

                widget.onTabChange?.call(i);
              },
              active: i == selectedIndex,
              borders: widget.tabs.length == 1
                  ? {Borders.all}
                  : i == 0
                      ? {Borders.topLeft, Borders.bottomLeft}
                      : i == (widget.tabs.length - 1)
                          ? {Borders.topRight, Borders.bottomRight}
                          : {},
            )
        ],
      ),
    );
  }
}
