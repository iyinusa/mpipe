import 'package:mpipe/Helpers/countrycodes.dart';
import 'package:mpipe/CustomWidgets/gradientContainers.dart';
import 'package:mpipe/Helpers/picker.dart';
import 'package:mpipe/Screens/Top Charts/top.dart' as topScreen;
import 'package:mpipe/Screens/Home/saavn.dart' as homeScreen;
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mpipe/Helpers/config.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';

class SettingPage extends StatefulWidget {
  final Function callback;
  SettingPage({this.callback});
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String appVersion;
  int appVersionCheck;
  Box settingsBox = Hive.box('settings');
  String name = Hive.box('settings').get('name', defaultValue: 'Guest User');
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music');
  List dirPaths = Hive.box('settings').get('searchPaths', defaultValue: []);
  String streamingQuality =
      Hive.box('settings').get('streamingQuality', defaultValue: '96 kbps');
  String downloadQuality =
      Hive.box('settings').get('downloadQuality', defaultValue: '320 kbps');
  String canvasColor =
      Hive.box('settings').get('canvasColor', defaultValue: 'Grey');

  String cardColor =
      Hive.box('settings').get('cardColor', defaultValue: 'Grey850');
  bool stopForegroundService =
      Hive.box('settings').get('stopForegroundService', defaultValue: true);
  bool stopServiceOnPause =
      Hive.box('settings').get('stopServiceOnPause', defaultValue: true);
  String region = Hive.box('settings').get('region', defaultValue: 'Nigeria');
  bool useProxy = Hive.box('settings').get('useProxy', defaultValue: false);
  String themeColor =
      Hive.box('settings').get('themeColor', defaultValue: 'Red');
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400);
  bool synced = false;
  List languages = ["English"];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList();

  @override
  void initState() {
    main();
    super.initState();
  }

  void main() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersionCheck = int.parse(packageInfo.version.replaceAll('.', ''));
    appVersion = packageInfo.version;
    setState(() {});
  }

  updateUserDetails(String key, dynamic value) {
    final userID = Hive.box('settings').get('userID');
    final dbRef = FirebaseDatabase.instance.reference().child("Users");
    dbRef.child(userID).update({"$key": "$value"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          elevation: 0,
          stretch: true,
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height / 4.5,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            stretchModes: [StretchMode.zoomBackground],
            background: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Center(
                child: Text(
                  "Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                child: Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
                child: GradientCard(
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: Hive.box('settings').listenable(),
                        builder: (context, box, widget) {
                          return SwitchListTile(
                              activeColor: Theme.of(context).accentColor,
                              title: Text('Dark Mode'),
                              dense: true,
                              value: box.get('darkMode') ?? true,
                              onChanged: (val) {
                                box.put('darkMode', val);
                                currentTheme.switchTheme(val);
                                updateUserDetails('darkMode', val);
                                themeColor = val ? 'Red' : 'Red';
                                colorHue = 400;
                                updateUserDetails('themeColor', themeColor);
                                updateUserDetails('colorHue', colorHue);
                              });
                        },
                      ),
                      ListTile(
                        title: Text('Accent Color & Hue'),
                        subtitle: Text('$themeColor, $colorHue'),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Theme.of(context).accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[900],
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 3.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              List colors = [
                                'Amber',
                                'Blue',
                                'Cyan',
                                'Deep Orange',
                                'Deep Purple',
                                'Green',
                                'Indigo',
                                'Light Blue',
                                'Light Green',
                                'Lime',
                                'Orange',
                                'Pink',
                                'Purple',
                                'Red',
                                'Teal',
                                'Yellow',
                              ];
                              return BottomGradientContainer(
                                borderRadius: BorderRadius.circular(20.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    scrollDirection: Axis.vertical,
                                    itemCount: colors.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (int hue in [
                                              100,
                                              200,
                                              400,
                                              700
                                            ])
                                              GestureDetector(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.125,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.125,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      color: MyTheme().getColor(
                                                          colors[index], hue),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Colors.grey[900],
                                                          blurRadius: 5.0,
                                                          spreadRadius: 0.0,
                                                          offset:
                                                              Offset(0.0, 3.0),
                                                        )
                                                      ],
                                                    ),
                                                    child: (themeColor ==
                                                                colors[index] &&
                                                            colorHue == hue)
                                                        ? Icon(
                                                            Icons.done_rounded)
                                                        : SizedBox(),
                                                  ),
                                                  onTap: () {
                                                    themeColor = colors[index];
                                                    colorHue = hue;
                                                    updateUserDetails(
                                                        'themeColor',
                                                        themeColor);
                                                    updateUserDetails(
                                                        'colorHue', colorHue);
                                                    currentTheme.switchColor(
                                                        colors[index],
                                                        colorHue);
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  }),
                                          ],
                                        ),
                                      );
                                    }),
                              );
                            },
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text('Background Gradient'),
                        subtitle:
                            Text('Gradient used as background everywhere'),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Theme.of(context).accentColor,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? currentTheme.getBackGradient()
                                    : [
                                        Colors.white,
                                        Theme.of(context).canvasColor,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[900],
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 3.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              List gradients = currentTheme.backOpt;
                              return BottomGradientContainer(
                                borderRadius: BorderRadius.circular(20.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    scrollDirection: Axis.vertical,
                                    itemCount: gradients.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: GestureDetector(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: gradients[index],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[900],
                                                    blurRadius: 5.0,
                                                    spreadRadius: 0.0,
                                                    offset: Offset(0.0, 3.0),
                                                  )
                                                ],
                                              ),
                                              child: (currentTheme
                                                          .getBackGradient() ==
                                                      gradients[index])
                                                  ? Icon(Icons.done_rounded)
                                                  : SizedBox(),
                                            ),
                                            onTap: () {
                                              settingsBox.put(
                                                  'backGrad', index);
                                              currentTheme.backGrad = index;
                                              widget.callback();
                                              Navigator.pop(context);
                                              setState(() {});
                                            }),
                                      );
                                    }),
                              );
                            },
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text('Card Gradient'),
                        subtitle: Text('Gradient used in Cards'),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Theme.of(context).accentColor,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? currentTheme.getCardGradient()
                                    : [
                                        Colors.white,
                                        Theme.of(context).canvasColor,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[900],
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 3.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              List gradients = currentTheme.cardOpt;
                              return BottomGradientContainer(
                                borderRadius: BorderRadius.circular(20.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    scrollDirection: Axis.vertical,
                                    itemCount: gradients.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: GestureDetector(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: gradients[index],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[900],
                                                    blurRadius: 5.0,
                                                    spreadRadius: 0.0,
                                                    offset: Offset(0.0, 3.0),
                                                  )
                                                ],
                                              ),
                                              child: (currentTheme
                                                          .getCardGradient() ==
                                                      gradients[index])
                                                  ? Icon(Icons.done_rounded)
                                                  : SizedBox(),
                                            ),
                                            onTap: () {
                                              settingsBox.put(
                                                  'cardGrad', index);
                                              currentTheme.cardGrad = index;
                                              widget.callback();
                                              Navigator.pop(context);
                                              setState(() {});
                                            }),
                                      );
                                    }),
                              );
                            },
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text('Bottom Sheets Gradient'),
                        subtitle: Text('Gradient used in Bottom Sheets'),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Theme.of(context).accentColor,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? currentTheme.getBottomGradient()
                                    : [
                                        Colors.white,
                                        Theme.of(context).canvasColor,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[900],
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 3.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              List gradients = currentTheme.backOpt;
                              return BottomGradientContainer(
                                borderRadius: BorderRadius.circular(20.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    scrollDirection: Axis.vertical,
                                    itemCount: gradients.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: GestureDetector(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.125,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: gradients[index],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[900],
                                                    blurRadius: 5.0,
                                                    spreadRadius: 0.0,
                                                    offset: Offset(0.0, 3.0),
                                                  )
                                                ],
                                              ),
                                              child: (currentTheme
                                                          .getBottomGradient() ==
                                                      gradients[index])
                                                  ? Icon(Icons.done_rounded)
                                                  : SizedBox(),
                                            ),
                                            onTap: () {
                                              settingsBox.put(
                                                  'bottomGrad', index);
                                              currentTheme.bottomGrad = index;
                                              Navigator.pop(context);
                                              setState(() {});
                                            }),
                                      );
                                    }),
                              );
                            },
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text('Canvas Color'),
                        subtitle: Text('Color of Background Canvas'),
                        onTap: () {},
                        trailing: DropdownButton(
                          value: canvasColor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            setState(() {
                              currentTheme.switchCanvasColor(newValue);
                              canvasColor = newValue;
                            });
                          },
                          items: <String>['Grey', 'Black']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        dense: true,
                      ),
                      ListTile(
                        title: Text('Card Color'),
                        subtitle:
                            Text('Color of Search Bar, Alert Dialogs, Cards'),
                        onTap: () {},
                        trailing: DropdownButton(
                          value: cardColor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            setState(() {
                              currentTheme.switchCardColor(newValue);
                              cardColor = newValue;
                            });
                          },
                          items: <String>[
                            'Grey800',
                            'Grey850',
                            'Grey900',
                            'Black'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        dense: true,
                      ),
                      ListTile(
                          title: Text('Change to Default'),
                          dense: true,
                          onTap: () {
                            Hive.box('settings').put('darkMode', true);

                            settingsBox.put('backGrad', 1);
                            currentTheme.backGrad = 1;
                            settingsBox.put('cardGrad', 3);
                            currentTheme.cardGrad = 3;
                            settingsBox.put('bottomGrad', 2);
                            currentTheme.bottomGrad = 2;

                            currentTheme.switchCanvasColor('Grey');
                            canvasColor = 'Grey';

                            currentTheme.switchCardColor('Grey850');
                            cardColor = 'Grey900';

                            themeColor = 'Red';
                            colorHue = 400;
                            currentTheme.switchTheme(true);
                            updateUserDetails('darkMode', true);
                            updateUserDetails('themeColor', 'Red');
                            updateUserDetails('colorHue', 400);
                            setState(() {});
                            widget.callback();
                          }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Text(
                  'Music & Playback',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
                child: GradientCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Music Language"),
                        subtitle: Text('To display songs on Home Screen'),
                        trailing: SizedBox(
                          width: 150,
                          child: Text(
                            preferredLanguage.isEmpty
                                ? "None"
                                : preferredLanguage.join(", "),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        dense: true,
                        onTap: () {
                          showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                List checked = List.from(preferredLanguage);
                                return StatefulBuilder(builder:
                                    (BuildContext context, StateSetter setStt) {
                                  return BottomGradientContainer(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 10),
                                              scrollDirection: Axis.vertical,
                                              itemCount: languages.length,
                                              itemBuilder: (context, idx) {
                                                return CheckboxListTile(
                                                  activeColor: Theme.of(context)
                                                      .accentColor,
                                                  value: checked
                                                      .contains(languages[idx]),
                                                  title: Text(languages[idx]),
                                                  onChanged: (value) {
                                                    value
                                                        ? checked
                                                            .add(languages[idx])
                                                        : checked.remove(
                                                            languages[idx]);
                                                    setStt(() {});
                                                  },
                                                );
                                              }),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              style: TextButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .accentColor,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                'Ok',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              style: TextButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .accentColor,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  preferredLanguage = checked;
                                                  Navigator.pop(context);
                                                  Hive.box('settings').put(
                                                      'preferredLanguage',
                                                      checked);
                                                  updateUserDetails(
                                                      "preferredLanguage",
                                                      checked);
                                                  homeScreen.fetched = false;
                                                  homeScreen.preferredLanguage =
                                                      preferredLanguage;
                                                  widget.callback();
                                                });
                                                if (preferredLanguage.length ==
                                                    0)
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      elevation: 6,
                                                      backgroundColor:
                                                          Colors.grey[900],
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      content: Text(
                                                        'No Music language selected. Select a language to see songs on Home Screen',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      action: SnackBarAction(
                                                        textColor:
                                                            Theme.of(context)
                                                                .accentColor,
                                                        label: 'Ok',
                                                        onPressed: () {},
                                                      ),
                                                    ),
                                                  );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              });
                        },
                      ),
                      ListTile(
                          title: Text("Spotify Local Charts Location"),
                          subtitle: Text('Select country for Local Charts'),
                          trailing: SizedBox(
                            width: 150,
                            child: Text(
                              region,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                                isDismissible: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  Map<String, String> codes =
                                      CountryCodes().countryCodes;
                                  List<String> countries = codes.keys.toList();
                                  return BottomGradientContainer(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        scrollDirection: Axis.vertical,
                                        itemCount: countries.length,
                                        itemBuilder: (context, idx) {
                                          return ListTileTheme(
                                            selectedColor:
                                                Theme.of(context).accentColor,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.only(
                                                  left: 25.0, right: 25.0),
                                              title: Text(countries[idx]),
                                              trailing: region == countries[idx]
                                                  ? Icon(Icons.check_rounded)
                                                  : SizedBox(),
                                              selected:
                                                  region == countries[idx],
                                              onTap: () {
                                                topScreen.items = [];
                                                region = countries[idx];
                                                topScreen.fetched = false;
                                                Hive.box('settings')
                                                    .put('region', region);
                                                updateUserDetails(
                                                    "country", region);
                                                Navigator.pop(context);
                                                widget.callback();
                                                setState(() {});
                                              },
                                            ),
                                          );
                                        }),
                                  );
                                });
                          }),
                      ListTile(
                        title: Text('Streaming Quality'),
                        subtitle: Text('Higher quality uses more data'),
                        onTap: () {},
                        trailing: DropdownButton(
                          value: streamingQuality ?? '96 kbps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            setState(() {
                              streamingQuality = newValue;
                              Hive.box('settings')
                                  .put('streamingQuality', newValue);
                              updateUserDetails('streamingQuality', newValue);
                            });
                          },
                          items: <String>['96 kbps', '160 kbps', '320 kbps']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        dense: true,
                      ),
                      ListTile(
                          title: Text('Search Location'),
                          subtitle: Text('Locations to search for local music'),
                          dense: true,
                          onTap: () {
                            final GlobalKey<AnimatedListState> _listKey =
                                GlobalKey<AnimatedListState>();
                            showModalBottomSheet(
                                isDismissible: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return BottomGradientContainer(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: AnimatedList(
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      key: _listKey,
                                      scrollDirection: Axis.vertical,
                                      initialItemCount: dirPaths.length + 1,
                                      itemBuilder: (cntxt, idx, animation) {
                                        return (idx == 0)
                                            ? ListTile(
                                                title: Text('Add Location'),
                                                leading:
                                                    Icon(CupertinoIcons.add),
                                                onTap: () async {
                                                  String temp = await Picker()
                                                      .selectFolder(context,
                                                          'Select Folder');
                                                  if (temp.trim() != '' &&
                                                      !dirPaths
                                                          .contains(temp)) {
                                                    dirPaths.add(temp);
                                                    Hive.box('settings').put(
                                                        'searchPaths',
                                                        dirPaths);
                                                    _listKey.currentState
                                                        .insertItem(
                                                            dirPaths.length);
                                                  } else {
                                                    if (temp.trim() == '')
                                                      Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        elevation: 6,
                                                        backgroundColor:
                                                            Colors.grey[900],
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        content: Text(
                                                          temp.trim() == ''
                                                              ? 'No folder selected'
                                                              : 'Already added',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        action: SnackBarAction(
                                                          textColor:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                          label: 'Ok',
                                                          onPressed: () {},
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              )
                                            : SizeTransition(
                                                sizeFactor: animation,
                                                child: ListTile(
                                                  leading: Icon(
                                                      CupertinoIcons.folder),
                                                  title:
                                                      Text(dirPaths[idx - 1]),
                                                  trailing: IconButton(
                                                    icon: Icon(
                                                      CupertinoIcons.clear,
                                                      size: 15.0,
                                                    ),
                                                    onPressed: () {
                                                      dirPaths
                                                          .removeAt(idx - 1);
                                                      Hive.box('settings').put(
                                                          'searchPaths',
                                                          dirPaths);
                                                      _listKey.currentState
                                                          .removeItem(
                                                              idx,
                                                              (context,
                                                                      animation) =>
                                                                  Container());
                                                      // setStt(() {});
                                                    },
                                                  ),
                                                ),
                                              );
                                      },
                                    ),
                                  );
                                });
                          })
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
                child: GradientCard(
                  child: Column(children: [
                    ListTile(
                      title: Text('Download Quality'),
                      subtitle: Text('Higher quality uses more disk space'),
                      onTap: () {},
                      trailing: DropdownButton(
                        value: downloadQuality ?? '320 kbps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          setState(() {
                            downloadQuality = newValue;
                            Hive.box('settings')
                                .put('downloadQuality', newValue);
                            updateUserDetails('downloadQuality', newValue);
                          });
                        },
                        items: <String>['96 kbps', '160 kbps', '320 kbps']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                            ),
                          );
                        }).toList(),
                      ),
                      dense: true,
                    ),
                    SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title: Text('Download Lyrics'),
                        subtitle: Text('Default: Off'),
                        dense: true,
                        value: settingsBox.get('downloadLyrics',
                            defaultValue: false),
                        onChanged: (val) {
                          settingsBox.put('downloadLyrics', val);
                          setState(() {});
                        }),
                    ListTile(
                      title: Text('Download Location'),
                      subtitle: Text('$downloadPath'),
                      trailing: TextButton(
                        child: Text('Reset'),
                        style: TextButton.styleFrom(
                          primary:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                          //       backgroundColor: Theme.of(context).accentColor,
                        ),
                        onPressed: () async {
                          downloadPath = await ExtStorage
                              .getExternalStoragePublicDirectory(
                                  ExtStorage.DIRECTORY_MUSIC);
                          Hive.box('settings')
                              .put('downloadPath', downloadPath);
                          setState(() {});
                        },
                      ),
                      onTap: () async {
                        String temp = await Picker()
                            .selectFolder(context, 'Select Download Location');
                        if (temp.trim() != '') {
                          downloadPath = temp;
                          Hive.box('settings').put('downloadPath', temp);
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 6,
                              backgroundColor: Colors.grey[900],
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'No folder selected',
                                style: TextStyle(color: Colors.white),
                              ),
                              action: SnackBarAction(
                                textColor: Theme.of(context).accentColor,
                                label: 'Ok',
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      },
                      dense: true,
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Text(
                  'Others',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
                child: GradientCard(
                  child: Column(children: [
                    SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title: Text('Show Last Session on Home Screen'),
                        subtitle: Text('Default: On'),
                        dense: true,
                        value:
                            settingsBox.get('showRecent', defaultValue: true),
                        onChanged: (val) {
                          settingsBox.put('showRecent', val);
                          updateUserDetails('showRecent', val);
                          setState(() {});
                          widget.callback();
                        }),
                    SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title: Text('Show Search History'),
                        subtitle: Text('Default: On'),
                        dense: true,
                        value:
                            settingsBox.get('showHistory', defaultValue: true),
                        onChanged: (val) {
                          settingsBox.put('showHistory', val);
                          updateUserDetails('showHistory', val);
                          setState(() {});
                        }),
                    SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title: Text('Stop music on App Close'),
                        subtitle: Text(
                            "If turned off, music won't stop even after app close until you press stop button\nDefault: On\n"),
                        isThreeLine: true,
                        dense: true,
                        value: stopForegroundService ?? true,
                        onChanged: (val) {
                          Hive.box('settings')
                              .put('stopForegroundService', val);
                          stopForegroundService = val;
                          updateUserDetails('stopForegroundService', val);
                          setState(() {});
                        }),
                    SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title:
                            Text('Remove Service from foreground when paused'),
                        subtitle: Text(
                            "If turned on, you can slide notification when paused to stop the service. But Service can also be stopped by android to release memory. If you don't want android to stop service while paused, turn it off\nDefault: On\n"),
                        isThreeLine: true,
                        dense: true,
                        value: stopServiceOnPause ?? true,
                        onChanged: (val) {
                          Hive.box('settings').put('stopServiceOnPause', val);
                          stopServiceOnPause = val;
                          updateUserDetails('stopServiceOnPause', val);
                          setState(() {});
                        }),
                    // SwitchListTile(
                    //     activeColor: Theme.of(context).accentColor,
                    //     title: Text('Use Proxy (Beta)'),
                    //     subtitle: Text(
                    //         "Turn this on if you are not from India and having issues like getting only Indian Songs. You can even use a VPN"),
                    //     dense: true,
                    //     isThreeLine: true,
                    //     value: useProxy,
                    //     onChanged: (val) {
                    //       Hive.box('settings').put('useProxy', val);
                    //       useProxy = val;
                    //       updateUserDetails('useProxy', val);
                    //       setState(() {});
                    //     }),
                    if (useProxy)
                      ListTile(
                        title: Text('Proxy Settings'),
                        subtitle: Text('Change Proxy IP and Port'),
                        dense: true,
                        trailing: Text(
                          '${Hive.box('settings').get("proxyIp")}:${Hive.box('settings').get("proxyPort")}',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final _controller = TextEditingController(
                                  text: settingsBox.get('proxyIp'));
                              final _controller2 = TextEditingController(
                                  text:
                                      settingsBox.get('proxyPort').toString());
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'IP Address',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      autofocus: true,
                                      controller: _controller,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Port',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      autofocus: true,
                                      controller: _controller2,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[700],
                                      // backgroundColor: Theme.of(context).accentColor,
                                    ),
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                    ),
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      settingsBox.put(
                                          'proxyIp', _controller.text.trim());
                                      settingsBox.put('proxyPort',
                                          int.parse(_controller2.text.trim()));
                                      Navigator.pop(context);
                                      updateUserDetails(
                                          'proxyIp', _controller.text.trim());
                                      updateUserDetails('proxyPort',
                                          _controller2.text.trim());
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Text(
                  'About',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
                child: GradientCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Version'),
                        subtitle: Text('Tap to check for updates'),
                        onTap: () {
                          final dbRef = FirebaseDatabase.instance
                              .reference()
                              .child("LatestVersion");
                          dbRef.once().then((DataSnapshot snapshot) {
                            if (int.parse(snapshot.value
                                    .toString()
                                    .replaceAll('.', '')) >
                                appVersionCheck) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 6,
                                  backgroundColor: Colors.grey[900],
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Update Available!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  action: SnackBarAction(
                                    textColor: Theme.of(context).accentColor,
                                    label: 'Update',
                                    onPressed: () {
                                      final dLink = FirebaseDatabase.instance
                                          .reference()
                                          .child("LatestLink");
                                      dLink
                                          .once()
                                          .then((DataSnapshot linkSnapshot) {
                                        launch(linkSnapshot.value);
                                      });
                                    },
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 6,
                                  backgroundColor: Colors.grey[900],
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Congrats! You are using the latest version :)',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  action: SnackBarAction(
                                    textColor: Theme.of(context).accentColor,
                                    label: 'Ok',
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        trailing: Text(
                          'v$appVersion',
                          style: TextStyle(fontSize: 12),
                        ),
                        dense: true,
                      ),
                      // Divider(
                      //   height: 0,
                      //   indent: 15,
                      //   endIndent: 15,
                      // ),
                      ListTile(
                        title: Text('Share'),
                        subtitle:
                            Text('Let your friends know about mPipe Player'),
                        onTap: () {
                          Share.share(
                              'Hey! Check out this cool music player app: https://play.google.com/store/apps/details?id=com.kenafftechnology.mpipe');
                        },
                        dense: true,
                      ),

                      ListTile(
                        title: Text('Contact Us'),
                        subtitle: Text('Feedbacks appreciated'),
                        dense: true,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      // stops: [0, 0.2, 0.8, 1],
                                      colors: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? [
                                              Colors.grey[850],
                                              Colors.grey[850],
                                              Colors.grey[900],
                                            ]
                                          : [
                                              Colors.white,
                                              Theme.of(context).canvasColor,
                                            ],
                                    ),
                                  ),
                                  // color: Colors.black,
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(MdiIcons.gmail),
                                            iconSize: 40,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launch(
                                                  "https://mail.google.com/mail/?extsrc=mailto&url=mailto%3A%3Fto%3Dkenafftech%40gmail.com%26subject%3DRegarding%2520mPipe%2520App");
                                            },
                                          ),
                                          Text('Gmail'),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(MdiIcons.telegram),
                                            iconSize: 40,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launch(
                                                  "https://t.me/kenafftechnology");
                                            },
                                          ),
                                          Text('Telegram'),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(MdiIcons.instagram),
                                            iconSize: 40,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launch(
                                                  "https://instagram.com/kenafftechnology");
                                            },
                                          ),
                                          Text('Instagram'),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                      ),
                      ListTile(
                        title: Text('More info'),
                        dense: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                child: Center(
                  child: Text(
                    '?? Copyright ${DateTime.parse(new DateTime.now().toString()).year.toString()} | All rights reserved.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
