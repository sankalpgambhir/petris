#include <verilated.h>
#include <cstdio>
#include <iostream>
#include "obj_dir/Vamain_wrapper.h"
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
#define INTSCALE 20
#define OFFSETX 200
#define OFFSETY 35

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

void integer_scale(Uint32[10][20], Uint32[200][400], int);
void linearize_pixel(Uint32[200][400], Uint32[]);


int main(int argc, char* argv[]){
    Verilated::commandArgs(argc, argv); // pass args to verilator

    auto* wrapper = new Vamain_wrapper; // instantiate top module


    auto end = std::chrono::steady_clock::now();
    auto start = end;
    auto time_taken = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count(); 

    int num_pix = WIDTH * HEIGHT;
    int num_reduced_pix = (num_pix) / (INTSCALE*INTSCALE);

    // initialize frame
    SDL_Init(SDL_INIT_EVERYTHING);
    SDL_Renderer* renderer;
    SDL_Window* window;
    SDL_Texture* texture;
    init_frame(&renderer, &window, &texture);
    Uint32 reduced_matrix[10][20];
    Uint32 pixel_matrix[10*INTSCALE][20*INTSCALE];
    Uint32 pixel_array [num_pix];
    int count_x = 0, count_y = 0;

    SDL_Event e;
    int actions = 0;
    const Uint8 *keys = SDL_GetKeyboardState(nullptr);

    // clean grid
    for(int i = 0; i < num_pix; i++){
        pixel_array[i] = SDL_MapRGBA(SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888), 0x00, 0x00, 0x00, 0x00);
    }

    if (window == nullptr){
        return -1;
    }

    while (!Verilated::gotFinish()){ // or SDL_Quit
        wrapper->clock = wrapper->clock ? 0 : 1;

        wrapper->eval();

        //if (wrapper->in_display && !wrapper->vga_r){
        //    printf("Problem %d\n", wrapper->vga_r);
        //}
        


        // generate pixel array
        if(wrapper->in_display){
            reduced_matrix[wrapper->count_x][wrapper->count_y] = 
                SDL_MapRGBA(
                    SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888),
                    (int) wrapper->vga_r * 0xFF,
                    (int) wrapper->vga_g * 0xFF,
                    (int) wrapper->vga_b * 0xFF,
                    0xFF // alpha
                );
            printf("%d, %d, %d\n", wrapper->vga_r, wrapper->vga_g, wrapper->vga_b);
        }

        // update frame
        if(!wrapper->vsync){
            // take input and validate
            SDL_PollEvent(&e);

            integer_scale(reduced_matrix, pixel_matrix, INTSCALE);
            linearize_pixel(pixel_matrix, pixel_array);
            
            if(e.type == SDL_QUIT){
                break;
            }
            else if (e.type == SDL_KEYDOWN){
                actions = check_event(keys);
            } // move around with action

            wrapper->actions = actions;
            if(update_frame(&renderer, &texture, pixel_array)){
                printf("Couldn't update frame! %s", SDL_GetError());
                break;
            }

        }

        // measure loop time
        end = std::chrono::steady_clock::now();
        time_taken = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count(); 
        start = end;
        if(!wrapper->hsync){
            //printf("%d us\n", time_taken);
        }

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

void integer_scale(Uint32 from[10][20], Uint32 to[10*INTSCALE][20*INTSCALE], int scale){
    for(int i = 0; i < 10; i++){
        for(int j = 0; j < 20; j++){
            for(int k = 0; k < scale; k++){
                for(int l = 0; l < scale; l++){
                    to[i*scale + k][j*scale + l] = from[i][j];
                }
            }
        }        
    }
    return ;   
}

void linearize_pixel(Uint32 from[10*INTSCALE][20*INTSCALE], Uint32 to[WIDTH*HEIGHT]){
    for(int i = 0; i < 10*INTSCALE; i++){
        for(int j = 0; j < (20 * INTSCALE); j++){
            to[(i + OFFSETX) + (j + OFFSETY)*WIDTH] = from[i][j];
        }    
    }
    return ;  
}