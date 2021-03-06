import 'package:mpipe/APIs/api.dart';
import 'package:mpipe/CustomWidgets/gradientContainers.dart';
import 'package:mpipe/Helpers/playlist.dart';
import 'package:mpipe/Services/youtube_services.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchAddPlaylist {
  Future<Map> addYtPlaylist(String link) async {
    try {
      RegExpMatch id = RegExp(r'.*list=(.*)').firstMatch(link);
      print(id[1]);
      Playlist metadata = await YouTubeServices().getPlaylistDetails(id[1]);
      List<Video> tracks = await YouTubeServices().getPlaylistSongs(id[1]);
      return {
        'title': metadata.title,
        'image': metadata.thumbnails.standardResUrl,
        'author': metadata.author,
        'description': metadata.description,
        'tracks': tracks,
        'count': tracks.length,
      };
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }

  Stream<Map> songsAdder(String playName, List<Video> tracks) async* {
    int _done = 0;
    for (Video track in tracks) {
      String trackName;
      try {
        trackName = track.title;
        yield {'done': ++_done, 'name': trackName};
      } catch (e) {
        yield {'done': ++_done, 'name': ''};
      }
      try {
        List result =
            await SaavnAPI().fetchTopSearchResult(trackName.split("|")[0]);
        addPlaylistMap(playName, result[0]);
      } catch (e) {
        print('Error in $_done: $e');
      }
    }
  }

  Future<void> showProgress(int _total, BuildContext cxt, String playlistName,
      String image, List<Video> tracks) async {
    showModalBottomSheet(
      isDismissible: false,
      backgroundColor: Colors.transparent,
      context: cxt,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStt) {
          return BottomGradientContainer(
            child: SizedBox(
              height: 300,
              width: 300,
              child: StreamBuilder<Object>(
                  stream: songsAdder(playlistName, tracks),
                  builder: (ctxt, snapshot) {
                    Map data = snapshot?.data;
                    int _done = (data ?? const {})['done'] ?? 0;
                    String name = (data ?? const {})['name'] ?? '';
                    if (_done == _total) Navigator.pop(ctxt);
                    return Stack(
                      children: [
                        Center(
                          child: Text('$_done / $_total'),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                                child: Text(
                              'Converting Songs',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )),
                            SizedBox(
                              height: 75,
                              width: 75,
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(ctxt).accentColor),
                                  value: _done / _total),
                            ),
                            Center(
                                child: Text(
                              name,
                              textAlign: TextAlign.center,
                            )),
                          ],
                        ),
                      ],
                    );
                  }),
            ),
          );
        });
      },
    );
  }
}
