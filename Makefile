# Xcodeproj

xcodeproj:
	swift package generate-xcodeproj --xcconfig-overrides=Development.xcconfig

# Unit Test

test-macos:
	set -o pipefail && \
		xcodebuild clean test \
		-project SwiftRex.xcodeproj \
		-scheme SwiftRex\ macOS \
		-destination platform="macOS" \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		ONLY_ACTIVE_ARCH=YES \
		VALID_ARCHS=x86_64 \
		| xcpretty

test-ios:
	set -o pipefail && \
		xcodebuild clean test \
		-project SwiftRex.xcodeproj \
		-scheme SwiftRex\ iOS \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.3" \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		ONLY_ACTIVE_ARCH=YES \
		VALID_ARCHS=x86_64 \
		| xcpretty

test-swift:
	swift test

test-all: test-mac test-ios

# Lint

lint:
	@if which swiftlint >/dev/null; then \
		swiftlint autocorrect; \
	else \
    	echo "warning: SwiftLint not installed, please run `brew install swiftlint`"; \
	fi

# Sourcery

sourcery:
	@if which sourcery >/dev/null; then \
		sourcery; \
	else \
		echo "warning: Sourcery not installed, please run `brew install sourcery`"; \
	fi

# Carthage Copy

carthage-copy:
	@if which carthage >/dev/null; then \
		export SCRIPT_INPUT_FILE_0="$(SRCROOT)/Carthage/Build/${PLATFORM}/RxSwift.framework" \
		export SCRIPT_INPUT_FILE_COUNT=1 \
		export SCRIPT_OUTPUT_FILE_0="$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/RxSwift.framework" \
		export SCRIPT_OUTPUT_FILE_COUNT=1; \
		carthage copy-frameworks; \
	else \
		echo "warning: Carthage not installed, please run `brew install carthage`"; \
	fi

carthage-copy-mac: PLATFORM = Mac
carthage-copy-mac: carthage-copy

carthage-copy-ios: PLATFORM = iOS
carthage-copy-ios: carthage-copy

carthage-copy-watchos: PLATFORM = watchOS
carthage-copy-watchos: carthage-copy

carthage-copy-tvos: PLATFORM = tvOS
carthage-copy-tvos: carthage-copy

# Pre-Build

prebuild-mac: sourcery lint carthage-copy-mac

prebuild-ios: sourcery lint carthage-copy-ios

prebuild-watchos: sourcery lint carthage-copy-watchos

prebuild-tvos: sourcery lint carthage-copy-tvos