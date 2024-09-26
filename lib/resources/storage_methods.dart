import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    try {
      // Check if the user is authenticated
      if (_auth.currentUser == null) {
        throw FirebaseAuthException(
            code: "USER_NOT_AUTHENTICATED",
            message: "User is not authenticated.");
      }

      // Creating a reference for the image in Firebase Storage
      Reference ref =
          _storage.ref().child(childName).child(_auth.currentUser!.uid);

      // Start uploading the file
      UploadTask uploadTask = ref.putData(file);

      // Listen to the upload task for status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      // Wait for the upload to complete
      TaskSnapshot snap = await uploadTask;

      // Get the download URL for the image
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl; // Return the URL for the uploaded image
    } catch (err) {
      // Print detailed error to console and return error message
      print('Error during image upload: $err');
      return err.toString();
    }
  }
}
