#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_Editor_CFC CommonFC

package require tdom

#___________________________________________________________________________________________________________________________________________
method GDD_Editor_CFC constructor {{mark 0}} {
 set this(L_rels)  [list]
 set this(L_nodes) [list]

 set this(root_node)      {}
 set this(root_node_type) {}
 set this(root_rel_type)  {}
 set this(L_types)        {}
 set this(GDD_DSL)        {}
}

#___________________________________________________________________________________________________________________________________________
method GDD_Editor_CFC destructor {} {
 foreach t $this(L_types) {$t dispose}
 this inherited
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors GDD_Editor_CFC [list root_node GDD_DSL]
Generate_List_accessor GDD_Editor_CFC L_rels  relations
Generate_List_accessor GDD_Editor_CFC L_nodes nodes

#___________________________________________________________________________________________________________________________________________
method GDD_Editor_CFC Add_or_update_node {name args} {
 if {[gmlObject info exists object $name]} {
   if {[string equal [lindex [gmlObject info classes $name] 0] GDD_Node]} {
    } else {return 2}
  } else {GDD_Node $name
         }

 eval "$name configure $args"
 return 0
}

#___________________________________________________________________________________________________________________________________________
method GDD_Editor_CFC Add_or_update_relation {name args} {
 if {[gmlObject info exists object $name]} {
   if {[string equal [lindex [gmlObject info classes $name] 0] GDD_Relationship]} {
    } else {return 2}
  } else {GDD_Relationship $name
         }

 eval "$name configure $args"
 return 0
}

#________________________________________________________________________________________________________________________________________
proc L_methodes_get_GDD_Editor {} {return [list {get_GDD_DSL { }} {get_relations { }} {get_nodes { }} {get_root_node { }} ] }
proc L_methodes_set_GDD_Editor {} {return [list {set_GDD_DSL {d}} ] }

