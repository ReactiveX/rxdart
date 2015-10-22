@test.TestOn("browser")

library test.all;

import 'package:test/test.dart' as test;

import 'observable_tests.dart' as observable_tests;
import 'scheduler_tests.dart' as scheduler_tests;

void main() {
  observable_tests.main();
  scheduler_tests.main();
}





