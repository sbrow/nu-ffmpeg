# nu-ffmpeg

Utility commands for working with ffmpeg in nushell.

## Capabilities ([see examples](#examples))

- Return tables from `ffprobe`
- `ffprobe` multiple files at once
- Use `streams`, `streams video`, and `streams audio` to filter `ffprobe` output
- get the `dimensions` of a video stream as a record

- Apply complex filters to a video using standard shell pipes `|` rather than filtergraph syntax.
- Conditionally apply filters to a video based on the inputs
- Tab-completion for filter options. i.e. `fps --round<tab>` will yield `zero inf down up near`

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

### Supported Filters

| name    | usage                                                                                                                                                                                                                                      |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| crop    | Crop the input video to given dimensions.                                                                                                                                                                                                  |
| format  | Convert the input video to one of the specified pixel formats. Libavfilter will try to pick one that is suitable as input to the next filter.                                                                                              |
| fps     | Convert the video to specified constant frame rate by duplicating or dropping frames as necessary.                                                                                                                                         |
| loop    | loop video frames                                                                                                                                                                                                                          |
| overlay | Overlay one video on top of another.                                                                                                                                                                                                       |
| settb   | Set the timebase to use for the output frames timestamps. It is mainly useful for testing timebase configuration.                                                                                                                          |
| split   |                                                                                                                                                                                                                                            |
| vflip   | Flip the input video vertically.                                                                                                                                                                                                           |
| xfade   | Apply cross fade from one input video stream to another input video stream. The cross fade is applied for specified duration. Both inputs must be constant frame-rate and have the same resolution, pixel format, frame rate and timebase. |


## Examples

```nu
# Return a table from ffprobe
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4
╭───┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬──────────────╮
│ # │                                                                                                         streams                                                                                                         │    format    │
├───┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────┤
│ 0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬───────┬────────┬─────────────┬──────────────┬─────────────────┬────────────┬──────────────┬─────╮ │ {record 11   │
│   │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_tag  │ width │ height │ coded_width │ coded_height │ closed_captions │ film_grain │ has_b_frames │ ... │ │ fields}      │
│   │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼───────┼────────┼─────────────┼──────────────┼─────────────────┼────────────┼──────────────┼─────┤ │              │
│   │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x31637661 │  1280 │    720 │        1280 │          720 │               0 │          0 │            0 │ ... │ │              │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a             │ 0x6134706d │  ❎   │   ❎   │     ❎      │      ❎      │       ❎        │     ❎     │      ❎      │ ... │ │              │
│   │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴───────┴────────┴─────────────┴──────────────┴─────────────────┴────────────┴──────────────┴─────╯ │              │
╰───┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────╯
```

```nu
# Use ffprobe on mutliple files at once
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 https://sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv
╭───┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬──────────────╮
│ # │                                                                                                         streams                                                                                                         │    format    │
├───┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────┤
│ 0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬───────┬────────┬─────────────┬──────────────┬─────────────────┬────────────┬──────────────┬─────╮ │ {record 11   │
│   │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_tag  │ width │ height │ coded_width │ coded_height │ closed_captions │ film_grain │ has_b_frames │ ... │ │ fields}      │
│   │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼───────┼────────┼─────────────┼──────────────┼─────────────────┼────────────┼──────────────┼─────┤ │              │
│   │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x31637661 │  1280 │    720 │        1280 │          720 │               0 │          0 │            0 │ ... │ │              │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a             │ 0x6134706d │  ❎   │   ❎   │     ❎      │      ❎      │       ❎        │     ❎     │      ❎      │ ... │ │              │
│   │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴───────┴────────┴─────────────┴──────────────┴─────────────────┴────────────┴──────────────┴─────╯ │              │
│ 1 │ ╭───┬────────────┬─────────────────────────────┬────────────────┬────────────┬──────────────────┬───────────┬───────┬────────┬─────────────┬──────────────┬─────────────────┬────────────┬──────────────┬─────╮         │ {record 10   │
│   │ │ # │ codec_name │       codec_long_name       │    profile     │ codec_type │ codec_tag_string │ codec_tag │ width │ height │ coded_width │ coded_height │ closed_captions │ film_grain │ has_b_frames │ ... │         │ fields}      │
│   │ ├───┼────────────┼─────────────────────────────┼────────────────┼────────────┼──────────────────┼───────────┼───────┼────────┼─────────────┼──────────────┼─────────────────┼────────────┼──────────────┼─────┤         │              │
│   │ │ 0 │ mpeg4      │ MPEG-4 part 2               │ Simple Profile │ video      │ [0][0][0][0]     │ 0x0000    │  1280 │    720 │        1280 │          720 │               0 │          0 │            0 │ ... │         │              │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding) │ LC             │ audio      │ [0][0][0][0]     │ 0x0000    │  ❎   │   ❎   │     ❎      │      ❎      │       ❎        │     ❎     │      ❎      │ ... │         │              │
│   │ ╰───┴────────────┴─────────────────────────────┴────────────────┴────────────┴──────────────────┴───────────┴───────┴────────┴─────────────┴──────────────┴─────────────────┴────────────┴──────────────┴─────╯         │              │
╰───┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────╯
```

```nu
# Extract the video streams from a video
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video
╭────┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬───────┬────────┬─────────────┬──────────────┬─────────────────┬────────────┬──────────────┬─────────────────────┬─────╮
│  # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_tag  │ width │ height │ coded_width │ coded_height │ closed_captions │ film_grain │ has_b_frames │ sample_aspect_ratio │ ... │
├────┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼───────┼────────┼─────────────┼──────────────┼─────────────────┼────────────┼──────────────┼─────────────────────┼─────┤
│  0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x31637661 │  1280 │    720 │        1280 │          720 │               0 │          0 │            0 │ 1:1                 │ ... │
╰────┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴───────┴────────┴─────────────┴──────────────┴─────────────────┴────────────┴──────────────┴─────────────────────┴─────╯
# Extract the audio streams from a video
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams audio
╭───┬────────────┬─────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬────────────┬─────────────┬──────────┬────────────────┬─────────────────┬─────────────────┬─────┬──────────────┬────────────────┬─────╮
│ # │ codec_name │       codec_long_name       │ profile │ codec_type │ codec_tag_string │ codec_tag  │ sample_fmt │ sample_rate │ channels │ channel_layout │ bits_per_sample │ initial_padding │ id  │ r_frame_rate │ avg_frame_rate │ ... │
├───┼────────────┼─────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼────────────┼─────────────┼──────────┼────────────────┼─────────────────┼─────────────────┼─────┼──────────────┼────────────────┼─────┤
│ 1 │ aac        │ AAC (Advanced Audio Coding) │ LC      │ audio      │ mp4a             │ 0x6134706d │ fltp       │ 48000       │        6 │ 5.1            │               0 │               0 │ 0x2 │ 0/0          │ 0/0            │ ... │
╰───┴────────────┴─────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴────────────┴─────────────┴──────────┴────────────────┴─────────────────┴─────────────────┴─────┴──────────────┴────────────────┴─────╯
```

```nu
# Extract the dimensions of a video stream
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video | first | dimensions
╭────────┬──────╮
│ width  │ 1280 │
│ height │ 720  │
╰────────┴──────╯
```
