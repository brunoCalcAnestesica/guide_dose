import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class SimpleBeepPlayerController {
  final double bpm;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  bool _isPlaying = false;

  SimpleBeepPlayerController({this.bpm = 115}) {
    _audioPlayer.setVolume(1.0);
  }

  Future<void> start() async {
    if (_isPlaying) return;

    stop();
    _isPlaying = true;

    // Calcula o intervalo baseado no BPM (115 BPM para RCP)
    final intervalMs = (60000 / bpm).round();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (_isPlaying) {
        try {
          _audioPlayer.play(AssetSource('pcr/sounds/click.mp3'));
        } catch (e) {
          // Erro silencioso para não interromper o funcionamento
        }
      }
    });
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    stop();
    _audioPlayer.dispose();
  }
}
