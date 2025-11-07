package switch_tb_pkg;

    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;

    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color_t;

    typedef struct {
        bit [10:0] packet_0;
        bit [10:0] packet_1;
        time       timestamp;
        logic      port;
        bit        is_prog;
    } uart_packet_sent;

    typedef struct {
        logic [10:0] address;
        logic        port;
    } address_port;

        //------------------------
    //      Scoreboard       |
    //------------------------

    //-------------------------
    //  Packet checker (0 no err)
    //  Packet checker (1 bad start bit)
    //  Packet checker (2 bad parity)
    //  Packet checker (3 bad stop bit)
    //-------------------------

    function bit [1:0] check_packet(
        input bit [10:0] packet_test
    );
        if(packet_test[10]!=0)begin
            return 1;
        end
        if(packet_test[1]!=^packet_test[10:2])begin
            return 2;
        end
        if(packet_test[0]!=1)begin
            return 3;
        end
        return 0;
    endfunction
endpackage
