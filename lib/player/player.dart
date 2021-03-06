import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;

  MusicPlayer({this.songInfo, this.changeTrack, this.key}) : super(key: key);
  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void iconChange() {
    if (isPlaying == true) {
      setState(() {
        Icon(Icons.play_arrow);
      });
    } else {
      setState(() {
        Icon(Icons.pause);
      });
    }
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentvalue = minmumvalue;
    maximumvalue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentvalue);
      endTime = getDuration(maximumvalue);
    });
    isPlaying = false;
    changeState();
    player.positionStream.listen((duration) {
      currentvalue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentvalue);
///////////////////////////////////////////////////////iwrote toTestOn9;07AM,March:12
        if (currentvalue >= maximumvalue) {
          return widget.changeTrack(true);
        }
        ///////////////////////////////
      });
    });
  }

  void changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "NOW PLAYING",
          style: TextStyle(color: Colors.teal[200]),
        ),
        leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 150, 5, 0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: widget.songInfo.albumArtwork == null
                  ? AssetImage(
                      'android/assets/images/Apple-Music-artist-promo.jpg')
                  : FileImage(File(widget.songInfo.albumArtwork)),
              radius: 150,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 10, 30, 5),
              margin: EdgeInsets.fromLTRB(30, 10, 0, 30),
              child: Text(
                widget.songInfo.title,
                style: TextStyle(
                    color: Colors.teal[200],
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                widget.songInfo.artist,
                style: TextStyle(
                    color: Colors.teal[200],
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Slider(
              inactiveColor: Colors.teal[200],
              activeColor: Colors.redAccent,
              min: minmumvalue,
              max: maximumvalue,
              value: currentvalue,
              onChanged: (value) {
                currentvalue = value;

                player.seek(
                  Duration(
                    milliseconds: currentvalue.round(),
                  ),
                );
                if (currentvalue >= maximumvalue) {
                  widget.changeTrack(true);
                }
              },
            ),
            Container(
              transform: Matrix4.translationValues(0, -5, 0),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                        color: Colors.teal[200],
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    endTime,
                    style: TextStyle(
                        color: Colors.teal[200],
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Icon(Icons.skip_previous_outlined,
                        color: Colors.green, size: 55),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(false);
                    },
                  ),
                  GestureDetector(
                    child: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Colors.red,
                        size: 85),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      changeState();
                    },
                  ),
                  GestureDetector(
                    child: Icon(Icons.skip_next_outlined,
                        color: Colors.green, size: 55),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(true);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey,
    );
  }
}
