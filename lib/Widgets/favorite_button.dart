import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/Models/user.dart';
import 'package:goribernetflix/Services/favorites.dart';
import 'package:goribernetflix/Services/user.dart';
import 'package:goribernetflix/Widgets/responsive_button.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/future_adt.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  final String seriesId;

  const FavoriteButton({required this.seriesId});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  Future<void> _setFavorite(int userId) async {
    return Provider.of<FavoritesService>(context, listen: false)
        .saveFavorite(widget.seriesId, userId);
  }

  Future<void> _removeFavorite(int userId) async {
    return Provider.of<FavoritesService>(context, listen: false)
        .removeFavorite(widget.seriesId, userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<User?>(
      future: Provider.of<UserService>(context).getCurrentUser(),
      builder: (context, result) => result.where(
        onInProgress: () => _buildButton(
          isFavorite: false,
          loading: true,
        ),
        onSuccess: (user) {
          if (user != null) {
            return resolveFavorite(user.id);
          } else {
            return const SizedBox.shrink();
          }
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget resolveFavorite(int userId) {
    return FutureBuilder2<bool>(
      future: Provider.of<FavoritesService>(context)
          .checkFavorite(widget.seriesId, userId),
      builder: (context, result) {
        return result.where(
          onInProgress: () => _buildButton(
            userId: userId,
            isFavorite: false,
            loading: true,
          ),
          onSuccess: (isFavorite) => _buildButton(
            userId: userId,
            isFavorite: isFavorite,
            loading: false,
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildButton({
    required bool isFavorite,
    int? userId,
    bool loading = true,
  }) {
    return ResponsiveButton(
      icon: loading
          ? FeatherIcons.loader
          : isFavorite
              ? FeatherIcons.check
              : FeatherIcons.plus,
      label: "Add to list",
      onPressed: userId == null
          ? () {}
          : () async {
              if (isFavorite) {
                await _removeFavorite(userId);
              } else {
                await _setFavorite(userId);
              }
              setState(() {});
            },
    );
  }
}
