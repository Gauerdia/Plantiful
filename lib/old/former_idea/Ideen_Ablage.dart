// DROPDOWNMENU

/*
// APPBAR
      appBar: AppBar(
        title: Text('Brew Crew'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: [


          FlatButton.icon(
              onPressed: () async {
                _auth.signOut();
              },
              icon: Icon(Icons.account_circle),
              label: Text('logout')),


          FlatButton.icon(
            onPressed: () => _showSettingsPanel(),
            label: Text('settings'),
            icon: Icon(Icons.settings),
          ),

          PopupMenuButton(
            icon: Icon(Icons.api_outlined),
            //child: Center(child: Text('click here')),
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.account_circle,
                      color: Colors.black),
                      Text("logout"),
                    ],
                  ) ,

              ),
              PopupMenuItem(
                  value: 1,
                  child: Text("secoond")),
          ],
            onSelected: (result) {
              switch(result){
                case 1:
                     {
                       _showMyDialog();
                  }
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedPage()),
                  );
                  break;
              }
            },
          ),

        ],
      ),

 */


// INLINE VARIABLES

/*
subtitle: Text('Take ${posting.date} sugar(s)'),
 */


// USE A PICTURE AS A SMALL ICON
/*
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/images/coffee_icon.png'
                ),
                radius: 25.0,
              ),
 */