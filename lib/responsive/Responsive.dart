import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/UserProvider.dart';
import 'package:provider/provider.dart';
import '../models/userModel.dart';
import '../utils/dimensions.dart';

class ResponsiveLayout extends StatefulWidget {
  Widget MobileScreen;
  Widget WebScreen;
  ResponsiveLayout({required this.MobileScreen,required this.WebScreen});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
  }
  addData()async{
    UserProvider _userProvider = Provider.of<UserProvider>(context,listen: false);
    await  _userProvider.refreshUser();
 }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth>webScreen){
        // web screen
        return widget.WebScreen;
      }else{
        // mobile screen
        return widget.MobileScreen;
      }
    },);
  }
}
