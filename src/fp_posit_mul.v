module fp_posit_mul #(
    parameter ACT_WIDTH = 16,
    parameter EXP_WIDTH = 5,
    parameter MAN_WIDTH = 10
)(
    input                   clk,
    input                   rst,
    input [ACT_WIDTH-1:0]   act,
    input                   w,
    input                   valid, // help identify the length of valid stream
    input                   set, // set = 1 when idle to set precision
    input [3:0]             precision, // Up to 8-bit Posit, es = 0
    output reg              sign_out,
    output [4:0]            exp_out,
    output [13:0]           man_out,
    output reg              start_acc,
    output reg              done
);

wire                      act_sign;
wire [4:0]                act_exponent;
wire [9:0]                act_mantissa;
wire [10:0]               fixed_mantissa;
assign {act_sign, act_exponent, act_mantissa} = act;

reg [3:0]             _precision;

always @(posedge clk or negedge rst)
    if (!rst) _precision <= 0;
    else if (set) _precision <= precision;

reg [3:0]             count;
reg                   regime_done;
reg                   _regime;
reg                   regime_next;
reg                   regime_sign;
reg [1:0] state;  // 2-bit state register
reg [1:0] state_next;  // 2-bit state register

// Define states
localparam SIGN     = 2'b00;
localparam REGIME   = 2'b01;
localparam MANTISSA = 2'b10;

// Sequential: Update state and signals
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        // state       <= SIGN;
        count       <= 0;
        regime_done <= 0;
        start_acc   <= 0;
        done        <= 0;
    end 
    else begin
        // state       <= state_next;  // Update state
        if (valid) begin
            if (count<_precision-1) count <= count + 1;
            else count <= 0;
        end
    end
end

// Combinational: Define next state logic
always @(*) begin
    case (count)
        4'b0000:  state = SIGN;
        4'b0001:  state = REGIME;
        default:  begin
            if (count < _precision-1)
                if (regime_done) state = MANTISSA;
                else state = REGIME;
            else state = SIGN;
        end
    endcase
end

// Output logic
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        start_acc   <= 0;
        done        <= 0;
        regime_done <= 0;
        sign_out    <= 0;
        _regime     <= 0;
    end 
    else if (valid) begin
        if (state == SIGN) sign_out <= act[ACT_WIDTH-1] ^ w;
        if (state == REGIME) begin
            _regime <= w;
            if (count == 1) regime_sign <= w; // 0 for positive 1 for negative
            else if (_regime^w) begin
                regime_done <= 1;
            end
        end
        if (count == _precision-1) begin
            regime_done <= 0;  // Reset regime_done
            done        <= 1;
        end 
        else begin
            start_acc   <= 0;
            done        <= 0;
        end
    end
end

endmodule

// module fixed_point_adder(
//     input      [13:0]  A,
//     input      [13:0]  B,
//     output     [13:0]  C
// );
// // This is the intermediate represetation in order to have the least # of rounding at the end of computation.
// // The 14-bit fixed point representation consists of 4 bits . 10 bits mantissa
// // which is able to hold everything accurately without 
// assign C = A + B;
// endmodule