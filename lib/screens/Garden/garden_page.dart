
/*
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/services/database.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:sticky_headers/sticky_headers.dart';

class GardenPage extends StatefulWidget {

  final AuthUser authUser;
  final UserProfile authUserProfile;

  const GardenPage({Key key, this.authUser, this.authUserProfile}) : super(key: key);

  @override
  _GardenPageState createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {

  UserProfile authUserProfile;

  final listHeader = ["Monsteras","defef","fefe","fefe","fefe","efef"];
  final listContentDate = ["20/01/2020","01/01/2021","04/05/2019","20/01/2020","01/01/2021","04/05/2019"];
  final listContentMarket = ["Exchange","Sell","No","Exchange","Sell","No"];
  final listTitle = ["Maybe a Name?","Maybe a Name?","Maybe a Name?","Maybe a Name?","Maybe a Name?","Trivago?"];

  @override
  void initState() {
    super.initState();
    _checkForUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar('My Profile',context,widget.authUser,authUserProfile),
      body: Container(
        color: Colors.green[100],
        child: createMainColumn(),
      ),
    );
  }

  void _checkForUserProfile() async{
    if(widget.authUserProfile != null){
      authUserProfile = widget.authUserProfile;
    }else{
      await _fetchUserProfileFromFirebase();
    }
  }

  Future<List<UserProfile>> _fetchUserProfileFromFirebase() async{
    print("Start _fetchUserProfileFromFirebase.");
    try{
      var userProfileStream = DatabaseService(uid: widget.authUser.uid).userProfile;
      userProfileStream.listen(
              (result) {
            authUserProfile = result;
            print("_fetchUserProfileFromFirebase successful.");
            return result;
          }, onDone: (){
        print("_fetchUserProfileFromFirebase Task Done.");
      }, onError: (error) {
        print("_fetchUserProfileFromFirebase Error " + error.toString());
        return null;
      });
    }catch(e){
      print("Catch _fetchUserProfileFromFirebase " + e.toString());
    }
  }

  Widget createMainColumn(){
    return Column(
      children: [
        createButtons(),
        Expanded(child: buildPlantView())
      ],
    );
  }

  Widget createButtons(){
    return Row(
      children: [
        TextButton(
            onPressed: (){
              onClickAddNewCategory();
            },
            child: Text("Add new plant!")
        ),
        TextButton(
            onPressed: (){
              onClickAddNewPlant();
            },
            child: Text("Add new category!")
        ),
      ],
    );
  }

  Widget buildPlantView(){
      return ListView.builder(
        // For every listHeader we create a new StickHeader
        itemCount: listHeader.length,
        itemBuilder: (context, index) {
        return _buildStickyHeader(index);
      },
        shrinkWrap: true,
      );
  }

  Widget _buildStickyHeader(int index){
    return StickyHeader(
      header: new Container(
        height: 38.0,
        color: Colors.green[100],
        padding: new EdgeInsets.symmetric(horizontal: 12.0),
        alignment: Alignment.centerLeft,
        child: new Text(listHeader[index],
          style: const TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
        ),
      ),
      content: Container(
        child: buildGridView(),
      ),
    );
  }

  Widget buildGridView(){
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: listTitle.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1,),
      itemBuilder: (context, index){
        return buildPlantCard(index);
      },
    );
  }

  Widget buildPlantCard(int index){
    return Card(
      margin: EdgeInsets.all(4.0),
      color: Colors.green[200],
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 6.0, bottom: 2.0),
        child: Column(
          children: [
            Center(
              child: Image(
                image: AssetImage('assets/images/no_foto_idea.jpg'),
                width: 100,
                height: 100,
              ),
            ),
            Text(listTitle[index],
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text("Mine Since: " + listContentDate[index]),
            Text("Open on market: " + listContentMarket[index])
          ],
        ),
      ),
    );
  }


  Widget createPlantTile(){

  }

  void onClickAddNewCategory(){

  }

  void onClickAddNewPlant(){

  }

}



 */