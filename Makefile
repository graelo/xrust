#
# Parameters
#

# Name of the docker executable
DOCKER = docker

# Docker organization to pull the images from
ORG = u0xy

# Rust release to embed in the image
ifndef RUST_VERSION
	RUST_VERSION = 1.41.0
endif

# All currently available images
IMAGES = linux-arm64 linux-armv5-musl linux-armv6-musl linux-armv7l-musl

# All available images including additional ones which don't link correctly
# IMAGES = linux-arm64 linux-arm64-musl linux-armv5 linux-armv5-musl linux-armv6 linux-armv6-musl linux-armv7 linux-armv7l-musl linux-mips linux-mipsel

# Minimum versions (compilation will fail if Rust version is below)
# - linux-arm64: rust-1.41.0
# - linux-arm64-musl: rust-1.48.0
# - linux-armv5-musl: rust-1.30.0
# - linux-armv6-musl: rust-1.30.0
# - linux-armv7l-musl: rust-1.30.0

# Tag images with date and Git short hash in addition to revision
TAG_BUILD := $(shell date -u +'%Y%m%d')-$(shell git rev-parse --short HEAD)
TAG_RUST = rust-$(RUST_VERSION)

.PHONY: $(IMAGES)

$(IMAGES):
	@echo using Rust $(RUST_VERSION)
	@$(DOCKER) build \
		-t $(ORG)/$@ \
		-t $(ORG)/$@:$(TAG_BUILD) \
		-t $(ORG)/$@:$(TAG_RUST) \
		--build-arg RUST_VERSION=$(RUST_VERSION) \
		-f Dockerfile.$@ \
		.

.SECONDEXPANSION:
$(addsuffix .test,$(IMAGES)): $$(basename $$@)
	@echo testing $(basename $@)
	@rm -rf testing
	@mkdir testing ; \
		cd testing ; \
		docker run --rm u0xy/$(basename $@):rust-${RUST_VERSION} > xrs ; \
		chmod u+x xrs ; \
		./xrs cargo version || exit 1; \
		./xrs cargo init --bin --name hello || exit 1 ; \
		./xrs cargo build --release || exit 1 ; \
		cd ..

test:
	@for image in $(IMAGES); do \
		make $$image.test ; \
		echo "\n ============== \n" ; \
	done
	@rm -rf testing
