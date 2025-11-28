class checker extends component_base;

  sequencer seq_h;
  monitor mon_h[4];

  function new(string n, component_base p=null);
    super.new(n,p);
  endfunction

  // Implement run task for comparison
  // Integrate into VC

endclass
