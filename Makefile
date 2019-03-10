.PHONY: deps.get deps.outdated rpi0.firmware rpi0.burn rpi0.push host.clean-and-test host.test host.setup ssh

deps.get:
	MIX_TARGET=rpi0 mix deps.get
	MIX_TARGET=host mix deps.get

deps.outdated:
	MIX_TARGET=rpi0 mix hex.outdated
	MIX_TARGET=host mix hex.outdated

rpi0.firmware:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix firmware

rpi0.burn:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix do firmware, firmware.burn

rpi0.push:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix firmware
	./script/upload.sh ada.local _build/rpi0_dev/nerves/images/ada.fw

host.clean-and-test:
	MIX_TARGET=host MIX_ENV=test mix do ecto.reset, test

host.test:
	MIX_TARGET=host MIX_ENV=test mix test

host.setup:
	mix local.rebar --force
	mix local.hex --force
	mix archive.install hex nerves_bootstrap --force
	MIX_TARGET=host mix deps.get

ssh:
	ssh ada.local
