# petris
An FPGA based Tetris clone

The code is written in Verilog and compiled into C++ to then be run under a wrapper.
You will need the following to run `petris`:
- GCC
- Verilator
- SDL2 / SDL2 TTF Libraries

The code has been tested primarily on Linux, and doesn't always play well with Windows due to Verilator having limited support on the platform. Feel free to donate a Macintosh if you wish for us to test it on OSX.

Clone the repository into a location of your choice:
```
git clone https://github.com/sankalpgambhir/petris
cd petris
```

To compile the simulation, move into the `code` folder:
```
cd code
```
And use either of the two equivalent targets 
```
make fresh
make verilate execute
```
`fresh` also cleans files from previous compilations. Use target `clean` for explicit cleanup after compilation.

If you wish to recompile the associated project report, move into the `docs` folder, assuming you're in the `petris` folder and use the `fresh` target:
```
cd docs
make fresh
```
Use a program such as Okular to open the generated PDF file:
```
okular main.pdf
```

Copyright &copy 2020 Sankalp Gambhir and Pushkar Mohile under the MPL-2.0. See the `LICENSE` file for more details.