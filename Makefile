PROJECT = stree
SWIFT_FLAGS = --configuration release

build:
	swift build $(SWIFT_FLAGS)

run:
	swift run $(SWIFT_FLAGS) $(PROJECT) $(ARGS)

clean:
	rm -r .build/

install: build
	mkdir -p ~/.local/bin/
	cp .build/release/stree ~/.local/bin/
