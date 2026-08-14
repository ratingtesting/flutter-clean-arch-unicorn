Map<String, dynamic> ktestUserMap = {
  "id": 15,
  "username": "kminchelle",
  "email": "kminchelle@qq.com",
  "firstName": "Jeanne",
  "password": "",
  "lastName": "Halvorson",
  "gender": "female",
  "image": "https://robohash.org/autquiaut.png?size=50x50&set=set1",
  "token": "eyJhbG...xKhs",
};

/// Expected output from User.toJson() - without password/token for security
Map<String, dynamic> ktestUserSecureMap = {
  "id": 15,
  "username": "kminchelle",
  "email": "kminchelle@qq.com",
  "firstName": "Jeanne",
  "lastName": "Halvorson",
  "gender": "female",
  "image": "https://robohash.org/autquiaut.png?size=50x50&set=set1",
};

/// Cached user data - for SecureStorage only (no token in this model)
String userCachedData = '''
{
 "id": 15,
  "username": "kminchelle",
  "email": "kminchelle@qq.com",
  "firstName": "Jeanne",
  "lastName": "Halvorson",
  "gender": "female",
  "image": "https://robohash.org/autquiaut.png?size=50x50&set=set1"
}
''';
