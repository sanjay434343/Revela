import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String _openAIUrl = 'https://text.pollinations.ai/openai';
  static const int _requestTimeout = 60;

  /// Analyzes a product image and returns the result
  Future<ProductResult> analyzeProduct(File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Read image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Create payload for AI analysis
      final payload = {
        'model': 'openai',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': '''IMPORTANT: First, determine if this image contains a food/beverage product or consumable item.

If it is NOT a food/beverage/consumable product, respond with:
{
  "isProduct": false,
  "message": "This image does not contain a food or consumable product. Please scan a food item, beverage, or supplement."
}

If it IS a food/beverage/consumable product, analyze it and respond with:
{
  "isProduct": true,
  "productName": "product name (max 50 chars)",
  "ingredients": ["top 5-8 key ingredients only"],
  "healthScore": 0-100,
  "aiExplanation": "brief 2-3 sentence analysis focusing on key health concerns",
  "toxicityAlerts": ["max 3 critical alerts only, each under 60 chars"],
  "alternatives": ["max 3 better alternatives, each under 40 chars"]
}

Keep all responses concise. Focus only on the most important health information.'''
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/png;base64,$base64Image'}
              }
            ]
          }
        ],
        'max_tokens': 800
      };

      // Send request with timeout
      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(
        Duration(seconds: _requestTimeout),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection and try again.');
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Extract AI response content
        String? aiResponse;
        try {
          aiResponse = result['choices'][0]['message']['content'];
        } catch (e) {
          throw Exception('Unable to process AI response. Please try again.');
        }

        if (aiResponse == null || aiResponse.isEmpty) {
          throw Exception('No response received from AI. Please try again.');
        }

        // Parse JSON response from AI
        try {
          // Extract JSON from markdown code blocks if present
          String jsonStr = aiResponse;
          if (aiResponse.contains('```json')) {
            final startIdx = aiResponse.indexOf('```json') + 7;
            final endIdx = aiResponse.lastIndexOf('```');
            if (endIdx > startIdx) {
              jsonStr = aiResponse.substring(startIdx, endIdx).trim();
            }
          } else if (aiResponse.contains('```')) {
            final startIdx = aiResponse.indexOf('```') + 3;
            final endIdx = aiResponse.lastIndexOf('```');
            if (endIdx > startIdx) {
              jsonStr = aiResponse.substring(startIdx, endIdx).trim();
            }
          }

          final analysisData = jsonDecode(jsonStr);
          
          // Check if it's a valid product
          if (analysisData['isProduct'] == false) {
            throw Exception(analysisData['message'] ?? 
              'This image does not contain a food or consumable product. Please scan a food item.');
          }

          // Validate and clean the data
          return _validateAndCleanResult(analysisData);
        } catch (e) {
          if (e.toString().contains('does not contain a food')) {
            rethrow;
          }
          // If JSON parsing fails, try to extract any usable information
          throw Exception('Unable to analyze the product. Please ensure the image is clear and try again.');
        }
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else if (response.statusCode >= 500) {
        throw Exception('Service temporarily unavailable. Please try again later.');
      } else {
        throw Exception('Failed to analyze product. Error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on FormatException {
      throw Exception('Invalid image format. Please use a valid image file.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection and try again.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to analyze product: ${e.toString()}');
    }
  }

  /// Validate and clean the analysis result
  ProductResult _validateAndCleanResult(Map<String, dynamic> data) {
    try {
      // Limit ingredients to top 8
      List<String> ingredients = List<String>.from(data['ingredients'] ?? []);
      if (ingredients.length > 8) {
        ingredients = ingredients.sublist(0, 8);
      }

      // Limit toxicity alerts to 3
      List<String> alerts = List<String>.from(data['toxicityAlerts'] ?? []);
      if (alerts.length > 3) {
        alerts = alerts.sublist(0, 3);
      }

      // Limit alternatives to 3
      List<String> alternatives = List<String>.from(data['alternatives'] ?? []);
      if (alternatives.length > 3) {
        alternatives = alternatives.sublist(0, 3);
      }

      // Truncate product name if too long
      String productName = (data['productName'] ?? 'Unknown Product').toString();
      if (productName.length > 50) {
        productName = productName.substring(0, 47) + '...';
      }

      // Truncate AI explanation if too long
      String explanation = (data['aiExplanation'] ?? '').toString();
      if (explanation.length > 300) {
        explanation = explanation.substring(0, 297) + '...';
      }

      // Validate health score
      int healthScore = data['healthScore'] ?? 50;
      if (healthScore < 0) healthScore = 0;
      if (healthScore > 100) healthScore = 100;

      return ProductResult(
        productName: productName,
        ingredients: ingredients,
        healthScore: healthScore,
        aiExplanation: explanation,
        toxicityAlerts: alerts,
        alternatives: alternatives,
      );
    } catch (e) {
      throw Exception('Invalid product data received. Please try scanning again.');
    }
  }

  /// Alternative method: Analyze using product barcode
  Future<ProductResult> analyzeByBarcode(String barcode) async {
    try {
      final productData = await fetchFromOpenFoodFacts(barcode);
      
      if (productData.isEmpty || productData['status'] == 0) {
        throw Exception('Product not found in database');
      }

      final product = productData['product'];
      final productName = product['product_name'] ?? 'Unknown Product';
      final ingredients = product['ingredients_text']?.split(',').map((e) => e.trim()).toList() ?? [];
      
      // Use AI to analyze the ingredients
      final analysisResult = await analyzeIngredientsWithAI(ingredients, productName);
      
      return analysisResult;
    } catch (e) {
      throw Exception('Barcode analysis failed: $e');
    }
  }

  /// Analyze ingredients list using AI
  Future<ProductResult> analyzeIngredientsWithAI(List<String> ingredients, String productName) async {
    try {
      final payload = {
        'model': 'openai',
        'messages': [
          {
            'role': 'user',
            'content': '''Analyze these ingredients for "$productName" and provide a health assessment.

Ingredients: ${ingredients.join(', ')}

Return your response in JSON format:
{
  "healthScore": 0-100,
  "aiExplanation": "detailed analysis",
  "toxicityAlerts": ["alert1", "alert2"],
  "alternatives": ["alternative1", "alternative2"]
}'''
          }
        ],
        'max_tokens': 1000
      };

      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: _requestTimeout));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final aiResponse = result['choices'][0]['message']['content'];
        
        try {
          String jsonStr = aiResponse;
          if (aiResponse.contains('```json')) {
            final startIdx = aiResponse.indexOf('```json') + 7;
            final endIdx = aiResponse.lastIndexOf('```');
            jsonStr = aiResponse.substring(startIdx, endIdx).trim();
          }

          final analysisData = jsonDecode(jsonStr);
          return ProductResult(
            productName: productName,
            ingredients: ingredients,
            healthScore: analysisData['healthScore'] ?? 50,
            aiExplanation: analysisData['aiExplanation'] ?? '',
            toxicityAlerts: List<String>.from(analysisData['toxicityAlerts'] ?? []),
            alternatives: List<String>.from(analysisData['alternatives'] ?? []),
          );
        } catch (e) {
          return ProductResult(
            productName: productName,
            ingredients: ingredients,
            healthScore: 50,
            aiExplanation: aiResponse,
            toxicityAlerts: [],
            alternatives: [],
          );
        }
      } else {
        throw Exception('AI analysis failed');
      }
    } catch (e) {
      throw Exception('Ingredient analysis failed: $e');
    }
  }

  /// Fetches ingredients from OpenFoodFacts API
  Future<Map<String, dynamic>> fetchFromOpenFoodFacts(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Generate shareable summary content using AI
  Future<String> generateShareableSummary(ProductResult result) async {
    try {
      final payload = {
        'model': 'openai',
        'messages': [
          {
            'role': 'user',
            'content': '''Create a comprehensive yet concise shareable summary for this product analysis:

Product: ${result.productName}
Health Score: ${result.healthScore}/100
Key Ingredients: ${result.ingredients.take(5).join(', ')}
Health Alerts: ${result.toxicityAlerts.isNotEmpty ? result.toxicityAlerts.join(', ') : 'None'}
AI Analysis: ${result.aiExplanation}
Alternatives: ${result.alternatives.isNotEmpty ? result.alternatives.take(2).join(', ') : 'None suggested'}

Create an informative summary (max 400 chars) suitable for sharing. Include:
- Product name with emoji
- Health score with rating
- Top 3 key ingredients
- Main health concerns (if any)
- One alternative suggestion (if available)
- Brief verdict

Use emojis and make it engaging but informative.'''
          }
        ],
        'max_tokens': 250
      };

      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final aiResult = jsonDecode(response.body);
        final summary = aiResult['choices'][0]['message']['content'];
        return summary?.trim() ?? _generateDefaultSummary(result);
      } else {
        return _generateDefaultSummary(result);
      }
    } catch (e) {
      return _generateDefaultSummary(result);
    }
  }

  /// Generate a default shareable summary if AI fails
  String _generateDefaultSummary(ProductResult result) {
    final emoji = result.healthScore >= 80 ? '✅' : result.healthScore >= 60 ? '⚠️' : '❌';
    final rating = result.healthScore >= 80 ? 'Excellent' : result.healthScore >= 60 ? 'Moderate' : 'Poor';
    
    String summary = '''$emoji ${result.productName}
━━━━━━━━━━━━━━━━
📊 Health Score: ${result.healthScore}/100 ($rating)

🧪 Key Ingredients:''';

    // Add top 3 ingredients
    final topIngredients = result.ingredients.take(3).toList();
    for (var ingredient in topIngredients) {
      summary += '\n  • $ingredient';
    }

    // Add alerts if any
    if (result.toxicityAlerts.isNotEmpty) {
      summary += '\n\n⚠️ Health Concerns:';
      for (var alert in result.toxicityAlerts.take(2)) {
        summary += '\n  • $alert';
      }
    }

    // Add alternatives if any
    if (result.alternatives.isNotEmpty) {
      summary += '\n\n💡 Better Options:';
      for (var alt in result.alternatives.take(2)) {
        summary += '\n  • $alt';
      }
    }

    // Add verdict
    summary += '\n\n${result.aiExplanation.substring(0, result.aiExplanation.length > 100 ? 100 : result.aiExplanation.length)}...';
    
    summary += '\n\n━━━━━━━━━━━━━━━━\nScanned with Revela 📱';

    return summary;
  }
}
