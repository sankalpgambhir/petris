.PHONY: clean verilate execute fresh

VERILATING = $(wildcard *.v)
OBJECTS = $(wildcard ./obj_dir/*.cpp)
VERILATOR_INCLUDE = /usr/local/share/verilator/include
VERILATORCPP = $(VERILATOR_INCLUDE)/verilated.cpp

all: fresh

clean:
	@rm -rf ./obj_dir/
	@rm -f *.o

verilate: 
	@verilator amain_wrapper.v --cc -Wno-WIDTH

verilateall:
	@verilator $(VERILATING) --cc -Wno-WIDTH

verilation: *.v

%.v:
	@verilator $@ --cc -Wno-WIDTH

execute:
	@g++ execution.cc $(OBJECTS) $(VERILATORCPP) -I$(VERILATOR_INCLUDE) -lSDL2 -lSDL2_ttf -o execution.o
	@echo "=================="
	@./execution.o

fresh: clean verilate execute