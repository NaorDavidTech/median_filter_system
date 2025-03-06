
	module median_filter
	#(
		 parameter WINDOW_SIZE = 3, // Configurable window size
		 parameter IMAGE_WIDTH = 8, // Image width in pixels
		 parameter IMAGE_HEIGHT = 8, // Image height in pixels
		 parameter PIXEL_WIDTH = 8  // Pixel data width in bits
	)
	(
		 input  clk,         // System clock
		 input  rst_n,       // Active-low reset
		 input  data_valid,  // Input data valid signal
		 input  [PIXEL_WIDTH-1:0] data_in, // Input pixel data (8-bit)
		 output reg data_valid_out,// Output data valid signal
		 output reg [PIXEL_WIDTH-1:0] data_out // Filtered output pixel data
	);

	// Total pixels in window
	localparam WINDOW_AREA = WINDOW_SIZE * WINDOW_SIZE;  
	
	// Input buffer storage
	reg [PIXEL_WIDTH-1:0] line_buffers [0:WINDOW_SIZE-1][0:IMAGE_WIDTH-1];
	reg [3:0] col_count;
	reg [3:0] row_count;
	
	// Window formation stage
	reg [PIXEL_WIDTH-1:0] window_buffer [0:WINDOW_AREA-1];
	reg stage1_valid;
	wire window_valid;
	
	// Sorting stage 
	reg [PIXEL_WIDTH-1:0] stage1_values [0:WINDOW_AREA-1];
	reg [PIXEL_WIDTH-1:0] sorted [0:WINDOW_AREA-1];
	reg [PIXEL_WIDTH-1:0] temp;
	reg [PIXEL_WIDTH-1:0] sort_result;
	reg sort_valid;
	
	// Result calculation registers
	reg [PIXEL_WIDTH-1:0] median_value;
	reg median_valid;

	// Processing loop variables
	integer i, j, k;
	



	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
	// Reset line buffers and counters
			for (i = 0; i < WINDOW_SIZE; i = i + 1)
				for (j = 0; j < IMAGE_WIDTH; j = j + 1)
					 line_buffers[i][j] <= 8'b0;
			col_count <= 4'b0;
			row_count <= 4'b0;
		end
		else if (data_valid) begin
	// Check if this is the first pixel of a new row (except the very first pixel)
			if (col_count == IMAGE_WIDTH) begin
				// Shift all rows down
				for (i = WINDOW_SIZE - 1; i > 0; i = i - 1) begin
					 for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
						  line_buffers[i][j] <= line_buffers[i - 1][j];
					 end
				end
				
				// Clear the top row
				for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
					 line_buffers[0][j] <= 8'b0;
				end
				
	      // Insert the first pixel of the new row at position 0
				line_buffers[0][0] <= data_in;
				col_count <= 1;// Set to 1 since we've stored the pixel at position 0
				
	   	// Update row count
				if (row_count == IMAGE_HEIGHT - 1)
					 row_count <= 4'b0;
				else
					 row_count <= row_count + 1;
			end
			else begin
				// Store the current pixel into the first row
				line_buffers[0][col_count] <= data_in;
				col_count <= col_count + 1;
			end
		end
	end

	
	
		
	// Window validity condition
	assign window_valid = (row_count >= WINDOW_SIZE-1) && 
								 (col_count >= WINDOW_SIZE-1) && 
								 (col_count < IMAGE_WIDTH) &&
								 (row_count < IMAGE_HEIGHT);


		 
		 
	// Window formation - improved for hardware efficiency
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i = 0; i < WINDOW_AREA; i = i + 1)
				window_buffer[i] <= 8'b0;
				stage1_valid <= 1'b0;
		end
		else if (data_valid && window_valid) begin
			// Construct window from line buffers
			k = 0;
			for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
				for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
					if (col_count >= j && col_count < IMAGE_WIDTH) begin
					  window_buffer[k] <= line_buffers[i][col_count - j];
					end
					k = k + 1; 
				end
			end
		  
		  // Pipeline control - updated only when window is valid
		  stage1_valid <= window_valid;
		end
		else begin
		  // Maintain previous state when no new data
		  stage1_valid <= 1'b0;
		end
	end


	

	// Stage 1: Prepare values for sorting 
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i = 0; i < WINDOW_AREA; i = i + 1)
				stage1_values[i] <= 8'b0;
		end
		else if (stage1_valid) begin
			for (i = 0; i < WINDOW_AREA; i = i + 1)
				stage1_values[i] <= window_buffer[i];
		end
	end
		 
		
		
		
	// Stage 2: Sorting and median calculation 
	always @(*) begin
		for (i = 0; i < WINDOW_AREA; i = i + 1) begin
			 // Copy stage1_values into sorted array
			 sorted[i] = stage1_values[i]; 
		end

		// Simple bubble sort
		for (i = 0; i < WINDOW_AREA - 1; i = i + 1) begin
			for (j = 0; j < WINDOW_AREA - 1 - i; j = j + 1) begin
				if (sorted[j] > sorted[j + 1]) begin
					temp = sorted[j];  // Swap values if out of order
					sorted[j] = sorted[j + 1];
					sorted[j + 1] = temp;
				end
			end
		end

		// Calculate median (combinational logic)
		sort_result = sorted[WINDOW_AREA >> 1];
		sort_valid = stage1_valid;
	end
	 
	 
	 

	// Stage 3: Register the median value 
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
		  median_value <= 8'b0;
		  median_valid <= 1'b0;
		end
		else begin
		  median_value <= sort_result;
		  median_valid <= sort_valid;
		end
	end

			
	
	// Output stage
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_out <= 8'b0;
			data_valid_out <= 1'b0;
		end
		else begin
			data_valid_out <= median_valid;
			data_out <= median_value;
		end
	end

	endmodule




     