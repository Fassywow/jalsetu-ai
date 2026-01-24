import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyCyEWJpF3cjzDHHwK3_jJsiibO7u-yUUGE'; // TODO: Replace with actual API key
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
    );
  }

  Future<String> generateContent(String prompt,
      {File? image, String language = 'en', List<Content>? history}) async {
    final systemPrompt = _getSystemPrompt(language);

    // For vision requests, we still use the single-turn generateContent for now
    // as multi-turn with images can be complex or model-dependent.
    // However, we can include previous text context if needed.
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final fullPrompt = '$systemPrompt\n\nUser Query: $prompt';
      final content = [
        Content.multi([
          TextPart(fullPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      try {
        final response = await _visionModel.generateContent(content);
        return response.text ?? 'No response generated.';
      } catch (e) {
        return 'Error: $e';
      }
    } else {
      // For text-only chat, use startChat to maintain history
      try {
        // We prepend the system prompt to the history or the first message
        List<Content> chatHistory = history ?? [];

        // If history is empty, we can just send the prompt with system instruction.
        // But startChat is better for ongoing context.

        final chat = _model.startChat(history: chatHistory);

        // Send the system prompt + user prompt combined for the current turn
        // OR rely on the model's system instruction if supported (Gemini 1.5).
        // For 'gemini-pro', we often prepend context.

        // Strategy: Send the system prompt as part of the message content if it's a new chat,
        // or just the user prompt if history exists.
        // A simple way is to prepend system prompt to the user's current message.

        final fullMessage = '$systemPrompt\n\n$prompt';
        final content = Content.text(fullMessage);

        final response = await chat.sendMessage(content);
        return response.text ?? 'No response generated.';
      } catch (e) {
        return 'Error: $e';
      }
    }
  }

  String _getSystemPrompt(String language) {
    String langInstruction = '';
    switch (language) {
      case 'hi':
        langInstruction = 'Respond in Hindi (but keep JSON keys in English).';
        break;
      case 'gu':
        langInstruction =
            'Respond in Gujarati (but keep JSON keys in English).';
        break;
      default:
        langInstruction = 'Respond in English.';
    }

    return '''
You are an expert AI assistant for an app called "Smart Catch AI".
Your domain is strictly limited to **Indian Edible Fishes**, marine life, fishing tips, and seafood preparation.

**CRITICAL: YOU MUST ALWAYS RESPOND IN VALID JSON FORMAT.**
Do not output any text outside the JSON block.
The JSON structure must be as follows:

{
  "type": "general" | "fish_info" | "recipe",
  "message": "Your conversational response here...",
  "data": { ... } // specific data based on type
}

**Types & Data Schemas:**

1. **"general"**: For greetings, general questions, or when no specific fish/recipe detail is needed.
   - "data": null

2. **"fish_info"**: When identifying a fish or giving detailed info about a species.
   - "data": {
       "name": "Common Name",
       "scientific_name": "Scientific Name",
       "description": "Brief description...",
       "nutritional_info": "Key nutrients...",
       "regions": ["Region 1", "Region 2"]
     }

3. **"recipe"**: When asked for a recipe or cooking method.
   - "data": {
       "title": "Recipe Name",
       "ingredients": ["Item 1", "Item 2"],
       "steps": ["Step 1", "Step 2"]
     }

$langInstruction
If the user asks about something unrelated to fish, return type "general" with a polite refusal.
Keep your "message" field concise, helpful, and friendly.

**Formatting Instructions for "message" field:**
- **ALWAYS** start with a clear, bold Title (using Markdown # or ##).
- Follow with a brief subtitle or introductory sentence.
- Use **Bullet Points** for the main content.
- Keep the tone professional, insightful, and structured.
- **Do not** use large blocks of plain text. Break it down.
- Example structure:
  # Title
  Subtitle
  - Point 1
  - Point 2
  - Point 3
''';
  }
}
