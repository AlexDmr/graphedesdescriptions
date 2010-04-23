#_________________________________________________________________________________________________________
#___ Here is only defined the GML-TCL structure of the GOM. ______________________________________________
#___ Operations such as loading or saving will be made by the COmet GOM_editor. __________________________
#___ Fundamontaly, GOM structure is docomposed in the following parts : __________________________________
#_____ * Nodes         : Describes an interactive system. ________________________________________________
#_____ * Nodes_Types   : Describes a type of node. Nodes_Types are classified in an ontological __________
#_______________________ structure with a "kind of" relationship. Each of them describes what kind of ____
#_______________________ informations will be present in the node and how it will be expressed. __________
#_____ * Relationships : Describes the relationships between 2 or more nodes. ____________________________
#_______________________ A relationship is typed. ________________________________________________________
#_____ * Rel_Types     : Describes a type of relationships. Rel_types are classified in an ontological ___
#_______________________ structure with a "kind of" relationship. Each of them describes what kind of ____
#_______________________ constraints will be present in the relationship and how it will be expressed. ___
#_________________________________________________________________________________________________________

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method Markable_entity constructor {} {
 set this(L_marks) [list]
 set this(type)    {}
 set this(descr)   {}
}
#_________________________________________________________________________________________________________
Generate_accessors Markable_entity type

#_________________________________________________________________________________________________________
method Markable_entity Has_MetaData {var}     {return [info exists this(metadata,$var)]}
method Markable_entity get_MetaData {} {
 set L {}
 set p [string length metadata,]
 foreach {var val} [array get this metadata,*] {
   lappend L [list [string range $var $p end] $val]
  }
 return $L
}
method Markable_entity Add_MetaData {var val} {set this(metadata,$var) $val}
method Markable_entity Sub_MetaData {var}     {if {[catch "unset this(metadata,$var)" res]} {return 0} else {return 1}}
method Markable_entity Val_MetaData {var}     {return $this(metadata,$var)}

#_________________________________________________________________________________________________________
method Markable_entity configure args {
 set L_cmd [split $args -]
 foreach cmd $L_cmd {
   if {[string equal $cmd {}]} {continue}
   if {[string equal [string index $cmd 0] | ]} {
     set cmd [string range $cmd 1 end]
     eval $cmd
    } else {eval "$objName $cmd"}
  }
}

#_________________________________________________________________________________________________________
method Markable_entity Has_for_marks {m} {
 if {[lsearch $this(L_marks) $m] == -1} {return 0}
 return 1
}
#_________________________________________________________________________________________________________
method Markable_entity Sub_marks {L_m} {
 foreach m $L_m {
   set pos [lsearch $this(L_marks) $m]
   if {[$pos != -1]} {set this(L_marks) [lreplace $this(L_marks) $pos $pos]}
  }
}
#_________________________________________________________________________________________________________
method Markable_entity Add_marks {L_m} {
 set this(L_marks) [concat $this(L_marks) $L_m]
 return $this(L_marks)
}
#_________________________________________________________________________________________________________
method Markable_entity set_marks {L_m} {
 return [set this(L_marks) $L_m]
}
#_________________________________________________________________________________________________________
method Markable_entity get_marks {} {
 return $this(L_marks)
}
#_________________________________________________________________________________________________________
method Markable_entity Has_no_mark {} {
 set length [llength $this(L_marks)]
 if {$length > 0} {return 0}
 return 1
}
#_________________________________________________________________________________________________________
method Markable_entity get_descriptions {}  {return $this(descr)}
method Markable_entity set_descriptions {d} {set this(descr) $d}

#_________________________________________________________________________________________________________
#_______________________________________ Nodes_types structure ___________________________________________
#_________________________________________________________________________________________________________
method GDD_NodeType constructor {id_nodetype {descr {}}} {
 set this(id_node_type) $id_node_type
 set this(descr)        $descr
}
#_________________________________________________________________________________________________________
method GDD_NodeType get_id_node_type {} {return $this(id_node_type)}
#_________________________________________________________________________________________________________
method GDD_NodeType get_descr {}  {return $this(descr)}
method GDD_NodeType set_descr {d} {set this(descr) $d}

