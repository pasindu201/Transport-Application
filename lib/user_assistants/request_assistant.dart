import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    try {
      final httpResponse = await http.get(Uri.parse(url));

      if (httpResponse.statusCode == 200) {
        final responseData = httpResponse.body;
        final decodedResponseData = jsonDecode(responseData);

        return decodedResponseData;
      } else {
        return "Error occurred. Failed. Status code: ${httpResponse.statusCode}";
      }
    } catch (e) {
      return "Error occurred. Failed. Exception: $e";
    }
  }
}
