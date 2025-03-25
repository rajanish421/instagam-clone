
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import '../models/userModel.dart';

class UserProvider extends ChangeNotifier{
  User?  _user;
  final authMethods methods = authMethods();
  User get getUser =>_user!;

  Future<void> refreshUser()async{
    User user = await methods.getUserData();
    _user = user;
    notifyListeners();
  }

}