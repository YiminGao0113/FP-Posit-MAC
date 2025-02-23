`timescale 1ns/1ps

module fp_posit_mul_tb;

    parameter ACT_WIDTH = 16;
    parameter EXP_WIDTH = 5;
    parameter MAN_WIDTH = 10;

    reg clk;
    reg rst;
    reg [ACT_WIDTH-1:0] act;
    reg w;
    reg valid;
    reg set;
    reg [3:0] precision;
    
    // Expected values for verification (Modify these based on expected behavior)
    reg [4:0] expected_exp [0:3];
    reg [13:0] expected_man [0:3];
    
    wire sign_out;
    wire [4:0] exp_out;
    wire [13:0] mantissa_out;
    wire done;

    // Instantiate the module under test
    fp_posit_mul #(ACT_WIDTH, EXP_WIDTH, MAN_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .act(act),
        .w(w),
        .valid(valid),
        .set(set),
        .precision(precision),
        .sign_out(sign_out),
        .exp_out(exp_out),
        .mantissa_out(mantissa_out),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

    expected_exp[0] = 5'b00011; expected_man[0] = 14'b01001010011100;
    expected_exp[1] = 5'b11011; expected_man[1] = 14'b01001010011100;
    expected_exp[2] = 5'b11011; expected_man[2] = 14'b01001010011100;
    expected_exp[3] = 5'b11100; expected_man[3] = 14'b00011000110100;
        // Create VCD file for GTKWave
        $dumpfile("build/fp_posit_mul.vcd");
        $dumpvars(0, fp_posit_mul_tb);  // Dump all signals of the testbench

        // Initialize signals
        clk = 0;
        rst = 0;
        act = 16'h1234; // Example fixed activation value
        w = 0;
        valid = 0;
        set = 0;
        precision = 4;

        // Apply reset
        #10 rst = 1;
        #10 rst = 0;
        #10 rst = 1;

        // Set precision (enable set for one cycle)
        #10 set = 1;
        #10 set = 0;
        
        // Start simulation
        #10 valid = 1;
        #10 w = ~w;
        #10 w = ~w;
        #10 w = ~w;
        #5 act = 16'hf234;
        #5 w = ~w;
        // Change w each cycle
        repeat (10) begin
            #10 w = ~w;
        end
        #10 valid = 0;
        #30 valid = 1;
        #10 w = 0;
        #40 w = 1;
        #10 w = 0;
        // End simulation
        #50 $finish;
    end

    // Expected values for verification (modify as necessary)
    // reg [4:0] expected_exp = 5'b10101; // Example expected exponent
    // reg [13:0] expected_man = 14'b11001100110011; // Example expected mantissa

    integer index = 0;
    // Monitor outputs when done = 1 and compare with expected values
    always @(posedge clk) begin
        if (done) begin
            $display("Time: %0t | Exp Out: %b | Mantissa Out: %b", $time, exp_out, mantissa_out);
            if (exp_out !== expected_exp[index] || mantissa_out !== expected_man[index]) begin
                $display("Mismatch detected! Expected Exp: %b, Expected Mantissa: %b", expected_exp[index], expected_man[index]);
            end else begin
                $display("Output matches expected values.");
            end
            index = index + 1;
        end
    end

endmodule
