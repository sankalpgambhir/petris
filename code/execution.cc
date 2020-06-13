#include <verilated.h>
#include <cstdio>
#include "obj_dir/Vmain_wrapper.h"

// a bit annoyed by Verilator's naming
#define clock main_wrapper__DOT__clock

vluint64_t main_time = 0; // simulation time

// used by $time
double sc_time_stamp(void){
    return main_time;
}

int main(int argc, char* argv[]){
    Verilated::commandArgs(argc, argv); // pass args to verilator

    auto wrapper = new Vmain_wrapper; // instantiate top module

    while (!Verilated::gotFinish()){ // or SDL_Quit
        wrapper->clock = wrapper->clock ? 0 : 1;

        wrapper->eval();

        // add possible delay here based on frame rate
        main_time++;
    }

    // simulation finishes, clean up
    wrapper->final();
    delete wrapper;

    return 0;
}