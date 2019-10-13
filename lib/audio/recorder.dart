abstract class Recorder {
  String audioFileLocation;

  Recorder(this.audioFileLocation);

  Future recordAudio();
  Future stopRecordAudio();
}