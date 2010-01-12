#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation____________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_Navigator_LM_LP Logical_presentation
#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_LM_LP constructor {name descr args} {
 set this(init_ok) 0
 this inherited $name $descr
 this set_L_actives_PM {}
   set this(num_sub) 0
 
 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
   set this(comet_name) $comet_name

# Nesting parts
 set this(cont)     "${objName}_nested_cont"
 set this(gdd_req)  "${objName}_nested_gdd_req"
 set this(gdd_rep)  "${objName}_nested_gdd_rep"
 set this(gdd_bt)   "${objName}_nested_gdd_bt"
 set this(gdd_visu) "${objName}_nested_gdd_visu"
 set    str "$this(cont) = C_Cont(, $this(gdd_req)  = C_Spec()"
 append str                      ", $this(gdd_rep)  = C_Text()"
 append str                      ", $this(gdd_bt)   = C_Act(set_text SEARCH)"
 append str                      ", $this(gdd_visu) = C_GDDVisu(set_root IS_root)"
 append str                     ")"
 set L_nested [interpretor_DSL_comet_interface Interprets $str $objName]
 this Add_nested_daughters [lindex $L_nested 1] $this(cont) $this(cont) _LM_LP
 $this(gdd_bt) Subscribe_to_activate $objName "$objName search_for \[$this(gdd_req) get_text\]"

# Style
 Text_PM_P_zone_TK $this(gdd_rep)_PM_P_zone_TK {} {}
   set L [$this(gdd_rep)_LM_LP get_L_PM] 
   $this(gdd_rep)_LM_LP set_L_PM $this(gdd_rep)_PM_P_zone_TK
   $this(gdd_rep)_LM_LP set_L_actives_PM $this(gdd_rep)_PM_P_zone_TK
   foreach PM $L {$PM dispose}
# Adding some PM of presentations
 set PM_tab_TK "${comet_name}_PM_P_tab_TK_[this get_a_unique_id]"
   GDD_Navigator_PM_tab_TK $PM_tab_TK $PM_tab_TK "A TK list of marked choices representing $objName"
   this Add_PM $PM_tab_TK

# Factories
 this Add_PM_factories [Generate_factories_for_PM_type [list {GDD_Navigator_PM_U Ptf_HTML} \
                                                       ] $objName]

 set this(init_ok) 1
 this set_PM_active $PM_tab_TK

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC GDD_Navigator_LM_LP [L_methodes_set_GDD_Navigator] {}          {$this(L_actives_PM)}
Methodes_get_LC GDD_Navigator_LM_LP [L_methodes_get_GDD_Navigator] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_LM_LP get_Visu {} {return $this(gdd_visu)}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_LM_LP set_root {r} {
 $this(gdd_visu) Compute
 foreach PM [this get_L_actives_PM] {
   $PM set_root $r
  }
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_LM_LP search_for {req} {
 set DSL [this get_GDD_DSL]
 if {[$DSL QUERY $req] == 1} {
   set txt [$DSL get_Result]
  } else {set txt "ERROR :\n[$DSL get_ERROR]"
         }
 $this(gdd_rep) set_text $txt
}
