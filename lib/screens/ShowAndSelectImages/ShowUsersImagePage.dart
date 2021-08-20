import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantopia1/models/user.dart';
import 'package:plantopia1/shared/Routing.dart';
import 'package:plantopia1/shared/reusableWidgets.dart';
import 'package:plantopia1/shared/style.dart';

class ShowUsersImagePage extends StatefulWidget {

  final String folder;
  final AuthUser authUser;
  final UserProfile authUserProfile;
  final UserProfile userProfile;
  final String localImageUrl;
  final Size screenSize;
  final int index;

  ShowUsersImagePage({Key key,
    this.folder,
    this.authUser,
    this.authUserProfile,
    this.userProfile,
    this.screenSize,
    this.localImageUrl,
    this.index
  }) : super(key: key);

  @override
  _ShowUsersImagePageState createState() => _ShowUsersImagePageState();
}

class _ShowUsersImagePageState extends State<ShowUsersImagePage> {

  Size screenSize;

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // The appBar all the pages share
      appBar: ReusableWidgets.getAppBar("Change image",context,widget.authUser,widget.authUserProfile),
      body: _buildMainContainer(),
    );
  }

  Widget _buildMainContainer(){
    return Container(
        color: Colors.green[300],
        child: _buildMainColumn()
    );
  }

  Widget _buildMainColumn(){
    return Column(
      children: [
        SizedBox(height: 30,),
        _buildImageContainer(),
        _buildButtonRow(),
      ],
    );
  }

  Widget _buildImageContainer(){
    return Container(
      height: screenSize.height/1.35,
      width: screenSize.width/1.05,
      child: widget.localImageUrl != "none"
          ? CachedNetworkImage(
        imageUrl: widget.localImageUrl,
        placeholder: (context, url) =>
            CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            Icon(Icons.error),
        fit: BoxFit.cover,
      )
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/no_foto_idea.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(){
    return Center(
        child: Row(
          children: [
            Container(
              child: TextButton(
                  onPressed: (){
                    routeToSelectImagePage(context,
                        widget.folder,
                        widget.authUser,
                        widget.authUserProfile,
                        widget.screenSize,
                        widget.index);
                  },
                  child: Text("Send a message!"),
                  style: ThemeButtons.secondButton
              ),
            ),
          ],
        )
    );
  }


}
