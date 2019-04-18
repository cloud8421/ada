# SETTINGS

ADA_NODE := ada.local

# DEV TOOLCHAIN

# Installs tools and dependencies, produces a firmware file
all: dev.setup rpi0.burn
.PHONY: all

# Installs tools and dependencies
dev.setup: dev.base deps.get
.PHONY: dev.setup

# Installs base requirements
dev.base:
	mix local.rebar --force
	mix local.hex --force
	mix archive.install hex nerves_bootstrap --force
.PHONY: dev.base

# Spins up a local swagger instance with api documentation.
# Cannot be tried out because of CORS issues.
dev.swagger:
	docker run \
		-p 8080:8080 \
		-v '$(realpath ./priv/swagger.json):/var/ada/swagger.json' \
		-e SWAGGER_JSON=/var/ada/swagger.json \
	swaggerapi/swagger-ui
.PHONY: dev.swagger

# DEPENDENCIES

# Fetches dependencies
deps.get:
	MIX_TARGET=rpi0 mix deps.get
	MIX_TARGET=host mix deps.get
.PHONY: deps.get

# Show outdated dependencies
deps.outdated:
	MIX_TARGET=rpi0 mix hex.outdated
	MIX_TARGET=host mix hex.outdated
.PHONY: deps.outdated

# FIRMWARE MANAGEMENT

# Produces the firmware file
rpi0.firmware:
	MIX_TARGET=rpi0 mix firmware
.PHONY: rpi0.firmware

# Produces the firmware file and burns it on a SD card
rpi0.burn:
	MIX_TARGET=rpi0 mix do firmware, firmware.burn
.PHONY: rpi0.burn

# Updates the firmware on the device over-the-air
rpi0.push:
	MIX_TARGET=rpi0 mix firmware
	./script/upload.sh $(ADA_NODE) _build/rpi0_dev/nerves/images/ada.fw
.PHONY: rpi0.push

# Connects to the running Ada instance via SSH
rpi0.ssh:
	ssh $(ADA_NODE)
.PHONY: rpi0.ssh

# HOST TASKS

# Produces the ada CLI remote control executable
host.cli:
	MIX_TARGET=host mix escript.build
.PHONY: host.cli

## Runs the test suite
host.test:
	MIX_TARGET=host MIX_ENV=test mix test
.PHONY: host.test

## Opens a local, interactive shell
host.shell:
	MIX_TARGET=host iex -S mix
.PHONY: host.shell

# CI

## Installs needed tools and deps for CI
ci.setup: dev.base
	MIX_TARGET=host mix deps.get

## Runs tests on CI
ci.test: dev.base
	MIX_TARGET=host MIX_ENV=test mix test

## Produces documentation suitable for CI deployment
ci.docs:
	mix docs -o public
.PHONY: ci.docs
