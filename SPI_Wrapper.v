module SinglePort_SRAM #(
    parameter MEM_WIDTH = 8,
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input clk,
    input rst_n,
    input rx_valid,           // Data on din is valid when high
    input [9:0] din,          // Operation + data
    output reg [7:0] dout,    // Output data
    output reg tx_valid       // High when dout is valid
);

    reg [MEM_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    reg [ADDR_SIZE-1:0] address;
    reg [MEM_WIDTH-1:0] data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout     <= 8'b0;
            tx_valid <= 1'b0;
            address  <= {ADDR_SIZE{1'b0}};
            data     <= {MEM_WIDTH{1'b0}};
        end else begin
            if (rx_valid) begin
                case (din[9:8])
                    2'b00: begin
                        address <= din[7:0]; // Set address
                    end
                    2'b01: begin
                        data <= din[7:0];
                        mem[address] <= din[7:0]; // Write to memory
                    end
                    2'b10: begin
                        address <= din[7:0]; // Set address for reading
                    end
                    2'b11: begin
                        dout <= mem[address]; // Read from memory
                        tx_valid <= 1'b1;
                    end
                    default: tx_valid <= 1'b0; 
                endcase
            end else begin
                tx_valid <= 1'b0;
            end
        end
    end
endmodule


module SPI_Slave(
    input clk,
    input rst_n,
    input MOSI,
    input SS_n,
    input tx_valid,
    input [7:0] tx_data,
    output reg MISO,
    output reg rx_valid,
    output reg [9:0] rx_data
);
    reg [9:0] parallel_data;
    reg [3:0] counter; //for counting number of bits in serial-to-parallel
    reg [3:0] read_counter;
    reg CHECK_READ; //0 for add, 1 for data;
(* fsm_encoding = "gray" *) reg [2:0] current;



    reg [2:0] next;

    reg [7:0] tx_shift_reg;
    reg [3:0] tx_bit_cnt;
    reg start_tx;
    
    parameter IDLE= 3'b000;
    parameter CHK_CMD = 3'b001;
    parameter WRITE = 3'b010;
    parameter READ_ADD = 3'b011;
    parameter READ_DATA = 3'b100;

    //state memory
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current <= IDLE;
        end else begin
            current <= next;
        end
    end

    //NEXT STATE LOGIC
    always @(*) begin
        case(current) 
            IDLE:
                if(!SS_n)
                    next = CHK_CMD;
                else
                    next = IDLE;
            
            CHK_CMD:
                if (SS_n)
                    next = IDLE;
                else if(!SS_n && !MOSI)
                    next = WRITE; 
                else if(!SS_n && MOSI) begin
                    if(!CHECK_READ)     
                        next = READ_ADD;
                    else 
                        next = READ_DATA;               
                end

            WRITE:
                if(SS_n)
                    next = IDLE;
                else begin
                    next = WRITE;
                end
            
            READ_ADD:
                if (SS_n) begin
                    next = IDLE; 
                end else if (!SS_n /* add condition to check read*/ ) begin
                    next = READ_ADD; 
                end

            READ_DATA:
                if (SS_n) begin
                    next = IDLE; 
                end else if (!SS_n /* add condition to check read*/ ) begin
                    next = READ_DATA;   
                end
        endcase        
    end

    //OUTPUT
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_valid      <= 0;
            MISO          <= 0;
            rx_data       <= 0;
            counter       <= 0;
            tx_shift_reg  <= 8'b0;
            tx_bit_cnt    <= 0;
            start_tx      <= 0;
            CHECK_READ    <= 0;
            parallel_data <= 0;
            //read_counter  <= 0;
        end else begin
            case(current) 
                IDLE: begin
                    rx_valid      <= 0;
                    rx_data       <= 0;
                    counter       <= 0;
                    tx_bit_cnt    <= 0;
                    start_tx      <= 0;
                    //CHECK_READ    <= 0;
                    parallel_data <= 0;
                    //read_counter  <= 0;
                end 

                CHK_CMD: begin
                    //counter <= 0;
                end

                WRITE: begin
                    parallel_data <= {parallel_data[8:0], MOSI};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data <= parallel_data;
                        counter <= 0;
                        //SS_n = 1'b1;
                    end else begin
                        rx_valid <= 1'b0;
                    end
                end 

                READ_ADD: begin 
                    //parallel_data <= tx_data;                    
                    parallel_data <= {parallel_data[8:0], MOSI};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data <= parallel_data;
                        counter <= 0;
                        CHECK_READ <= 1;
                        //SS_n = 1'b1;
                    end else begin
                        rx_valid <= 1'b0;
                    end
                end

                READ_DATA: begin
                    //first we need to get parallel data as usual for read data command (full 10 clk cycles per usual)
                    parallel_data <= {parallel_data[8:0], MOSI};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data  <= parallel_data;
                        counter  <= 0;
                    end else begin
                        rx_valid <= 1'b0;
                    end
                
                    if (tx_valid) begin
                        tx_shift_reg <= tx_data;
                        start_tx     <= 1;
                    end
                
                    if (start_tx) begin
                        MISO <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0}; // Shift left
                        tx_bit_cnt <= tx_bit_cnt + 1;

                        if (tx_bit_cnt == 7) begin
                            tx_bit_cnt <= 0;
                            start_tx   <= 0;
                            CHECK_READ <= 0;
                        end
                    end
                end

                default: rx_valid <= 1'b0;

            endcase
        end
    end

endmodule


module SPI_Wrapper(
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
);

    wire [7:0] tx_data;
    wire [9:0] rx_data;
    wire tx_valid;
    wire rx_valid;

    SPI_Slave SPI(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .MISO(MISO),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    SinglePort_SRAM #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256),
        .ADDR_SIZE(8)
    ) RAM (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .din(rx_data),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );

endmodule

