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

# Convert the video to specified constant frame rate by duplicating or dropping frames as necessary.
export def fps [
  --input (-i): list<string>: = []
  --output (-o): list<string>: = []
 --start-time (-s) # Assume the first PTS should be the given value, in seconds.
# This allows for padding/trimming at the start of stream. By default, no assumption is made about the first frame’s expected PTS, so no padding or trimming is done. For example, this could be set to 0 to pad the beginning with duplicates of the first frame if a video stream starts after the audio stream or to trim any frames with a negative PTS.
  --round (-r): string@fps-round-options # Timestamp (PTS) rounding method. use completion to view available options.
  --eof-action (-e): string # Action performed when reading the last frame. Possible values are: "round", "pass"
  fps: string = '25' # The desired output frame rate. It accepts expressions containing the following constants:
# "source_fps": The input’s frame rate
# "ntsc": NTSC frame rate of 30000/1001
# "pal": PAL frame rate of 25.0
# "film": Film frame rate of 24.0
# "ntsc_film": NTSC-film frame rate of 24000/1001
  ] {
  cmd filters append [
    (complex-filter fps {fps: $fps round: $round} -i $input)
  ]
}

def fps-round-options [] {
  [
    'zero'
    'inf'
    'down'
    'up'
    'near'
  ]
}

# Set the timebase to use for the output frames timestamps. It is mainly useful for testing timebase configuration.
export def settb [
  --input (-i): list<string>: = []
  --output (-o): list<string>: = []
  timebase # The value for tb is an arithmetic expression representing a rational. The expression can contain the constants "AVTB" (the default timebase), "intb" (the input timebase) and "sr" (the sample rate, audio only). Default value is "intb".
  ] {
  cmd filters append [
    (complex-filter settb {expr: $timebase} -i $input -o $output)
  ]
}

# TODO: Refactor "list to-pipe-separated-string"
def "list to-pipe-separated-string" []: list -> string {
  let list = $in;

  if ($list | length) > 0 {
    $list | str join '|'
  }
}

# Convert the input video to one of the specified pixel formats. Libavfilter will try to pick one that is suitable as input to the next filter.
export def format [
  --input (-i): list<string>: = []
  --output (-o): list<string>: = []
  --pix-fmts (-p): list<string> # A list of pixel format names
  --color-spaces (-c): list<string> # A list of color space names
  --color-ranges (-r): list<string> # A list of color range names
  ] {
  cmd filters append [
    (complex-filter format {
      pix_fmts: ($pix_fmts | list to-pipe-separated-string)
      color_spaces: ($color_spaces | list to-pipe-separated-string)
      color_ranges: ($color_ranges | list to-pipe-separated-string)
    } -i $input -o $output)
  ]
}

# Apply cross fade from one input video stream to another input video stream. The cross fade is applied for specified duration.
# Both inputs must be constant frame-rate and have the same resolution, pixel format, frame rate and timebase.
export def xfade [
  --input (-i): list<string> = []
  --output (-o): list<string> = []
  --transition (-t): string@xfade-transitions = fade # Set one of available transition effects (activate completion to view)
  --duration (-d): float = 1.0 # Set cross fade duration in seconds. Range is 0 to 60 seconds. Default duration is 1 second.
  --offset (-O): float = 0.0 # Set cross fade start relative to first input stream in seconds. Default offset is 0.
  --expr (-e): string
] {
  cmd filters append [
    (complex-filter xfade -i $input -o $output { transition: $transition duration: $duration offset: $offset expr: $expr })
  ]
}

# List of available transition effects
def xfade-transitions [] {
  [
    'custom'
    'fade'
    'wipeleft'
    'wiperight'
    'wipeup'
    'wipedown'
    'slideleft'
    'slideright'
    'slideup'
    'slidedown'
    'circlecrop'
    'rectcrop'
    'distance'
    'fadeblack'
    'fadewhite'
    'radial'
    'smoothleft'
    'smoothright'
    'smoothup'
    'smoothdown'
    'circleopen'
    'circleclose'
    'vertopen'
    'vertclose'
    'horzopen'
    'horzclose'
    'dissolve'
    'pixelize'
    'diagtl'
    'diagtr'
    'diagbl'
    'diagbr'
    'hlslice'
    'hrslice'
    'vuslice'
    'vdslice'
    'hblur'
    'fadegrays'
    'wipetl'
    'wipetr'
    'wipebl'
    'wipebr'
    'squeezeh'
    'squeezev'
    'zoomin'
    'fadefast'
    'fadeslow'
    'hlwind'
    'hrwind'
    'vuwind'
    'vdwind'
    'coverleft'
    'coverright'
    'coverup'
    'coverdown'
    'revealleft'
    'revealright'
    'revealup'
    'revealdown'
  ]
}

export def split [
  --input (-i): list<string>: = []
  output: list<string>
] {
    let cmd = $in;

    let n = ($output | length);

    $cmd | cmd filters append [(complex-filter 'split' (if $n != 2 {
      {'n': $n}
    } else {
      {}
    }) -i $input -o $output)]
}

# Crop the input video to given dimensions.
export def crop [
  --input (-i): list<string> = []
  --width (-w): string = 'iw'
  --height (-h): string
  --keep-aspect (-k) # Force the output display aspect ratio to be the same of the input
  --exact (-e) # If enabled, subsampled videos will be cropped at exact width/height/x/y as specified
  x = '0'
  y = '0'
] {
  cmd filters append [
    (complex-filter crop {
      w: $width
      h: $height
      x: $x
      y: $y
      keep_aspect: $keep_aspect
      exact: $exact
    } -i $input)
  ]
}

# Flip the input video vertically.
export def vflip [
  --input: list<string> = []
  output: list<string>
] {
  cmd filters append [
    (complex-filter vflip -i $input -o $output)
  ]
}

#TODO: Finish

# Overlay one video on top of another.
export def overlay [
  -x: int = 0
  -y: int = 0
  --output: list<string>
  input: list<string>
] {
  cmd filters append [
    (complex-filter overlay -i $input -o $output {x: $x y: $y})
  ]
}
