#include <verilated.h>
#include <cstdio>
#include <iostream>
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
#define Vaction main_wrapper__DOT__actions

vluint64_t main_time = 0; // simulation time

// used by $time
double sc_time_stamp(void){
    return main_time;
}

// function prototypes
void init_frame(SDL_Renderer**, SDL_Window**, SDL_Texture**);
int update_frame(SDL_Renderer**, SDL_Texture**, Uint32*);
void clean_frame(SDL_Renderer**, SDL_Window**, SDL_Texture**);

int check_event(const Uint8*);


int main(int argc, char* argv[]){
    Verilated::commandArgs(argc, argv); // pass args to verilator

    auto* wrapper = new Vmain_wrapper; // instantiate top module


    auto end = std::chrono::steady_clock::now();
    auto start = end;
    auto time_taken = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count(); 


    // initialize frame
    SDL_Init(SDL_INIT_EVERYTHING);
    SDL_Renderer* renderer;
    SDL_Window* window;
    SDL_Texture* texture;
    init_frame(&renderer, &window, &texture);
    Uint32 pixel_array [WIDTH * HEIGHT];
    int count_x = 0, count_y = 0;

    SDL_Event e;
    int action = 0;
    const Uint8 *keys = SDL_GetKeyboardState(nullptr);

    for(int i = 0; i < WIDTH*HEIGHT; i++){
        pixel_array[i] = SDL_MapRGBA(SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888), 0x00, 0x00, 0x00, 0x00);
        std::cout << pixel_array[i];
    }

    if (window == nullptr){
        return -1;
    }

    while (!Verilated::gotFinish()){ // or SDL_Quit
        wrapper->clock = wrapper->clock ? 0 : 1;

        wrapper->eval();

        // take input and validate
        SDL_PollEvent(&e);
        
        if(e.type == SDL_QUIT){
            break;
        }
        else if (e.type == SDL_KEYDOWN){
            action = check_event(keys);
        } // move around with action
        
        wrapper->Vaction = action;

        // generate pixel array

        // update frame
        if(update_frame(&renderer, &texture, pixel_array)){
            printf("Could not update frame! %s", SDL_GetError());
            break;
        }

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
    clean_frame(&renderer, &window, &texture);
    delete wrapper, renderer, window, texture;

    return 0;
}

void init_frame(SDL_Renderer** renderer, SDL_Window** window, SDL_Texture** texture){
    SDL_CreateWindowAndRenderer(WIDTH, HEIGHT, SDL_WINDOW_INPUT_FOCUS, window, renderer);
    SDL_SetWindowTitle(*window, WINDOW_TITLE);
    SDL_Delay(100);
    if(*window == nullptr){
        printf("Couldn't initialize window!\t%s", SDL_GetError());
        return ;
    }
    SDL_RenderClear(*renderer);

    *texture = SDL_CreateTexture(*renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, WIDTH, HEIGHT);
    return ;
}

int update_frame(SDL_Renderer** renderer, SDL_Texture** texture, Uint32 pixel_array[]){
    int pitch = WIDTH * sizeof(Uint32);
    SDL_UpdateTexture(*texture, nullptr, pixel_array, pitch);

    SDL_RenderClear(*renderer);
    SDL_RenderCopy(*renderer, *texture, nullptr, nullptr);
    SDL_RenderPresent(*renderer);

    return 0;
}

void clean_frame(SDL_Renderer** renderer, SDL_Window** window, SDL_Texture** texture){
    SDL_DestroyTexture(*texture);
    SDL_DestroyWindow(*window);
    SDL_DestroyRenderer(*renderer);
    SDL_Quit();

    return ;
}

int check_event(const Uint8* keys){
    int actions = 0;
    if (keys[SDL_SCANCODE_LEFT]){
        actions += 0b0010;
    }
    if (keys[SDL_SCANCODE_RIGHT]){
        actions += 0b0001;
    }

    return actions;
}