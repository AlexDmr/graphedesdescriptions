source graphviz.tcl
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Canvas_graph_GDD constructor {dsl_gdd tk_root graphdot_IP graphdot_port} {
 set this(graphdot_IP)   $graphdot_IP
 set this(graphdot_port) $graphdot_port
 set this(dsl_gdd)       dsl_gdd
 set this(tk_root)       $tk_root
 
 set this(canvas)        $this(tk_root)._$objName
 set this(gc)            ${objName}_GC
 GraphComet $this(gc)
 
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors Canvas_graph_GDD [list graphdot_IP graphdot_port canvas]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Canvas_graph_GDD Query_update {Q} {
# Destroy previous objects
 $this(canvas) delete $objName

# Call the graph server to build the new graph
 set rep [$this(gc) GDD_query_to_canvas_commands $this(dsl_gdd) $objName $this(graphdot_IP) $this(graphdot_port) $Q]
 set c $this(canvas)
 eval $rep
 
# Bind some interaction
 $this(canvas) bind <>
}
