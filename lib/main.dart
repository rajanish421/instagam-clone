import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/UserProvider.dart';
import 'package:instagram_clone/responsive/Responsive.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/singup_screen.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram clone',
        theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: mobileBackgroundColor
        ),
        home:StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // active connection
              if(snapshot.connectionState == ConnectionState.active){
                // have data means user exist
                if(snapshot.hasData){
                    return ResponsiveLayout(MobileScreen: MobileScreenLayout(), WebScreen: WebScreenLayout());
                }
                else if(snapshot.hasError){
                  return Center(child: Text(snapshot.toString()),);
                }
              }

              // waiting connection
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }

              // user not logged in
              return LoginScreen();
            },
        ),
      ),
    );
  }
}
