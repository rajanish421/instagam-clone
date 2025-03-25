import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods{
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // to upload image
  Future<String> uploadImageToStorag(String childName , Uint8List file , bool isPost)async{

    Reference ref = await _storage.ref().child(childName).child(_auth.currentUser!.uid);
   // this code is for store multiple post with same uid and different id(uuid)
    // if we not use this then override the previous post
    if(isPost){
      String id = Uuid().v1();
     ref = ref.child(id);
    }
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap =  await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

}