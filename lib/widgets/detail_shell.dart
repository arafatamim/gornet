import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/utils.dart';
import 'package:goribernetflix/widgets/scaffold_with_button.dart';
import 'package:ticker_text/ticker_text.dart';

class DetailShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final List<List<Widget>>? meta;
  final Widget? child;
  final Widget? bottomWidget;
  final List<Widget>? actions;
  final ImageUris? imageUris;

  const DetailShell({
    required this.title,
    this.meta,
    this.child,
    this.imageUris,
    this.subtitle,
    this.description,
    this.bottomWidget,
    this.actions,
  });

  bool isWide(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return deviceSize.width > 720;
  }

  @override
  Widget build(BuildContext context) {
    if (isWide(context)) {
      return _buildWideLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ScaffoldWithButton(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            centerTitle: true,
            actions: actions,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(title),
              background: Stack(
                children: <Widget>[
                  _buildBackdropImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(100)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (meta != null)
                    for (final row in meta!) ...[
                      Row(children: row),
                      const SizedBox(height: 10)
                    ],
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    _buildGenres(),
                    const SizedBox(height: 10),
                  ],
                  if (bottomWidget != null) ...[
                    bottomWidget!,
                    const SizedBox(height: 10),
                  ],
                  if (description != null) ...[
                    ExpansionTile(
                      title: const Text("Synopsis"),
                      maintainState: true,
                      children: [_buildSynopsisText()],
                    ),
                  ],
                  // Expanded(child: child)
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsisText() {
    return Builder(
      builder: (context) => Text(
        description.toString(),
        softWrap: true,
        style: Theme.of(context).textTheme.bodyText1?.copyWith(height: 1.4),
      ),
    );
  }

  Align _buildGenres() {
    return Align(
      alignment: Alignment.topLeft,
      child: Builder(builder: (context) {
        return Text(
          subtitle!,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Colors.grey.shade400,
                fontSize: 20,
              ),
        );
      }),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return ScaffoldWithButton(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            _buildBackdropImage(),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _linearGradient(context),
              ),
              padding: const EdgeInsets.all(50.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        imageUris?.logo != null
                            ? _buildLogo(imageUris!.logo!)
                            : _buildHeadlineText(),
                        const SizedBox(height: 20),
                        if (actions != null) ...[
                          Row(children: actions!),
                          const SizedBox(height: 10)
                        ],
                        if (meta != null)
                          for (final row in meta!) ...[
                            Row(children: row),
                            const SizedBox(height: 10)
                          ],
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildGenres()
                        ],
                        if (description != null) ...[
                          const SizedBox(height: 20),
                          Expanded(
                            child: TickerText(
                              scrollDirection: Axis.vertical,
                              child: _buildSynopsisText(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (bottomWidget != null) bottomWidget!,
                      ],
                    ),
                  ),
                  const SizedBox(width: 50, height: 50),
                  Flexible(
                    flex: 5,
                    child: child ?? const SizedBox.shrink(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeadlineText() => Builder(
        builder: (context) {
          return Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline1,
            ),
          );
        },
      );

  LinearGradient _linearGradient(BuildContext context) {
    return LinearGradient(
      begin: isWide(context) ? Alignment.centerLeft : Alignment.topCenter,
      end: isWide(context) ? Alignment.centerRight : Alignment.bottomCenter,
      colors: [Colors.black.withAlpha(230), Colors.transparent],
    );
  }

  Widget _buildLogo(String logo) {
    if (isSvg(imageUris!.logo!)) {
      return Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200,
          ),
          child: SvgPicture.network(
            imageUris!.logo!,
            height: 150,
            color: Colors.grey.shade50,
            colorBlendMode: BlendMode.srcIn,
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageBuilder: (context, imageProvider) {
          return Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Image(image: imageProvider),
            ),
          );
        },
        imageUrl: imageUris!.logo!,
        fadeInDuration: const Duration(milliseconds: 150),
        errorWidget: (context, url, error) => _buildHeadlineText(),
        fit: BoxFit.scaleDown,
      );
    }
  }

  Widget _buildBackdropImage() {
    return imageUris?.backdrop != null
        ? CachedNetworkImage(
            fadeInDuration: const Duration(milliseconds: 300),
            imageUrl: imageUris!.backdrop!,
            fit: BoxFit.cover,
            placeholder: (context, url) => _theatreBackdrop,
            errorWidget: (context, url, error) => _theatreBackdrop,
            width: double.infinity,
            height: double.infinity,
          )
        : _theatreBackdrop;
  }

  Widget get _theatreBackdrop => Image.asset(
        "assets/theatre.jpg",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
}
