import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vaaig/secrets.dart'; // Ensure correct path to secrets.dart

class OpenAIService {
  List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-0125",
          "messages": [
            {
              'role': 'user',
              'content': 'Does this message want to generate an AI picture, image, art or anything similar? $prompt. Simply answer with a yes or no.',
            }
          ],
        }),
      );

      print(res.body);

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'].toString();
        content = content.trim().toLowerCase();

        switch (content) {
          case 'yes':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-0125",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'].toString();
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          'prompt': prompt,
          'n': 1,
        }),
      );

      print(res.body);

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'].toString();
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
