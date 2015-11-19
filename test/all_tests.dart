@test.TestOn("browser")

library test.all;

import 'package:test/test.dart' as test;

import 'observable_test.dart' as observable_tests;
import 'scheduler_test.dart' as scheduler_tests;
import 'subject_test.dart' as subject_tests;

void main() {
  observable_tests.main();
  scheduler_tests.main();
  subject_tests.main();
}
