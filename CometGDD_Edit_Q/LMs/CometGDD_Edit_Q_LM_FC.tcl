inherit CometGDD_Edit_Q_LM_FC Logical_model

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_LM_FC constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 set PM_basic [CPool get_a_comet CometGDD_Edit_Q_PM_FC_basic]
 this Add_PM        $PM_basic
 this set_PM_active $PM_basic

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDD_Edit_Q_LM_FC [P_L_methodes_set_CometGDD_Edit_Q] {} {$this(L_actives_PM)}
Methodes_get_LC CometGDD_Edit_Q_LM_FC [P_L_methodes_get_CometGDD_Edit_Q] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_FC {} {return [P_L_methodes_set_CometGDD_Edit_Q]}
Generate_LM_setters CometGDD_Edit_Q_LM_FC [P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_FC]

#___________________________________________________________________________________________________________________________________________


