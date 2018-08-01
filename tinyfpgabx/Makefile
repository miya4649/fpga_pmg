PROJECT=top
PCF=tinyfpgabx.pcf
DEVICE_SHORT=8k
DEVICE=lp$(DEVICE_SHORT)
PACKAGE=cm81
SOURCE=*.v
TMPFILE=$(PROJECT).blif $(PROJECT).asc $(PROJECT).rpt $(PROJECT).bin .sconsign.dblite Composer.v MiniAudioIface.v fifo.v frac_clk.v mini_audio.v rom_chorddata.v rom_scaledata.v singleportram.v synthesijer_logic_rshift32.v hardware.asc hardware.bin hardware.blif

all: $(PROJECT).bin

$(PROJECT).blif: $(SOURCE)
	yosys -p 'synth_ice40 -top $(PROJECT) -blif $(PROJECT).blif' $(SOURCE)

$(PROJECT).asc: $(PCF) $(PROJECT).blif
	arachne-pnr -r -d $(DEVICE_SHORT) -P $(PACKAGE) -o $(PROJECT).asc -p $(PCF) $(PROJECT).blif

$(PROJECT).bin: $(PROJECT).asc
	icepack $(PROJECT).asc $(PROJECT).bin

timing: $(PROJECT).asc
	icetime -d $(DEVICE) -mtr $(PROJECT).rpt $(PROJECT).asc

prog: $(PROJECT).bin
	tinyprog -p $(PROJECT).bin

clean:
	rm -f $(TMPFILE)
