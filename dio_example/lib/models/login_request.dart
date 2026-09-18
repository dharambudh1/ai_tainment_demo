class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
    required this.expiresInMins,
  });

  factory LoginRequest.from({required Map<String, dynamic> json}) {
    return LoginRequest(
      username: json["username"]! as String,
      password: json["password"]! as String,
      expiresInMins: json["expiresInMins"] as int,
    );
  }

  final String username;
  final String password;
  final int expiresInMins;

  Map<String, Object> toJson() {
    return <String, Object>{
      "username": username,
      "password": password,
      "expiresInMins": expiresInMins,
    };
  }
}
