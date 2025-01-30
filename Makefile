PROJECT = stree
SWIFT_FLAGS = --configuration release

build:
	swift build $(SWIFT_FLAGS)

run:
	swift run $(SWIFT_FLAGS) $(PROJECT) $(ARGS)

clean:
	rm -r .build/

install: build
	sudo cp .build/release/stree /usr/local/bin/
