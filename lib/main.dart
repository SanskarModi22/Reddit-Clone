import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/router.dart';
import 'package:routemaster/routemaster.dart';
import 'core/common/error_text.dart';
import 'core/common/loader.dart';
import 'features/auth/controller/auth_controller.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'theme/pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

// This widget is the root of your application.
class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(
            authControllerProvider.notifier) //Instance of AuthController class
        .getUserData(data.uid) //User data will be fetched
        .first; //Only first element in the stream will be fetched
    ref.read(userProvider.notifier).update((state) => userModel);
    //userProvider ka jo model hoga usko update karenge
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
        //Here data means that whether the user is already signed in or signed out
        data: (data) => MaterialApp.router(
              title: 'Reddit Clone',
              debugShowCheckedModeBanner: false,
              theme: ref.watch(themeNotifierProvider),
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                if (data != null) {
                  getData(ref, data);
                  if (userModel != null) {
                    //User ka data is availaible
                    return loggedInRoute;
                  }
                }
                return loggedOutRoute;
              }),
              routeInformationParser: const RoutemasterParser(),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
