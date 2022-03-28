import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_manager/models/user.dart';

class UserServices {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future addUserDataToDatabase(AppUser appUser) async {
    String uid = appUser.uid;
    String email = appUser.email;
    String password = appUser.password;
    String userName = appUser.userName;
    
    Map<String, dynamic> data = {
      "uid": uid,
      "email": email,
      "password": password,
      "userName": userName
    };
    await _firebaseFirestore.collection("Users").doc(uid).set(data);
  }

  // Users => uid <= getData

  Future<Stream<DocumentSnapshot>> getUserData(String uid) async {
    return _firebaseFirestore.collection("Users").doc(uid).snapshots();
  }


}
