import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

class StaticAssetsApi {
  final String folderPath;

  StaticAssetsApi(this.folderPath);

  Router get router {
    final router = Router();

    router.get('/<file|.*>', (Request req) async {
      final assetPath = p.join(folderPath, req.requestedUri.path.substring(1));
      return await createFileHandler(assetPath)(req);
    });

    return router;
  }
}
