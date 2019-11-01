import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class Speaker {
  StreamSubscription audioPlayerCompletedSubscription;
  AudioPlayer audioPlayer = AudioPlayer();

  void stopThenPlayLocalAudio(localPath) async {
    await audioPlayer.stop();
    await audioPlayer.play(localPath, isLocal: true);
  }

  void stopLocalAudio(localPath) async {
    await audioPlayer.stop();
  }

  Future playLocalAudio(localPath) async {
    if (audioPlayerCompletedSubscription != null) {
      audioPlayerCompletedSubscription.cancel();
    }

    await audioPlayer.play(localPath, isLocal: true);

    Completer completer = Completer();
    audioPlayerCompletedSubscription =
        audioPlayer.onPlayerCompletion.listen((_) {
      audioPlayer.release();
      completer.complete();
    });

    return completer.future;
  }
}
