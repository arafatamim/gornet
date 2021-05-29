import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({Key? key, this.itemCount = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 400),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.55,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => ShimmerItem(),
        ),
      ),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  const ShimmerItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: Item(color: Colors.blue),
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
    );
  }
}

class Item extends StatelessWidget {
  final Color color;

  const Item({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 220,
            height: 250,
            color: color,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 16.0,
                  color: color,
                  margin: EdgeInsets.only(bottom: 5),
                ),
                Container(
                  width: 80.0,
                  height: 14.0,
                  color: color,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
