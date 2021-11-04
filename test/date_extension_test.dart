import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/date_extension.dart';

void main() {
  test('Counter value should be incremented', () {
    final yesterday = DateTime.now().subtract(Duration(days: 1));

    final str = yesterday.smartString();

    expect(str.split(" ")[0], "Yesterday");
  });
}
