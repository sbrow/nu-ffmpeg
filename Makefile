SHELL:=/nix/store/kx4ic1nmgsfh3qhr74vxq7g97pal7mn4-nushell-0.108.0/bin/nu

all: README.md

README.md: examples/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 examples/videos/sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv
	gomplate --config .gomplate.yml

examples/videos/sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4:
	wget -x -P examples/videos https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4

examples/videos/sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv:
	wget -x -P examples/videos https://sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv

clean:
	rm -f README.md

clean-all: clean
	rm -rf examples/videos/**

.PHONY: clean all
