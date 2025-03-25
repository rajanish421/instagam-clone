import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/PostScreen.dart';
import 'package:instagram_clone/utils/Colors.dart';

import '../screens/Feed_screen.dart';
import '../screens/Profile_screen.dart';
import '../screens/Search_screen.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
 late PageController pageController;
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void pageChange(int page){
   setState(() {
     _page = page;
   });
  }

  void onTapped(int page){
pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: PageView(
        children: [
          FeedScreen(),
          SearchScreen(),
         PostScreen(),
          Text("4"),
          ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
        ],
        controller:
        pageController,
        onPageChanged: pageChange,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
          items:<BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: (_page == 0) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: (_page == 1) ? primaryColor : secondaryColor,
                ),
                label: '',
                backgroundColor: primaryColor),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle,
                  color: (_page == 2) ? primaryColor : secondaryColor,
                ),
                label: '',
                backgroundColor: primaryColor),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: (_page == 3) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: (_page == 4) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
          ],
        onTap: onTapped,
      ),
    );
  }
}
