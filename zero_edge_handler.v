module zero_edge_handler
#(
    parameter WINDOW_SIZE = 3,     // Must match the median filter parameter
    parameter IMAGE_WIDTH = 8,     // Image width in pixels
    parameter IMAGE_HEIGHT = 8,    // Image height in pixels
    parameter PIXEL_WIDTH = 8      // Pixel data width in bits
)
(
    input wire clk,                // System clock
    input wire rst_n,              // Active-low reset
    
    // Filtered data interface
    input wire filtered_valid,     // Filtered data valid signal
    input wire [PIXEL_WIDTH-1:0] filtered_data, // Filtered pixel data
    
    // Output interface
    output reg data_valid_out,     // Output data valid signal
    output reg [PIXEL_WIDTH-1:0] data_out,      // Output pixel data
    output reg frame_complete      // Signal indicating complete frame output
);

    // Calculate margin size (non-filtered region at each edge)
    localparam MARGIN = (WINDOW_SIZE - 1) / 2;
    
    // Calculate dimensions of filtered area
    localparam FILTERED_WIDTH = IMAGE_WIDTH - 2*MARGIN;
    localparam FILTERED_HEIGHT = IMAGE_HEIGHT - 2*MARGIN;
    
    // Counters for tracking position in output image
    reg [3:0] out_row, out_col;
    
    // Counter for filtered pixels received
    reg [7:0] filtered_count;
    
    // Storage for filtered pixels
    reg [PIXEL_WIDTH-1:0] filtered_buffer [0:FILTERED_WIDTH*FILTERED_HEIGHT];
    
    // State machine states
    localparam COLLECTING = 2'b00;
    localparam OUTPUTTING = 2'b01;
    localparam COMPLETED = 2'b10;
    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset system
            filtered_count <= 0;
            out_row <= 0;
            out_col <= 0;
            data_valid_out <= 0;
            data_out <= 0;
            frame_complete <= 0;
            state <= COLLECTING;
        end
        else begin
            case (state)
                // Collect all filtered pixels
                COLLECTING: begin
                    if (filtered_valid) begin
                        filtered_buffer[filtered_count] <= filtered_data;
                        filtered_count <= filtered_count + 1;
                        
                        // Check if we have received all filtered pixels
                        if (filtered_count == FILTERED_WIDTH*FILTERED_HEIGHT) begin
                            filtered_count <= 0;
                            state <= OUTPUTTING;
                        end
                    end
                end
                
                // Output complete image with zero-padded edges
                OUTPUTTING: begin
                    data_valid_out <= 1;
                    
                    // If pixel is in the border region, output zero
                    if (out_row < MARGIN || out_row >= IMAGE_HEIGHT-MARGIN || 
                        out_col < MARGIN || out_col >= IMAGE_WIDTH-MARGIN) begin
                        data_out <= {PIXEL_WIDTH{1'b0}}; // Output zeros for edge pixels
                    end
                    else begin
                        // Output filtered pixel for internal region
                        // Calculate index in filtered buffer
                        data_out <= filtered_buffer[(out_row-MARGIN)*FILTERED_WIDTH + (out_col-(MARGIN-1))];
                    end
                    
                    // Update position counters
                    if (out_col == IMAGE_WIDTH-1) begin
                        out_col <= 0;
                        if (out_row == IMAGE_HEIGHT-1) begin
                            out_row <= 0;
                            state <= COMPLETED;
                        end
                        else begin
                            out_row <= out_row + 1;
                        end
                    end
                    else begin
                        out_col <= out_col + 1;
                    end
                end
                
                // Signal completion and reset for next frame
                COMPLETED: begin
                    data_valid_out <= 0;
                    frame_complete <= 1;
                    state <= COLLECTING;
                end
            endcase
        end
    end
endmodule