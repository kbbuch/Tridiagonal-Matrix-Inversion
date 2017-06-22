# Tridiagonal-Matrix-Inversion

A hardware accelerator for inverting tridiagonal matrix was designed. Initially, the tridiagonal matrix of 32-bit floating point values was stored in the given SRAM and the final result was written to the same SRAM continuing to the address next to the last value of the given matrix stored. 

The design contains 2 32-bit floating point multipliers, 1 32-bit floating point divider and 1 32-bit floating point adder-subtracted provided in the Design-Ware library by Synopsys.

The provided divider was pipelined into 6 stages so as to reduce the critical path delay and obtain the fastest clock possible.

The accelerator was designed so as to give the best throughput possible in the minimum number of cycle achievable without pipelining with minimum hardware possible.

The metric used to decide the performance of the design was 1/(delay.area) (ns-1.um-2).

 
ECE 464/520 ASIC DESIGN PROJECT
Kunal Buch

Abstract:

A hardware accelerator for inverting tridiagonal matrix was designed. Initially, the tridiagonal matrix of 32-bit floating point values was stored in the given SRAM and the final result was written to the same SRAM continuing to the address next to the last value of the given matrix stored. 

The design contains 2 32-bit floating point multipliers, 1 32-bit floating point divider and 1 32-bit floating point adder-subtracted provided in the Design-Ware library by Synopsys.

The provided divider was pipelined into 6 stages so as to reduce the critical path delay and obtain the fastest clock possible.

The accelerator was designed so as to give the best throughput possible in the minimum number of cycle achievable without pipelining with minimum hardware possible.

The metric used to decide the performance of the design was 1/(delay.area) (ns-1.um-2).


1. Introduction

The purpose of the project is to demonstrate your skills in designing a substantial digital system using the Verilog and Synthesis techniques.

The further report consists of the description of tasks undertaken to complete the design and synthesis to obtain the minimum area and the fastest clock possible, timing diagrams of the initial, intermediate and the final values obtained, the block-level diagram of the design.

2. Micro-Architecture
o	The algorithm used to design the architecture of this design was borrowed from the https://en.wikipedia.org/wiki/Tridiagonal_matrix using the intermediate values of theta and phi to obtain the final T-1 elements.
o	The structure was pipelined with the focus on the most optimum throughput possible. i.e. after reading the inputs, the outputs should start flowing into destination and should not incur any bubble cycle loss.
o	The critical path was maintained to only one of the structures amongst the divider multiplier and the add-sub modules from Design-Ware library. Out of these 3, divider had the critical path of around 65ns with the additional multiplexers on the input and de-mux unit on the output.
o	The critical path combinational logic of divider was broken down into 6 sub-stages so as to reduce the clock period further and increase the performance.

3. Interface Specification
o	The input to the design are the 32-bit floating point elements of the tridiagonal matrix. These are in turn used to calculate the 32-bit floating point theta and phi as the intermediate values according to

 https://en.wikipedia.org/wiki/Tridiagonal_matrix.

o	The final values of the inverted matrix are calculated using the formula stated in the above link which are 32-bit floating point elements.
o	These are sent to the destination SRAM one by one each cycle to the specified write-address.
o	The given SRAM is characterized with 1 read – 1 write port and with the read delay of 4ns.

4. Technical Implementation
o	The final design was split into 2 modules, the one being the main design and the other being the pipelined divider.
o	The main design unit consists of 2 32-bit floating point multiplier units and 1 32-bit floating point add-sub unit.
o	The pipelined divider consists of the Design-Ware divider with the 6 stage registers so as to reduce the critical path delay of the divider.

5. Verification
•	An excel sheet was prepared so as to check with the given validation output matches. Differences of up-to 12 Least significant bits was ignored due to the round off tolerance made acceptable by the instructor.
•	The -diff tool provided was also used to check the total matches out of the 100.

6. Results Achieved
•	Throughput: 
o	Total cycles = 146
o	Total outputs = 100
o	Cycles per instruction = 1.46
•	Area: 29509.2420 um2
•	Clock Period: 16 ns

7. Conclusions
•	The hardware to accelerate the inversion of the given tri-diagonal matrix was designed in Verilog 2001 and using the Design-Ware modules by Synopsys for 32-bit floating point calculation.
•	Better performance can be obtained by using a different path and approach for the synthesis flow using the optimal heuristics.
•	Number of cycles obtained for the given number of stages used to pipeline the divider was obtained as the optimal number.
•	Area can further be reduced by using the SRAM to store the intermediate values and reuse the registers in the design to reduce the number of registers used in the design.
•	Further pipelining of the multiplier can be implemented to reduce the clock period, although this can be limited by the SRAM delay to obtain the values from it.

