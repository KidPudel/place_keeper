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
import 'package:is_first_run/is_first_run.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_keeper/bloc/auth/auth_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_bloc.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/common/custom_colors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:place_keeper/internal/di/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _showFirstMessage();
  }

  void _getLastPosition() {
    final List<String>? lastPositionEncoded = locator.get<SharedPreferences>().getStringList('last_position');
    if (lastPositionEncoded != null) {
      final lat = double.parse(lastPositionEncoded[0]);
      final long = double.parse(lastPositionEncoded[1]);
      final lastPositionDecoded = LatLng(lat, long);
      setState(() {
        _currentPosition = lastPositionDecoded;
      });
      _animatedMapController.animateTo(dest: _currentPosition, zoom: 15);
    } else {
      print("NOOPE");
      setState(() {
        _currentPosition = const LatLng(55.7558, 37.6173);
      });
    }
  }

  Future<void> _showFirstMessage() async {
    if (await IsFirstRun.isFirstCall() && context.mounted) {
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            Animate(
                child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: CustomColors.surface,
          title: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              child: ListView(children: [
                const Text(
                  'Developed by Iggy (Купчиненко Игорь)\n',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                Text(
                  'WARNING: Чтобы получить весь функционал, используйте VPN. (Planet VPN)\n',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
                const Text(
                    'О приложении', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const Text(
                    'Это приложение позволяет вам сохранять и удалять любые места на карте, а так же определять текущую геолокацию.\n'),
                const Text(
                    'Функционал', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                const Text(
                    'В приложении можно создать аккаунт, в котором будут храниться ваши отмеченные места.'),
                const Text(
                    'Их можно добавлять нажатием на карту и удалять через экран профиля, так же на карте можно нажать на точку и посмотреть детали и удалить место.'),
              ]),
            ),
          ),
          actions: [
            SizedBox(
                width: 100,
                child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "ок",
                      style: TextStyle(fontSize: 20),
                    )))
          ],
        )),
      );
    }
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
                  initialCenter: _currentPosition!,
                  onTap: (tapPosition, point) {
                    if (context.read<AuthBloc>().state.status.isSignedIn) {
                      // set new position
                      locator.get<SharedPreferences>().setStringList('last_position', [point.latitude.toString(), point.longitude.toString()]);
                      context.read<UsersDbBloc>().add(AddPlaceToUser(
                          uid: context.read<AuthBloc>().state.uid,
                          lat: point.latitude,
                          long: point.longitude));
                    } else {
                      final snackBar = SnackBar(
                        content: const Text(
                          'Чтобы сохранять места, вам нужно авторизироваться',
                          style: TextStyle(fontSize: 18),
                        ),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                                bottom: Radius.circular(0))),
                        action: SnackBarAction(
                            label: 'ok',
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }, onMapReady: () => _getLastPosition(),),
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
                          point: LatLng(state.places[i].latitude,
                              state.places[i].longitude),
                          child: GestureDetector(
                            child: const Icon(
                              Icons.place,
                              color: CustomColors.indigoPurple,
                              size: 40,
                            ),
                            onTap: () {
                              _placeDetails(context, state.places[i],
                                  state.decodedPlaces[i]);
                            },
                          ))
                    }
                  ]);
                })
              ]),
          UserHud(getCurrentLocationCallback: _checkPermission),
          BlocBuilder<UsersDbBloc, UsersDbState>(
            builder: (context, state) {
              if (state.status.isLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                      valueColor:
                          AlwaysStoppedAnimation(CustomColors.indigoPurple)),
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  void _placeDetails(
      BuildContext context, GeoPoint place, String decodedPlace) async {
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
                      style: const TextStyle(fontSize: 20),
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
                                    title: const Text(
                                        "Вы уверены, что хотите удалить место?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          child: const Text("Не удалять")),
                                      TextButton(
                                          onPressed: () {
                                            context.read<UsersDbBloc>().add(
                                                DeletePlaceFromUser(
                                                    uid: context
                                                        .read<AuthBloc>()
                                                        .state
                                                        .uid,
                                                    lat: place.latitude,
                                                    long: place.longitude,
                                                    decodedPlace:
                                                        decodedPlace));
                                            context.pop();
                                            context.pop();
                                          },
                                          child: const Text("Удалить"))
                                    ]),
                              ),
                            ),
                        child: const Text(
                          "Удалить место",
                          style: TextStyle(fontSize: 18),
                        )),
                  )
                ]),
              ));
    }
  }

  Future _checkPermission() async {
    if (await Permission.location.request().isGranted) {
      _getCurrentLocation();
    } else {
      await Permission.location.request();
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
