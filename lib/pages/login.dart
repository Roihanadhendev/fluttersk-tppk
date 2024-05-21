import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  late String _email, _password;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isObscure = true;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/loginregister.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Sistem Informasi Layanan Pengaduan & Pencegahan Penanggulangan Kekerasan di Satuan Pendidikan Provinsi Sumatera Selatan",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Sign In",
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? "Masukan email" : null,
                          onSaved: (value) => setState(() {
                            this._email = value!;
                          }),
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                          validator: (value) => value!.length < 5
                              ? 'Enter at least 8 characters'
                              : null,
                          onSaved: (NewValue) => setState(() {
                            this._password = NewValue!;
                          }),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        _isLoading
                            ? LoadingAnimationWidget.waveDots(
                                color: Colors.white, size: 50.0)
                            : Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formkey.currentState!.validate()) {
                                        _formkey.currentState!.save();
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          UserCredential _userCredential =
                                              await _auth
                                                  .signInWithEmailAndPassword(
                                                      email: _email,
                                                      password: _password);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pushNamed('/home');
                                        } on FirebaseAuthException catch (e) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          if (e.code == 'user-not-found') {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                    'User not Found for Email'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Okay')),
                                                ],
                                              ),
                                            );
                                          } else if (e.code ==
                                              'wrong-password') {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                        title: Text('Error'),
                                                        content: Text(
                                                            'Wrong Password For The Username Entered'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child:
                                                                  Text('Okay'))
                                                        ]));
                                          }
                                        }
                                      }
                                    },
                                    child: const Text("Masuk")),
                              ),
                        TextButton(
                            onPressed: () => {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed("/resetPassword"),
                                },
                            child: _PasswordResetbutton()),
                        SizedBox(
                          height: 20.0,
                          child: Text(
                            "atau",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SignInButton(
                          Buttons.Google,
                          onPressed: () async {
                            // Trigger Google sign in flow
                            final GoogleSignInAccount? googleUser =
                                await _googleSignIn.signIn();

                            if (googleUser != null) {
                              // Obtain the authentication result (Google Sign In credential)
                              final GoogleSignInAuthentication googleAuth =
                                  await googleUser.authentication;

                              // Create a Firebase credential with the Google Sign In credential
                              final credential = GoogleAuthProvider.credential(
                                  accessToken: googleAuth.accessToken,
                                  idToken: googleAuth.idToken);

                              // Sign in with Firebase using the Google credential
                              try {
                                final UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithCredential(credential);

                                // Navigate to the home screen (or handle successful login)
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamed('/home');
                              } on FirebaseAuthException catch (e) {
                                // Handle Firebase authentication errors (optional)
                                print(e.code);
                                print(e.message);
                              } catch (error) {
                                // Handle other errors (optional)
                                print(error);
                              }
                            }
                          },
                        ),
                        TextButton(
                            onPressed: () => {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed("/register")
                                },
                            child: Text(
                              'Belum Memiliki Akun ? Daftar',
                              style: TextStyle(color: Colors.white),
                            )),
                        TextButton(
                            onPressed: () => {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed("/home")
                                },
                            child: Text(
                              "Login as Guest Account",
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                  ))),
        )
      ],
    ));
  }
}

class _PasswordResetbutton extends StatefulWidget {
  const _PasswordResetbutton({super.key});

  @override
  State<_PasswordResetbutton> createState() => __PasswordResetbuttonState();
}

class __PasswordResetbuttonState extends State<_PasswordResetbutton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      child: Text(
        'Lupa Kata Sandi ?',
        style: TextStyle(
          color: isHovered ? Colors.white : Colors.white,
          decoration:
              isHovered ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
