import 'package:mockito/mockito.dart';

class MockBrowserDetection extends Mock {
  bool isSafari() => false;
  bool isChrome() => true;
  bool isFirefox() => false;
  bool isEdge() => false;
}
