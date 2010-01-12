#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
inherit CometGDDVisu Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu constructor {name descr args} {
 this inherited $name $descr
## CFC
   set CFC_name "${objName}_CFC"
     CometGDDVisu_CFC $CFC_name
     this set_Common_FC $CFC_name
## LMs
   set this(LM_LP) "${objName}_LM_LP";
     CometGDDVisu_LM_LP $this(LM_LP) $this(LM_LP) "The logical presentation of $objName";
     this Add_LM $this(LM_LP)

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDDVisu [L_methodes_set_GDDVisu] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometGDDVisu [L_methodes_get_GDDVisu] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu Compute {} {
 set m [clock seconds]
 set f ${objName}_gdd.dot
 [this get_Common_FC] Compute $f $m
 foreach LM [this get_L_LM] {
   $LM Compute $f $m
  }
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu Select_GDD_element {id} {
 puts "$objName Select_GDD_element \"$id\""
}


#___________________________________________________________________________________________________________________________________________
method CometGDDVisu GDD_element_PM_selected {PM id} {
}

Manage_CallbackList CometGDDVisu [list GDD_element_PM_selected] end