#_________________________________________________________________________________________________________
#__________________________________________ Nodes structure ______________________________________________
#_________________________________________________________________________________________________________
inherit GDD_Node Markable_entity
method GDD_Node constructor {} {
 this inherited
   set this(factory_req)  {}
   set this(L_source_rel) {}
   set this(L_dest_rel)   {}
   set this(L_factories)  {}
   set this(ptf)          *
   set this(L_attributs)  {}
 return $objName
}

#_________________________________________________________________________________________________________
method GDD_Node dispose {} {
 foreach r [this get_L_source_rel] {
   $r Sub_L_source_nodes $objName
   if {[llength [$r get_L_source_nodes]]==0} {$r dispose}
  }
 foreach r [this get_L_dest_rel]   {
   $r Sub_L_dest_nodes   $objName
   if {[llength [$r get_L_dest_nodes]]  ==0} {$r dispose}
  }

 this inherited
}
#_________________________________________________________________________________________________________
method GDD_Node get_name {} {return $objName}                      

#_________________________________________________________________________________________________________
Generate_accessors     GDD_Node [list factory_req ptf]
Generate_List_accessor GDD_Node L_source_rel L_source_rel
Generate_List_accessor GDD_Node L_dest_rel   L_dest_rel
Generate_List_accessor GDD_Node L_factories  L_factories
Generate_List_accessor GDD_Node L_attributs  L_attributs

#_________________________________________________________________________________________________________
method GDD_Node get_source_rels_typed {t} {return [this get_rels_typed $t [this get_L_source_rel]]}
method GDD_Node get_dest_rels_typed   {t} {return [this get_rels_typed $t [this get_L_dest_rel]]}
method GDD_Node get_rels_typed {t L} {
 set L_res {}
 foreach r $L {
   if {[string equal $t [$r get_type]]} {lappend L_res $r}
  }
 return $L_res
}

#_________________________________________________________________________________________________________
#________________________________________ Rel_types structure ____________________________________________
#_________________________________________________________________________________________________________
method GDD_RelType constructor {id_reltype {descr {}}} {
 set this(id_reltype) $id_reltype
 set this(descr)      $descr

# Let's define the list of rel_type wich are specialisation of this rel_type
 set this(L_specialized_rel) [list]
} 
#_________________________________________________________________________________________________________
method GDD_RelType get_id_reltype {} {return $this(id_reltype)}
#_________________________________________________________________________________________________________
method GDD_RelType get_descr {}  {return $this(descr)}
method GDD_RelType set_descr {d} {set this(descr) $d}
#_________________________________________________________________________________________________________
method GDD_RelType Add_specialisations {L_rt} {Add_list this(L_specialized_rel) $L_rt]}
method GDD_RelType Add_specialisations {L_rt} {Sub_list this(L_specialized_rel) $L_rt]}
method GDD_RelType set_specialisations {L_rt} {set this(L_specialized_rel) $L_rt}

#_________________________________________________________________________________________________________
#______________________________________ Relationships structure __________________________________________
#_________________________________________________________________________________________________________
inherit GDD_Relationship Markable_entity
method GDD_Relationship constructor {} {
 this inherited
   set this(L_source_nodes) {}
   set this(L_dest_nodes)   {}
   set this(card)           1
   set this(name)           $objName
 return $objName
}

#_________________________________________________________________________________________________________
method GDD_Relationship dispose {} {
 foreach n [this get_L_source_nodes] {$n Sub_L_source_rel $objName}
 foreach n [this get_L_dest_nodes]   {$n Sub_L_dest_rel   $objName}

 this inherited
}

#_________________________________________________________________________________________________________
Generate_List_accessor GDD_Relationship L_source_nodes L_source_nodes
Generate_List_accessor GDD_Relationship L_dest_nodes   L_dest_nodes
Generate_accessors GDD_Relationship [list card name]
