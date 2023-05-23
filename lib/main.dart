import 'dart:developer';

import 'package:flutter/material.dart';

bool isAuthenticated = false;

final Map<String, PageRoute> routes = {
  '/': MaterialPageRoute(
    builder: (_) => const MyHomePage(title: 'Flutter Demo Home Page'),
  ),
  '/protectedRoute': CustomPageRouter(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const ProtectedRoute();
    },
    guards: [
      AuthGuard(),
    ],
  ),
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: '/',
      // routes: {
      //   '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      //   '/protectedRoute': (context) => const ProtectedRoute(),
      // },
      onGenerateRoute: generateRoute,
    );
  }

  Route<dynamic>? generateRoute(RouteSettings settings) {
    return routes[settings.name];
    // for (final element in routes.keys) {
    //   if (element == settings.name) {
    //     return routes[element];
    //   }
    // }
    // return null;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthGuard authGuard = AuthGuard();

  void navigateToProtectedRoute(BuildContext context) async {
    // bool canAccess = await authGuard.canActivate();
    NavigationHelper.navigateToRoute(context, '/protectedRoute');
    // if (canAccess) {
    // } else {
    //   showAlertDialog(context, 'user not auth');
    // }
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            //
            //
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Tap FAB to Lock/Unlock',
              ),
              const SizedBox(
                height: 12,
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Next Route'),
                  onPressed: () {
                    navigateToProtectedRoute(context);
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: changeAuth,
          tooltip: 'Unlock guard',
          child: isAuthenticated ? const Icon(Icons.lock_open) : const Icon(Icons.lock),
        ));
  }

  void changeAuth() {
    setState(() {
      isAuthenticated = !isAuthenticated;
    });
  }
}

void showAlertDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

abstract class IRouterGuard {
  Future<bool> canActivate();

  @override
  String toString() => runtimeType.toString();
}

class AuthGuard implements IRouterGuard {
  @override
  Future<bool> canActivate() async {
    return isAuthenticated;
  }
}

class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Route'),
      ),
      body: const Center(
        child: Text('new route'),
      ),
    );
  }
}

class NavigationHelper {
  static void navigateToRoute(BuildContext context, String route) async {
    final pageRoute = routes[route];
    if (pageRoute is CustomPageRouter) {
      final List<bool> listCanActivate = [];
      for (final guard in pageRoute.guards) {
        listCanActivate.add(await guard.canActivate());
      }
      if (listCanActivate.every((element) => element)) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, route);
      } else {
        final firstFalse = listCanActivate.firstWhere((element) => !element);
        final routeGuardName = pageRoute.guards[listCanActivate.indexOf(firstFalse)].toString().split("'")[1];
        log('$routeGuardName dont active');
        // ignore: use_build_context_synchronously
        showAlertDialog(context, '$routeGuardName dont active');
      }
    }
  }
}

class CustomPageRouter extends PageRouteBuilder {
  CustomPageRouter({required super.pageBuilder, this.guards = const []});
  final List<IRouterGuard> guards;
}
