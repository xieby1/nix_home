all: SUMMARY.md
	mdbook build

NIXs = $(shell find . -name "*.nix" -not -path "./book*")
NIX_MDs = $(addsuffix .md,${NIXs})
%.md: %
	markcode $< > $@

# update markcode progross
README.md: ./.markcode_progress.sh ${NIXs}
	./$<

ALL_MDs = $(shell find . -name "*.md" -not -name "SUMMARY.md")
SUMMARY.md: .genSUMMARY.sh ${NIX_MDs} ${ALL_MDs}
	./$< > $@
