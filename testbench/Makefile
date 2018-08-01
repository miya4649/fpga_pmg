EXES=main
SRCS=$(wildcard *.v ../synthesijer/*.v ../synthesijer/lib/hdl/*.v)
VCDS=$(wildcard *.vcd)

all: $(EXES)

run: $(EXES)
	vvp $(EXES)

$(EXES): $(SRCS)
	iverilog -Wall -o $(EXES) $(SRCS)

clean:
	rm -f $(EXES) $(VCDS)
