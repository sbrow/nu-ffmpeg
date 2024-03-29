#!/usr/bin/env nu

use ../ffprobe ["main" "streams video"];

def main [] {
  echo "# Extract the video streams from a video"
  echo "> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video"
  ffprobe $'($env.FILE_PWD)/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'
  | streams video
}
