import 'package:redis/redis.dart';
import 'package:uuid/uuid.dart';

import 'token_pair.dart';
import 'utils.dart';

class TokenService {
  TokenService(this.db, this.secret);

  final RedisConnection db;
  final String secret;

  static late Command _cache;
  final String _prefix = 'token';

  Future<void> start({
    required String host,
    required password,
    required int port,
  }) async {
    _cache = await db.connect(host, port);
    await _cache.send_object(['AUTH', password]);
  }

  Future<TokenPair> createTokenPair(String userId) async {
    final tokenId = Uuid().v4();
    final token =
        generateJwt(userId, 'http://localhost', secret, jwtId: tokenId);

    final refreshTokenExpiry = Duration(seconds: 60);
    final refreshToken = generateJwt(
      userId,
      'http://localhost',
      secret,
      jwtId: tokenId,
      expiry: refreshTokenExpiry,
    );

    await addRefreshToken(tokenId, refreshToken, refreshTokenExpiry);

    return TokenPair(token, refreshToken);
  }

  Future<void> addRefreshToken(String id, String token, Duration expiry) async {
    await _cache.send_object(['SET', '$_prefix:$id', token]);
    await _cache.send_object(['EXPIRE', '$_prefix:$id', expiry.inSeconds]);
  }

  Future<dynamic>? getRefreshToken(String id) async {
    return await _cache.get('$_prefix:$id');
  }

  Future<void> removeRefreshToken(String id) async {
    await _cache.send_object(['EXPIRE', '$_prefix:$id', '-1']);
  }
}
