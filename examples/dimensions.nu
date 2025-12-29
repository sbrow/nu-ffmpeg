#!/usr/bin/env nu

use ../ffprobe ["main" "dimensions" "streams video"];

def main [] {
  print "# Extract the dimensions of a video stream"
  print "> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video | first | dimensions"
  (
    ffprobe $'($env.FILE_PWD)/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'
    | streams video
    | first
    | dimensions
  )
}
