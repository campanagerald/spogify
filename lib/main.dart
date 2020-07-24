import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.expand_more),
          centerTitle: true,
          title: Column(
            children: <Widget>[
              Text('Playing from your library'),
              Text('Liked Songs'),
            ],
          ),
          actions: <Widget>[
            Icon(
              Icons.more_vert,
            )
          ],
        ),
        body: MyHomePage(),
      ),
    );
  }
}

enum PlayStatus { PLAYING, PAUSE, STOP }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioCache player = AudioCache(prefix: 'audio/');
  AudioPlayer audioPlayer;
  int totalDuration;
  Duration currentPosition = Duration(seconds: 0);
  Duration maxDuration = Duration(seconds: 0);
  PlayStatus playStatus = PlayStatus.STOP;

  double value = 10;

  play() async {
    if (playStatus == PlayStatus.STOP) {
      audioPlayer = await player.play('grateful.mp3');

      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() => maxDuration = d);
      });

      audioPlayer.onAudioPositionChanged.listen((Duration p) {
        setState(() => currentPosition = p);
      });

      setState(() {
        playStatus = PlayStatus.PLAYING;
      });
    } else if (playStatus == PlayStatus.PAUSE) {
      audioPlayer.resume();
      setState(() {
        playStatus = PlayStatus.PLAYING;
      });
    } else if (playStatus == PlayStatus.PLAYING) {
      audioPlayer.pause();
      setState(() {
        playStatus = PlayStatus.PAUSE;
      });
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.asset(
            'assets/images/neffex.jpeg',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Grateful'),
                  Text('NEFFEX'),
                ],
              ),
              Icon(Icons.favorite),
            ],
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SliderTheme(
                  data: SliderThemeData(
                    trackShape: CustomTrackShape(),
                  ),
                  child: Slider(
                      min: 0,
                      max: maxDuration.inSeconds.toDouble(),
                      value: currentPosition.inSeconds.toDouble(),
                      onChanged: (newValue) {
                        setState(() => currentPosition =
                            Duration(seconds: newValue.toInt()));
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_printDuration(currentPosition)),
                    Text(_printDuration(maxDuration)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.shuffle),
              Icon(Icons.skip_previous),
              GestureDetector(
                onTap: play,
                child: playStatus == PlayStatus.PAUSE ||
                        playStatus == PlayStatus.STOP
                    ? Icon(Icons.play_arrow)
                    : Icon(Icons.pause),
              ),
              Icon(Icons.skip_next),
              Icon(Icons.repeat),
            ],
          )
        ],
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
