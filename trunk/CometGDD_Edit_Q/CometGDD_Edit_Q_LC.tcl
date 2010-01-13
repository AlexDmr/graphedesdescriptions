inherit CometGDD_Edit_Q Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q constructor {name descr args} {
 this inherited $name $descr
 this set_GDD_id CT_CometGDD_Edit_Q

 set CFC ${objName}_CFC; CometGDD_Edit_Q_CFC $CFC; this set_Common_FC $CFC

 set this(LM_FC) ${objName}_LM_FC
 CometGDD_Edit_Q_LM_FC $this(LM_FC) $this(LM_FC) "The LM FC of $name"
   this Add_LM $this(LM_FC)
 set this(LM_LP) ${objName}_LM_LP
 CometGDD_Edit_Q_LM_LP $this(LM_LP) $this(LM_LP) "The LM LP of $name"
   this Add_LM $this(LM_LP)
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q dispose {} {this inherited}
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDD_Edit_Q [P_L_methodes_set_CometGDD_Edit_Q] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometGDD_Edit_Q [P_L_methodes_get_CometGDD_Edit_Q] {$this(FC)}

