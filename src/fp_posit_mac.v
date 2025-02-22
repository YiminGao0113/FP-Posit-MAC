module fp_posit_mac #(
    parameter ACT_WIDTH = 16,
    parameter ACC_WIDTH = 32
)(
    input                   clk,
    input                   rst,
    input                   valid,
    input [3:0]             precision,
    input                   set,
    input [ACT_WIDTH-1:0]   act,
    input                   w,
    input [4:0]             exp_min,
    input [31:0]            fixed_point_acc,
    output [4:0]            exp_out,
    output [ACC_WIDTH-1:0]  fixed_point_out,
    output                  done
);

// Intermediate signals between Multiplier and Accumulator
wire                    start_acc;
wire                    sign_out;
wire [4:0]              exp_out_mul;
wire [13:0]             mantissa_out;

// Accumulator signals
reg [4:0]               exp_min_reg;
reg                     acc_start;

// Instantiate the Multiplier Unit (fp16 × posit)
fp_posit_mul #(
    .ACT_WIDTH(ACT_WIDTH)
) mul_unit (
    .clk(clk),
    .rst(rst),
    .act(act),
    .w(w),
    .valid(valid),
    .set(set), // No precision setting needed dynamically here
    .precision(precision), // Default precision
    .sign_out(sign_out),
    .exp_out(exp_out_mul),
    .mantissa_out(mantissa_out),
    .done(start_acc)
);

// Instantiate the Accumulator Unit
fp_posit_acc acc_unit (
    .clk(clk),
    .rst(rst),
    .start(start_acc),
    .sign_in(sign_out),
    .exp_set(exp_min),
    .fixed_point_acc(fixed_point_acc),
    .exp_in(exp_out_mul),
    .fixed_point_in(mantissa_out),
    .exp_out(exp_out),
    .fixed_point_out(fixed_point_out),
    .done(done)
);

endmodule
