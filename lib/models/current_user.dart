import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CurrentUser {
  static UserModel? currentUser;
}


