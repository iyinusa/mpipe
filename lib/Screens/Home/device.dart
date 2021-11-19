import 'package:mpipe/Helpers/format.dart';
import 'package:mpipe/Screens/Common/song_list.dart';
import 'package:mpipe/Screens/Player/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mpipe/APIs/api.dart';
// import 'package:flutter_audio_query/flutter_audio_query.dart';

bool fetched = false;
List preferredLanguage =
    Hive.box('settings').get('preferredLanguage') ?? ['English'];
Map data = Hive.box('cache').get('homepage', defaultValue: {});
List lists = ["recent", ...?data["collections"]];

class DeviceHomePage extends StatefulWidget {
  @override
  _DeviceHomePageState createState() => _DeviceHomePageState();
}

class _DeviceHomePageState extends State<DeviceHomePage> {
  List recentList =
      Hive.box('recentlyPlayed').get('recentSongs', defaultValue: []);

  /// create a FlutterAudioQuery instance.
  // final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  // void getArtists() async {
  //   /// check and update Playlists
  //   // Box settingsBox = Hive.box('settings');
  //   // List playlistNames = [];
  //   // playlistNames = settingsBox.get('playlistNames')?.toList() ?? [];

  //   // playlistNames.forEach((item) {
  //   //   FlutterAudioQuery.createPlaylist(playlistName: item);
  //   // });

  //   List<PlaylistInfo> songs = await audioQuery.getPlaylists();

  //   print('Total Items: ' + songs.length.toString());

  //   songs.forEach((artist) {
  //     print('++++++++++++++++++++++++\n' +
  //         artist.toString() +
  //         '\n+++++++++++++++++++++++++');
  //   });
  // }

  void getHomePageData() async {
    Map recievedData = await SaavnAPI().fetchHomePageData();
    if (recievedData != null && recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ["recent", ...?data["collections"]];
    }
    setState(() {});
    recievedData = await FormatResponse().formatPromoLists(data);
    if (recievedData != null && recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ["recent", ...?data["collections"]];
    }
    setState(() {});
  }

  String getSubTitle(Map item) {
    final type = item['type'];
    if (type == 'charts') {
      return '';
    } else if (type == 'playlist') {
      return formatString(item['subtitle']);
    } else if (type == 'radio_station') {
      return "Artist Radio";
    } else if (type == "song") {
      return formatString(item["artist"]);
    } else {
      final artists = item['more_info']['artistMap']['artists']
          .map((artist) => artist['name'])
          .toList();
      return formatString(artists.join(', '));
    }
  }

  String formatString(String text) {
    return text == null
        ? ''
        : text
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"")
            .trim();
  }

  @override
  Widget build(BuildContext context) {
    // get Artists
    // getArtists();

    print('UserID: ' + Hive.box('settings').get('userID'));

    if (!fetched) {
      // getHomePageData();
      // fetched = true;
    }
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        scrollDirection: Axis.vertical,
        itemCount: data.isEmpty ? 1 : lists.length,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return (recentList.isEmpty ||
                    !Hive.box('settings').get('showRecent', defaultValue: true))
                ? SizedBox()
                : Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                            child: Text(
                              'Recently Played',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4 + 10,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          itemCount: recentList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.height / 4 - 30,
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        errorWidget: (context, _, __) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                        imageUrl: recentList[index]["image"]
                                            .replaceAll('http:', 'https:')
                                            .replaceAll('50x50', '500x500')
                                            .replaceAll('150x150', '500x500'),
                                        placeholder: (context, url) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${recentList[index]["title"]}',
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${recentList[index]["artist"]}',
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => PlayScreen(
                                      data: {
                                        'response': recentList,
                                        'index': index,
                                        'offline': false,
                                      },
                                      fromMiniplayer: false,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(
                      '${formatString(data['modules'][lists[idx]]["title"])}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              data[lists[idx]] == null
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height / 4 + 5,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.height / 4 - 30,
                            child: Column(
                              children: [
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image(
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                ),
                                Text(
                                  'Loading ...',
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Please Wait',
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 4 + 5,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        itemCount: data[lists[idx]].length,
                        itemBuilder: (context, index) {
                          final item = data[lists[idx]][index];
                          final currentSongList = data[lists[idx]]
                              .where((e) => (e["type"] == 'song'))
                              .toList();
                          final subTitle = getSubTitle(item);
                          return GestureDetector(
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.height / 4 - 30,
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      errorWidget: (context, _, __) => Image(
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                      imageUrl: item["image"]
                                          .replaceAll('http:', 'https:')
                                          .replaceAll('50x50', '500x500')
                                          .replaceAll('150x150', '500x500'),
                                      placeholder: (context, url) => Image(
                                        image: (item["type"] == 'playlist' ||
                                                item["type"] == 'album')
                                            ? AssetImage('assets/album.png')
                                            : item["type"] == 'artist'
                                                ? AssetImage(
                                                    'assets/artist.png')
                                                : AssetImage(
                                                    'assets/cover.jpg'),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${formatString(item["title"])}',
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subTitle != ''
                                      ? Text(
                                          subTitle,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => item["type"] ==
                                          "song"
                                      ? PlayScreen(
                                          data: {
                                            'response': currentSongList,
                                            'index': currentSongList.indexWhere(
                                                (e) => (e["id"] == item['id'])),
                                            'offline': false,
                                          },
                                          fromMiniplayer: false,
                                        )
                                      : SongsListPage(
                                          listImage: item["image"],
                                          listItem: item,
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          );
        });
  }
}
