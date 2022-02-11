import 'package:envify/envify.dart';

part 'config.g.dart';

@Envify()
abstract class Env {
  static const String secretKey = _Env.secretKey;
  static const String mongoUrl = _Env.mongoUrl;
  static const String redisHost = _Env.redisHost;
  static const String redisPassword = _Env.redisPassword;
  static const int redisPort = _Env.redisPort;
  static const int serverPort = _Env.serverPort;
}
