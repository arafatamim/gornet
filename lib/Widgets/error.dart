import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/Models/models.dart';

class ErrorMessage extends StatelessWidget {
  final Object? error;

  const ErrorMessage(this.error, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 110),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FeatherIcons.frown,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(height: 1.1),
              )
            ],
          ),
        ),
      ),
    );
  }

  String get errorMessage => error is DioError
      ? (error as DioError).message
      : error is ServerError
          ? (error as ServerError).message
          : error is String
              ? (error as String)
              : "Unhandled error. Contact system administrator.";
}
