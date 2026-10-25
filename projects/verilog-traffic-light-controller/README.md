# Verilog Traffic Light Controller with Pedestrian Request

A small, synthesizable Verilog RTL project demonstrating an FSM-based two-road traffic light controller with a latched pedestrian request.

## Design overview

- Four vehicle-light phases: north-south green/yellow and east-west green/yellow.
- A pedestrian-walk phase that holds both vehicle directions red.
- A pending-request flag so a short pedestrian request is retained until it can be serviced.
- Parameterized phase lengths for simulation and reuse.
- A self-checking testbench that checks the expected phase sequence, request servicing, and safe light combinations.

**Scope:** educational digital-design exercise only. It is not intended to control real traffic equipment.

## Repository layout

- rtl/traffic_light_controller.v — synthesizable controller RTL.
- tb/tb_traffic_light_controller.v — self-checking simulation testbench.
- docs/test_plan.md — planned verification scenarios.
- docs/evidence.md — how to inspect reproducible simulation evidence.
- .github/workflows/traffic-light-controller-sim.yml — automated simulation workflow.

## Light encodings

| Signal value | Meaning |
|---|---|
| 2'b00 | Red |
| 2'b01 | Yellow |
| 2'b10 | Green |
| walk = 1 | Pedestrian phase active |

## Run the simulation locally

Install Icarus Verilog and optionally GTKWave.

From this project directory, run:

    iverilog -g2012 -Wall -o traffic_light_sim rtl/traffic_light_controller.v tb/tb_traffic_light_controller.v
    vvp traffic_light_sim

The testbench writes traffic_light_controller.vcd in the current directory. Open it with GTKWave to inspect the clock, reset, request, vehicle lights and walk output.

On Windows, run the same commands in PowerShell after adding Icarus Verilog to PATH.

## Verification and evidence

The testbench prints named PASS checks and exits with a non-zero status if an assertion fails. The GitHub Actions workflow compiles and runs the testbench on pushes and pull requests, then uploads the simulator log and VCD waveform as a run artifact.

**Evidence policy:** only a completed workflow run or a locally executed simulator log is a simulation result. Do not treat source code alone as proof of a passing simulation. See docs/evidence.md.

## Interface

Inputs: clk, active-low asynchronous reset rst_n, and synchronous ped_request.

Outputs: ns_light[1:0], ew_light[1:0], and walk.

## Limitations

This is a compact portfolio exercise, not a complete intersection controller. It does not model sensors, fail-safe hardware, timing requirements for a real road junction, or any safety certification.