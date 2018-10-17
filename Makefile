.PHONY: deps.get rpi0.firmware rpi0.burn host.clean-and-test host.test host.setup

deps.get:
	MIX_TARGET=rpi0 mix deps.get
	MIX_TARGET=host mix deps.get

rpi0.firmware:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix firmware

rpi0.burn:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix do firmware, firmware.burn

host.clean-and-test:
	MIX_TARGET=host MIX_ENV=test mix do ecto.reset, test

host.test:
	MIX_TARGET=host MIX_ENV=test mix test

host.setup:
	mix local.rebar --force
	mix local.hex --force
	mix archive.install hex nerves_bootstrap --force
	MIX_TARGET=rpi0 mix deps.get
