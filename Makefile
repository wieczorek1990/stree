SWIFT_FLAGS = --configuration release

build:
	swift build $(SWIFT_FLAGS)

run:
	swift run $(SWIFT_FLAGS)

clean:
	rm -r .build/
