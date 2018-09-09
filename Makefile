.PHONY: firmware burn

firmware:
	mix firmware

burn:
	mix do firmware, firmware.burn
