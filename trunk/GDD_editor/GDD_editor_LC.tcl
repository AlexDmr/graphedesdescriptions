#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
# Editor of a GDD node. A GDD node is a model of an interactive system. This model is composed of several_
#   descriptions (C&T, AUI, CUI, WSDL...). The node is related both as source and target to some relations
#   Endly some informations about factories are available. Id est :   ____________________________________
#     * WSDL specification on how interact with the factory           ____________________________________
#     * Natural language description on how interact with the factory ____________________________________
#     * Adresses of some factories                                    ____________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________

inherit C_GDD_Editor Logical_consistency

#___________________________________________________________________________________________________________________________________________
method C_GDD_Editor constructor {name descr args} {
 this inherited $name $descr
## CFC
   set CFC_name "${objName}_CFC"
     GDD_Editor_CFC $CFC_name
     this set_Common_FC $CFC_name
## LMs
   set this(LM_LP) "${objName}_LM_LP";
     GDD_editor_LM_LP $this(LM_LP) $this(LM_LP) "The logical presentation of $objName";
     this Add_LM $this(LM_LP)
   set this(LM_FC) "${objName}_LM_FC";
     GDD_editor_LM_FC $this(LM_FC) $this(LM_FC) "The logical functional core of $objName";
     this Add_LM $this(LM_FC)

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC C_GDD_Editor [L_methodes_set_GDD_Editor] {$this(FC)} {$this(L_LM)}
Methodes_get_LC C_GDD_Editor [L_methodes_get_GDD_Editor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method C_GDD_Editor Add_or_update_node {name args} {
 eval "[this get_Common_FC] Add_or_update_node $name $args"
}

#___________________________________________________________________________________________________________________________________________
method C_GDD_Editor Add_or_update_relation {name args} {
 eval "[this get_Common_FC] Add_or_update_relation $name $args"
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_types_from_file {f_name} {
 return [${objName}_CFC Load_types_from_file $f_name]
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_types {txt} {
 return [${objName}_CFC Load_types $txt]
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_GDD {f_name} {
 [this get_Common_FC] Load_GDD $f_name
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Save_GDD {f_name} {
 [this get_Common_FC] Save_GDD $f_name
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_types_from_file {f_name} {
 $this(LM_FC) Load_types_from_file $f_name
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_types {txt} {
 $this(LM_FC) Load_types $txt
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Load_GDD {f_name} {
 $this(LM_FC) Load_GDD $f_name
}

#________________________________________________________________________________________________________________________________________
method C_GDD_Editor Save_GDD {f_name} {
 $this(LM_FC) Save_GDD $f_name
}
