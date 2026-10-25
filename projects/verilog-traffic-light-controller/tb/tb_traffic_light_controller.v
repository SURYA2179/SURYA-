timescale 1ns/1ps

module tb_traffic_light_controller;

    localparam [1:0] RED    = 2'b00;
    localparam [1:0] YELLOW = 2'b01;
    localparam [1:0] GREEN  = 2'b10;

    localparam integer NS_GREEN_CYCLES  = 5;
    localparam integer NS_YELLOW_CYCLES = 2;
    localparam integer EW_GREEN_CYCLES  = 5;
    localparam integer EW_YELLOW_CYCLES = 2;
    localparam integer PED_WALK_CYCLES  = 4;

    reg clk;
    reg rst_n;
    reg ped_request;
    wire [1:0] ns_light;
    wire [1:0] ew_light;
    wire walk;

    integer checks;

    traffic_light_controller #(
        .NS_GREEN_CYCLES(NS_GREEN_CYCLES),
        .NS_YELLOW_CYCLES(NS_YELLOW_CYCLES),
        .EW_GREEN_CYCLES(EW_GREEN_CYCLES),
        .EW_YELLOW_CYCLES(EW_YELLOW_CYCLES),
        .PED_WALK_CYCLES(PED_WALK_CYCLES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ped_request(ped_request),
        .ns_light(ns_light),
        .ew_light(ew_light),
        .walk(walk)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("traffic_light_controller.vcd");
        $dumpvars(0, tb_traffic_light_controller);
    end

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check_outputs;
        input [1:0] expected_ns;
        input [1:0] expected_ew;
        input       expected_walk;
        input [8*40-1:0] check_name;
        begin
            checks = checks + 1;
            if ((ns_light !== expected_ns) ||
                (ew_light !== expected_ew) ||
                (walk !== expected_walk)) begin
                $display("FAIL: %0s at %0t | NS=%b EW=%b WALK=%b | expected NS=%b EW=%b WALK=%b",
                         check_name, $time, ns_light, ew_light, walk,
                         expected_ns, expected_ew, expected_walk);
                $fatal(1, "Output mismatch");
            end else begin
                $display("PASS: %0s | NS=%b EW=%b WALK=%b",
                         check_name, ns_light, ew_light, walk);
            end
        end
    endtask

    // Safety invariant: conflicting green signals are never asserted together,
    // and pedestrian walk is only active while both vehicle signals are red.
    always @(negedge clk) begin
        if (rst_n) begin
            if ((ns_light == GREEN) && (ew_light == GREEN))
                $fatal(1, "Safety failure: both roads green");
            if (walk && ((ns_light != RED) || (ew_light != RED)))
                $fatal(1, "Safety failure: walk active without both roads red");
        end
    end

    initial begin
        checks = 0;
        rst_n = 1'b0;
        ped_request = 1'b0;

        repeat (2) tick;
        @(negedge clk);
        rst_n = 1'b1;
        #1;
        check_outputs(GREEN, RED, 1'b0, "reset enters NS green");

        // Verify the complete normal vehicle phase sequence.
        repeat (NS_GREEN_CYCLES - 1) tick;
        check_outputs(GREEN, RED, 1'b0, "NS green holds for configured interval");
        tick;
        check_outputs(YELLOW, RED, 1'b0, "NS transitions to yellow");

        repeat (NS_YELLOW_CYCLES) tick;
        check_outputs(RED, GREEN, 1'b0, "EW green follows NS yellow");

        repeat (EW_GREEN_CYCLES) tick;
        check_outputs(RED, YELLOW, 1'b0, "EW transitions to yellow");

        repeat (EW_YELLOW_CYCLES) tick;
        check_outputs(GREEN, RED, 1'b0, "cycle returns to NS green without request");

        // Reset and verify a short pedestrian pulse is remembered and serviced.
        @(negedge clk);
        rst_n = 1'b0;
        ped_request = 1'b0;
        repeat (2) tick;
        @(negedge clk);
        rst_n = 1'b1;
        #1;
        check_outputs(GREEN, RED, 1'b0, "second reset clears request state");

        @(negedge clk);
        ped_request = 1'b1;
        @(negedge clk); // one sampled clock edge has occurred
        ped_request = 1'b0;

        repeat (NS_GREEN_CYCLES - 1) tick;
        check_outputs(YELLOW, RED, 1'b0, "pending request does not skip NS yellow");

        repeat (NS_YELLOW_CYCLES) tick;
        check_outputs(RED, GREEN, 1'b0, "pending request waits through EW green");

        repeat (EW_GREEN_CYCLES) tick;
        check_outputs(RED, YELLOW, 1'b0, "pending request waits through EW yellow");

        repeat (EW_YELLOW_CYCLES) tick;
        check_outputs(RED, RED, 1'b1, "pedestrian phase services pending request");

        repeat (PED_WALK_CYCLES - 1) tick;
        check_outputs(RED, RED, 1'b1, "pedestrian walk holds for configured interval");
        tick;
        check_outputs(GREEN, RED, 1'b0, "controller returns to NS green after walk");

        $display("PASS: all %0d directed output checks completed.", checks);
        $display("PASS: safety invariants remained satisfied.");
        $finish;
    end

    // Prevent a broken FSM from hanging the CI job indefinitely.
    initial begin
        #5000;
        $fatal(1, "Timeout: simulation did not complete");
    end

endmodule
