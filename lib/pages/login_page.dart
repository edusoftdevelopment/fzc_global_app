import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/api/user_api.dart';
import 'package:fzc_global_app/components/text_input.dart';
import 'package:fzc_global_app/models/user_model.dart';
import 'package:fzc_global_app/screens/splash_screen.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPending = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void onSubmit() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        setState(() {
          isPending = true;
        });
        UserModel response =
            await loginUser(emailController.text, passwordController.text);

        SecureStorage secureStorage = SecureStorage();
        await secureStorage.writeSecureData(
            SecureStorageKeys.userId, response.loginId.toString());
        await secureStorage.writeSecureData(
            SecureStorageKeys.email, response.emailAddress);
        await secureStorage.writeSecureData(
            SecureStorageKeys.username, response.userName);
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const CustomSplashScreen()));
          Fluttertoast.showToast(
            msg: "Logged In Successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString().replaceAll("Exception", ""),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 238, 4, 16),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        setState(() {
          isPending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: const Text("Login"),
        // Settings button temporarily hidden
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings, color: Constants.whiteColor),
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/settings/configuration');
        //     },
        //     tooltip: 'API Configuration',
        //   ),
        // ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("FZC Parts",
                  style: TextStyle(
                    fontSize: 28,
                  )),
              const SizedBox(
                height: 30,
              ),
              TextInput(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(
                height: 30,
              ),
              TextInput(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    onPressed: isPending ? null : onSubmit,
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isPending) ...[
                          const CircularProgressIndicator()
                        ] else ...[
                          const Text("Login"),
                        ],
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: isPending
                            ? Constants.primaryColor200
                            : Constants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
