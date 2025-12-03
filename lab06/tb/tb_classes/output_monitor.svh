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
class output_monitor extends uvm_component;
    `uvm_component_utils(output_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual switch_bfm bfm;
    uvm_analysis_port #(uart_packet_sent) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(uart_packet_sent r);
        ap.write(r);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        bfm.output_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase



endclass : output_monitor






