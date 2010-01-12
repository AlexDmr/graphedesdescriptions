#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometGDDVisu_PM_P_HTML_image PM_HTML

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image constructor {name descr args} {
 this inherited $name $descr
   set class(last_compute) {}
   if {[info exists class(L_shapes)]} {} else {
     set class(L_shapes) {}
    }
   set class(imap)          {}
   set class(js_mark)       {}

   set this(AJAX_root_for_answer) "$objName AJAX_maj"

 eval "$objName configure $args"
 return $objName
}
#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image get_js_mark { } {return $class(js_mark)}
method CometGDDVisu_PM_P_HTML_image set_js_mark {m} {set class(js_mark) $m}

#___________________________________________________________________________________________________________________________________________
Generate_accessors CometGDDVisu_PM_P_HTML_image AJAX_root_for_answer

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image destructor {} {this inherited}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDDVisu_PM_P_HTML_image [L_methodes_set_GDDVisu] {$this(FC)} {}
Methodes_get_LC CometGDDVisu_PM_P_HTML_image [L_methodes_get_GDDVisu] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image get_L_shapes {} {return $class(L_shapes)}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image Process_imap {} {
 set L [split $class(imap) "\n"]
 set L [lrange $L 1 end]
 set class(L_shapes) {}
 foreach e $L {
   regexp {^(.*) Click_on_GDD\((.*), (.*)\) (.*)$} $e reco shape type id coords
   lappend class(L_shapes) "<area shape=\"$shape\" coords=\"$coords\" alt=\"$id\" href=\"javascript:Click_on_GDD\('${type}', '${id}'\)\" />"
  }
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image Compute {f m} {
 if {[string equal $class(last_compute) $m]} {return}

 set gv [this get_gv_gdd]
 if {[catch "exec \"C:/Program Files/Graphviz2.16/bin/dot.exe\" -Tgif $f -o [this get_LM].gif" err]} {
   puts "ERROR in \"$objName Compute $f $m\"\n$err"
  }
 set class(imap) [exec "C:/Program Files/Graphviz2.16/bin/dot.exe" -Timap $f]
 this Process_imap

 set class(last_compute) $m
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image Select_GDD_element {params} {
# puts "$objName Select_GDD_element $params"
 set L_var_val {}
 this AJAX_annalyse_msg params 0 L_var_val
 foreach e $L_var_val {set [lindex $e 0] [lindex $e 1]}

# puts "[this get_LC] GDD_element_PM_selected $objName $id"
 [this get_LC] GDD_element_PM_selected $objName $id
 [this get_L_roots] set_AJAX_root [this get_AJAX_root_for_answer]
}


#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image Render_JS {strm_name mark {dec {}}} {
 upvar $strm_name strm
 if {$mark != [this get_js_mark]} {
   append strm $dec {function Click_on_GDD(type, id) } "\{\n"
   append strm $dec {  Debug.echo("Click sur " + type + " " + id);} "\n"
   set tab ${objName}_AJAX_tab
   append strm $dec $tab { = new Array();} "\n"
   append strm $dec $tab {["} ${objName}__XXX__Select_GDD_element {"]= "2 id " + id.length + " " + id} "\;\n"
   append strm $dec $tab {["Comet_port"] = } [[this get_L_roots] get_server_port] "\;\n"
   append strm $dec {Ajax.get("set", "#", "} [this get_AJAX_root_for_answer] {", } $tab {, false)} "\;\n"
   append strm $dec " \}\n"
  }

 this set_js_mark $mark
 this Render_daughters_JS strm $mark $dec
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
 append strm $dec "<div [this Style_class]>\n"
   this AJAX_Render strm "$dec  "
 append strm $dec "</div>\n"
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image AJAX_Render {strm_name {dec {}}} {
 upvar $strm_name strm

# Render the map
 append strm $dec {<map id ="} [this get_LM]_map {" name="} [this get_LM]_map "\">\n"
   foreach shape $class(L_shapes) {
     append strm "$dec  $shape\n"
    }
 append strm $dec {</map>} "\n"

# Render the image and point to the map
 append strm $dec "<img alt=\"$objName\" src=\"[this get_LM].gif\" usemap =\"#[this get_LM]_map\" />\n"
 this Render_daughters strm "$dec "
}

#___________________________________________________________________________________________________________________________________________
method CometGDDVisu_PM_P_HTML_image AJAX_maj {strm_name} {
 upvar $strm_name strm

 set txt ""
   this AJAX_Render txt
 append strm [string length $objName] { } [string length $txt] { } $objName { } $txt { }
}

