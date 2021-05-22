import 'dart:math' as Math;
import 'package:flutter/material.dart';
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

List<Widget> buildLabel(String label, {IconData? icon, String? imageAsset}) {
  return [
    if (icon != null) ...[
      Icon(
        icon,
        color: Colors.white,
        size: 30,
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
    Text(
      label,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    SizedBox(width: 30),
  ];
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
          icon: Icon(Icons.refresh),
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
