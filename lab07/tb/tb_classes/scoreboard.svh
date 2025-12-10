class scoreboard extends uvm_subscriber #(output_transaction);
    `uvm_component_utils(scoreboard)

    protected typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;

    protected typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color_t;

    protected test_result_t        test_result = TEST_PASSED;
    protected address_port addr_port_table[$]; // table of address to ports
    protected uart_packet_sent input_packets[$]; //queue of found input packets
    protected uart_packet_sent output_packets[$]; //queue of found output packets
    protected uart_packet_sent uart_good_sent[$]; // queue of sent packages that should appear on output
    protected uart_packet_sent uart_error_found[$]; // queue of packages that should NOT appear on output

    uvm_tlm_analysis_fifo #(input_transaction) in_packets;
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


    //------------------------
    // Input checker
    protected function void input_check(input_transaction temp_packet);
        uart_packet_sent temp_input;
        address_port temp_addr;
        integer queue_index[$];
        
        temp_input.packet_0=temp_packet.packet_0;
        temp_input.packet_1=temp_packet.packet_1;
        temp_input.is_prog=temp_packet.is_prog;

        if((check_packet(temp_packet.packet_0)==0) && (check_packet(temp_packet.packet_1)==0))begin
            queue_index = addr_port_table.find_index() with(item.address == temp_packet.packet_0);
            if(temp_packet.is_prog==1)begin
                if(queue_index.size() > 0)begin 
                    addr_port_table.delete(queue_index[0]);
                end
                temp_addr.address=temp_packet.packet_0;
                temp_addr.port=temp_packet.packet_1[9];
                addr_port_table.push_front(temp_addr);
            end
            else if(temp_packet.is_prog==0)begin
                if(queue_index.size() > 0)begin
                    temp_input.port = addr_port_table[queue_index[0]].port;
                    uart_good_sent.push_front(temp_input);
                end
            end
        end
        else begin
            uart_error_found.push_front(temp_input);
        end                
    endfunction : input_check
    //------------------------
    // Output checker
    protected function void output_check(temp_packet);
        uart_packet_sent temp_packet;
        address_port temp_addr;
        integer queue_index[$];
        queue_index = uart_good_sent.find_index() with((item.packet_0==temp_packet.packet_0)&&(item.packet_1==temp_packet.packet_1)&&(item.port==temp_packet.port||$isunknown(item.port)));
        if(queue_index.size() > 0)begin 
            uart_good_sent.delete(queue_index[0]);
        end
    endfunction : output_check

    function void write(output_transaction t);
        input_transaction temp_packet;
        while(!in_packets.is_empty())begin
            if(!in_packets.try_get(temp_packet))begin
                input_check(temp_packet);
            end
        end
        output_check(t.output_packets);
    endfunction

    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        in_packets = new ("in_packets", this);
    endfunction : build_phase

    // used to modify the color of the text printed on the terminal
    function void set_print_color ( print_color_t c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction
    
    function void print_test_result (test_result_t r);
        if(r == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction

    function void report_phase(uvm_phase phase);
        int i;
        integer queue_index[$];
        super.report_phase(phase);
        
        if(uart_good_sent.size()>0)begin
            test_result=TEST_FAILED;
        end
        print_test_result(test_result);
    endfunction : report_phase

endclass