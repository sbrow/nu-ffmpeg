
# nu-ffmpeg

Utility commands for working with ffmpeg in nushell.

## Capabilities

- Return tables from `ffprobe`

```nu
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4
╭────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────╮
│  # │                                                           streams                                                            │ ... │
├────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────┤
│  0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬─────╮  │ ... │
│    │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_tag  │ ... │  │     │
│    │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼─────┤  │     │
│    │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x31637661 │ ... │  │     │
│    │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a             │ 0x6134706d │ ... │  │     │
│    │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴─────╯  │     │
╰────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────╯

```

- `ffprobe` multiple files at once
```nu
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 https://sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv
╭────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────╮
│  # │                                                           streams                                                            │ ... │
├────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────┤
│  0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬─────╮  │ ... │
│    │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_tag  │ ... │  │     │
│    │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼─────┤  │     │
│    │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x31637661 │ ... │  │     │
│    │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a             │ 0x6134706d │ ... │  │     │
│    │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴─────╯  │     │
│  1 │ ╭───┬────────────┬─────────────────────────────┬────────────────┬────────────┬──────────────────┬───────────┬───────┬─────╮  │ ... │
│    │ │ # │ codec_name │       codec_long_name       │    profile     │ codec_type │ codec_tag_string │ codec_tag │ width │ ... │  │     │
│    │ ├───┼────────────┼─────────────────────────────┼────────────────┼────────────┼──────────────────┼───────────┼───────┼─────┤  │     │
│    │ │ 0 │ mpeg4      │ MPEG-4 part 2               │ Simple Profile │ video      │ [0][0][0][0]     │ 0x0000    │  1280 │ ... │  │     │
│    │ │ 1 │ aac        │ AAC (Advanced Audio Coding) │ LC             │ audio      │ [0][0][0][0]     │ 0x0000    │  ❎   │ ... │  │     │
│    │ ╰───┴────────────┴─────────────────────────────┴────────────────┴────────────┴──────────────────┴───────────┴───────┴─────╯  │     │
╰────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────╯

```

- Use `streams`, `streams video`, and `streams audio` to filter `ffprobe` output

```nu
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video
╭────┬─────────────┬────────────────────────────────────────────┬──────────┬─────────────┬───────────────────┬─────────────┬────────┬─────╮
│  # │ codec_name  │              codec_long_name               │ profile  │ codec_type  │ codec_tag_string  │  codec_tag  │ width  │ ... │
├────┼─────────────┼────────────────────────────────────────────┼──────────┼─────────────┼───────────────────┼─────────────┼────────┼─────┤
│  0 │ h264        │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10  │ Main     │ video       │ avc1              │ 0x31637661  │   1280 │ ... │
╰────┴─────────────┴────────────────────────────────────────────┴──────────┴─────────────┴───────────────────┴─────────────┴────────┴─────╯

> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams audio
╭────┬─────────────┬──────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬────────────┬─────────────┬─────╮
│  # │ codec_name  │       codec_long_name        │ profile │ codec_type │ codec_tag_string │ codec_tag  │ sample_fmt │ sample_rate │ ... │
├────┼─────────────┼──────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼────────────┼─────────────┼─────┤
│  1 │ aac         │ AAC (Advanced Audio Coding)  │ LC      │ audio      │ mp4a             │ 0x6134706d │ fltp       │ 48000       │ ... │
╰────┴─────────────┴──────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴────────────┴─────────────┴─────╯

```

- get the `dimensions` of a video stream as a record

```nu
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video | first | dimensions
╭────────┬──────╮
│ width  │ 1280 │
│ height │ 720  │
╰────────┴──────╯

```
- Tab-completion for filter options. i.e. `fps --round<tab>` will yield `zero inf down up near`
- Apply and parse complex filters to a video (Work In Progress)

## Setup

The `ffmpeg` and `ffprobe` commands are required to be installed and available
in your path; they are not installed for you.

Currently only nushell version 0.89.0
 is supported.

After that, clone this repository and add the following code to your scripts,
or to your `config.nu` file:

```nu
use <path-to-repository>/ffprobe
use <path-to-repository>/filters *
```

## FFProbe

### Commands

| name                  | usage                                                            |
| --------------------- | ---------------------------------------------------------------- |
| ffprobe               | Run ffprobe on a list of files and return the output as a table. |
| ffprobe dimensions    | Get the dimensions of a video stream                             |
| ffprobe streams       | Retrieve all the streams from a list of ffprobe outputs          |
| ffprobe streams audio | Retrieve all the audio streams from a list of ffprobe outputs    |
| ffprobe streams video | Retrieve all the video streams from a list of ffprobe outputs    |


## FFMpeg

## Supported Filters

| name    | usage                                                                                              |
| ------- | -------------------------------------------------------------------------------------------------- |
| crop    | Crop the input video to given dimensions.                                                          |
| fps     | Convert the video to specified constant frame rate by duplicating or dropping frames as necessary. |
| loop    | loop video frames                                                                                  |
| overlay | Overlay one video on top of another.                                                               |
| split   |                                                                                                    |
| vflip   | Flip the input video vertically.                                                                   |

