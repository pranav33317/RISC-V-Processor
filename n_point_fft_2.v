module FFT_NPoint (
    input [15:0] x[0:N-1],  // N-point input data (complex numbers as [real, imag])
    output [15:0] X[0:N-1]  // N-point FFT output (complex numbers as [real, imag])
);
    // Internal wires for storing intermediate FFT results (both real and imag)
    wire [15:0] fft_real[N-1:0], fft_imag[N-1:0];
    wire [15:0] twiddle_real[N-1:0], twiddle_imag[N-1:0];

    // Generate twiddle factors for combining
    genvar k;
    generate
        for(k=0; k<N/2; k=k+1) begin : twiddle_gen
            // Twiddle factor W_N^k = cos(2*pi*k/N) - j*sin(2*pi*k/N)
            assign twiddle_real[k] = $cos(2 * 3.14159 * k / N); // Real part
            assign twiddle_imag[k] = -$sin(2 * 3.14159 * k / N); // Imaginary part
        end
    endgenerate

    // Recursive call for FFT using the 2-point FFTs
    genvar i;
    generate
        for(i=0; i<N/2; i=i+1) begin : fft_stage
            FFT2Point fft_inst (
                .x0_real(x[2*i]), 
                .x0_imag(x[2*i+1]),
                .x1_real(x[2*i+2]),
                .x1_imag(x[2*i+3]),
                .X0_real(fft_real[2*i]), 
                .X0_imag(fft_imag[2*i]),
                .X1_real(fft_real[2*i+1]), 
                .X1_imag(fft_imag[2*i+1])
            );
        end
    endgenerate

    // Combine the results from the recursive FFTs and apply twiddle factors
    always @(*) begin
        // Combining the results for even and odd indexed results with twiddle factors
        integer k;
        for(k=0; k<N/2; k=k+1) begin
            // Combine the even and odd indexed results (with twiddle factor for odd)
            X[k] = fft_real[k] + twiddle_real[k] * fft_real[k+N/2] - twiddle_imag[k] * fft_imag[k+N/2];
            X[k+N/2] = fft_real[k] - twiddle_real[k] * fft_real[k+N/2] + twiddle_imag[k] * fft_imag[k+N/2];
        end
    end
endmodule

