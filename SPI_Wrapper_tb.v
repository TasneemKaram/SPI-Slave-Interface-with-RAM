
module SPI_Wrapper_tb();

    reg clk;
    reg rst_n;
    reg SS_n;
    reg MOSI;
    wire MISO;

    // Instantiate the SPI Wrapper
    SPI_Wrapper uut (
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    reg [9:0] read_val;

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    task spi_send;
        input [9:0] data;
        integer i;
        begin
            SS_n = 0;
            repeat(2)@(negedge clk); 

            for (i = 9; i >= 0; i = i - 1) begin
                MOSI <= data[i];
                @(negedge clk);
            end
        end
    endtask

    task spi_read;
        output [9:0] data_out;
        integer i;
        begin
            data_out = 10'b0;
            SS_n = 0;
            @(negedge clk); 

            for (i = 9; i >= 0; i = i - 1) begin
                MOSI <= 1'b0; // dummy bits
                @(negedge clk);
                data_out[i] <= MISO;
            end

            SS_n = 1;
            repeat(5) @(negedge clk);
        end
    endtask


    initial begin
        clk   = 0;
        rst_n = 0;
        SS_n  = 1;
        MOSI  = 0;

        repeat(5) @(negedge clk);
        rst_n = 1;
        repeat(2) @(negedge clk);

        // 1. Set Address (Opcode = 2'b00), Address = 0x01
        MOSI = 0;
        spi_send(10'b00_00000001);

        SS_n = 1; 
        repeat(2) @(negedge clk);

        // 2. Write Data (Opcode = 2'b01), Data = 0xAB
        MOSI = 0;
        spi_send(10'b01_10101011);

        SS_n = 1; 
        repeat(2) @(negedge clk);

        // 3. Set Address for Read (Opcode = 2'b10), Address = 0x01
        MOSI = 1;
        spi_send(10'b10_00000001);

        SS_n = 1; 
        repeat(2) @(negedge clk);

        // 4. Trigger Read (Opcode = 2'b11), data irrelevant
        MOSI = 1;
        spi_send(10'b11_00000000);

        // 5. Dummy transfer to receive read data
        spi_read(read_val);  // Send 10 dummy bits to read 8 data bits out

        // Finish simulation
        repeat(5) @(negedge clk);
        $finish;
    end

endmodule