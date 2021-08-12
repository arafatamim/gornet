import 'package:flutter/material.dart';

class MiscKey extends StatelessWidget {
  const MiscKey({
    Key? key,
    required this.text,
    this.onPress,
    this.flex = 1,
  }) : super(key: key);
  final String text;
  final VoidCallback? onPress;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.blueGrey.shade700,
          child: InkWell(
            onTap: () {
              onPress?.call();
            },
            child: Container(
              child: Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 18.0,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
