import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'utils.dart';

class AuthApi {
  DbCollection store;
  String secret;

  AuthApi(this.store, this.secret);

  Router get router {
    final router = Router();

    router.post('/register', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = json.decode(payload);
      final email = userInfo['email'];
      final password = userInfo['password'];

      // Ensure email and password fields are present
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response(HttpStatus.badRequest,
            body: 'Please provide your email and password');
      }

      // Ensure user is unique
      final user = await store.findOne(where.eq('email', email));
      if (user != null) {
        return Response(HttpStatus.badRequest, body: 'User already exists');
      }

      // Create user
      final salt = generateSalt();
      final hashedPassword = hashPassword(password, salt);
      await store.save({
        'email': email,
        'password': hashedPassword,
        'salt': salt,
      });

      return Response.ok('Successfully registered user');
    });

    router.post('/login', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = json.decode(payload);
      final email = userInfo['email'];
      final password = userInfo['password'];

      // Ensure email and password fields are present
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response(HttpStatus.badRequest,
            body: 'Please provide your email and password');
      }

      final user = await store.findOne(where.eq('email', email));
      if (user == null) {
        return Response.forbidden('Incorrect user and/or password');
      }

      final hashedPassword = hashPassword(password, user['salt']);
      if (hashedPassword != user['password']) {
        return Response.forbidden('Incorrect user and/or password');
      }

      // Generate JWT and send with response
      final userId = (user['_id'] as ObjectId).toHexString();
      final token = generateJwt(userId, 'http://localhost', secret);

      return Response.ok(json.encode({'token': token}), headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      });
    });

    router.post('/logout', (Request req) async {
      if (req.context['authDetails'] == null) {
        return Response.forbidden('Not authorised to perform this operation.');
      }
      return Response.ok('Successfully logged out');
    });

    return router;
  }
}
