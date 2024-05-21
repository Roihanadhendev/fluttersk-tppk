import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();
  late String _email, _password, _name;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isObscure = true;
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
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
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 22.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: "Nama Lengkap",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Masukkan Nama Lengkap" : null,
                        onSaved: (newValue) => setState(() {
                          this._name = newValue!;
                        }),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Masukkan Email" : null,
                        onSaved: (newValue) => setState(() {
                          this._email = newValue!;
                        }),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value!.length < 8
                            ? "Password minimal 8 karakter"
                            : null,
                        onSaved: (newValue) => setState(() {
                          this._password = newValue!;
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
                                      try {
                                        UserCredential userCredential =
                                            await _auth
                                                .createUserWithEmailAndPassword(
                                                    email: _email,
                                                    password: _password);
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pushNamed('/login');
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'weak-password') {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text(
                                                        'Password Terlalu Lemah'),
                                                    content: Text(
                                                        'Silahkan gunakan password yang lebih kuat'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text('OK'))
                                                    ],
                                                  ));
                                        } else if (e.code == 'email-found') {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text(
                                                        'Email Sudah Terdaftar'),
                                                    content: Text(
                                                        'Silahkan gunakan email yang lain'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text('OK'))
                                                    ],
                                                  ));
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('Daftar')),
                            )
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
