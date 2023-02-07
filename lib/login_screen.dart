import 'package:animated_login/animated_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Artboard? riveArtboard;

  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerLookLeft;
  late RiveAnimationController controllerLookRight;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;

  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String testEmail = 'osama22@gmail.com';
  String testPassword = 'osamadev202010';
  final FocusNode focusNodePassword = FocusNode();

  bool isLookLeft = false;
  bool isLookRight = false;
  bool isMain = false;
  removeAllControllers() {
    riveArtboard!.artboard.removeController(controllerIdle);
    riveArtboard!.artboard.removeController(controllerHandsUp);
    riveArtboard!.artboard.removeController(controllerHandsDown);
    riveArtboard!.artboard.removeController(controllerLookLeft);
    riveArtboard!.artboard.removeController(controllerLookRight);
    riveArtboard!.artboard.removeController(controllerSuccess);
    riveArtboard!.artboard.removeController(controllerFail);
    isLookLeft = false;
    isLookRight = false;
  }

  lookLeft() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerLookLeft);
    isLookLeft = true;
  }

  lookRight() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerLookRight);
    isLookRight = true;
  }

  addHandsUp() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerHandsUp);
  }

  addHandsDown() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerHandsDown);
  }

  void checkForPasswordFocusNodeToChangeAnimationState() {
    focusNodePassword.addListener(() {
      if (focusNodePassword.hasFocus) {
        addHandsUp();
      } else if (!focusNodePassword.hasFocus) {
        addHandsDown();
      }
    });
  }

  successState() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerSuccess);
  }

  faileState() {
    removeAllControllers();
    riveArtboard!.artboard.addController(controllerFail);
  }

  void validateForLogin() {
    focusNodePassword.unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!globalKey.currentState!.validate()) {
        faileState();
      } else {
        successState();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    controllerIdle = SimpleAnimation(AnimationEnum.idle.name);
    controllerHandsUp = SimpleAnimation(AnimationEnum.Hands_up.name);
    controllerHandsDown = SimpleAnimation(AnimationEnum.hands_down.name);
    controllerLookLeft = SimpleAnimation(AnimationEnum.Look_down_left.name);
    controllerLookRight = SimpleAnimation(AnimationEnum.Look_down_right.name);
    controllerSuccess = SimpleAnimation(AnimationEnum.success.name);
    controllerFail = SimpleAnimation(AnimationEnum.fail.name);

    rootBundle.load('assets/animated_login_screen.riv').then((value) async {
      final file = RiveFile.import(value);
      riveArtboard = file.mainArtboard;
      riveArtboard!.addController(controllerIdle);
      setState(() {});
    });
    checkForPasswordFocusNodeToChangeAnimationState();
  }

  @override
  Widget build(BuildContext context) {
    Size query = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Osama Tr')),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: query.width / 20,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: SizedBox(
                height: query.height / 3,
                // width: query.width * 1,
                child: riveArtboard != null
                    ? Rive(
                        artboard: riveArtboard!,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Form(
                key: globalKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        label: const Text('Email'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      validator: (val) =>
                          val != testEmail ? 'Wrong email ' : null,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            value.length < 16 &&
                            !isLookLeft) {
                          lookLeft();
                        } else if (value.isNotEmpty &&
                            value.length > 16 &&
                            !isLookRight) {
                          lookRight();
                        }
                      },
                    ),
                    SizedBox(
                      height: query.height * 0.03,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: const Text('Password'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      focusNode: focusNodePassword,
                      validator: (val) =>
                          val != testPassword ? 'wrong password' : null,
                    ),
                    SizedBox(
                      height: query.height * 0.08,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 14)),
                      onPressed: validateForLogin,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    )
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
