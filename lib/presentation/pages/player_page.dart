import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  double _progress = 0.0;
  double _speed = 1.0;
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trình nghe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text('Current track', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Icon(Icons.music_note, size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.replay_10), onPressed: () {}),
                IconButton(icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 48), onPressed: () => setState(() => _playing = !_playing)),
                IconButton(icon: const Icon(Icons.forward_10), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              ChoiceChip(label: const Text('0.5x'), selected: _speed == 0.5, onSelected: (_) => setState(() => _speed = 0.5)),
              ChoiceChip(label: const Text('1x'), selected: _speed == 1.0, onSelected: (_) => setState(() => _speed = 1.0)),
              ChoiceChip(label: const Text('1.5x'), selected: _speed == 1.5, onSelected: (_) => setState(() => _speed = 1.5)),
              ChoiceChip(label: const Text('2x'), selected: _speed == 2.0, onSelected: (_) => setState(() => _speed = 2.0)),
            ])
          ],
        ),
      ),
    );
  }
}
