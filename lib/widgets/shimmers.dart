import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({Key? key, this.itemCount = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < itemCount; i++)
            const ShimmerItem(child: CoverShimmer())
        ],
      ),
    );
    // child: GridView.builder(
    //   shrinkWrap: true,
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 5,
    //     childAspectRatio: 0.55,
    //   ),
    //   itemCount: itemCount,
    //   itemBuilder: (context, index) => const ShimmerItem(
    //     child: CoverShimmer(),
    //   ),
    // ),
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
                  margin: const EdgeInsets.only(bottom: 5),
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
      color: color,
    );
  }
}
