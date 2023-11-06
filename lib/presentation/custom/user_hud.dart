import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/datastore/users_db_bloc.dart';
import '../../bloc/datastore/users_db_event.dart';
import '../../common/custom_colors.dart';
import '../../common/routes.dart';

typedef GetCurrentLocationCallback = Future Function();

class UserHud extends StatelessWidget {
  final GetCurrentLocationCallback getCurrentLocationCallback;
  const UserHud({
    super.key,
    required this.getCurrentLocationCallback
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () {
                        getCurrentLocationCallback();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.deepPurple,
                      )),
                ),
                SizedBox(
                    width: 100,
                    child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                      if (state.status.isSignedIn) {
                        context
                            .read<UsersDbBloc>()
                            .add(GetUserFromDb(uid: state.uid));
                      } else if (state.status.isSignedOut) {
                        // clean up after signed out
                      }
                    }, builder: (context, state) {
                      if (state.status.isSignedIn) {
                        return ElevatedButton(
                          onPressed: () {
                            context.push(Routes.userPage().route);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: const Icon(
                            Icons.accessibility,
                            color: Colors.deepPurple,
                          ),
                        );
                      } else if (state.status.isSignedOut) {
                        return ElevatedButton(
                            onPressed: () {
                              context.push(Routes.entryPage().route);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade50,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20))),
                            child: Text(
                              "Войти",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: CustomColors.indigoPurple),
                            ));
                      } else {
                        return const CircularProgressIndicator.adaptive();
                      }
                    })),
              ],
            )
          ],
        ),
      ),
    );
  }
}
