.PHONY: deps.get firmware burn clean-and-test test

deps.get:
	MIX_TARGET=rpi0 mix deps.get

firmware:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix firmware

burn:
	$(MAKE) -C web-ui prod
	MIX_TARGET=rpi0 mix do firmware, firmware.burn

clean-and-test:
	MIX_TARGET=host MIX_ENV=test mix do ecto.reset, test

test:
	MIX_TARGET=host MIX_ENV=test mix test
