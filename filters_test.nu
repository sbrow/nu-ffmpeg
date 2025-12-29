#!/usr/bin/env nu

use std [assert];

use ./ffmpeg.nu [complex-filter "parse filter"];
use ./filters.nu [vloop];

def main [] {
   let test_commands = (
        scope commands
            | where ($it.type == "custom")
                and ($it.description | str starts-with "[test]")
                and not ($it.description | str starts-with "ignore")
            | get name
            | each { |test| [$"print 'Running test: ($test)'", $test] } | flatten
            | str join "; "
    )

    # $test_commands | explore

    nu --commands $"source ($env.CURRENT_FILE); ($test_commands)"
    print "Tests completed successfully"
}

#[test]
def loop_has_defaults [] {
  let got = (vloop 10 1);
  let want = (complex-filter 'loop' { loop: 10 size: 1 });
  assert equal $got $want;
}

#[test]
def setting_time_sets_start_to-1 [] {
  let got = (vloop 10 1 -t 0.5);
  let want = (complex-filter 'loop' {
      loop: 10
      size: 1
      start: -1
      time: 0.5
    });

  assert equal $got $want;
}
