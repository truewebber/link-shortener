import 'dart:async';
import 'package:js/js.dart';
import 'package:universal_html/html.dart' as html;

@JS('grecaptcha')
mixin Recaptcha {
  external static Promise execute(String siteKey, dynamic options);
}

@JS('Promise')
class Promise {
  external factory Promise(void Function(Function resolve, Function reject) executor);
  external Promise then(Function onFulfilled, [Function? onRejected]);
}

extension FutureExtension on Promise {
  Future<T> asFuture<T>() {
    final completer = Completer<T>();
    then(
      allowInterop((value) => completer.complete(value as T)),
      allowInterop(completer.completeError),
    );
    return completer.future;
  }
}

extension RecaptchaExtension on html.Window {
  dynamic get recaptcha => Recaptcha;
}
