import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:place_keeper/bloc/auth/auth_bloc.dart';
import 'package:place_keeper/bloc/auth/auth_event.dart';
import 'package:place_keeper/bloc/auth/auth_state.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/common/custom_colors.dart';
import 'package:place_keeper/common/routes.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "user",
      child: Scaffold(
          appBar: AppBar(
            title: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return Text(state.email);
            }),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                context.go(Routes.mapPage().route);
              },
            ),
            actions: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status.isSignedOut) {
                    context.go(Routes.mapPage().route);
                  }
                },
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOut());
                    context.read<UsersDbBloc>().add(SignOutFromDb());
                  },
                ),
              ),
            ],
          ),
          body:
              BlocBuilder<UsersDbBloc, UsersDbState>(builder: (context, state) {
            if (state.status.isLoaded && state.places.isNotEmpty) {
              return ListView.builder(
                  itemCount: state.places.length,
                  itemBuilder: (context, index) {
                    return FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(state.decodedPlaces[index]),
                              IconButton(
                                  onPressed: () {
                                    context.read<UsersDbBloc>().add(
                                        DeletePlaceFromUser(
                                            uid: context
                                                .read<AuthBloc>()
                                                .state
                                                .uid,
                                            lat: state.places[index].latitude,
                                            long: state.places[index].longitude,
                                            decodedPlace:
                                                state.decodedPlaces[index]));
                                  },
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          const Divider(
                            color: Colors.blueGrey,
                            thickness: 1,
                          )
                        ],
                      ),
                    );
                  });
            } else if (state.places.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/empty.png'),
                  const Text(
                    "Кажется ваша корзина еще пуста ;(",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(CustomColors.indigoPurple),
                ),
              );
            }
          })),
    );
  }
}
