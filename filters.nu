#!/usr/bin/env -S nu --stdin

use std [assert];

use ./ffmpeg.nu ["complex-filter" "cmd filters append"]

# loop video frames
export def loop [
  --input (-i): list<string>: = []
  --output (-o): list<string>: = []
  loop: int # Set the number of loops. Setting this value to -1 will result in infinite loops. Default is 0.
  size: int # Set maximal size in number of frames. Default is 0.
  --start (-s): int # Set first frame of loop. Default is 0.
  --time (-t): float # Set the time of loop start in seconds. Only used if option named start is set to -1.
] {
  cmd filters append [
    (complex-filter loop {
      loop: $loop
      size: $size
      start: (if ($time | is-empty) { $start } else { -1 })
      time: $time
    } -i $input -o $output)
  ]
}

export def fps [
  --input (-i): list<string>: = []
  --output (-o): list<string>: = []
  --round (-r): string

  fps: int
  ] {
  cmd filters append [
    (complex-filter fps {fps: $fps round: $round} -i $input)
    (complex-filter settb {expr: $'1/($fps)' } -o $output)
  ]
}

export def split [
  --input (-i): list<string>: = []
  --output (-o): string
] {
    let cmd = $in;

    let n = ($output | length);

    $cmd | cmd filters append [(complex-filter 'split' (if $n != 2 {
      {'n': $n}
    } else {
      {}
    }) -i $input -o $output)]
}

# TODO: Finish
export def crop [
  --input: list<string> = []
  --width (-w): string = 'iw'
  --height (-h): string
  x = '0'
  y = '0'
] {
  cmd filters append [
    (complex-filter crop {w: $width h: $height x: $x, y: $y} -i $input)
  ]
}

# TODO: Finish
export def vflip [
  ...output: string
] {
  cmd filters append [
    (complex-filter vflip -o $output)
  ]
}
