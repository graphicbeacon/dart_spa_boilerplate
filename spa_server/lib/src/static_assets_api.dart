import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

class StaticAssetsApi {
  final String path;

  StaticAssetsApi({required this.path});

  Router get router {
    final router = Router();

    router.get('/<file|.*>', (Request req) async {
      final assetPath = p.join(path, req.requestedUri.path.substring(1));
      return await createFileHandler(assetPath)(req);
    });

    return router;
  }
}
