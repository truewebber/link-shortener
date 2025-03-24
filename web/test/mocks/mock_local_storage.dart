// import 'dart:async';
// import 'dart:convert';

// /// Простой мок для LocalStorage, который не использует таймеры
// class MockLocalStorage {
//   MockLocalStorage() {
//     // Инициализация мок-хранилища без таймеров и файловых операций
//     _readyCompleter.complete(true);
//   }
//   final Map<String, dynamic> _storage = {};
//   final Completer<bool> _readyCompleter = Completer<bool>();
  
//   Future<bool> get ready => _readyCompleter.future;
  
//   bool get initialized => true;
  
//   String? getItem(String key) {
//     if (_storage.containsKey(key)) {
//       final value = _storage[key];
//       if (value is String) {
//         return value;
//       } else {
//         try {
//           return jsonEncode(value);
//         } catch (e) {
//           return value.toString();
//         }
//       }
//     }
//     return null;
//   }
  
//   Future<void> setItem(String key, dynamic value) async {
//     _storage[key] = value;
//   }
  
//   Future<void> deleteItem(String key) async {
//     _storage.remove(key);
//   }
  
//   Future<void> clear() async {
//     _storage.clear();
//   }
  
//   /// Метод для очистки ресурсов (не требуется для этого мока, 
//   /// но нужен для совместимости с интерфейсом)
//   void dispose() {
//     // Ничего не делаем, так как нет ресурсов для очистки
//   }
// }
