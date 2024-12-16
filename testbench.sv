`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_item extends uvm_sequence_item;
  
  //`uvm_object_utils(seq_item)
  
  rand bit [31:0] data;
  rand bit [7:0] address;
  
  `uvm_object_utils_begin(seq_item)
  `uvm_field_int(data,UVM_ALL_ON)
  `uvm_field_int(address,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
endclass

class sequence_a extends uvm_sequence#(seq_item);
  
  `uvm_object_utils(sequence_a)
  
  seq_item xtns;
  static int no_of_xtns = 0;
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
  task pre_body();
    no_of_xtns++;
    `uvm_info("SEQUENCE_A",$sformatf("no_of_xtns = %0d",no_of_xtns),UVM_LOW)
  endtask
  
  task body();
    repeat(2)
      begin
        xtns = seq_item::type_id::create("xtns");
        assert(xtns.randomize());
        xtns.print();
      end
  endtask 
  
endclass

class main_seq extends uvm_sequence#(seq_item);
  
  `uvm_object_utils(main_seq)
  
  sequence_a seqs_a;
  
  function new(string name = "main_seq");
    super.new(name);
  endfunction
  
  task body();
    repeat(3)
      begin
        seqs_a = sequence_a::type_id::create("seqs_a");
        seqs_a.start(m_sequencer);
      end
  endtask
  
endclass

class sequencer extends uvm_sequencer#(seq_item);
  
  `uvm_component_utils(sequencer)
  
  function new(string name = "sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass

class test extends uvm_test;
  
  `uvm_component_utils(test)
  
  main_seq m_seqs;
  sequencer seqr;
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = sequencer::type_id::create("seqr",this);
    m_seqs = main_seq::type_id::create("m_seqs");
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    m_seqs.start(seqr);
    phase.drop_objection(this);
  endtask 
  
endclass


module tb;
  
  initial 
    begin
      run_test("test");
    end
  
endmodule