import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer

@cocotb.test()
async def test_systolic_array_full_flow(dut):
    dut._log.info("Starting Systolic Array Gate-Level Test")

    # Use 200ns (5MHz) to match config.json
    clock = Clock(dut.clk, 200, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize and Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # Phase 1: Load 18 bytes
    dut._log.info("Loading Data...")
    for i in range(18):
        dut.ui_in.value = i + 1
        await ClockCycles(dut.clk, 1)

    # Phase 2: Wait for Calculation (S_CALC)
    # Give it 5 cycles just to be safe for gate delays
    await ClockCycles(dut.clk, 5)

    # Phase 3: Verify Output Phase
    dut._log.info("Checking for data_valid strobe...")
    
    # Wait for the rising edge, then wait 10ns for gates to settle
    await RisingEdge(dut.clk)
    await Timer(10, units="ns") 

    # Check uio_out[0]
    uio_val = dut.uio_out.value.integer
    is_valid = uio_val & 0x01
    
    if is_valid != 1:
        dut._log.error(f"Strobe failed! uio_out was {uio_val:02x}")
        # Let's run a few more cycles to see if it shows up late
        for _ in range(5):
            await ClockCycles(dut.clk, 1)
            if dut.uio_out.value.integer & 0x01:
                dut._log.info("Strobe found late - timing is just tight!")
                break
    
    assert is_valid == 1, "data_valid strobe not detected at expected time"
    dut._log.info("Test Passed!")