#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation____________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit RelationEditor_LM_LP Logical_presentation
#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP constructor {name descr args} {
 set this(init_ok) 0
 this inherited $name $descr
 this set_L_actives_PM {}
   set this(num_sub) 0
 
 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
   set this(comet_name) $comet_name

# Nesting parts
 set this(Interleaving)  "${objName}_nested_interleaving"
  set this(cont_new_node)    "${objName}_nested_cont_new_node"
    set this(new_node_name)    "${objName}_nested_new_node_name"
    set this(new_node_type)    "${objName}_nested_new_node_type"
    set this(new_rel_type)     "${objName}_nested_new_rel_type"
    set this(new_node_src_dst) "${objName}_nested_new_node_src_dst"
    set this(new_node_OKbt)    "${objName}_nested_new_node_OKbt"
  set this(InterL_nodes)   "${objName}_nested_InterL_info_nodes"
   set this(DC_nodes_in)    "${objName}_nested_DC_info_nodes_in"
   set this(DC_nodes_out)   "${objName}_nested_DC_info_nodes_out"

# DSL description
 set L_tmp [list GDD_C&T GDD_AUI GDD_CUI GDD_FUI]
   set L_node_type {}
   foreach e $L_tmp {lappend L_node_type "\"$e\""}
   set L_node_type [join $L_node_type ,]
 set L_tmp [list GDD_relation GDD_inheritance GDD_restriction GDD_specialization GDD_extension GDD_concretization GDD_implementation GDD_composition GDD_encapsulation  GDD_use]
   set L_rel_type {}
   foreach e $L_tmp {lappend L_rel_type "\"$e\""}
   set L_rel_type [join $L_rel_type ,]


 append str "$this(Interleaving) = |||(, $this(cont_new_node) = C_Cont(, $this(new_node_name)=C_Spec()"
 append str                                                           ", $this(new_node_type)=C_DC(,$L_node_type)"
 append str                                                           ", $this(new_node_src_dst)=C_DC(, \"source of\", \"target of\")"
 append str                                                           ", $this(new_rel_type)=C_DC(,$L_rel_type)"
 append str                                                          ")"
 append str                           ", $this(InterL_nodes)=|||(, $this(DC_nodes_in)  = C_DC()"
 append str                                                     ", $this(DC_nodes_out) = C_DC()"
 append str                                                    ")"
 append str                          ")"

 set L_nested [interpretor_DSL_comet_interface Interprets $str $objName]
# puts "$objName Add_nested_daughters [lindex $L_nested 1] $this(Interleaving) $this(Interleaving) _LM_LP"
 this Add_nested_daughters [lindex $L_nested 1] $this(Interleaving) $this(Interleaving) _LM_LP
# puts "_________________________________________________________________________________________________"
  set PM_i [lindex [$this(Interleaving)_LM_LP get_L_compatible_actives_PM_with_ptf Ptf_TK] 0]
    if {$PM_i != ""} {$PM_i set_cmd_placement {pack $p -side left -expand 1 -fill both}}

# Style
 set i_DSL interpretor_DSL_comet_interface
 set r $this(new_node_name)_LM_LP;    Encapsulate $r PM_Universal U_LM_encaps_specifyer_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_cont     = C_Cont(,\"Create node \", [$r get_factice_LC]())" ${r}_nested_style_cont_LM_LP
 set r $this(new_node_type)_LM_LP;    Encapsulate $r PM_Universal U_LM_encaps_choice_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_descr    = C_Cont(,\"type : \", [$r get_factice_LC]())" [$r get_factice_LC]_LM_LP
 set r $this(new_rel_type)_LM_LP;     Encapsulate $r PM_Universal U_LM_encaps_choice_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_descr    = C_Cont(,\"relation : \", [$r get_factice_LC]())" [$r get_factice_LC]_LM_LP
 set r $this(cont_new_node)_LM_LP;    Encapsulate $r PM_Universal U_LM_encaps_specifyer_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_descr    = C_Cont(, [$r get_factice_LC](), $this(new_node_OKbt)=C_Act(set_text CREATE))" ${r}_nested_style_descr_LM_LP

# set r $this(il_nodes_in)_LM_LP   ; Encapsulate_for_extendability $r PM_Universal U_LM_encaps_interleaving_LM_P "Add" "New in nodes"
# set r $this(il_nodes_out)_LM_LP  ; Encapsulate_for_extendability $r PM_Universal U_LM_encaps_interleaving_LM_P "Add" "New out nodes"

#                                      __________________________________________________                                                  _
#                                                          Bindings                                                                        _
#                                      --------------------------------------------------                                                  _
 $this(new_node_OKbt)   Subscribe_to_activate $objName "$objName Validate"

# Adding some PM of presentations
 set PM_U "${comet_name}_PM_P_Universal_[this get_a_unique_id]"
   RelationEditor_PM_U $PM_U $PM_U "A TK list of marked choices representing $objName"
   this Add_PM $PM_U
 set this(init_ok) 1
 this set_PM_active $PM_U

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC RelationEditor_LM_LP [L_methodes_set_RelationEditor] {}          {$this(L_actives_PM)}
Methodes_get_LC RelationEditor_LM_LP [L_methodes_get_RelationEditor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP set_Relation_name {v} {
 $this(Relation_name) set_text $v
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP set_L_source_nodes {Lr} {
 $this(il_nodes_in)  maj_txt_daughters $Lr
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP set_L_dest_nodes {Lr} {
 $this(il_nodes_out) maj_txt_daughters $Lr
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP set_descriptions {v} {
 $this(Relation_descr)    set_text $v
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP get_L_source_nodes {} {
 return [$this(il_nodes_in) get_daughters_name]
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP get_L_dest_nodes {} {
 return [$this(il_nodes_out) get_daughters_name]
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP get_descriptions {} {
 return [$this(Relation_descr) get_text]
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP get_Relation_name {} {
 return [$this(Relation_name) get_text]
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP Edit {n} {
 set CFC [this get_Common_FC]

 set L [$this(DC_nodes_in)  get_out_daughters]; $this(DC_nodes_in)  set_daughters_R {}; foreach e $L {$e dispose}
 set L [$this(DC_nodes_out) get_out_daughters]; $this(DC_nodes_out) set_daughters_R {}; foreach e $L {$e dispose}
 set L {}; foreach r [$n get_L_source_rel] {Add_list L [$r get_L_dest_nodes]  }; $this(DC_nodes_in)  set_daughters_R $L
 set L {}; foreach r [$n get_L_dest_rel]   {Add_list L [$r get_L_source_nodes]}; $this(DC_nodes_out) set_daughters_R $L
}

#___________________________________________________________________________________________________________________________________________
method RelationEditor_LM_LP Validate {} {
 set LC [this get_LC]
 set n_name  [$this(new_node_name) get_text]
 set n_type  [[$this(new_node_type) get_currents] get_text]
 set pos [lsearch [$this(new_node_src_dst) get_out_daughters] [$this(new_node_src_dst) get_currents]]
 set r_type  [[$this(new_rel_type) get_currents] get_text]

 [this get_LC] Add_related_node $n_name $n_type $r_type [lindex [list source dest] $pos]
}
