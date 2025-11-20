virtual class base_tpgen extends uvm_component;

    // The macro is not there as we never instantiate/use the base_tpgen
    //    `uvm_component_utils(base_tpgen)
    
    protected virtual switch_bfm bfm;
    
    //------------------------------------------------------------------------------
    // constructor
    //------------------------------------------------------------------------------
        function new (string name, uvm_component parent);
            super.new(name, parent);
        endfunction : new
        
    //------------------------------------------------------------------------------
    // function prototypes
    //------------------------------------------------------------------------------
        pure virtual protected function bit [0:10] generate_uart_packet(
        input  bit         err_start,       
        input  bit         err_parity,      
        input  bit         err_stop 
        );
        pure virtual protected function byte get_data();
    
    //------------------------------------------------------------------------------
    // build phase
    //------------------------------------------------------------------------------
        function void build_phase(uvm_phase phase);
            if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
                $fatal(1,"Failed to get BFM");
        endfunction : build_phase
    
    //------------------------------------------------------------------------------
    // run phase
    //------------------------------------------------------------------------------
        task run_phase(uvm_phase phase);
        integer i;
        integer report_queue_index[$];

        bfm.sin = 1;
        bfm.prog = 1;
        bfm.rst_n = 0;

        repeat(32)@(posedge bfm.clk);
        bfm.rst_n = 1;

        bfm.packet_0 = 11'b01111001101; //dodanie adresu port 1(sprawdzenie czy podczas prog nie wypisuje)
        bfm.packet_1 = 11'b01000000011; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111000001; //dodanie adresu port 0
        bfm.packet_1 = 11'b00000000001; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //dodanie adresu min
        bfm.packet_1 = 11'b00000000001; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111111101; //dodanie adresu max
        bfm.packet_1 = 11'b00000000001; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.prog = 0;

        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył port 0
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111001101; //prawidłowy przesył port 1
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył adrr max
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //prawidłowy przesył adrr min
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        bfm.packet_1 = 11'b01111111101;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //prawidłowy przesył dana min
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00111110101; //przesyl na nieistniejacy adres (nie obchodzi go adres)
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        
        bfm.packet_0 = 11'b01111000001; //bledny bit startu(ciagly przesyl paczek err)
        repeat(50)begin
        bfm.packet_1 = generate_uart_packet(1,0,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit parity(ciagly przesyl paczek err)
        repeat(500)begin
        bfm.packet_1 = generate_uart_packet(0,1,0);
        //$display("%11b",packet_1);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit stopu(ciagly przesyl paczek err)
        repeat(500)begin
        bfm.packet_1 = generate_uart_packet(0,0,1);
        //$display("%11b",packet_1);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit startu opoznienie
        repeat(50)begin
        repeat(352)@(posedge bfm.clk);
        bfm.packet_1 = generate_uart_packet(1,0,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit parity opoznienie
        repeat(50)begin
        repeat(352)@(posedge bfm.clk);
        bfm.packet_1 = generate_uart_packet(0,1,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit stopu opoznienie
        repeat(50)begin
        repeat(352)@(posedge bfm.clk);
        bfm.packet_1 = generate_uart_packet(0,0,1);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.rst_n = 0;
        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        bfm.packet_1 = 11'b01111111101;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.prog = 1;

        bfm.packet_0 = 11'b01111111101; //dodanie adresu max
        bfm.packet_1 = 11'b00000000001; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        
        repeat(50) repeat (16) @(posedge bfm.clk);

    
            phase.drop_objection(this);
    
        endtask : run_phase
    
    
    endclass : base_tpgen
    