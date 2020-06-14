#include <verilated.h>
#include <cstdio>
#include "obj_dir/Vmain_wrapper.h"
#include <chrono>
#include <SDL2/SDL.h>
#include <tuple>
// we'll clean up includes later

// parameters
#define WINDOW_TITLE "petris"
#define WIDTH 640
#define HEIGHT 480
#define HPITCH 800
#define VPITCH 525

// a bit annoyed by Verilator's naming
#define clock main_wrapper__DOT__clock

vluint64_t main_time = 0; // simulation time

// used by $time
double sc_time_stamp(void){
    return main_time;
}

// function prototypes
std::tuple<SDL_Renderer*, SDL_Window*, SDL_Texture*> init_frame(void);
void clean_frame(SDL_Renderer*, SDL_Window*, SDL_Texture*);


int main(int argc, char* argv[]){
    Verilated::commandArgs(argc, argv); // pass args to verilator

    auto* wrapper = new Vmain_wrapper; // instantiate top module


    auto end = std::chrono::steady_clock::now();
    auto start = end;
    auto time_taken = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count(); 


    // initialize frame
    auto [renderer, window, texture] = init_frame();

    if (window == nullptr){
        return -1;
    }

    while (!Verilated::gotFinish()){ // or SDL_Quit
        wrapper->clock = wrapper->clock ? 0 : 1;

        wrapper->eval();

        // update frame
        

        // measure loop time
        end = std::chrono::steady_clock::now();
        time_taken = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count(); 
        start = end;
        printf("%d ns\n", time_taken);

        // add possible delay here based on frame rate
        main_time++;
    }

    // simulation finishes, clean up
    wrapper->final();
    clean_frame(renderer, window, texture);
    delete wrapper;

    return 0;
}

std::tuple<SDL_Renderer*, SDL_Window*, SDL_Texture*> init_frame(void){
    SDL_Renderer* renderer;
    SDL_Window* window;
    SDL_Texture* texture;
    SDL_Init(SDL_INIT_EVERYTHING);

    SDL_CreateWindowAndRenderer(WIDTH, HEIGHT, SDL_WINDOW_INPUT_GRABBED, &window, &renderer);
    SDL_Delay(100);
    if(window == nullptr){
        printf("Couldn't initialize window!\t%s", SDL_GetError());
        return {nullptr, nullptr, nullptr};
    }
    SDL_SetWindowTitle(window, WINDOW_TITLE);
    SDL_RenderClear(renderer);

    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, HPITCH, VPITCH);

    return {renderer, window, texture};
}

int update_frame(SDL_Renderer* renderer, SDL_Texture* texture, Uint32 pixel_array[]){
    int pitch = HPITCH * sizeof(Uint32);
    SDL_UpdateTexture(texture, nullptr, pixel_array, pitch);

    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, nullptr, nullptr);
    SDL_RenderPresent(renderer);
}

void clean_frame(SDL_Renderer* renderer, SDL_Window* window, SDL_Texture* texture){
    SDL_DestroyTexture(texture);
    SDL_DestroyWindow(window);
    SDL_DestroyRenderer(renderer);
    SDL_Quit();
}