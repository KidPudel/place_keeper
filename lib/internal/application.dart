import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:place_keeper/bloc/auth/auth_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/common/routes.dart';
import 'package:place_keeper/common/themes.dart';
import 'package:place_keeper/presentation/entry_page.dart';
import 'package:place_keeper/presentation/login_page.dart';
import 'package:place_keeper/presentation/map_page.dart';
import 'package:place_keeper/presentation/signup_page.dart';

import '../bloc/auth/auth_bloc.dart';
import '../presentation/user_page.dart';

class Application extends StatelessWidget {
  Application({super.key});

  final GoRouter _goRouter =
      GoRouter(initialLocation: Routes.mapPage().route, routes: [
    GoRoute(
      path: Routes.mapPage().route,
      name: Routes.mapPage().route,
      builder: (context, state) => const MapPage(),
    ),
    GoRoute(
      path: Routes.entryPage().route,
      name: Routes.entryPage().route,
      pageBuilder: (context, state) => CustomTransitionPage(
        transitionDuration: Duration(milliseconds: 200),
        reverseTransitionDuration: Duration(milliseconds: 100),
        key: state.pageKey,
        child: const EntryPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
          scale: CurvedAnimation(
              parent: animation, curve: Curves.easeIn, reverseCurve: Curves.easeOut),
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: Routes.userPage().route,
      name: Routes.userPage().route,
      pageBuilder: (context, state) => CustomTransitionPage(
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        key: state.pageKey,
        child: const UserPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeIn, reverseCurve: Curves.easeOut),
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc()..add(AuthStateChanges()),
          ),
          BlocProvider(
            create: (context) => UsersDbBloc(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: _goRouter,
          title: "Place Keeper",
          theme: lightTheme,
        ));
  }
}
