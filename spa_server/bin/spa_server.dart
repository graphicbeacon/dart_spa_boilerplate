import 'package:spa_server/spa_server.dart';

void main(List<String> arguments) async {
  const secret = Env.secretKey;
  final db = Db(Env.mongoUrl);

  await db.open();
  print('Connected to our database');

  final store = db.collection('users');
  final app = Router();

  app.mount('/auth/', AuthApi(store, secret).router);

  app.mount('/users/', UserApi(store).router);

  app.mount('/assets/', StaticAssetsApi('public').router);

  app.all('/<name|.*>', fallback('public/index.html'));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(secret))
      .addHandler(app);

  await serve(handler, 'localhost', 8080);
}
