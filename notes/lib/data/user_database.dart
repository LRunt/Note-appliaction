import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';

class UserDatabase {
  /// If the user is logged or not
  /// 0 - user id not logged
  /// 1 - user is logged
  int isLogged = 0;

  /// Username of the user
  String username = "";

  /// Password of the user
  String password = "";

  void createDefaultData() {
    boxUser.put(USER_LOGGED, isLogged);
  }

  void loadData() {}

  void updateDatabase() {}
}
