import 'package:flutter_riverpod/flutter_riverpod.dart';

// Di Riverpod 3, kita menggunakan class Notifier
class SelectedVehiclesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    // Ini adalah initial state-nya
    return {};
  }

  void toggle(int id) {
    if (state.contains(id)) {
      // Menggunakan spread operator untuk membuat Set baru (Immutable)
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void clear() {
    state = {};
  }
}

// Cara deklarasi providernya sedikit berubah
final selectedVehiclesProvider =
    NotifierProvider<SelectedVehiclesNotifier, Set<int>>(
      SelectedVehiclesNotifier.new,
    );
