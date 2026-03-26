import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'floating_label.dart';

class FloatingLabelData {
  FloatingLabelData({
    required this.id,
    required this.text,
    required this.color,
    required this.position,
  });

  final String id;
  final String text;
  final Color color;
  final Offset position;
}

class FloatingLabelNotifier extends StateNotifier<List<FloatingLabelData>> {
  FloatingLabelNotifier() : super([]);

  void show(String text, Color color, Offset position) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final data = FloatingLabelData(
      id: id,
      text: text,
      color: color,
      position: position,
    );
    state = [...state, data];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final floatingLabelProvider =
    StateNotifierProvider<FloatingLabelNotifier, List<FloatingLabelData>>((ref) {
  return FloatingLabelNotifier();
});

class FloatingLabelLayer extends ConsumerWidget {
  const FloatingLabelLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(floatingLabelProvider);

    return Stack(
      children: [
        child,
        ...labels.map((label) => FloatingLabel(
              key: ValueKey(label.id),
              text: label.text,
              color: label.color,
              position: label.position,
              onRemove: () =>
                  ref.read(floatingLabelProvider.notifier).remove(label.id),
            )),
      ],
    );
  }
}
