import 'package:flutter/foundation.dart';
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
    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      children: <Widget>[
        for (var i = 0; i < widget.tabs.length; i++)
          ResponsiveButton(
            color: widget.color,
            foregroundColor: widget.foregroundColor,
            label: widget.tabs[i].label,
            onPressed: () {
              controller.animateTo(i);

              widget.tabs[i].onPressed?.call();

              widget.onTabChange?.call(i);
            },
            borders: widget.tabs.length == 1
                ? Borders.all
                : i == 0
                    ? Borders.left
                    : i == (widget.tabs.length - 1)
                        ? Borders.right
                        : Borders.middle,
          )
      ],

      /* widget.tabs
            .map((t) => GButton(
                  key: t.key,
                  border: t.border ?? widget.tabBorder,
                  activeBorder: t.activeBorder ?? widget.tabActiveBorder,
                  shadow: t.shadow ?? widget.tabShadow,
                  borderRadius: t.borderRadius ??
                      BorderRadius.all(
                        Radius.circular(widget.tabBorderRadius),
                      ),
                  debug: widget.debug,
                  margin: t.margin ?? widget.tabMargin,
                  active: selectedIndex == widget.tabs.indexOf(t),
                  gap: t.gap ?? widget.gap,
                  iconActiveColor: t.iconActiveColor ?? widget.activeColor,
                  iconColor: t.iconColor ?? widget.color,
                  iconSize: t.iconSize ?? widget.iconSize,
                  textColor: t.textColor ?? widget.activeColor,
                  rippleColor: t.rippleColor ?? widget.rippleColor,
                  hoverColor: t.hoverColor ?? widget.hoverColor,
                  padding: t.padding ?? widget.padding,
                  textStyle: t.textStyle ?? widget.textStyle,
                  text: t.text,
                  icon: t.icon,
                  haptic: widget.haptic,
                  leading: t.leading,
                  curve: widget.curve,
                  backgroundGradient:
                      t.backgroundGradient ?? widget.tabBackgroundGradient,
                  backgroundColor:
                      t.backgroundColor ?? widget.tabBackgroundColor,
                  duration: widget.duration,
                ))
            .toList()
            */
    );
  }
}
