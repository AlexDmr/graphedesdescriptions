#___________________________________________________________________________________________________________________________________________
#___________________________________________ Définition of Logical Model of présentation ___________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometGDDVisu_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_LM_LP constructor {name descr args} {
 this inherited $name $descr

# Adding some physical presentations
 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}

 this Add_PM_factories [Generate_factories_for_PM_type [list {CometGDDVisu_PM_P_HTML_image Ptf_HTML} \
                                                       ] $objName]

 set this(init_ok) 1

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDDVisu_LM_LP [L_methodes_set_GDDVisu] {$this(FC)} {$this(L_actives_PM)}
Methodes_get_LC CometGDDVisu_LM_LP [L_methodes_get_GDDVisu] {$this(FC)}
