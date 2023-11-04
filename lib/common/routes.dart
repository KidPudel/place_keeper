class Routes {
  final String route;

  // return existing constructor on every call to constructor (singleton)
  Routes._({required this.route});

  factory Routes.mapPage() => Routes._(route: "/map_page");
  factory Routes.entryPage() => Routes._(route: "/entry_page");
  factory Routes.userPage() => Routes._(route: "/user_page");
}