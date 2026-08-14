import 'package:equatable/equatable.dart';

/// Domain model for an authenticated user.
///
/// `toJson` excludes `password` and `token` for security — never serialize
/// credentials. Use [toLoginJson] only for the login request payload.
class User extends Equatable {
  const User({
    this.id = 0,
    this.username = '',
    this.password = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.image = '',
    this.token = '',
  });

  final int id;
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String token;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      image: json['image'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  /// Security: excludes password and token from serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }

  /// Login payload — includes credentials.
  Map<String, dynamic> toLoginJson() {
    return {'username': username, 'password': password};
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    gender,
    image,
  ];
}
