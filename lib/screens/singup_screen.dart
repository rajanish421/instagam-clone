import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/screens/login_screen.dart';

import '../Widgets/text_field_input.dart';
import '../resources/auth_methods.dart';
import '../responsive/Responsive.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/Colors.dart';
import '../utils/utils.dart';
class singupScreen extends StatefulWidget {
  const singupScreen({super.key});

  @override
  State<singupScreen> createState() => _singupScreenState();
}

class _singupScreenState extends State<singupScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage()async{
    Uint8List img = await imagePick(ImageSource.gallery);
    setState(() {
  _image = img;
    });
  }

  void signUpUser()async{
    setState(() {
      isLoading = true;
    });
      String res = await authMethods().signUpUser(
          file: _image!,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passController.text,
          bio: _bioController.text);
      if(res != 'success'){
          showSnackBar(context, res);
      }else{
        // navigate to home screen
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ResponsiveLayout(MobileScreen: MobileScreenLayout(), WebScreen: WebScreenLayout()),
        ));
      }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              children: [
                Spacer(flex: 1,),
                SvgPicture.asset('assets/ic_instagram.svg',
                  height: 64,
                  color: primaryColor,
                ),
                SizedBox(height: 64,),
               Stack(
                 children: [
                   _image != null ? CircleAvatar(
                     radius:64,
                     backgroundImage: MemoryImage(_image!),
                   ):CircleAvatar(
                     radius:64,
                     backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                   ),
                   Positioned(
                     bottom: -10,
                       left: 80,
                       child: IconButton(onPressed: (){
                         selectImage();
                       }, icon: Icon(Icons.add_a_photo))),
                 ],
               ),
                SizedBox(height: 24,),
                TextFieldInput(
                  textInputType:TextInputType.text ,
                  textEditingController: _usernameController,
                  hintText: "Enter your username",
                ),
                SizedBox(height: 24,),
                TextFieldInput(
                  textInputType:TextInputType.emailAddress ,
                  textEditingController: _emailController,
                  hintText: "Enter your email",
                ),
                SizedBox(height: 24,),
                TextFieldInput(
                  textInputType: TextInputType.text,
                  textEditingController: _passController,
                  hintText: 'Enter your password',
                  isPass: true,
                ),
                SizedBox(height: 24,),
                TextFieldInput(
                  textInputType:TextInputType.text ,
                  textEditingController: _bioController,
                  hintText: "Enter your bio",
                ),
                SizedBox(height: 24,),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    child: isLoading?Center(child: CircularProgressIndicator(),):Text("sing up"),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical:12),
                    decoration: const ShapeDecoration(
                        shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ) ,
                        color: blueColor
                    ),
                  ),
                ),
                Spacer(flex: 1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child:const Text("Already have an account? "),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                      },
                      child: Container(
                        child: Text("Login " , style: TextStyle(fontWeight: FontWeight.bold),),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),)),
    );
  }
}
