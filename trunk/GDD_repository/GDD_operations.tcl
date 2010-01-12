#_________________________________________________________________________________________________________
#___ Here is only defined the operations that can be applied on the GOM structure. _______________________
#___ Operations such as loading or saving will be made by the COmet GOM_editor. __________________________
#___ Set manipulations are also describe, intersection, union etc...The aim is to be able to designate ___
#___ nodes of a particular subgraph and to recognize some properties. ____________________________________
#___ Another kinds of operation are research operations. Usefull to detect a particular node having ______
#___ particular properties. Depending on the research algorithm, some properties can be expressed. _______
#___ E.G. : The resulting node is as close as possible in terms of X from the original node (source of the
#__________ algorythm. ___________________________________________________________________________________
#_________________________________________________________________________________________________________
#_ GDD function goodies
proc Retrieve_equivalents_implem_of {gdd PM cond_pivot cond_final_node {with_original 0}} {
#set req "NODE()->REL(type~= GDD_inheritance && type!~=GDD_extension)*->\$p($cond_pivot)<-REL(type~=GDD_inheritance && type!=GDD_restriction)*<REL(type~=GDD_implementation)<-\$n($cond_final_node)"
 set req "NODE()->REL(type~= GDD_inheritance)*->\$p($cond_pivot)<-REL(type~=GDD_inheritance && type!=GDD_restriction)*<REL(type~=GDD_implementation)<-\$n($cond_final_node)" 
 #puts "$gdd QUERY \"?n, p : $PM : $req\""
 $gdd QUERY "?n, p : $PM : $req"
 #puts "  OK"
 set L_res [$gdd get_Result]
 #puts "  L_res : {$L_res}"
   Invert_list L_res
 set nL {}
 if {$with_original} {set L_already {}} else {set L_already $PM}
 foreach res $L_res {
   set L_tmp [lindex [lindex $res 2] 1]
     set L_put $L_tmp
	 Sub_list L_put     $L_already
	 Add_list L_already $L_tmp
   if {[llength $L_put]} {lappend nL [list [lindex $res 1] $L_put]}
  }
 
 return $nL 
}

#_________________________________________________________________________________________________________
#_________________________________ Let's define a GDD-operator class _____________________________________
#_________________________________________________________________________________________________________
method GDD_operator constructor {GDD_root_node} {
 set this(GDD_root_node) $GDD_root_node
 set this(L_set_nodes)   [list]
}

#_________________________________________________________________________________________________________
#________________________________________ Obtaining a subgraph ___________________________________________
#_________________________________________________________________________________________________________
# cond are expressed considering that :
#   - node is the considered node
#   - rel  is the considered relationship
#   - mark is the current mark
#   - All op_if_XXX_YYY return a set of GDD_node
method GDD_operator Process_sub_graph {L_root mark \
                                       cond_node op_if_node_ok op_if_node_not_ok
                                       cmd_get_rel cond_rel op_if_rel_ok op_if_rel_not_ok} {
 set rep [list]
 foreach node $L_root {
   set node $root
   if {[eval $cond_node]} {set new_rep [eval $op_if_node_ok]
                           set rep [concat $rep $new_rep]
                          } else {set new_rep [eval $op_if_node_not_ok]
                                  set rep [concat $rep $new_rep]
                                 }
   set L_rel [eval $cmd_get_rel]
   foreach rel $L_rel {
     if {[eval $cond_rel]} {
       set new_rep [eval $op_if_rel_ok]
       set rep [concat $rep $new_rep]
      } else {set new_rep [eval $op_if_rel_not_ok]
              set rep [concat $rep $new_rep]}
    }
  }
 return $rep
}

#_________________________________________________________________________________________________________
#___________________________________________ Cleaning marks ______________________________________________
#_________________________________________________________________________________________________________
method GDD_operator Cleaning_marks {root} {
 set cond_node           {$node Has_no_mark}
   set op_if_node_ok     {}
   set op_if_node_not_ok {$node set_marks ""}
 set cmd_get_rel         {this get_source_relationships}
 set cond_rel            {1}
   set op_if_rel_ok      {this Get_sub_graph [$rel get_L_node_dest]}
   set op_if_rel_not_ok  {}
   
 this Process_sub_graph $root {}                                     \
                        $cond_node $op_if_node_ok $op_if_node_not_ok \
                        $cmd_get_rel                                 \
                        $cond_rel $op_if_rel_ok $op_if_rel_not_ok
}



