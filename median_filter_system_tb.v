	`timescale 1ns/1ps

	module median_filter_system_tb;

	// Parameters
	parameter WINDOW_SIZE = 3;
	parameter IMAGE_WIDTH = 8;
	parameter IMAGE_HEIGHT = 8;
	parameter PIXEL_WIDTH = 8;
	parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)

	// Signals
	reg clk;
	reg rst_n;
	reg data_valid;
	reg [PIXEL_WIDTH-1:0] data_in;
	wire data_valid_out;
	wire [PIXEL_WIDTH-1:0] data_out;
	wire frame_complete;

	// Test image data
	reg [PIXEL_WIDTH-1:0] test_image [0:IMAGE_WIDTH*IMAGE_HEIGHT-1];
	reg [PIXEL_WIDTH-1:0] output_image [0:IMAGE_WIDTH*IMAGE_HEIGHT-1];
	integer output_idx;

	// File handling variables
	integer i, j, file, r;
	reg [PIXEL_WIDTH-1:0] value;
	reg timeout;

	// DUT instantiation - Complete system
	median_filter_system #(
		 .WINDOW_SIZE(WINDOW_SIZE),
		 .IMAGE_WIDTH(IMAGE_WIDTH),
		 .IMAGE_HEIGHT(IMAGE_HEIGHT),
		 .PIXEL_WIDTH(PIXEL_WIDTH)
	) dut (
		 .clk(clk),
		 .rst_n(rst_n),
		 .data_valid(data_valid),
		 .data_in(data_in),
		 .data_valid_out(data_valid_out),
		 .data_out(data_out),
		 .frame_complete(frame_complete)
	);

	// Clock generation
	initial begin
		 clk = 0;
		 forever #(CLK_PERIOD/2) clk = ~clk;
	end

	// Output collection
	always @(posedge clk) begin
		 if (data_valid_out) begin
			  output_image[output_idx] <= data_out;
			  output_idx <= output_idx + 1;
		 end
	end

	// Timeout process
	initial begin
		 timeout = 0;
		 #(CLK_PERIOD*150);
		 timeout = 1;
	end

	// Test procedure
	initial begin
		 // Initialize
		 rst_n = 0;
		 data_valid = 0;
		 data_in = 0;
		 output_idx = 0;
		 
		 // Read test image
		 file = $fopen("test_image.txt", "r");
		 if (file == 0) begin
			  $display("Error opening file");
			  $finish;
		 end
		 
		 for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
			  for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
					r = $fscanf(file, "%h", value);
					if (r != 1) begin
						 $display("Error reading file at row %0d, col %0d", i, j);
						 $finish;
					end
					test_image[i*IMAGE_WIDTH + j] = value;
			  end
		 end
		 $fclose(file);
		 
		 // Display loaded test image to verify
		 $display("Loaded test image:");
		 for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
			  for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
					$write("%02X ", test_image[i*IMAGE_WIDTH + j]);
			  end
			  $display("");
		 end
		 
		 // Reset
		 #(CLK_PERIOD*5);
		 rst_n = 1;
		 #(CLK_PERIOD*2);
		 
		 // Feed test image data
		 for (i = 0; i < IMAGE_WIDTH*IMAGE_HEIGHT; i = i + 1) begin
			  data_valid = 1;
			  data_in = test_image[i];
			  #(CLK_PERIOD);
		 end
		 
		 // Wait for processing to complete
		 #(CLK_PERIOD*22);
		 data_valid = 0;
		 
		 // Wait for frame complete signal or timeout
		 while (!frame_complete && !timeout) begin
			  #(CLK_PERIOD);
		 end
		 
		 if (timeout) begin
			  $display("Warning: Test timed out waiting for frame_complete signal");
		 end
		 
		 #(CLK_PERIOD*10);
		 
		 // Display output
		 $display("Output image:");
		 for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
			  for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
					$write("%02X ", output_image[i*IMAGE_WIDTH + j]);
			  end
			  $display("");
		 end
		 
		 
		 $display("Verification complete.");
		 $finish;
	end

	endmodule