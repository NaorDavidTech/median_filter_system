// Top module
module median_filter_system
#(
    parameter WINDOW_SIZE = 3,
    parameter IMAGE_WIDTH = 8,
    parameter IMAGE_HEIGHT = 8,
    parameter PIXEL_WIDTH = 8
)
(
    input wire clk,
    input wire rst_n,
    input wire data_valid,
    input wire [PIXEL_WIDTH-1:0] data_in,
    output wire data_valid_out,
    output wire [PIXEL_WIDTH-1:0] data_out,
    output wire frame_complete
);

    // Internal connections
    wire filtered_valid;
    wire [PIXEL_WIDTH-1:0] filtered_data;

    // Instantiate median filter
    median_filter #(
        .WINDOW_SIZE(WINDOW_SIZE),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) median_filter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(data_valid),
        .data_in(data_in),
        .data_valid_out(filtered_valid),
        .data_out(filtered_data)
    );

    // Instantiate zero edge handler
    zero_edge_handler #(
        .WINDOW_SIZE(WINDOW_SIZE),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) edge_handler_inst (
        .clk(clk),
        .rst_n(rst_n),
        .filtered_valid(filtered_valid),
        .filtered_data(filtered_data),
        .data_valid_out(data_valid_out),
        .data_out(data_out),
        .frame_complete(frame_complete)
    );

endmodule