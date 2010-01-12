#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation____________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit NodeEditor_LM_LP Logical_presentation
#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP constructor {name descr args} {
 set this(init_ok) 0
 this inherited $name $descr
 this set_L_actives_PM {}
   set this(num_sub) 0
 
 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
   set this(comet_name) $comet_name

# Nesting parts
set this(OK_CANCEL) "${objName}_nested_OK_CANCEL"
 set this(Interleaving)  "${objName}_nested_interleaving"
  set this(Node_name)     "${objName}_nested_node_name"
  set this(Node_descr)    "${objName}_nested_node_descr"
  set this(Node_type)     "${objName}_nested_node_type"
  set this(InterL_info_f) "${objName}_nested_InterL_info_factories"
   set this(Descr_factory) "${objName}_nested_Descr_factory"
   set this(il_factories)  "${objName}_nested_il_factories"

# DSL description
 global GDD_node
 if {[info exists GDD_node]} {set L_node_type [GDD_node get_sub_types]} else {set L_node_type [list GDD_C&T GDD_AUI GDD_CUI GDD_FUI]}
 set L_tmp $L_node_type; set L_node_type {}
 set pos 0; foreach n $L_tmp {lappend L_node_type "\"$n\""}
 set L_node_type [join $L_node_type ", "]

 set    str "$this(OK_CANCEL) = C_OkCa(-set_txt_OK ADD -set_txt_CANCEL SUB"
 append str                           ", $this(Node_name)  = C_Spec()"
 append str                           ", $this(Node_descr) = C_Spec()"
 append str                           ", $this(Node_type)  = C_DC(, $L_node_type)"
 append str                           ", $this(InterL_info_f) = C_Cont(, $this(Descr_factory) = C_Spec()"
 append str                                                           ", $this(il_factories)  = |||()"
 append str                                                          ")"
 append str                          ")"

 set L_nested [interpretor_DSL_comet_interface Interprets $str $objName]
 this Add_nested_daughters [lindex $L_nested 1] $this(OK_CANCEL) $this(OK_CANCEL) _LM_LP

# Style
 set i_DSL interpretor_DSL_comet_interface
 set r $this(Node_name)_LM_LP;     Encapsulate $r PM_Universal U_LM_encaps_specifyer_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_cont     = C_Cont(,\"Node name: \", [$r get_factice_LC]())" ${r}_nested_style_cont_LM_LP
 set r $this(Node_descr)_LM_LP;    Encapsulate $r PM_Universal U_LM_encaps_specifyer_LM_P;
   $r Nested_style $i_DSL "${r}_nested_style_descr    = C_Cont(,\"Node description: \", [$r get_factice_LC]())" ${r}_nested_style_descr_LM_LP

# set PM_i [lindex [$this(Interleaving)_LM_LP get_L_compatible_actives_PM_with_ptf Ptf_TK] 0]
#   $PM_i set_cmd_placement {pack $p -side left -expand 1 -fill both}

 set r $this(il_factories)_LM_LP ; Encapsulate_for_extendability $r PM_Universal U_LM_encaps_interleaving_LM_P "Add" "New factory"

#                                      __________________________________________________                                                  _
#                                                          Bindings                                                                        _
#                                      --------------------------------------------------                                                  _
 $this(OK_CANCEL)   Subscribe_to_activate_OK     $objName "$objName Validate"
 $this(OK_CANCEL)   Subscribe_to_activate_CANCEL $objName "\[$objName get_LC\] Sub_node \[$this(Node_name) get_text\]"

# Adding some PM of presentations
 set PM_U "${comet_name}_PM_P_Universal_[this get_a_unique_id]"
   NodeEditor_PM_U $PM_U $PM_U "A TK list of marked choices representing $objName"
   this Add_PM $PM_U
 set this(init_ok) 1

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC NodeEditor_LM_LP [L_methodes_set_NodeEditor] {}          {$this(L_actives_PM)}
Methodes_get_LC NodeEditor_LM_LP [L_methodes_get_NodeEditor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_node_type {}  {return [[$this(Node_type) get_currents] get_text]}
method NodeEditor_LM_LP set_node_type {v} {
 foreach c [$this(Node_type) get_out_daughters] {
   if {[string equal $v [$c get_text]]} {$this(Node_type) set_currents $c
                                         break
                                        }
  }
}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP set_node_name {v} {$this(Node_name) set_text $v}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP set_descriptions {v} {$this(Node_descr)    set_text $v}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP set_factory_req {v} {$this(Descr_factory) set_text $v}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP set_L_factories {Lf} {$this(il_factories) maj_txt_daughters $Lf}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_node_name {} {return [$this(Node_name) get_text]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_description {} {return [$this(Node_descr) get_text]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_L_source_rel {} {return [$this(il_rels_in) get_daughters_name]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_L_dest_rel {} {return [$this(il_rels_out) get_daughters_name]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_factory_req {} {return [$this(Descr_factory) get_text]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP get_L_factories {} {return [$this(il_factories) get_daughters_name]}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP Edit {n} {
 set CFC [this get_Common_FC]
 this set_L_factories   [$CFC get_L_factories]
 this set_descriptions  [$CFC get_descriptions]
 this set_factory_req   [$CFC get_factory_req]
 this set_node_name     [$CFC get_node_name]
 this set_node_type     [$CFC get_node_type]
}

#___________________________________________________________________________________________________________________________________________
method NodeEditor_LM_LP Validate {} {
 set CFC [this get_Common_FC]
 $CFC set_node_name    [this get_node_name]
 $CFC set_node_type    [this get_node_type]
 $CFC set_descriptions [this get_description]
 $CFC set_factory_req  [this get_factory_req]
 $CFC set_L_factories  [this get_L_factories]

 [this get_LC] Validate
}
