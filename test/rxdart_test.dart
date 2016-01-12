library test.rx;

import 'observable/stream_test.dart' as stream_test;
import 'observable/combine_latest_test.dart' as combine_latest_test;
import 'observable/combine_latest_map_test.dart' as combine_latest_map_test;
import 'observable/merge_test.dart' as merge_test;
import 'observable/zip_test.dart' as zip_test;

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
import 'operators/repeat_test.dart' as repeat_test;
import 'operators/replay_test.dart' as replay_test;

void main() {
  stream_test.main();
  combine_latest_test.main();
  combine_latest_map_test.main();
  merge_test.main();
  zip_test.main();

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
  repeat_test.main();
  replay_test.main();
}