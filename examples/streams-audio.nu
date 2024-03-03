#!/usr/bin/env nu

use ../ffprobe ["main" "streams audio"];

# Extract the audio streams from a video
def main [] {
  echo "> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams audio"
  ffprobe $'($env.FILE_PWD)/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'
  | streams audio
}
