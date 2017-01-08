library test.rx;

import 'observable/stream_test.dart' as stream_test;
import 'observable/combine_latest_test.dart' as combine_latest_test;
import 'observable/concat_test.dart' as concat_test;
import 'observable/merge_test.dart' as merge_test;
import 'observable/zip_test.dart' as zip_test;
import 'observable/just_test.dart' as just_test;

import 'operators/debounce_test.dart' as debounce_test;
import 'operators/throttle_test.dart' as throttle_test;
import 'operators/retry_test.dart' as retry_test;
import 'operators/buffer_with_count_test.dart' as buffer_with_count_test;
import 'operators/window_with_count_test.dart' as window_with_count_test;
import 'operators/flat_map_test.dart' as flat_map_test;
import 'operators/flat_map_latest_test.dart' as flat_map_latest_test;
import 'operators/take_until_test.dart' as take_until_test;
import 'operators/scan_test.dart' as scan_test;
import 'operators/tap_test.dart' as tap_test;
import 'operators/start_with_test.dart' as start_with_test;
import 'operators/start_with_many_test.dart' as start_with_many_test;
import 'operators/repeat_test.dart' as repeat_test;
import 'operators/min_test.dart' as min_test;
import 'operators/max_test.dart' as max_test;
import 'operators/time_interval_test.dart' as time_interval_test;
import 'operators/pluck_test.dart' as pluck_test;

import 'observable/tween_test.dart' as tween_test;

import 'subject/behaviour_subject_test.dart' as behaviour_subject_test;

void main() {
  stream_test.main();
  combine_latest_test.main();
  concat_test.main();
  merge_test.main();
  zip_test.main();
  just_test.main();

  debounce_test.main();
  throttle_test.main();
  retry_test.main();
  buffer_with_count_test.main();
  window_with_count_test.main();
  flat_map_test.main();
  flat_map_latest_test.main();
  take_until_test.main();
  scan_test.main();
  tap_test.main();
  start_with_test.main();
  start_with_many_test.main();
  repeat_test.main();
  min_test.main();
  max_test.main();
  time_interval_test.main();
  pluck_test.main();

  tween_test.main();

  behaviour_subject_test.main();
}
