import 'package:flutter/material.dart';

class MetaLabel extends StatelessWidget {
  final String label;
  final Widget? leading;
  final bool hasBackground;

  const MetaLabel(
    this.label, {
    Key? key,
    this.hasBackground = false,
    this.leading,
  }) : super(key: key);

  Widget? _buildLeading() {
    if (leading is Icon) {
      final icon = leading as Icon;
      return Icon(
        icon.icon,
        color: Colors.grey.shade300,
        size: 25,
      );
    } else if (leading is Image) {
      final image = leading as Image;
      return Image(
        image: image.image,
        width: 30,
        height: 30,
      );
    } else {
      return leading;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (_buildLeading() != null) ...[
            _buildLeading()!,
            const SizedBox(width: 10),
          ],
          Container(
            padding: hasBackground
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                : null,
            decoration: hasBackground
                ? BoxDecoration(
                    color: Colors.grey.shade300.withAlpha(200),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: hasBackground
                        ? Colors.grey.shade900
                        : Colors.grey.shade200,
                    fontWeight:
                        hasBackground ? FontWeight.bold : FontWeight.normal,
                    fontSize: hasBackground ? 16 : 18,
                  ),
            ),
          ),
          MediaQuery.of(context).size.width > 720
              ? const SizedBox(width: 30)
              : const SizedBox(width: 15),
        ],
      ),
    );
  }
}
