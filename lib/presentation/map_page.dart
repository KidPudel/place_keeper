// think before you write, think on how it works step by step, understand the flow
// you can lookup only if:
// - you want to LEARN a new thing, like the basics of framework
// - or how to work with a specific library

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_keeper/bloc/auth/auth_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/common/custom_colors.dart';
import 'package:geocoding/geocoding.dart';

import '../bloc/auth/auth_state.dart';
import 'custom/user_hud.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  LatLng _currentPosition = const LatLng(55.7558, 37.6173);

  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //context.read<AuthBloc>().add(AuthStateChanges());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
              mapController: _animatedMapController.mapController,
              options: MapOptions(
                  initialZoom: 12,
                  initialCenter: _currentPosition,
                  onTap: (tapPosition, point) {
                    print('tap');
                    if (context.read<AuthBloc>().state.status.isSignedIn) {
                      context.read<UsersDbBloc>().add(AddPlaceToUser(
                          uid: context.read<AuthBloc>().state.uid,
                          lat: point.latitude,
                          long: point.longitude));
                    }
                  },
                  onMapReady: () async => await _checkPermission()),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.iggydev',
                ),
                BlocBuilder<UsersDbBloc, UsersDbState>(
                    builder: (context, state) {
                  return MarkerLayer(markers: [
                    for (int i = 0; i < state.places.length; i++) ...{
                      Marker(
                          point: LatLng(state.places[i].latitude, state.places[i].longitude),
                          child: GestureDetector(
                            child: const Icon(
                              Icons.place,
                              color: CustomColors.indigoPurple,
                              size: 40,
                            ),
                            onTap: () {
                              _placeDetails(context, state.places[i], state.decodedPlaces[i]);
                            },
                          ))
                    }
                  ]);
                })
              ]),
          UserHud(getCurrentLocationCallback: _checkPermission),
          BlocBuilder<UsersDbBloc, UsersDbState>(builder: (context, state) {
            if (state.status.isLoading) {
              return const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(CustomColors.indigoPurple)),);
            } else {
              return const SizedBox();
            }
          },)
        ],
      ),
    );
  }

  void _placeDetails(BuildContext context, GeoPoint place, String decodedPlace) async {
    final decodedPlace = await _decodePlace(place);
    if (context.mounted) {
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20), bottom: Radius.circular(0))),
          builder: (context) => SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      decodedPlace,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: ElevatedButton(
                        onPressed: () => showGeneralDialog(
                              context: context,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      Container(),
                              transitionBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  Animate(
                                child: AlertDialog.adaptive(
                                    title:
                                        Text("Вы уверены, что хотите удалить место?"),
                                    actions: [TextButton(onPressed: (){context.pop();}, child: Text("Не удалять")), TextButton(onPressed: (){
                                      context.read<UsersDbBloc>().add(
                                          DeletePlaceFromUser(uid: context.read<AuthBloc>().state.uid,
                                              lat: place.latitude, long: place.longitude, decodedPlace: decodedPlace));
                                      context.pop();
                                      context.pop();
                                    }, child: Text("Удалить"))]),
                              ),
                            ),
                        child: Text(
                          "Удалить место",
                          style: TextStyle(fontSize: 18),
                        )),
                  )
                ]),
              ));
    }
  }

  Future _checkPermission() async {
    print('checking permission');
    if (await Permission.locationWhenInUse.request().isGranted) {
      print("permission granted");

      _getCurrentLocation();
    } else {
      print('not granted');
      await Permission.locationWhenInUse.request();
      /*showGeneralDialog(context: context,
          pageBuilder: (context, animation, secondaryAnimation) => Container(),
          transitionBuilder: (context, animation, secondaryAnimation, child) =>
              Animate(child: AlertDialog(title: Text(),) ));*/
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return Future.error("permission location denied");
    }

    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _animatedMapController.animateTo(dest: _currentPosition, zoom: 15);
  }

  Future<String> _decodePlace(GeoPoint place) async {
    return await placemarkFromCoordinates(place.latitude, place.longitude).then(
        (value) => "Country: ${value[0].country}\nStreet: ${value[0].street}");
  }
}
