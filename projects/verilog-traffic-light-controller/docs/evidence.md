# Simulation Evidence

## Latest verified result

**Status: PASS** — GitHub Actions completed the RTL compile and self-checking simulation successfully on **2026-10-25**.

- **Workflow run:** https://github.com/SURYA2179/SURYA-/actions/runs/40168310846
- **Tested source commit:** db50c004f1d5f77ae59943fb575d919c03cf5319
- **Simulator:** Icarus Verilog 12.0-2build2 on the GitHub-hosted Ubuntu runner
- **Result:** all 13 directed output checks passed; the testbench also reported that safety invariants remained satisfied.
- **Evidence artifact:** traffic-light-controller-simulation-evidence, available from the workflow run page for 30 days after the run.

The artifact contains compile.log, simulation.log, and traffic_light_controller.vcd. Open the workflow run and use its Artifacts section to download the ZIP; open the VCD in GTKWave to inspect the waveform.

## What constitutes a pass

A passing run must compile successfully, exit with status zero, display the final PASS summary, and upload both the simulator log and VCD waveform. A failed assertion or compile error fails the workflow.

## Reproducibility

The workflow compiles and runs:

    iverilog -g2012 -Wall -o traffic_light_sim rtl/traffic_light_controller.v tb/tb_traffic_light_controller.v
    vvp traffic_light_sim

The testbench performs directed checks for reset state, phase sequencing, request latching and servicing, pedestrian-walk duration, return to vehicle traffic, and basic safety invariants.

## Evidence integrity

The status above refers to the exact source commit linked above. Later changes to RTL or testbench code must be verified by a fresh passing run. CI artifacts expire; the workflow run page retains the result and logs subject to GitHub's retention policy.