import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registration_app/model/registration_mode.dart';
import 'package:registration_app/provider/login_provider.dart';
import 'package:registration_app/services/auth.dart';
import 'package:registration_app/services/firestore.dart';
import 'package:registration_app/view/homescreen.dart';
import 'package:registration_app/view/widgets/buttons.dart';
import 'package:registration_app/view/widgets/textform_widget.dart';

class VerificationScreen extends StatelessWidget {
  VerificationScreen({
    Key? key,
  }) : super(key: key);

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterModel>(
      create: (_) => RegisterModel(),
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Consumer<RegisterModel>(
            builder: (context, registerModel, _) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: [
                    //?textformfield---
                    TextFormFieldWidget(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Email';
                        }
                        if (!isValidEmail(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: registerModel.updateEmail,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormFieldWidget(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        }
                        return null;
                      },
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: registerModel.updatePassword,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormFieldWidget(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Confirm Password';
                        }
                        if (value != registerModel.password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      hintText: 'Confirm Password',
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: registerModel.updatePasswordagain,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //?submit button--------------------------------------------
                    registerModel.loading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomElevatedButtons(
                            text: 'Submit',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScopeNode currentfocus =
                                    FocusScope.of(context);
                                if (!currentfocus.hasPrimaryFocus) {
                                  currentfocus.unfocus();
                                }
                                registerModel.loading = true;
                                try {
                                  dynamic result =
                                      await _auth.resgisterwithEmailAndPaswword(
                                    registerModel.email,
                                    registerModel.password,
                                  );
                                  if (result == null) {
                                    registerModel.setError(
                                        'An error occurred during registration.');
                                    registerModel.loading = false;
                                  } else {
                                    try {
                                      final user = ProfileModel(
                                        uid: _auth.auth.currentUser!.uid,
                                        email: registerModel.email,
                                        password: registerModel.password,
                                        confirmPassword:
                                            registerModel.confirmpassword,
                                      );

                                      await FirestoreService().createUser(user);

                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const HomeScreen();
                                      }));
                                    } catch (error) {
                                      registerModel.setError(error.toString());
                                    }
                                  }
                                  registerModel.loading = false;
                                } catch (error) {
                                  registerModel.setError(error.toString());

                                  registerModel.loading = false;
                                }
                              }
                            },
                          ),

                    if (registerModel.error.isNotEmpty)
                      Text(
                        registerModel.error,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

//?email format function--------------------------------------------------------
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }
}
