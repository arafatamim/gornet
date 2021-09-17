import 'package:goribernetflix/models/models.dart';

class Section {
  final Future<List<SearchResult>> itemFetcher;
  final String? title;
  const Section({
    required this.itemFetcher,
    this.title,
  });
}
