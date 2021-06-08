import 'package:chillyflix/Services/StorageService.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

class FavoriteIcon extends StatefulWidget {
  final RoundedCardStyle style;
  final MediaType mediaType;
  final String id;

  const FavoriteIcon({
    this.style = const RoundedCardStyle(),
    required this.id,
    required this.mediaType,
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
        .saveFavorite(widget.mediaType, widget.id);
  }

  Future<void> _removeFavorite() async {
    return Provider.of<FavoritesService>(context, listen: false)
        .removeFavorite(widget.mediaType, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: Provider.of<FavoritesService>(context).checkFavorite(
        widget.mediaType,
        widget.id,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return _buildButton(false, loading: true);
          case ConnectionState.done:
            if (snapshot.hasData) {
              final isFavorite = snapshot.data!;
              return _buildButton(isFavorite);
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

  Widget _buildButton(bool isFavorite, {bool loading = false}) {
    return RawMaterialButton(
      focusNode: _focusNode,
      onPressed: loading
          ? () {}
          : () async {
              if (isFavorite) {
                await _removeFavorite();
              } else
                await _setFavorite();
              setState(() {});
            },
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
            Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: loading
                  ? (Colors.grey)
                  : isFavorite
                      ? Colors.red
                      : _textColor,
            ),
            const SizedBox(width: 6),
            Text(
              "Favorite",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.apply(color: _textColor),
            )
          ],
        ),
      ),
    );
  }
}
