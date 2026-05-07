class StartupCard {
  final String id;
  final String name;
  final String stage;
  final String shortDescription;
  final double capitalRaisedCents;
  final double totalTokensIssued;
  final double currentTokenPriceCents;
  final String? coverImageUrl;
  final List<String> tags;

  StartupCard({required this.id, required this.name, required this.stage,
    required this.shortDescription, required this.capitalRaisedCents,
    required this.totalTokensIssued, required this.currentTokenPriceCents,
    this.coverImageUrl, required this.tags
  });
}