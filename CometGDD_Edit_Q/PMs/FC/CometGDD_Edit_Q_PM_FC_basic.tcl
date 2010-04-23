#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometGDD_Edit_Q_PM_FC_basic Physical_model

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_FC_basic constructor {name descr args} {
 this inherited $name $descr
   this set_nb_max_mothers 1
   this set_cmd_placement  {}
   
 set this(mark) 0
 set this(size) 15
 set this(txt_viz) {}
 set this(txt_gdd) {}
 set this(L_levels) [list get_L_LM get_L_actives_PM]
 set this(num_cluster) 0
 set this(GDD_C&T,color) "gray52"
 set this(GDD_AUI,color) "green"
 set this(GDD_CUI,color) "indianred1"
 set this(GDD_FUI,color) "cyan"

 set this(GDD_inheritance,color)    "white"
 set this(GDD_composition,color)    "white"
 set this(GDD_restriction,color)    "white"
 set this(GDD_specialization,color) "white"
 set this(GDD_extension,color)      "white"
 set this(GDD_concretization,color) "white"
 set this(GDD_implementation,color) "white"
 set this(GDD_encapsulation,color)  "white"
 set this(GDD_use,color)            "white"
 set this(js_fct) {}


 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDD_Edit_Q_PM_FC_basic [P_L_methodes_set_CometGDD_Edit_Q] {} {}
Methodes_get_LC CometGDD_Edit_Q_PM_FC_basic [P_L_methodes_get_CometGDD_Edit_Q] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometGDD_Edit_Q_PM_FC_basic [P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_FC]

#_________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_FC_basic get_color {t}   {return $this(${t},color)}
method CometGDD_Edit_Q_PM_FC_basic set_color {t c} {set this(${t},color) $c}

#___________________________________________________________________________________________________________________________________________
Inject_code CometGDD_Edit_Q_PM_FC_basic Query {} {
 set gdd [this get_DSL_GDD_QUERY]
 $gdd QUERY $v
 set this(L_nodes_to_relate) [lindex [$gdd get_Result] 0]
 set this(L_nodes_to_relate) [lindex $this(L_nodes_to_relate) 1]
 if {[regexp {^.*: *(.*) *:.*$} $v reco root]} {
   lappend this(L_nodes_to_relate) [lindex $root 0]
  } else {puts "  Malformation de la requête, on abandonne."
          return
		 }
  
   set    str "digraph abstract \{\n"
   append str "compound=true\;\n"
   if {[llength $this(L_nodes_to_relate)]} {this Build_sub_graph str}
   append str "\n\}\n"
 
 this prim_set_dot_descr $str
} __GDD_EXPLORATION__


#_________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_FC_basic Build_sub_graph {str_name} {
 upvar $str_name str
 
 foreach N $this(L_nodes_to_relate) {
   append str "  " $N {[label = "} $N {",shape=box,style=filled,fillcolor="} [this get_color [$N get_type]] {"}
   if {$this(js_fct) != ""} {append str "URL=\"$this(js_fct)(NODE, $N)\""}
   append str {];} "\n"
  }
  
 foreach N $this(L_nodes_to_relate) {
   # Parcourir les relations et l'écrire si la relation fait un lien avec un autre noeud de la liste
   foreach R [$N get_L_dest_rel] {
     if {[llength [Liste_Intersection [$R get_L_source_nodes] $this(L_nodes_to_relate)]]} {append str "  $R -> $N\;\n"}
    }
   foreach R [$N get_L_source_rel] {
     append str "  $R\[label=\"[$R get_type]\"\];\n"
     if {[llength [Liste_Intersection [$R get_L_dest_nodes  ] $this(L_nodes_to_relate)]]} {append str "  $N -> $R\;\n"}
    }
  }
}

#_________________________________________________________________________________________________________
# method CometGDD_Edit_Q_PM_FC_basic Build_sub_graph {str_name} {
 # upvar $str_name str
 
 # foreach N $this(L_nodes_to_relate) {
   # append str "  " $N {[label = "} $N {",shape=box,style=filled,fillcolor="} [this get_color [$N get_type]] {"}
   # if {$this(js_fct) != ""} {append str "URL=\"$this(js_fct)(NODE, $N)\""}
   # append str {];} "\n"
  # }
  
 # foreach N $this(L_nodes_to_relate) {
   # Parcourir les relations et l'écrire si la relation fait un lien avec un autre noeud de la liste
   # foreach R [$N get_L_source_rel] {
     # foreach N2 [$R get_L_dest_nodes] {
	   # if {[llength [Liste_Intersection [list $N2] $this(L_nodes_to_relate)]]} {append str "  $N -> $N2\;\n"}
	  # }
    # }
  # }
# }