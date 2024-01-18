#!/usr/bin/env nu

use std [assert];

use ./filters.nu [complex-filter loop "parse filter"];

# #[test]
def loop_has_defaults [] {
  let got = (loop 10 1);
  let want = (complex-filter 'loop' { loop: 10 size: 1 });
  assert equal $got $want;
}

# #[test]
def setting_time_sets_start_to-1 [] {
  let got = (loop 10 1 -t 0.5);
  let want = (complex-filter 'loop' {
      loop: 10
      size: 1
      start: -1
      time: 0.5
    });

  assert equal $got $want;
}
