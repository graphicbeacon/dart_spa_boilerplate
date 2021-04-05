class TokenPair {
  TokenPair(this.idToken, this.refreshToken);

  final String idToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'token': idToken,
        'refreshToken': refreshToken,
      };
}
