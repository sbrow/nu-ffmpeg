#!/usr/bin/env nu

use ../ffprobe ["main" "dimensions" "streams video"];

# Extract the dimensions of a video stream
def main [] {
  echo "> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video | first | dimensions"
  ffprobe $'($env.FILE_PWD)/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'
  | streams video | first | dimensions
}
