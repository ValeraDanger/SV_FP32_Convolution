`timescale 1ns / 1ps


module convolution_3x3_128_channels #(
    parameter DATA_WIDTH = 32,
    parameter KERNEL_SIZE = 3,
    parameter CHANNELS = 1
)(
    input logic clk,
    input logic rst,
    input logic valid_in,
    input logic [CHANNELS-1:0][KERNEL_SIZE*KERNEL_SIZE-1:0][DATA_WIDTH-1:0] data_in,   // Входные данные для всех каналов
    input logic [CHANNELS-1:0][KERNEL_SIZE*KERNEL_SIZE-1:0][DATA_WIDTH-1:0] kernel,    // Ядро (веса)
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] result_out,   // Результат свертки
    
    output logic [DATA_WIDTH-1:0] output_axis_a_tdata,
    output logic s_axis_a_tlast,
    output logic [CHANNELS-1:0][KERNEL_SIZE*KERNEL_SIZE-1:0] mul_valid_array
);
    
    // Промежуточные сигналы для результатов умножения
    logic [CHANNELS-1:0][KERNEL_SIZE*KERNEL_SIZE-1:0][DATA_WIDTH-1:0] mul_result;
    //logic [CHANNELS-1:0][KERNEL_SIZE*KERNEL_SIZE-1:0] mul_valid_array;  // Массив для хранения флагов valid от умножителей
    
    
    // Инстанцирование IP-ядра для операций умножения и суммирования (FMA)
    genvar i, j, ch;
    generate
        for (ch = 0; ch < CHANNELS; ch++) begin
            for (i = 0; i < KERNEL_SIZE; i++) begin
                for (j = 0; j < KERNEL_SIZE; j++) begin
                    fp_mul fp_mul_inst (
                        .aclk(clk),
                        .s_axis_a_tvalid(valid_in),
                        .s_axis_a_tdata(data_in[ch][i*KERNEL_SIZE + j]),
                        .s_axis_b_tvalid(valid_in),
                        .s_axis_b_tdata(kernel[ch][i*KERNEL_SIZE + j]),
                        .m_axis_result_tvalid(mul_valid_array[ch][i*KERNEL_SIZE + j]), 
                        .m_axis_result_tdata(mul_result[ch][i*KERNEL_SIZE + j])
                    );
                end
            end
        end
    endgenerate
    
    
    logic mul_valid;
    assign mul_valid = &mul_valid_array;


    logic aclk;
//  logic s_axis_a_tlast;
    logic s_axis_a_tvalid;
    logic [DATA_WIDTH-1:0] s_axis_a_tdata;
    logic m_axis_result_tvalid;
    logic [DATA_WIDTH-1:0] m_axis_result_tdata;
    
    // Подключение IP-ядра аккумулятора
    fp_accum fp_accum_inst (
        .aclk(clk),
        .s_axis_a_tlast(s_axis_a_tlast),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tdata(s_axis_a_tdata),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .m_axis_result_tdata(m_axis_result_tdata)
    );

    logic [8:0] channel_counter;
    logic [8:0] index_counter;
    logic data_loaded;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result_out <= 0;
            valid_out <= 0;
            channel_counter <= 0;
            index_counter <= 0;
            s_axis_a_tvalid <= 0;
            s_axis_a_tlast <= 0;
            data_loaded <= 0;
        end else begin
            if (mul_valid && !data_loaded) begin
                s_axis_a_tdata <= mul_result[channel_counter][index_counter];
                output_axis_a_tdata <= mul_result[channel_counter][index_counter];
                s_axis_a_tvalid <= 1;
                
                if (index_counter == KERNEL_SIZE * KERNEL_SIZE - 1) begin
                    index_counter <= 0;
                    if (channel_counter == CHANNELS - 1) begin
                        channel_counter <= 0;
                        s_axis_a_tlast <= 1; // last data
                        data_loaded <= 1;
                    end else begin
                      channel_counter <= channel_counter + 1;
                    end
                end else begin
                    index_counter <= index_counter + 1;
                end
                
            end else begin
                //s_axis_a_tvalid <= 0;
                s_axis_a_tlast <= 0;
            end

            if (m_axis_result_tvalid) begin
                result_out <= m_axis_result_tdata;
                valid_out <= 1;
            end

//            if (valid_out) begin
//                data_loaded <= 0;
//                valid_out <= 0;
//            end
        end
    end

endmodule
