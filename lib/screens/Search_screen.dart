import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/Profile_screen.dart';
import 'package:instagram_clone/utils/Colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isShowUser = false;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "search users",
            hintStyle: TextStyle(color: secondaryColor),

            border: InputBorder.none
          ),
          onFieldSubmitted: (String _){
            setState(() {
              isShowUser = true;
            });
          },
        ),
      ),
      body:isShowUser?FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').where('username',isGreaterThanOrEqualTo: _searchController.text).get(),
        builder:(context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          // if(!snapshot.hasData){
          //   return Center(child: CircularProgressIndicator(),);
          // }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: ()=>Navigator.push(context , MaterialPageRoute(builder: (context) => ProfileScreen(uid: snapshot.data!.docs[index]['uid']),)),
                  title: Text(snapshot.data!.docs[index]['username']),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!.docs[index]['photoUrl']),
                  ),
                );
              },
          );

        },
      ):FutureBuilder(
          future: FirebaseFirestore.instance.collection('post').get(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
            }
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    crossAxisCount: 3,
                  childAspectRatio: 4/6
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    snapshot.data!.docs[index]['postUrl'],
                  );
                },
            );
          },
      ),
    );
  }
}
