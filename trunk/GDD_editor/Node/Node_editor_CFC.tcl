#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit NodeEditor_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method NodeEditor_CFC constructor {{mark 0}} {
 set this(node_name)    ""
 set this(descriptions) ""
 set this(factory_req)  ""
 set this(node_type)    ""
 set this(L_factories)  [list]
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors NodeEditor_CFC [list node_name node_type L_source_rel L_dest_rel descriptions factory_req L_factories]

#___________________________________________________________________________________________________________________________________________
method NodeEditor_CFC Edit {n} {
 if {[lsearch [gmlObject info classes $n] GDD_Node]!=-1} {
   this set_L_factories   [$n get_L_factories]
   this set_descriptions  [$n get_descriptions]
   this set_factory_req   [$n get_factory_req]
   this set_node_name     $n
   this set_node_type     [$n get_type]
  }
}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_CFC Sub_node {n} {
 puts "$objName Sub_node $n"
 if {[gmlObject info exists object $n]} {
   set L_classes [gmlObject info classes $n]
   if {[lsearch $L_classes GDD_Node] != -1} {
     $n dispose
    }
  }
}

#________________________________________________________________________________________________________________________________________
proc L_methodes_get_NodeEditor {} {return [list {get_node_name {}}  {get_node_type {}}  {get_descriptions {}}  {get_factory_req {}}  {get_L_factories {}}  ] }
proc L_methodes_set_NodeEditor {} {return [list {set_node_name {v}} {set_node_type {v}} {set_descriptions {v}} {set_factory_req {v}} {set_L_factories {v}} {Edit {n}} {Sub_node {n}} ]}

