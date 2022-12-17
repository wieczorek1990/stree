PROJECT = stree
SWIFT_FLAGS = --configuration release

build:
	swift build $(SWIFT_FLAGS)

run:
	swift run $(SWIFT_FLAGS) $(PROJECT) $(ARGS)

clean:
	rm -r .build/

install: build
	sudo mkdir -p /usr/local/bin/
	sudo cp .build/release/stree /usr/local/bin/
