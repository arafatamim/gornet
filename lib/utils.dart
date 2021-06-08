import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes == 0) return "0 Bytes";
  final k = 1024;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  final i = (Math.log(bytes) / Math.log(k)).floor();
  final finalSize =
      (bytes / Math.pow(k, i)).toStringAsFixed(decimals.abs()); // 830.0
  return finalSize + " " + sizes[i];
}

Widget buildLabel(
  String label, {
  IconData? icon,
  String? imageAsset,
  bool hasBackground = false,
}) {
  return Container(
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.grey.shade300,
            size: 25,
          ),
          SizedBox(width: 10),
        ],
        if (imageAsset != null) ...[
          Image.asset(
            imageAsset,
            width: 30,
            height: 30,
          ),
          SizedBox(width: 10),
        ],
        Container(
          padding: hasBackground
              ? EdgeInsets.symmetric(horizontal: 10, vertical: 6)
              : null,
          decoration: hasBackground
              ? BoxDecoration(
                  color: Colors.grey.shade900.withAlpha(200),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            label,
            style: GoogleFonts.sourceSansPro(
              color:
                  hasBackground ? Colors.grey.shade300 : Colors.grey.shade200,
              fontSize: hasBackground ? 16 : 18,
            ),
          ),
        ),
        SizedBox(width: 30),
      ],
    ),
  );
}

Widget buildError(String message, {VoidCallback? onRefresh}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        message,
        style: GoogleFonts.sourceSansPro(fontSize: 16),
      ),
      if (onRefresh != null)
        TextButton.icon(
          onPressed: onRefresh,
          icon: Icon(FeatherIcons.refreshCcw),
          label: Text("Refresh"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              GoogleFonts.sourceSansPro(fontSize: 20),
            ),
          ),
        )
    ],
  );
}

T coalesceException<T>(T Function() func, T defaultValue) {
  try {
    return func();
  } catch (e) {
    print(e);
    return defaultValue;
  }
}

extension Converters on DateTime {
  String get longMonth {
    const Map<int, String> monthsInYear = {
      1: "january",
      2: "february",
      3: "march",
      4: "april",
      5: "may",
      6: "june",
      7: "july",
      8: "august",
      9: "september",
      10: "october",
      11: "november",
      12: "december"
    };
    return monthsInYear[this.month]!;
  }
}

extension CapExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${this.substring(1)}';
  String get capitalizeFirstOfEachWord =>
      this.split(" ").map((str) => str.capitalizeFirst).join(" ");
}
