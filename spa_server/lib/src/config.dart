import 'package:envify/envify.dart';

part 'config.g.dart';

@Envify()
abstract class Env {
  static const secretKey = _Env.secretKey;
  static const mongoUrl = _Env.mongoUrl;
  static const redisHost = _Env.redisHost;
  static const int redisPort = _Env.redisPort;
  static const int serverPort = _Env.serverPort;
}
