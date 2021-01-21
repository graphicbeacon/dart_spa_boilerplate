import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserApi {
  Router get router {
    final router = Router();

    router.get('/', (Request req) {
      return Response.ok('{ "users": ["Jermaine", "Sally", "Mark"] }',
          headers: {
            'content-type': 'application/json',
          });
    });

    return router;
  }
}
