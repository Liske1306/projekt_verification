class scoreboard;

    local virtual switch_bfm bfm;

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

    local test_result_t        test_result = TEST_PASSED;
    local address_port addr_port_table[$]; // table of address to ports
    local uart_packet_sent input_packets[$]; //queue of found input packets
    local uart_packet_sent output_packets[$]; //queue of found output packets
    local uart_packet_sent uart_good_sent[$]; // queue of sent packages that should appear on output
    local uart_packet_sent uart_error_found[$]; // queue of packages that should NOT appear on output
    
    function new (virtual switch_bfm b);
        bfm = b;
    endfunction : new
    local task automatic read_uart(//weird bugs unusable
        ref uart_packet_sent temp_packet,
        ref logic signal
        ); 
        begin
            int i;
            repeat(8)@(posedge bfm.clk);
            temp_packet.packet_0[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge bfm.clk);
                temp_packet.packet_0[i]=signal;
            end
            @(negedge signal);
            repeat(8)@(posedge bfm.clk);
            temp_packet.packet_1[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge bfm.clk);
                temp_packet.packet_1[i]=signal;
            end
            repeat(8)@(posedge bfm.clk);
        end
    endtask
    
    local task input_find();
        uart_packet_sent temp_packet_sin;
        int i;
        forever begin
            temp_packet_sin.is_prog=bfm.prog;
            @(negedge bfm.sin);
            read_uart(temp_packet_sin,bfm.sin);
            temp_packet_sin.timestamp=$time;
            input_packets.push_front(temp_packet_sin);
        end
    endtask : input_find
    
    local task output_find();
        integer i;
        integer queue_index[$];
        uart_packet_sent temp_packet;
        forever begin
            @(negedge bfm.sout0 or negedge bfm.sout1);
            temp_packet.timestamp=$time;
            if(bfm.sout0==0 && bfm.sout1==0) begin  //check which port is active (err if both or none)
            end
            else if(bfm.sout0==0) begin 
                temp_packet.port=0; //save data from sout0
                read_uart(temp_packet,bfm.sout0);
                output_packets.push_front(temp_packet);
            end
            else if(bfm.sout1==0) begin
                temp_packet.port=1; //save data from sout1
                read_uart(temp_packet,bfm.sout1);
                output_packets.push_front(temp_packet);
            end
            else begin
            end
        end
    endtask : output_find
    //------------------------
    // Input checker
    local task input_check();
        uart_packet_sent temp_packet;
        address_port temp_addr;
        integer queue_index[$];
        forever begin
            @(posedge bfm.clk);
            if(input_packets.size() > 0)begin
                temp_packet=input_packets.pop_front();
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
                            temp_packet.port = addr_port_table[queue_index[0]].port;
                            uart_good_sent.push_front(temp_packet);
                        end
                    end
                end
                else begin
                    uart_error_found.push_front(temp_packet);
                end                
            end
        end
    endtask : input_check
    //------------------------
    // Output checker
    local task output_check();
        uart_packet_sent temp_packet;
        address_port temp_addr;
        integer queue_index[$];
        forever begin
            @(posedge bfm.clk);
            if(output_packets.size() > 0)begin
                temp_packet=output_packets.pop_front();
                queue_index = uart_good_sent.find_index() with((item.packet_0==temp_packet.packet_0)&&(item.packet_1==temp_packet.packet_1)&&(item.timestamp==temp_packet.timestamp)&&(item.port==temp_packet.port||$isunknown(item.port)));
                if(queue_index.size() > 0)begin 
                    uart_good_sent.delete(queue_index[0]);
                end
                else begin
                    queue_index = uart_good_sent.find_index() with((item.timestamp==temp_packet.timestamp));
                    if(queue_index.size() > 0)begin 
                        test_result=TEST_FAILED;
                    end
                end
            end
            if(uart_error_found.size() > 0)begin
                
            end 
        end
    endtask : output_check

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

    task execute();
        fork
            input_find();
            output_find();
            output_check();
            input_check();
        join_none
    endtask

    function void print_result();
        int i;
        integer queue_index[$];
        /*for(i=0;i<uart_good_sent.size();i++) begin
            $display("ERR packet that did not appear,");
            $display("packet0:%b", uart_good_sent[i].packet_0);
            $display("packet1:%b", uart_good_sent[i].packet_1);
            $display("port:%b", uart_good_sent[i].port);
            $display("time:%d", uart_good_sent[i].timestamp);
            $display("Err packet_0? = %d",check_packet(uart_good_sent[i].packet_0));
            $display("Err packet_1? = %d",check_packet(uart_good_sent[i].packet_1));
            queue_index = addr_port_table.find_index() with(item.address == uart_good_sent[i].packet_0);
            if(queue_index.size() > 0)begin 
                $display("Address OK");
            end
            else begin
                $display("No address!");
            end
            $display("------------------------------------");
        end
        for(i=0;i<uart_error_found.size();i++) begin
            $display("ERR packet that should not appear");
            $display("packet0:%b", uart_error_found[i].packet_0);
            $display("packet1:%b", uart_error_found[i].packet_1);
            $display("port:%b", uart_error_found[i].port);
            $display("time:%d", uart_good_sent[i].timestamp);
            $display("Check if err packet_0 = %d",check_packet(uart_error_found[i].packet_0));
            $display("Check if err packet_1 = %d",check_packet(uart_error_found[i].packet_1));
            queue_index = addr_port_table.find_index() with(item.address == uart_error_found[i].packet_0);
            if(queue_index.size() > 0)begin 
                $display("Address OK");
                $display("Address = %h, Port= %d",addr_port_table[queue_index[0]].address,addr_port_table[queue_index[0]].port);
            end
            else begin
                $display("Address ERR");
            end
            $display("------------------------------------");
        end*/
        if(uart_good_sent.size()>0)begin
            test_result=TEST_FAILED;
        end
        print_test_result(test_result);
    endfunction
endclass