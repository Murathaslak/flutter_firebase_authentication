// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_dersleri/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Dersleri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late FirebaseAuth auth;
  final String _email = "murathaslak69@gmail.com";
  final String _password = "asdasd";

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint(
            "User oturum açık ${user.email} ve email durumu ${user.emailVerified}");
      } else {
        debugPrint("User oturumu kapalı");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Firebase Dersleri")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text("Email/Sifre Kayıt")),
            ElevatedButton(
                onPressed: () {
                  loginUserEmailAndPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: Text("Email/Sifre Giris")),
            ElevatedButton(
                onPressed: () {
                  signOutUser();
                },
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                child: Text("Oturumu Kapat")),
            ElevatedButton(
                onPressed: () {
                  deleteUser();
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text("Hesabımı Sil")),
            ElevatedButton(
                onPressed: () {
                  changePassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.purple),
                child: Text("Parola Değiştir")),
            ElevatedButton(
                onPressed: () {
                  changeEmail();
                },
                style: ElevatedButton.styleFrom(primary: Colors.pink),
                child: Text("Email Değiştir")),
            ElevatedButton(
                onPressed: () {
                  loginGoogle();
                },
                style: ElevatedButton.styleFrom(primary: Colors.pink),
                child: Text("Gmail İle Giriş")),
            ElevatedButton(
                onPressed: () {
                  loginPhone();
                },
                style: ElevatedButton.styleFrom(primary: Colors.amber),
                child: Text("Telefon İle Giriş")),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCredential.user;

      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint("Kullanıcının mailini onaylanmış,ilgili sayfaya gidebilir");
      }

      debugPrint(_userCredential.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint("***Giriş Başarılı*** \n ${_userCredential.toString()}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    await GoogleSignIn().disconnect();
    await auth.signOut();
  }

  void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      debugPrint("Önce Oturum Acınız");
    }
  }

  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword("asdasd");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("Tekrar oturum açınız");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword("asdasd");
        await auth.signOut();
        debugPrint("Şifre Güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.updateEmail("murathaslak69@gmail.com");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("Tekrar oturum açınız");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updateEmail("murathaslak69@gmail.com");
        await auth.signOut();
        debugPrint("Email Güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Once signed in, return the UserCredential
  }

  void loginPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905347485853',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint("Verification completed tetiklendi");
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smsCode = "123456";
        debugPrint("Code sent tetiklendi");
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);
        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("Code auto retriveltimeout tetiklendi");
      },
    );
  }
}
