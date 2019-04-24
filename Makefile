# SETTINGS

ADA_NODE := ada.local

help:
	@grep -E '^[a-zA-Z_-].+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-14s\033[0m %s\n", $$1, $$2}'
.PHONY: help

# DEV TOOLCHAIN

all: dev.setup rpi0.burn ## Installs tools and dependencies, produces a firmware file
.PHONY: all

dev.setup: dev.base deps.get ## Installs tools and dependencies
.PHONY: dev.setup

dev.base: ## Installs base requirements
	mix local.rebar --force
	mix local.hex --force
	mix archive.install hex nerves_bootstrap --force
.PHONY: dev.base

# DEPENDENCIES

deps.get: ## Fetches dependencies
	MIX_TARGET=rpi0 mix deps.get
	MIX_TARGET=host mix deps.get
.PHONY: deps.get

deps.outdated: ## Show outdated dependencies
	MIX_TARGET=rpi0 mix hex.outdated
	MIX_TARGET=host mix hex.outdated
.PHONY: deps.outdated

# FIRMWARE MANAGEMENT

rpi0.firmware: ## Produces the firmware file
	MIX_TARGET=rpi0 mix firmware
.PHONY: rpi0.firmware

rpi0.burn: ## Produces the firmware file and burns it on a SD card
	MIX_TARGET=rpi0 mix do firmware, firmware.burn
.PHONY: rpi0.burn

rpi0.push: ## Updates the firmware on the device over-the-air
	MIX_TARGET=rpi0 mix firmware
	./script/upload.sh $(ADA_NODE) _build/rpi0_dev/nerves/images/ada.fw
.PHONY: rpi0.push

rpi0.ssh: ## Connects to the running Ada instance via SSH
	ssh $(ADA_NODE)
.PHONY: rpi0.ssh

# HOST TASKS

host.cli: ## Produces the ada CLI remote control executable
	MIX_TARGET=host mix escript.build
.PHONY: host.cli

host.test: ## Runs the test suite
	MIX_TARGET=host MIX_ENV=test mix test
.PHONY: host.test

host.shell: ## Opens a local, interactive shell
	MIX_TARGET=host iex -S mix
.PHONY: host.shell

# CI

ci.base: dev.base ## Installs needed tools for CI
.PHONY: ci.base

ci.setup: ci.base ## Installs needed tools and deps for CI
	MIX_TARGET=host mix deps.get
	MIX_TARGET=host MIX_ENV=test mix deps.get
.PHONY: ci.setup

ci.test: ## Runs tests on CI
	MIX_TARGET=host MIX_ENV=test mix test
.PHONY: ci.test

ci.dialyzer: ## Runs Dialyzer on CI
	MIX_TARGET=host mix dialyzer --halt-exit-status
.PHONY: ci.dialyzer

ci.docs: ## Produces documentation suitable for CI deployment
	mix docs -o public
.PHONY: ci.docs
