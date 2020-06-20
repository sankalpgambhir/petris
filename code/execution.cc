#include <verilated.h>
#include <cstdio>
#include <iostream>
#include "obj_dir/Vamain_wrapper.h"
#include <chrono>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <tuple>
// we'll clean up includes later

// parameters
#define WINDOW_TITLE "petris"
#define WIDTH 640
#define HEIGHT 480
#define HPITCH 800
#define VPITCH 525
#define INTSCALE 20
#define OFFSETX 250
#define OFFSETY 35
#define TEXT_X 40
#define TEXT_Y 200
#define TEXT_W 200
#define TEXT_H 50

vluint64_t main_time = 0; // simulation time

// used by $time
double sc_time_stamp(void){
    return main_time;
}

// function prototypes
void init_frame(SDL_Renderer**, SDL_Window**, SDL_Texture**);
int update_frame(SDL_Renderer**, SDL_Texture**, Uint32*);
int update_text(SDL_Renderer*, SDL_Texture*, SDL_Surface*, TTF_Font*, SDL_Rect*, SDL_Color*, const char*);
void clean_frame(SDL_Renderer**, SDL_Window**, SDL_Texture**, SDL_Surface*, SDL_Texture*);

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

    // for text
    SDL_Rect rect;
    rect.x = TEXT_X;
    rect.y = TEXT_Y;
    rect.w = TEXT_W;
    rect.h = TEXT_H;
    TTF_Init();
    TTF_Font* font = TTF_OpenFont("font/uni.ttf", 10);
    SDL_Color text_color = {.r = 255, .g = 255, .b = 255};
    SDL_Texture* text_box_texture;
    SDL_Surface* text_surface;
    char text[100];


    SDL_Event e;
    int actions = 0;
    const Uint8 *keys = SDL_GetKeyboardState(nullptr);

    // clean grid
    for(int i = 0; i < num_pix; i++){
        pixel_array[i] = SDL_MapRGBA(SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888), 0x00, 0x00, 0x00, 0xFF);
    }
    for(int i = 0; i < 10 * INTSCALE; i++){
        for(int j = 0; j < 20 * INTSCALE; j++){
            pixel_matrix[i][j] = 0;
        }
    }

    // draw playfield border
    int border_x = OFFSETX - 5;
    int border_y = OFFSETY - 5;
    for(int i = 0; i < 10*INTSCALE; i++ ){
        pixel_array[(i + OFFSETX) + (OFFSETY)*WIDTH];
        pixel_array[(i + OFFSETX) + (20 + OFFSETY)*WIDTH];
    }
    for(int j = 0; j < 20*INTSCALE; j++ ){
        pixel_array[(OFFSETX) + (j + OFFSETY)*WIDTH] = SDL_MapRGBA(SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888), 0xFF, 0xFF, 0xFF, 0xFF);
        pixel_array[(10 + OFFSETX) + (j + OFFSETY)*WIDTH]= SDL_MapRGBA(SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888), 0xFF, 0xFF, 0xFF, 0xFF);
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
                    (int) wrapper->vga_r * 0xF4 + 0x0B,
                    (int) wrapper->vga_g * 0xF4 + 0x0B,
                    (int) wrapper->vga_b * 0xF4 + 0x0B,
                    0xFF // alpha
                );
            //printf("%d, %d, %d\n", wrapper->vga_r, wrapper->vga_g, wrapper->vga_b);
        }


        // take input and validate
        SDL_PollEvent(&e);

        if(e.type == SDL_QUIT){
            break;
        }
        else if (e.type == SDL_KEYDOWN){
            actions = check_event(keys);
        } // move around with action
        else{
            actions = 0;
        }

        wrapper->actions = actions;

        // update frame
        if(!wrapper->vsync){

            integer_scale(reduced_matrix, pixel_matrix, INTSCALE);
            linearize_pixel(pixel_matrix, pixel_array);
        
            if(update_frame(&renderer, &texture, pixel_array)){
                printf("Couldn't update frame! %s", SDL_GetError());
                break;
            }
            
            // update score
            sprintf(text, "PETRIS SCORE: %d", wrapper->score); // add actual score here
            
            if(update_text(renderer, 
                            text_box_texture,
                            text_surface,
                            font, 
                            &rect,
                            &text_color,
                            text)){
                printf("Couldn't update frame text! %s", SDL_GetError());
                break;
            }
            std::fflush(NULL);

            SDL_RenderPresent(renderer);

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
    clean_frame(&renderer, &window, &texture, text_surface, text_box_texture);
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
    //SDL_LockTexture(*texture, nullptr, (void**) &pixel_array, &pitch);
    //SDL_UnlockTexture(*texture);

    SDL_RenderClear(*renderer);
    SDL_RenderCopy(*renderer, *texture, nullptr, nullptr);

    return 0;
}

int update_text(SDL_Renderer* renderer,
                SDL_Texture* texture, 
                SDL_Surface* surface, 
                TTF_Font* font, 
                SDL_Rect* rect,
                SDL_Color* text_color, 
                const char* spool){
    surface = TTF_RenderText_Solid(font, spool, *text_color);
    texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_RenderCopy(renderer, texture, nullptr, rect);

    return 0;
}

void clean_frame(SDL_Renderer** renderer, 
                 SDL_Window** window, 
                 SDL_Texture** texture,
                 SDL_Surface* surface,
                 SDL_Texture* text_box_texture){
    TTF_Quit();
    SDL_DestroyTexture(*texture);
    SDL_FreeSurface(surface);
    SDL_DestroyTexture(text_box_texture);
    SDL_DestroyWindow(*window);
    SDL_DestroyRenderer(*renderer);
    SDL_Quit();

    return ;
}

int check_event(const Uint8* keys){
    int actions = 0;
    if (keys[SDL_SCANCODE_LEFT]){
        actions += 0b00010;
    }
    if (keys[SDL_SCANCODE_RIGHT]){
        actions += 0b00001;
    }
    if (keys[SDL_SCANCODE_DOWN]){
        actions += 0b00100;
    }

    return actions;
}

void integer_scale(Uint32 from[10][20], Uint32 to[10*INTSCALE][20*INTSCALE], int scale){
    for(int i = 0; i < 10; i++){
        for(int j = 0; j < 20; j++){
            for(int k = 1; k < scale - 1 ; k++){
                for(int l = 1; l < scale - 1 ; l++){
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