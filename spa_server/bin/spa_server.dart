import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:spa_server/spa_server.dart';

void main(List<String> arguments) async {
  final app = Router();

  app.mount('/users/', UserApi().router);

  app.get('/assets/<file|.*>', createStaticHandler('public'));

  app.get('/<name|.*>', (Request request, String name) {
    final indexFile = File('public/index.html').readAsStringSync();
    return Response.ok(indexFile, headers: {'content-type': 'text/html'});
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  await io.serve(handler, 'localhost', 8080);
}
