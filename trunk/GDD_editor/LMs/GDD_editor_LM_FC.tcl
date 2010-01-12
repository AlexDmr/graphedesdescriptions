#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation____________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_editor_LM_FC Logical_model
#___________________________________________________________________________________________________________________________________________
method GDD_editor_LM_FC constructor {name descr args} {
 this inherited $name $descr

 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
   set this(comet_name) $comet_name

 set PM_FC "${comet_name}_PM_FC_standard_[this get_a_unique_id]"
   GDD_Editor_PM_FC_standard $PM_FC $PM_FC ""
   this Add_PM $PM_FC; this set_PM_active $PM_FC

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC GDD_editor_LM_FC [L_methodes_set_GDD_Editor] {}          {$this(L_actives_PM)}
Methodes_get_LC GDD_editor_LM_FC [L_methodes_get_GDD_Editor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc L_methodes_set_GDD_Editor_FC {} {return [list {Load_types_from_file {f_name}} {Load_types {txt}} {Load_GDD {f_name}} {Save_GDD {f_name}}]}

Methodes_set_LC GDD_editor_LM_FC [L_methodes_set_GDD_Editor_FC] {} {[lindex $this(L_actives_PM) 0]}
