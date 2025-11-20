class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//---------------------------------
    // Random data generation functions
    
    protected function byte get_data();
    
        bit [1:0] zero_ones;
    
        zero_ones = 2'($random);
    
        if (zero_ones == 2'b00)
            return 8'h00;
        else if (zero_ones == 2'b11)
            return 8'hFF;
        else
            return 8'($random);
    endfunction : get_data
            
    //---------------------------------
    // Generate 11 bit UART packet
    protected function bit [0:10] generate_uart_packet(
        input  bit         err_start,       
        input  bit         err_parity,      
        input  bit         err_stop         
    );
        logic [7:0]data_byte;
        logic parity_bit;
        logic start_bit;
        logic stop_bit;
        logic [0:10] uart_packet;

        start_bit = 1'b0;
        stop_bit  = 1'b1;
        data_byte = get_data();
        parity_bit = ^data_byte;

        if (err_start)  begin
            start_bit  = ~start_bit;
            parity_bit  = ~parity_bit;
        end
        if (err_parity) parity_bit = ~parity_bit;
        if (err_stop)   stop_bit   = ~stop_bit;

        uart_packet = {start_bit, data_byte, parity_bit, stop_bit};

        return uart_packet;
    endfunction : generate_uart_packet

endclass : random_tpgen






