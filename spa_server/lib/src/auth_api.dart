import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'token_service.dart';
import 'utils.dart';

class AuthApi {
  DbCollection store;
  String secret;
  TokenService tokenService;

  AuthApi(this.store, this.secret, this.tokenService);

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
      await store.insertOne({
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
      try {
        final tokenPair = await tokenService.createTokenPair(userId);
        return Response.ok(json.encode(tokenPair.toJson()), headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        });
      } catch (e) {
        return Response.internalServerError(
            body: 'There was a problem logging you in. Please try again.');
      }
    });

    router.post('/logout', (Request req) async {
      final auth = req.context['authDetails'];
      if (auth == null) {
        return Response.forbidden('Not authorised to perform this operation.');
      }

      try {
        await tokenService.removeRefreshToken((auth as JWT).jwtId!);
      } catch (e) {
        return Response.internalServerError(
            body:
                'There was an issue logging out. Please check and try again.');
      }

      return Response.ok('Successfully logged out');
    });

    router.post('/refreshToken', (Request req) async {
      final auth = req.context['authDetails'] as JWT?;
      if (auth is JWT) {
        return Response(400, body: 'Id Token is still valid.');
      }

      final payload = await req.readAsString();
      final payloadMap = json.decode(payload);

      // Verify current token pair
      late JWT token;

      try {
        token = JWT.verify(payloadMap['refreshToken'], SecretKey(secret));

        final dbToken = await tokenService.getRefreshToken(token.jwtId!);

        if (dbToken == null) {
          return Response(400, body: 'Refresh token is not recognised.');
        }
      } on JWTExpiredError {
        return Response(400, body: 'Refresh token is expired.');
      } catch (err) {
        return Response(400, body: err.toString());
      }

      // Generate new pair
      try {
        final tokenPair = await tokenService.createTokenPair(token.subject!);
        return Response.ok(
          json.encode(tokenPair.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: 'There was a problem creating a new token. Please try again.',
        );
      }
    });

    return router;
  }
}
