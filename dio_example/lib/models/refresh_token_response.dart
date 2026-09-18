class RefreshTokenResponse {
  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, Object?> json) {
    return RefreshTokenResponse(
      accessToken: json["accessToken"]! as String,
      refreshToken: json["refreshToken"]! as String,
    );
  }

  final String accessToken;
  final String refreshToken;

  Map<String, Object> toJson() {
    return <String, Object>{
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}
