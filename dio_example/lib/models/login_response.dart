class LoginResponse {
  const LoginResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, Object?> json) {
    return LoginResponse(
      id: json["id"]! as int,
      username: json["username"]! as String,
      email: json["email"]! as String,
      firstName: json["firstName"]! as String,
      lastName: json["lastName"]! as String,
      gender: json["gender"]! as String,
      image: json["image"]! as String,
      accessToken: json["accessToken"] as String?,
      refreshToken: json["refreshToken"] as String?,
    );
  }

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? accessToken,
    String? refreshToken,
  }) {
    return LoginResponse(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      "id": id,
      "username": username,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "image": image,
      "accessToken": ?accessToken,
      "refreshToken": ?refreshToken,
    };
  }
}
