import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:place_keeper/presentation/login_page.dart';
import 'package:place_keeper/presentation/signup_page.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}


class _EntryPageState extends State<EntryPage> {

  int _currentPage = 0;
  PageController? _pageController;
  List<Widget>? _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pageController = PageController(initialPage: _currentPage);
    _pages = [
      SignUpPage(
        pageController: _pageController!,
      ),
      LoginPage(
        pageController: _pageController!
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (_currentPage == 0) ? const Text("Регистрация") : const Text("Авторизация"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: PageView.builder(
        // lazy
        controller: _pageController,
        itemCount: _pages!.length,
        itemBuilder: (context, index) => _pages![index],
        onPageChanged: (value) => setState((){
          // app bar awareness
          _currentPage = value;
        })
      ),
    );
  }
}
