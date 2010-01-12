#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit RelationEditor_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method RelationEditor_CFC constructor {{mark 0}} {
 set this(node)       {}
 set this(L_rels_in)  {}
 set this(L_rels_out) {}
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors RelationEditor_CFC [list L_rels_in L_rels_out]

#___________________________________________________________________________________________________________________________________________
method RelationEditor_CFC Edit {n} {
 if {[lsearch [gmlObject info classes $n] GDD_Node]!=-1} {
   set this(node) $n
   this set_L_rels_in  [$n get_L_source_rel]
   this set_L_rels_out [$n get_L_dest_rel]
  }
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_CFC Add_related_node {n n_type rel_type src_dst} {
# Do n still exists ? If not create it
 if {[gmlObject info exists object $n]} {} else {GDD_Node $n
                                                 $n set_type $n_type
                                                }

# Do this(node) or n has a n_type relation ? If not create it, if yes use it !
 if {[string equal $src_dst dest]} {set dst_src source} else {set dst_src dest}
 set r [$this(node) get_${dst_src}_rels_typed $rel_type]
 if {[string equal $r {}]} {
   set r [$n get_${src_dst}_rels_typed $rel_type]
   if {[string equal $r {}]} {set r "${rel_type}_$this(node)_${n}"
                              GDD_Relationship $r
                              $r set_type $rel_type
                             }
  }

# Plug all together
 $n          Add_L_${src_dst}_rel $r
 $this(node) Add_L_${dst_src}_rel $r
 $r          Add_L_${src_dst}_nodes $n
 $r          Add_L_${dst_src}_nodes $this(node)

# Re-Edit the current node
 this Edit $this(node)
}

#________________________________________________________________________________________________________________________________________
proc L_methodes_get_RelationEditor {} {return [list {get_L_rels_in {}}  {get_L_rels_out {}}  ] }
proc L_methodes_set_RelationEditor {} {return [list {set_L_rels_in {v}} {set_L_rels_out {v}} {Edit {n}} {Add_related_node {n n_type rel_type src_dst}}] }

