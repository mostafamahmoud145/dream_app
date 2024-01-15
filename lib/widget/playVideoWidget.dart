
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:video_player/video_player.dart';

class PlayVideoWidget extends StatefulWidget {
  final String url;

  const PlayVideoWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<PlayVideoWidget> createState() => _PlayVideoWidgetState();
}

class _PlayVideoWidgetState extends State<PlayVideoWidget> {
   late VideoPlayerController _controller;
   late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(widget.url);

    // Initialize the controllers and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controllers to loop the video.
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }
   @override
   Widget build(BuildContext context) {
     return Stack(alignment: Alignment.center,children: [
       Container(
         width: AppSize.w400.w,
         height: AppSize.h390.h,
         child: FutureBuilder(
           future: _initializeVideoPlayerFuture,
           builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.done) {
               // If the VideoPlayerController has finished initialization, use
               // the data it provides to limit the aspect ratio of the video.
               return AspectRatio(
                 aspectRatio: _controller.value.aspectRatio,
                 // Use the VideoPlayer widget to display the video.
                 child:  ClipRRect(
                     borderRadius: BorderRadius.circular(AppRadius.r50),child: VideoPlayer(_controller)),
               );
             } else {
               // If the VideoPlayerController is still initializing, show a
               // loading spinner.
               return const Center(
                 child: CircularProgressIndicator(),
               );
             }
           },
         ),
       ),
       Center(
         child: new IconButton(
             icon: new Icon(_controller.value.isPlaying?Icons.pause_circle_filled:Icons.play_circle,
               color: AppColors.white.withOpacity(.5),size: AppSize.w50,),
             onPressed: () { setState(() {
               if (_controller.value.isPlaying) {
                 _controller.pause();
               } else {
                 _controller.play();
               }
             });},
             color:Theme.of(context).primaryColor
         )
       ),
     ],
     );
   }

}