module fft_recursive #(
    parameter N = 64  // Set N as the input size of the FFT
)(
    input [31:0] x[0:N-1],  // Input signal array (32-bit each)
    input clk, reset,
    output reg [31:0] X[0:N-1]  // Output FFT array (32-bit each)
);

    // Split the input into even and odd
    wire [31:0] even[0:N/2-1];
    wire [31:0] odd[0:N/2-1];
    
    // Intermediate array to hold the even and odd values up to N/2
    wire [31:0] even_out[0:N/2-1];
    wire [31:0] odd_out[0:N/2-1];

    // Twiddle factor lookup (real and imaginary parts)
    reg [31:0] twiddle_real [0:N/2-1];
    reg [31:0] twiddle_imag [0:N/2-1];

    integer i;

    // Twiddle factor initialization using initial block
    initial begin
        case (N)
            2: begin
                twiddle_real[0] = 32'd1;
                twiddle_imag[0] = 32'd0;
            end
            4: begin
                twiddle_real[0] = 32'd1;
                twiddle_imag[0] = 32'd0;
                twiddle_real[1] = 32'd0;
                twiddle_imag[1] = 32'd1;
            end
            8: begin
                twiddle_real[0] = 32'd1;
                twiddle_imag[0] = 32'd0;
                twiddle_real[1] = 32'd0;
                twiddle_imag[1] = 32'd1;
                twiddle_real[2] = 32'd-1;
                twiddle_imag[2] = 32'd0;
                twiddle_real[3] = 32'd0;
                twiddle_imag[3] = 32'd-1;
            end
            16: begin
                twiddle_real[0] = 32'd1;
                twiddle_imag[0] = 32'd0;
                twiddle_real[1] = 32'd0;
                twiddle_imag[1] = 32'd1;
                twiddle_real[2] = 32'd-1;
                twiddle_imag[2] = 32'd0;
                twiddle_real[3] = 32'd0;
                twiddle_imag[3] = 32'd-1;
                twiddle_real[4] = 32'd0.7071;
                twiddle_imag[4] = 32'd0.7071;
                twiddle_real[5] = 32'd0;
                twiddle_imag[5] = 32'd1;
                twiddle_real[6] = 32'd-0.7071;
                twiddle_imag[6] = 32'd0.7071;
                twiddle_real[7] = 32'd0;
                twiddle_imag[7] = 32'd-1;
            end
            default: begin
                // Default case
                for (i = 0; i < N/2; i = i + 1) begin
                    twiddle_real[i] = 32'd1;
                    twiddle_imag[i] = 32'd0;
                end
            end
        endcase
    end

    // Split input into even and odd indexed sequences
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1) begin
                X[i] <= 32'b0;
            end
        end else begin
            // Split the input into even and odd indexed values
            for (i = 0; i < N/2; i = i + 1) begin
                even[i] <= x[2*i];      // Assign even indexed values 
                odd[i] <= x[2*i + 1];   // Assign odd indexed values
            end

            // Instantiate the 2-point FFT for each pair of even and odd values
            for (i = 0; i < N/2; i = i + 1) begin
                fft_2point fft_even (
                    .x0(even[i]),      // Use even[i] for the i-th even indexed element
                    .x1(even[i+1]),    // Use even[i+1] for the next even indexed element
                    .clk(clk),
                    .reset(reset),
                    .X0(even_out[i]),
                    .X1(even_out[i+1])
                );

                fft_2point fft_odd (
                    .x0(odd[i]),       // Use odd[i] for the i-th odd indexed element
                    .x1(odd[i+1]),     // Use odd[i+1] for the next odd indexed element
                    .clk(clk),
                    .reset(reset),
                    .X0(odd_out[i]),
                    .X1(odd_out[i+1])
                );
            end

            // Combine even and odd results using twiddle factors
            for (i = 0; i < N/2; i = i + 1) begin
                // Real part: X[i] = even_out[i] + (real_part * odd_out[i]) - (imag_part * odd_out[i])
                X[i] <= even_out[i] + (twiddle_real[i] * odd_out[i]) - (twiddle_imag[i] * odd_out[i]);

                // Imaginary part: X[i + N/2] = even_out[i] - (real_part * odd_out[i]) + (imag_part * odd_out[i])
                X[i + N/2] <= even_out[i] - (twiddle_real[i] * odd_out[i]) + (twiddle_imag[i] * odd_out[i]);
            end
        end
    end
endmodule

