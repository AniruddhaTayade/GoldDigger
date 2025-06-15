import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'sign_up.dart'; // ✅ Replace with correct path to your SignInScreen file

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CreateAccountPage(),
  ));
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌌 Fullscreen Background Image
          Image.asset(
            'assets/login.png',
            fit: BoxFit.cover,
          ),

          // 🌚 Overlay for readability
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // 🔲 Foreground UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ListView(
                children: [
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Fill your information below or register with your\nsocial account",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildTextField("Name"),
                  const SizedBox(height: 20),
                  buildTextField("Email"),
                  const SizedBox(height: 20),
                  buildTextField("Password", obscure: true),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                      ),
                      const Text(
                        "Agree with ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Terms & Condition",
                          style: TextStyle(
                              color: Color(0xFFBB86FC),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add sign-up logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Or sign up with",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialCircle(
                          icon: FontAwesomeIcons.facebook, color: Colors.blue),
                      SocialCircle(
                          icon: FontAwesomeIcons.google, color: Colors.red),
                      SocialCircle(
                          icon: FontAwesomeIcons.apple, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignInScreen(), // ✅ Your login screen
                          ),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Already have account? ",
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: Color(0xFFBB86FC),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class SocialCircle extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color? color;

  const SocialCircle({
    super.key,
    this.icon,
    this.iconAsset,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 15),
          )
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: color ?? Colors.black, size: 30)
            : iconAsset != null
                ? Image.asset(iconAsset!, width: 30, height: 30)
                : const SizedBox(),
      ),
    );
  }
}
