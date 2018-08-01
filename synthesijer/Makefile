SYNTHESIJER?=$(lastword $(sort $(wildcard $(HOME)/synthesijer/synthesijer*.jar)))

SYNTHESIJER_LIB?=$(lastword $(sort $(wildcard $(HOME)/synthesijer/synthesijer_lib_????????)))

SYNTHESIJER_EXTRA_LIB?=$(lastword $(sort $(wildcard $(HOME)/synthesijer/synthesijer_extra-libs_????????)))

CLASSPATH=$(SYNTHESIJER):$(SYNTHESIJER_EXTRA_LIB)/bin:.

LIB_SJR_VERILOG=singleportram.v synthesijer_logic_rshift32.v

EXLIB_SJR_VERILOG=

SOURCES=Composer.java lib/java/*.java

ROM_SOURCES=MakeROM/*.java


all: $(SOURCES) $(LIB_SJR_VERILOG) $(EXLIB_SJR_VERILOG) $(ROM_FILES) makerom
	java -cp $(CLASSPATH) synthesijer.Main --chaining --operation-strength-reduction --verilog $(SOURCES)
	cp *.v ../tinyfpgabx/
	cp lib/hdl/*.v ../tinyfpgabx/

$(LIB_SJR_VERILOG):
	cp $(SYNTHESIJER_LIB)/verilog/$@ ./

$(EXLIB_SJR_VERILOG):
	cp $(SYNTHESIJER_EXTRA_LIB)/hdl_lib/verilog/$@ ./

makerom: $(ROM_SOURCES)
	make -C MakeROM

clean:
	make -C MakeROM clean
	-rm -f *.class
	-rm -f *.v
	-rm -f *.vhd
	-rm -f *.xml
	-rm -f *.dot
	-rm -f *.o
	-rm -f sim
	-rm -f *.vcd
	-rm -f *.txt
	-rm -f *.ir
	-rm -f lib/java/*.class
