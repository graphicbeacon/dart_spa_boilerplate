import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('it should return a 200 response', () async {
    final response = await http.get('http://localhost:8080');

    expect(response.statusCode, HttpStatus.ok);
  });
}
