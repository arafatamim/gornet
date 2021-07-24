import 'package:goribernetflix/Services/favorites.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteIcon extends StatefulWidget {
  final RoundedCardStyle style;
  final String id;

  const FavoriteIcon({
    this.style = const RoundedCardStyle(),
    required this.id,
  });

  @override
  _FavoriteIconState createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
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

  Future<void> _setFavorite() async {
    return Provider.of<FavoritesService>(context, listen: false)
        .saveFavorite(widget.id);
  }

  Future<void> _removeFavorite() async {
    return Provider.of<FavoritesService>(context, listen: false)
        .removeFavorite(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: Provider.of<FavoritesService>(context).checkFavorite(
        widget.id,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return _buildButton(context, false, loading: true);
          case ConnectionState.done:
            if (snapshot.hasData) {
              final isFavorite = snapshot.data!;
              return _buildButton(context, isFavorite);
            } else {
              return Container();
            }
          default:
            if (snapshot.hasError) print(snapshot.error?.toString());
            return Container();
        }
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    bool isFavorite, {
    bool loading = false,
  }) {
    final deviceSize = MediaQuery.of(context).size;
    final onPressed = loading
        ? () {}
        : () async {
            if (isFavorite) {
              await _removeFavorite();
            } else {
              await _setFavorite();
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
