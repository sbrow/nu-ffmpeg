#!/usr/bin/env nu

use ../ffprobe;

def main [] {
  echo "# Use ffprobe on mutliple files at once"
  echo "> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 https://sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv"
  (
    ffprobe 
    $'($env.FILE_PWD)/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'
    $'($env.FILE_PWD)/videos/sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv'
  )
}
