#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation____________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_editor_LM_LP Logical_presentation
#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP constructor {name descr args} {
 set this(init_ok) 0
 this inherited $name $descr
 this set_L_actives_PM [list]
   set this(num_sub) 0
 
 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
   set this(comet_name) $comet_name

# Nesting parts
set this(OK_CANCEL) "${objName}_nested_OK_CANCEL"
 set this(Interleaving)  "${objName}_nested_interleaving"
  set this(save_name)     "${objName}_nested_node_saving"
  set this(load_descr)    "${objName}_nested_node_loading"
  set this(menu)          "${objName}_nested_node_menu"

# DSL description
 C_NodeEditor     ${objName}_NE  "Node Editor"     {A node editor, to visualize and specify a node in the GDD}
 C_RelationEditor ${objName}_RE  "Relation Editor" {A relation editor}
 C_GDD_Navigator  ${objName}_Nav "GDD Navigator"   {Allow to navigate using nodes and relationship}

 set    str "$this(Interleaving) = |||(, $this(menu) = C_Cont(, $this(save_name)  = C_Spec(set_name \"Save GDD\")"
 append str                                                  ", $this(load_descr) = C_DC  (set_name \"Load GDD\")"
 append str                                                  ")"
 append str                           ", ${objName}_Nav(), ${objName}_NE(), ${objName}_RE()"
 append str                          ")"


 puts "_________________________________________________________________________________________________"

# Style
 set i_DSL interpretor_DSL_comet_interface
 set L_res_DSL [$i_DSL Interprets $str GDD_Editor]
  this Add_nested_daughters [lindex $L_res_DSL 1] \
                            [lindex $L_res_DSL 0] \
                            [lindex $L_res_DSL 0] \
                            _LM_LP

# ${objName}_Nav in a window [TK]
  set str   "#$this(Interleaving)->_LM_LP(*->_LM_LP \\>${objName}_Nav/)"
  puts $str
  set L_rep {}
  #DEBUG UPDATE Style_CSSpp DSL_SELECTOR str L_rep $this(Interleaving) 1
  set L_rep [CSS++ $this(Interleaving) $str]
    #puts "L_rep : $L_rep"
    $L_rep Ptf_style [list {Ptf_TK PhysicalContainer_TK_window}]

# Styling
  set name $this(load_descr)_PM_P_dialog_TK
    $this(load_descr)_LM_LP Add_PM    [Choice_file_PM_P_dialog_TK $name $name {}]
    $this(load_descr)_LM_LP Ptf_style [list {Ptf_TK Choice_file_PM_P_dialog_TK}]
  set name $this(save_name)_PM_P_dialog_TK
    $this(save_name)_LM_LP Add_PM    [Specifyer_file_PM_P_dialog_TK $name $name {}]
    $this(save_name)_LM_LP Ptf_style [list {Ptf_TK Specifyer_file_PM_P_dialog_TK}]
  foreach PM_i [$this(Interleaving)_LM_LP get_L_compatible_actives_PM_with_ptf Ptf_TK] {
    $PM_i set_cmd_placement {pack $p -side left -expand 1 -fill both}
   }

#                                      __________________________________________________                                                  _
#                                                          Bindings                                                                        _
#                                      --------------------------------------------------                                                  _
 $this(load_descr) Subscribe_to_set_currents     $objName "if \{\[string equal \$lc \{\}\]\} \{\} else \{$objName Load_GDD \$lc\}"
 $this(save_name)  Subscribe_to_set_text         $objName "if \{\[string equal \$t  \{\}\]\} \{\} else \{\[$objName get_LC\] Save_GDD \$t \}"
 ${objName}_NE     Subscribe_to_Validate         $objName "$objName Validate_NE"
 ${objName}_RE     Subscribe_to_Validate         $objName "$objName Validate_RE"

 ${objName}_Nav    Subscribe_to_Activate_current_node  $objName "set n \[${objName}_Nav get_current_node \]; ${objName}_RE Edit \$n; ${objName}_NE Edit \$n"
# ${objName}_Nav    Subscribe_to_Activate_current_node $objName "${objName}_NE Edit \[${objName}_Nav get_current_node\]"

#                                      __________________________________________________                                                  _
#                                                 Adding some PM of presentations                                                          _
#                                      --------------------------------------------------                                                  _
 set PM_U "${comet_name}_PM_P_Universal_[this get_a_unique_id]"
   GDD_editor_PM_U $PM_U $PM_U ""
   this Add_PM $PM_U
 set this(init_ok) 1
 this set_PM_active $PM_U

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC GDD_editor_LM_LP [L_methodes_set_GDD_Editor] {}          {$this(L_actives_PM)}
Methodes_get_LC GDD_editor_LM_LP [L_methodes_get_GDD_Editor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP get_Nav {} {return ${objName}_Nav}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP set_GDD_DSL {d} {
 ${objName}_Nav set_GDD_DSL $d
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP Validate_NE {} {
 set NE ${objName}_NE

 [this get_LC] Add_or_update_node [$NE get_node_name]                        \
                                  -set_descriptions "[$NE get_descriptions]" \
                                  -set_factory_req  "[$NE get_factory_req]"  \
                                  -set_L_factories  "[$NE get_L_factories]"
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP Load_GDD {f_name} {
 [this get_LC] Load_GDD $f_name
 ${objName}_Nav set_root IS_root
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_LP Validate_RE {} {
 set RE ${objName}_RE

 [this get_LC] Add_or_update_relation [$RE get_Relation_name]                        \
                                      -set_L_source_nodes "[$RE get_L_source_nodes]" \
                                      -set_L_dest_nodes   "[$RE get_L_dest_nodes]"   \
                                      -set_descriptions   "[$RE get_descriptions]"
}

