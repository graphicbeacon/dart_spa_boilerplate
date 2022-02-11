import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

import './utils.dart';

class UserApi {
  DbCollection store;

  UserApi(this.store);

  Handler get router {
    final router = Router();

    router.get('/', (Request req) async {
      final authDetails = req.context['authDetails'] as JWT;
      final user = await store.findOne(
          where.eq('_id', ObjectId.fromHexString(authDetails.subject!)));

      if (user == null) {
        return Response.notFound('User details not found');
      }

      return Response.ok('{ "email": "${user['email']}" }', headers: {
        'content-type': 'application/json',
      });
    });

    final handler =
        Pipeline().addMiddleware(checkAuthorisation()).addHandler(router);

    return handler;
  }
}
