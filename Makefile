PROJ = mix2
MAIN_ENTITY = mix2
FLAGS = --std=08

PIN_DEF = leds.pcf
DEVICE = up5k
PACKAGE = sg48

VHDLS = note2freq.vhdl mix2.vhdl osc.vhdl wave.vhdl button_debouncer.vhdl

all: $(PROJ).bin

%.json: $(VHDLS) %.vhdl
	yosys -p 'ghdl $(FLAGS) $^ -e $(MAIN_ENTITY); synth_ice40 -json $@'

%.asc: %.json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

prog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.SECONDARY:

.PHONY: all prog clean
