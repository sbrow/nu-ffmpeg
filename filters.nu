#!/usr/bin/env -S nu --stdin

export def "parse filter" [
] {
  $in | parse --regex '^(?<name>[^=]+)=(?<params>.*)' | first |
  update params { parse --regex `(?<param>[^=]+)=(?<value>[^:]+):?` }
}

export def "filter to-string" [] {
  each { |filter| $'($filter.name)=($filter.params | format '{param}={value}')' } |
  str join ':'
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
