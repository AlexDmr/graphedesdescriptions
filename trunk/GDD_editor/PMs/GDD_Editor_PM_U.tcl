#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_editor_PM_U PM_Universal
#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U constructor {name descr args} {
 this inherited $name $descr
   this set_nb_max_mothers 1
   this set_cmd_placement {}
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC GDD_editor_PM_U [L_methodes_set_GDD_Editor] {}          {}
Methodes_get_LC GDD_editor_PM_U [L_methodes_get_GDD_Editor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U Add_mother {m {index -1}} {
 set rep [this inherited $m $index]
 if {$rep == 1} {
   if {[Ptf_HTML Accept_for_daughter ${objName}_cou_ptf]} {
     set nav [[this get_LM] get_Nav] 
     [${nav}_LM_LP get_Visu] Subscribe_to_GDD_element_PM_selected $objName "$objName HTML_GDD_node_selected \$PM \$id"
    }
  }

 return $rep
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U HTML_GDD_node_selected {PM id} {
 puts "$objName HTML_GDD_node_selected \"$PM\" \"$id\""
 [this get_L_roots] set_AJAX_root "$objName AJAX_Render"
 
 set nav [[this get_LM] get_Nav]
 $nav set_current_node $id
 $nav Activate_current_node
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U Render {strm_name {dec {}}} {
 upvar $strm_name strm

# Look for the GDD visu, set the corresponding AJAX balise for GDD_node_select
 set L [[this get_DSL_CSSpp] Interprets CometGDDVisu $objName]
 [lindex $L 0] set_AJAX_root_for_answer "$objName AJAX_maj"

# Render the node
 this inherited strm $dec
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U AJAX_Render {strm_name {dec {}}} {
 upvar $strm_name strm

 this Render_daughters strm "$dec  "
}

#___________________________________________________________________________________________________________________________________________
method GDD_editor_PM_U AJAX_maj {strm_name} {
 puts "coucou les gars"
 upvar $strm_name strm

 set txt ""
   this AJAX_Render txt
   set txt [string map [list "\n" {}] $txt]
 append strm [string length $objName] { } [string length $txt] { } $objName { } $txt { }
}

