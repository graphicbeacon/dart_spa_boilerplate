import 'package:envify/envify.dart';

part 'config.g.dart';

@Envify()
abstract class Env {
  static const secretKey = _Env.secretKey;
  static const mongoUrl = _Env.mongoUrl;
}
