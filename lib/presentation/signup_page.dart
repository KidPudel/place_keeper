import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:place_keeper/bloc/auth/auth_bloc.dart';
import 'package:place_keeper/bloc/auth/auth_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/common/routes.dart';
import 'package:place_keeper/data/models/app_user.dart';

import '../bloc/auth/auth_state.dart';
import 'custom/purple_text_field.dart';

class SignUpPage extends StatefulWidget {
  final PageController pageController;

  const SignUpPage({super.key, required this.pageController});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isEmailCorrect = false;
  bool _arePasswordsCorrect = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.addListener(() {
      _validateEmail();
    });
    _confirmPasswordController.addListener(() {
      _validatePasswords();
    });
    _passwordController.addListener(() {
      _validatePasswords();
    });
  }

  void _validateEmail() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _isEmailCorrect = EmailValidator.validate(_emailController.text);
      });
    }
  }

  void _validatePasswords() {
    if (_passwordController.text == _confirmPasswordController.text &&
        _confirmPasswordController.text.isNotEmpty) {
      setState(() {
        _arePasswordsCorrect = true;
      });
    } else {
      setState(() {
        _arePasswordsCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
            child: Column(
              children: [
                PurpleTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'example@mail.com',
                  errorMessage: !_isEmailCorrect && _emailController.text.isNotEmpty
                      ? 'Проверьте email формат'
                      : null,
                ),
                const SizedBox(
                  height: 15,
                ),
                PurpleTextField(
                  controller: _passwordController,
                  labelText: 'Пароль',
                ),
                const SizedBox(
                  height: 15,
                ),
                PurpleTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Повторите пароль',
                  errorMessage: !_arePasswordsCorrect &&
                          _confirmPasswordController.text.isNotEmpty
                      ? 'Пароли не совпадают'
                      : null,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                    onPressed: () {
                      widget.pageController.animateToPage(1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    },
                    child: const Text('Авторизация')),
                const Expanded(child: SizedBox()),
                FractionallySizedBox(
                    widthFactor: 0.9,
                    child: BlocListener<UsersDbBloc, UsersDbState>(
                      listener: (context, state) {
                        if (state.status.isLoaded) {
                          context.goNamed(Routes.userPage().route);
                        }
                      },
                      child: BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            print("listen");
                            if (state.status.isSignedIn) {
                              context.read<UsersDbBloc>().add(
                                  AddUserToDb(uid: state.uid, email: state.email));
                            } else if (state.status.isError) {
                              showGeneralDialog(
                                  context: context,
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                          Container(),
                                  transitionBuilder: (context, animation,
                                          secondaryAnimation, child) =>
                                      Animate(
                                          child: AlertDialog.adaptive(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)),
                                        title: Text(state.errorMessage!),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                context.read<AuthBloc>().add(SignOut());
                                                context.pop();
                                              },
                                              child: const Text('ok'))
                                        ],
                                      )).slideY(begin: 1, end: 0.1));
                            }
                          },
                          child: ElevatedButton(
                            onPressed: (_isEmailCorrect && _arePasswordsCorrect)
                                ? () {
                                    context.read<AuthBloc>().add(SignUp(
                                        email: _emailController.text,
                                        password: _confirmPasswordController.text));
                                  }
                                : null,
                            child: const Text("Продолжить"),
                          )),
                    ))
              ],
            ),
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state.status.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Colors.indigo)));
          } else {
            return const SizedBox();
          }
        },)
      ],
    );
  }
}
