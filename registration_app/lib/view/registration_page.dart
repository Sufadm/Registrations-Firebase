import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registration_app/provider/login_provider.dart';
import 'package:registration_app/services/auth.dart';
import 'package:registration_app/view/homescreen.dart';
import 'package:registration_app/view/login_screen.dart';
import 'package:registration_app/view/widgets/buttons.dart';
import 'package:registration_app/view/widgets/textform_widget.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});
  final AuthService _auth = AuthService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  'Email',
                ),
                //?textformfield widget---------------------------------------
                TextFormFieldWidget(
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter E mail' : null,
                  onChanged: (value) =>
                      Provider.of<LoginModel>(context, listen: false)
                          .updateEmail(value),
                  hintText: 'Enter your Email',
                  icon: Icons.email,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Password',
                ),
                TextFormFieldWidget(
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 3 ? 'Please enter a password' : null,
                  onChanged: (value) =>
                      Provider.of<LoginModel>(context, listen: false)
                          .updatePassword(value),
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<LoginModel>(
                  builder: (context, loginModel, _) => loginModel.loading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomElevatedButtons(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              FocusScopeNode currentfocus =
                                  FocusScope.of(context);
                              if (!currentfocus.hasPrimaryFocus) {
                                currentfocus.unfocus();
                              }
                              loginModel.loading = true;
                              try {
                                dynamic result =
                                    await _auth.signEmailAndPassword(
                                  loginModel.email,
                                  loginModel.password,
                                );
                                if (result == null) {
                                  loginModel.setError(
                                    'Email and password combination not found. Please register.',
                                  );
                                  Future.delayed(const Duration(seconds: 5),
                                      () {
                                    loginModel.setError('');
                                  });
                                  loginModel.loading = false;
                                } else {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                  );
                                  loginModel.loading = false;
                                }
                              } catch (error) {
                                loginModel.setError(error.toString());
                              }
                            }
                          },
                          text: 'Login',
                        ),
                ),
                Consumer<LoginModel>(
                  builder: (context, loginModel, _) => Visibility(
                    visible: loginModel.error.isNotEmpty,
                    child: Text(
                      loginModel.error,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VerificationScreen()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 150),
                    child: const Text(
                      'Register',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
