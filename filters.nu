#!/usr/bin/env -S nu --stdin

export def "parse filter" [
]: string -> table<name: string params: table<param: string, value: string>> {
  $in | parse --regex '^(?<name>[^=]+)=(?<params>.*)' | first | update params {
    parse --regex `(?<param>[^=]+)=(?<value>[^:]+):?`
  }
}

export def "filter to-string" [
]: table<name: string params: table<param: string, value: string>> -> string {
  each {
    $'($in.name)=($in.params | format '{param}={value}')'
  } | str join ':'
}

# Build a record representaion of a complex filter
export def complex-filter [
  name: string
  params: record = {}
]: nothing -> record<name: string params: table<param: string, value: string>> {
  {
    name: $name
    params: ($params | transpose param value | compact param value)
  }
}


export def "complex-filters to-string" [
  --pretty-print (-p)
]: table<input: list<string>, filters: table<name: string, params: table<param: string, value: string>>, output: string> -> string {
    $in | update filters {
      flatten | filter to-string
    } | update input {
      str join ']['
    } | format '[{input}]{filters}[{output}]' | str join (";" + (if $pretty_print { "\n"  } else { "" })) | str replace --all '[]' ''
}

# =============
# Begin Filters
# =============

# loop video frames
export def loop [
  loop: int # Set the number of loops. Setting this value to -1 will result in infinite loops. Default is 0.
  size: int # Set maximal size in number of frames. Default is 0.
  --start (-s): int # Set first frame of loop. Default is 0.
  --time (-t): float # Set the time of loop start in seconds. Only used if option named start is set to -1.
] {
  complex-filter loop {
    loop: $loop
    size: $size
    start: (if ($time | is-empty) { $start } else { -1 })
    time: $time
  }
}
