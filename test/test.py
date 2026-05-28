import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_systolic_array_full_flow(dut):
    dut._log.info("Starting Systolic Array Full Flow Test")

    # Set clock to 200ns (5 MHz) to match config.json
    clock = Clock(dut.clk, 200, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    dut._log.info("Reset complete. Design in S_LOAD state.")

    # --- Phase 1: Load 18 bytes (Matrix A and B) ---
    # We'll just load dummy incremental data 1, 2, 3... 18
    for i in range(18):
        dut.ui_in.value = i + 1
        await ClockCycles(dut.clk, 1)
    
    dut._log.info("Finished loading 18 bytes. Transitioning to S_CALC.")

    # --- Phase 2: Wait for Calculation ---
    # Per your logic fix, S_CALC takes 2 cycles (count 0 and count 1)
    await ClockCycles(dut.clk, 2)
    dut._log.info("Calculation cycles complete. Transitioning to S_OUT.")

    # --- Phase 3: Verify Output Phase ---
    # In S_OUT, uio_out[0] (data_valid) should be HIGH
    await RisingEdge(dut.clk)
    
    # Check data_valid strobe on uio_out[0]
    # uio_out is 8 bits, bit 0 is our strobe
    is_valid = dut.uio_out.value & 0x01
    assert is_valid == 1, f"Error: data_valid (uio_out[0]) is {is_valid}, expected 1"
    
    dut._log.info("Success! data_valid strobe detected in S_OUT state.")

    # Let it run for the full 27-byte output sequence
    await ClockCycles(dut.clk, 30)
    dut._log.info("Simulation finished successfully.")