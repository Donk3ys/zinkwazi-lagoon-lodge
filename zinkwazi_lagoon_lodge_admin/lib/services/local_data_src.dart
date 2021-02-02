import 'dart:html' show window;
import '../core/exception.dart';
import '../core/success.dart';

const JWT_KEY = 'jwt';

abstract class LocalDataSourceContract {
  Future<String> get jwt;
  Future<Success> setJwt(String jwt);
}

class LocalDataSource implements LocalDataSourceContract {

  // Getters
  @override
  Future<String> get jwt async {
    try {
      // Get jwt
      final jwt = window.localStorage[JWT_KEY];

      // Check jwt not null
      if (jwt == null || jwt == 'null') { throw CacheException('No token stored'); }

      print("[GETTING JWT] : $jwt");
      return jwt;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }


  // Setters
  @override
  Future<Success> setJwt(String jwt) async {
    print("[STORING JWT] : $jwt");
    try {
      window.localStorage[JWT_KEY] = jwt;
      return CacheSuccess('[CACHE STORE JWT] success');
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

}