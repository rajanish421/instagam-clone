import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/singup_screen.dart';
import 'package:instagram_clone/utils/utils.dart';
import '../Widgets/text_field_input.dart';
import '../responsive/Responsive.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/Colors.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  bool isLoading = false;
  @override
void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  // user login
  void userLogin()async{
    setState(() {
      isLoading = true;
    });
   String res = await authMethods().userLogin(
        email: _emailController.text,
        password: _passController.text,
    );
    if(res == 'success'){
      // navigate to home screen
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ResponsiveLayout(MobileScreen: MobileScreenLayout(), WebScreen: WebScreenLayout()),
      ));
    }else{
      showSnackBar(context, res);
    }
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
        children: [
          Spacer(flex: 2,),
          SvgPicture.asset('assets/ic_instagram.svg',
            height: 64,
            color: primaryColor,
          ),
          SizedBox(height: 64,),
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
          InkWell(
            onTap: userLogin,
            child: Container(
              child: isLoading?Center(child: CircularProgressIndicator(),):Text("Log in"),
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
                child: Text("Don't have account? "),
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => singupScreen(),));

                },
                child: Container(
                  child: Text("Sing up " , style: TextStyle(fontWeight: FontWeight.bold),),
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
