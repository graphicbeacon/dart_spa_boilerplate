import 'package:spa_server/spa_server.dart';

void main(List<String> arguments) async {
  const secret = Env.secretKey;
  const port = Env.serverPort;
  final db = await Db.create(Env.mongoUrl);
  final tokenService = TokenService(RedisConnection(), secret);

  await db.open();
  print('Connected to our database');

  await tokenService.start(
    host: Env.redisHost,
    password: Env.redisPassword,
    port: Env.redisPort,
  );
  print('Token Service running...');

  final store = db.collection('users');
  final app = Router();

  app.mount('/auth/', AuthApi(store, secret, tokenService).router);

  app.mount('/users/', UserApi(store).router);

  app.mount('/assets/', StaticAssetsApi(path: 'public').router);

  app.all('/<name|.*>', fallback('public/index.html'));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(secret))
      .addHandler(app);

  await serve(handler, InternetAddress.anyIPv4, port);

  print('HTTP Service running on port $port');
}
