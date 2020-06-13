.PHONY: clean verilate execute fresh

VERILATING = $(wildcard *.v)
OBJECTS = $(wildcard ./obj_dir/*.cpp)
VERILATOR_INCLUDE = /usr/local/share/verilator/include
VERILATORCPP = $(VERILATOR_INCLUDE)/verilated.cpp

all: fresh

clean:
	rm -rf ./obj_dir/
	rm *.o

verilate: 
	verilator main_wrapper.v --cc -Wno-WIDTH

execute:
	g++ execution.cc $(OBJECTS) $(VERILATORCPP) -I$(VERILATOR_INCLUDE) -o execution.o
	@echo "=================="
	@./execution.o

fresh: clean verilate execute