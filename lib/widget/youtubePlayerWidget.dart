
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';




class YouTubeVideoRow extends StatefulWidget {
  final String  link;

  const YouTubeVideoRow({
     Key? key,
    required this.link
  }) : super(key: key);

  @override
  _YouTubeVideoRowState createState() => _YouTubeVideoRowState();
}

class _YouTubeVideoRowState extends State<YouTubeVideoRow> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
    initialVideoId: widget.link.replaceAll("https://www.youtube.com/watch?v=", "").trim()
          .replaceAll("https://www.youtube.com/shorts/", "").trim(),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
         // aspectRatio:16/3,
          showVideoProgressIndicator: true,

        ),

        builder: (context, player) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Container(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: player),
                ),
              ],),
             
            ],
          );

        }
    );
  }
}