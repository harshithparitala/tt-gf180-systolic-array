3x3 Systolic Array for Matrix Multiplication

## What is the project?
	
This project is a hardware implementation of a 3x3 systolic array architecture for matrix multiplication, developed as part of the Benchmark II: Compute-Bound Scalability research. It is designed to demonstrate high computational efficiency by enabling massive parallel computation, overcoming the memory bottlenecks typically found in sequential architectures like traditional CPUs and GPUs.

## How it works

A systolic array is a parallel, hardware-based computational structure composed of multiple identical Processing Elements (PEs) arranged in a grid-like pattern. Data elements rhythmically pulse through the system, akin to a heartbeat. 
	Inside the array, each PE is a simple computational unit that performs a localized multiply-accumulate (MAC) operation. It takes an incoming 8-bit value from matrix A, multiplies it with an 8-bit value from matrix B, and adds the product to a 16-bit partial sum passed from a previous PE in the pipeline. 
	Because a 3x3 matrix multiplication natively requires 144 input pins and 144 output pins, and Tiny Tapeout only provides 8 dedicated inputs and 8 outputs, this design includes a top-level serial-to-parallel wrapper. The wrapper acts as a state machine: it uses shift registers to sequentially stream in the matrix elements over successive clock cycles, executes the parallel multiplication through the systolic pipeline, and then multiplexes the final 16-bit results back out through the 8-bit output pins.

## How to test

1.  Initialize: Assert the `rst_n` (active low) signal to clear the internal PE accumulators. This is crucial for resolving any undefined 'X' values before computation begins.
2.  Load Data: De-assert the reset. Sequentially feed the 8-bit values of Matrix A and Matrix B into the `ui_in` pins. The internal shift register will latch these values over 18 clock cycles.
3.  Execute: Once loaded, the data waves will propagate completely through the 3x3 array. New elements are fed into the array every cycle, allowing multiple computations to occur simultaneously across all PEs in the pipeline.
4.  Read Results: The final 16-bit accumulated results for Matrix C will be sequentially shifted out on the `uo_out` pins over the following clock cycles. Monitor these outputs to confirm the design's logical correctness.
