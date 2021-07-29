import 'package:goribernetflix/Models/user.dart';
import 'package:goribernetflix/Services/favorites.dart';
import 'package:goribernetflix/Services/user.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  final RoundedCardStyle style;
  final String seriesId;

  const FavoriteButton({
    this.style = const RoundedCardStyle(),
    required this.seriesId,
  });

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late Color _primaryColor;
  late Color _textColor;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    _primaryColor = widget.style.primaryColor;
    _textColor = widget.style.textColor;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
      });
    } else {
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
      });
    }
  }

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
    Widget resolveFavorite(int userId) => FutureBuilder<bool?>(
          future: Provider.of<FavoritesService>(context)
              .checkFavorite(widget.seriesId, userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _buildButton(context, userId, false, loading: true);
              case ConnectionState.done:
                if (snapshot.hasData) {
                  final isFavorite = snapshot.data!;
                  return _buildButton(context, userId, isFavorite);
                } else {
                  return const SizedBox.shrink();
                }
              default:
                if (snapshot.hasError) print(snapshot.error?.toString());
                return const SizedBox.shrink();
            }
          },
        );

    return FutureBuilder<User?>(
      future: Provider.of<UserService>(context).getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return resolveFavorite(user.id);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    int userId,
    bool isFavorite, {
    bool loading = false,
  }) {
    final deviceSize = MediaQuery.of(context).size;
    final onPressed = loading
        ? () {}
        : () async {
            if (isFavorite) {
              await _removeFavorite(userId);
            } else {
              await _setFavorite(userId);
            }
            setState(() {});
          };
    final icon = Icon(
      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: loading
          ? (Colors.grey)
          : isFavorite
              ? Colors.red
              : _textColor,
    );

    if (deviceSize.width > 720) {
      return RawMaterialButton(
        focusNode: _focusNode,
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                "Add to list",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.apply(color: _textColor),
              )
            ],
          ),
        ),
      );
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: "Add to list",
      );
    }
  }
}
