class ProductResult {
  final String productName;
  final List<String> ingredients;
  final int healthScore;
  final String aiExplanation;
  final List<String> toxicityAlerts;
  final List<String> alternatives;

  ProductResult({
    required this.productName,
    required this.ingredients,
    required this.healthScore,
    required this.aiExplanation,
    required this.toxicityAlerts,
    required this.alternatives,
  });

  factory ProductResult.fromJson(Map<String, dynamic> json) {
    return ProductResult(
      productName: json['productName'] ?? 'Unknown Product',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      healthScore: json['healthScore'] ?? 0,
      aiExplanation: json['aiExplanation'] ?? 'No analysis available',
      toxicityAlerts: List<String>.from(json['toxicityAlerts'] ?? []),
      alternatives: List<String>.from(json['alternatives'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'ingredients': ingredients,
      'healthScore': healthScore,
      'aiExplanation': aiExplanation,
      'toxicityAlerts': toxicityAlerts,
      'alternatives': alternatives,
    };
  }
}
