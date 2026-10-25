# Verification Test Plan

## Objective

Check the externally visible behavior of the parameterized Verilog traffic-light FSM and its pedestrian-request handling. Testbench defaults are intentionally small to keep simulation fast.

## Test cases

| ID | Scenario | Expected result |
|---|---|---|
| TC-01 | Assert reset | North-south green; east-west red; walk low |
| TC-02 | Let NS green interval elapse | NS changes to yellow |
| TC-03 | Let NS yellow interval elapse | EW changes to green |
| TC-04 | Let EW green interval elapse | EW changes to yellow |
| TC-05 | No pedestrian request | Controller returns to NS green |
| TC-06 | Pulse ped_request for one sampled clock | Request remains pending after input returns low |
| TC-07 | Pending request during normal phases | Regular NS yellow, EW green and EW yellow phases are preserved |
| TC-08 | End of EW yellow with a pending request | Both vehicle lights red and walk=1 |
| TC-09 | Pedestrian interval expires | Walk deasserts and NS green resumes |
| TC-10 | Safety monitor | Both directions are never green at once; walk only occurs when both are red |
| TC-11 | Simulation progress | Testbench ends before its timeout guard |

## Pass/fail criteria

- Each directed output check must match exactly, including unknown-value detection with case inequality.
- Any mismatch or safety-invariant violation calls $fatal, returning a non-zero simulator exit status.
- A passing run must print the final PASS summary and finish without the timeout guard firing.

## Reproducibility

Run from this directory:

    iverilog -g2012 -Wall -o traffic_light_sim rtl/traffic_light_controller.v tb/tb_traffic_light_controller.v
    vvp traffic_light_sim

The simulation creates traffic_light_controller.vcd for waveform inspection. The continuous-integration workflow also uploads its captured simulator output and VCD file as a workflow artifact.