import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:place_keeper/bloc/auth/auth_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/common/custom_colors.dart';
import 'package:place_keeper/common/routes.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'custom/purple_text_field.dart';

class LoginPage extends StatefulWidget {
  final PageController pageController;

  const LoginPage({super.key, required this.pageController});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailCorrect = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.addListener(() {
      _validateEmail();
    });
  }

  void _validateEmail() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _isEmailCorrect = EmailValidator.validate(_emailController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
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
            TextButton(
                onPressed: () {
                  widget.pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                },
                child: const Text('Регистрация')),
            const Expanded(child: SizedBox()),
            FractionallySizedBox(
                widthFactor: 0.9,
                child: BlocListener<UsersDbBloc, UsersDbState>(
                  listener: (context, state) => context.goNamed(Routes.userPage().route),
                  child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state.status.isSignedIn) {
                          context.read<UsersDbBloc>().add(GetUserFromDb(uid: state.uid));
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
                      onPressed: _isEmailCorrect ? () {
                        context.read<AuthBloc>().add(SignIn(email: _emailController.text, password: _passwordController.text));
                      } : null,
                      child: const Text("Продолжить"),
                    ),
                  ),
                ))
          ]),
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
