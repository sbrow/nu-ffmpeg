#!/usr/bin/env -S nu -n

use ../ffmpeg.nu;
use ../ffmpeg.nu [filterchain];
use ../filters.nu *;

# Re-encode the video to 30fps
def main []: nothing -> any {
  print '# Re-encode the video to 30fps, specifying input and output streams'
  print '('
  print '  fmpeg cmd ['https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'] []'
  print "  | filterchain -i ['0'] -o ['video'] { fps 30 }"
  print '  | ffmpeg run'
  print ')'
  print ''
  print 'Would run:'

  (
    ffmpeg cmd ['https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'] []
    | filterchain -i ['0'] -o ['video'] { fps 30 }
    | ffmpeg cmd to-args
    | ['ffmpeg' ...$in]
  )
}

