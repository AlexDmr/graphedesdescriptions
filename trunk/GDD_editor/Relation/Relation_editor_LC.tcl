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
inherit C_RelationEditor Logical_consistency

#___________________________________________________________________________________________________________________________________________
method C_RelationEditor constructor {name descr args} {
 this inherited $name $descr
## CFC
   set CFC_name "${objName}_CFC"
     RelationEditor_CFC $CFC_name
     this set_Common_FC $CFC_name
## LMs
   set this(LM_LP) "${objName}_LM_LP";
     RelationEditor_LM_LP $this(LM_LP) $this(LM_LP) "The logical presentation of $objName";
     this Add_LM $this(LM_LP)

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC C_RelationEditor [L_methodes_set_RelationEditor] {$this(FC)} {$this(L_LM)}
Methodes_get_LC C_RelationEditor [L_methodes_get_RelationEditor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method C_RelationEditor Validate {} {}
Manage_CallbackList C_RelationEditor Validate end
