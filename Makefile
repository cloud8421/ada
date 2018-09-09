.PHONY: firmware burn test

firmware:
	mix firmware

burn:
	mix do firmware, firmware.burn

test:
	MIX_TARGET=host mix test
