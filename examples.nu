#!/usr/bin/env nu

use ffmpeg.nu;
use filters.nu *;
use filters.nu; # overlay filter can't be used with a * immport

def main [] {
  # ffmpeg -i INPUT -filter_complex "split [main][tmp]; [tmp] crop=iw:ih/2:0:0, vflip [flip]; [main][flip] overlay=0:H/2" OUTPUT
  (
    ffmpeg cmd ['INPUT'] ['OUTPUT']
    | split ['main' 'tmp']
    | ffmpeg filterchain { crop --height 'ih/2' -i ['tmp'] | vflip ['flip'] }
    | filters overlay -i ['main' 'flip'] -x 0 -y 'H/2'
    | ffmpeg run --dry-run
  )

  # ffprobe 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'

  # ffprobe 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4' | streams video

  # Re-encode the video to 30fps
  #(
    # command ['https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4']
    # | fps 30
    # | command to-args
    # | ['ffmpeg', ...$in] 
  #)

  # Re-encode the video to 30fps, specifying inputs and outputs
  # (
    # ffmpeg cmd ['https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4']
    # | filterchain ['0'] { fps 30 } ['video']
    # | command to-args
    # | ['ffmpeg', ...$in] 
  # )


  #(ffmpeg cmd ['INPUT'] ['OUTPUT'] | fps 25 | loop 2 1 | get filters | to nuon);
  #ffmpeg cmd ['INPUT'] ['OUTPUT'] | ffmpeg filterchain ['in'] ['out'] { fps 25 | loop 2 1 } | ffmpeg cmd to-args
  #ffmpeg cmd ['INPUT'] ['OUTPUT'] | ffmpeg filterchain { fps 25 -i ['in'] | loop 2 1 -o ['out'] } | ffmpeg cmd to-args
}
