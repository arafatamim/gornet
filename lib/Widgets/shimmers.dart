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
          itemBuilder: (context, index) => const ShimmerItem(
            child: CoverShimmer(),
          ),
        ),
      ),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  final Widget child;
  const ShimmerItem({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
    );
  }
}

class CoverShimmer extends StatelessWidget {
  final Color color = Colors.white;

  const CoverShimmer({
    Key? key,
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

class SpotlightShimmer extends StatelessWidget {
  final color = Colors.white;
  const SpotlightShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 500,
      // height: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 400,
            width: 500,
            color: color,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 300,
                color: color,
              ), // logo/title
              SizedBox(height: 20),
              Container(
                width: 550,
                height: 200,
                color: color,
              ), // synopsis
              SizedBox(height: 20),
            ],
          )
        ],
      ),
    );
  }
}
