import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_bloc.dart';
import 'package:haichaoyin/player/music_data.dart';

class MyAudioPlayerWithBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    return Column(
      children: <Widget>[
        StreamBuilder<double>(
          stream: bloc.playerPosition,
          builder: (context, snapshot) {
            return LinearProgressIndicator(value: snapshot.data ?? 0.0,);
          },
        ),
        StreamBuilder<AudioPlayerState>(
          stream: bloc.playerSate,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch(snapshot.data) {

                case AudioPlayerState.STOPPED:
                  return IconButton(icon: Icon(Icons.play_circle_filled), onPressed: () => bloc.act(MusicControlOperation.play));
                  break;
                case AudioPlayerState.PLAYING:
                  return IconButton(icon: Icon(Icons.pause_circle_filled), onPressed: () => bloc.act(MusicControlOperation.pause));
                  break;
                case AudioPlayerState.PAUSED:
                  return IconButton(icon: Icon(Icons.play_circle_filled), onPressed: () => bloc.act(MusicControlOperation.play));
                  break;
                case AudioPlayerState.COMPLETED:
                  return IconButton(icon: Icon(Icons.replay), onPressed: () => bloc.act(MusicControlOperation.play));
                  break;
              }
            }
            return Text("x");
          },
        )
      ],
    );
  }

}
