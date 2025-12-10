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
class input_transaction extends uvm_transaction;
    `uvm_object_utils(input_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    rand logic [10:0] packet_0;
    rand logic [10:0] packet_1;
    rand logic is_rst;
    rand logic is_prog;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {        
        packet_1 dist { [11'b00000000000:11'b01111111111]:=1 };
    }
    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        input_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        packet_0 = copied_transaction_h.packet_0;
        packet_1 = copied_transaction_h.packet_1;
        is_rst = copied_transaction_h.is_rst;
        is_prog = copied_transaction_h.is_prog;

    endfunction : do_copy


    function input_transaction clone_me();
        
        input_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        input_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            packet_0 == compared_transaction_h.packet_0 &&
            packet_1 == compared_transaction_h.packet_1 &&
            is_rst == compared_transaction_h.is_rst &&
            is_prog == compared_transaction_h.is_prog;

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("packet_0: %11b  packet_1: %11b is_rst: %1b is_prog: %1b", packet_0, packet_1, is_rst, is_prog);
        return s;
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : input_transaction
