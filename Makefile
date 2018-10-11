.PHONY: deps.get firmware burn test

deps.get:
	MIX_TARGET=rpi0 mix deps.get

firmware:
	MIX_TARGET=rpi0 mix firmware

burn:
	MIX_TARGET=rpi0 mix do firmware, firmware.burn

test:
	MIX_TARGET=host MIX_ENV=test HTTP_PORT=4001 mix do ecto.reset, test
