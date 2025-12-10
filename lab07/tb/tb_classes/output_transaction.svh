/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class output_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    uart_packet_sent output_packets;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        output_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h,rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        output_packets = copied_transaction_h.output_packets;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("packet_0: %11b  packet_1: %11b port: %1b is_prog: %1b", output_packets.packet_0, output_packets.packet_1, output_packets.port, output_packets.is_prog);
        return s;
    endfunction : convert2string

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        output_transaction RHS;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);
        same = (output_packets == RHS.output_packets) && same;
        return same;
    endfunction : do_compare



endclass : output_transaction
