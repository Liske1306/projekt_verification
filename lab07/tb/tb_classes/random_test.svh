class random_test extends uvm_test;
    `uvm_component_utils(random_test)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    env env_h;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        env_h = env::type_id::create("env_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// end-of-elaboration-phase
//------------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        input_transaction tmp;               // transaction object to check the type generated

        this.print(uvm_default_table_printer); // print test env topology

        // printing the type of the transaction generated
        tmp = input_transaction::type_id::create("input_transaction", this);
        `uvm_info("COMMAND TRANSACTION", tmp.get_type_name(), UVM_NONE)
    endfunction : end_of_elaboration_phase

endclass


