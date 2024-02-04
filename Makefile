README.md:
	gomplate -f $@.tmpl --plugin "filters=./get_filter_support_table,ffprobe=./get_ffprobe_commands_table,version=./nu_version" > $@

clean:
	rm -f README.md

.PHONY: clean
