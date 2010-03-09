#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometGDD_Edit_Q_PM_P_TK_CANVAS_basic PM_TK_CANVAS

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic constructor {name descr args} {
 this inherited $name $descr

   this set_GDD_id GDD_CometCompo_evolution_PM_P_TK_canvas_basic
   set this(GDD_rel)  ""
   set this(GDD_type) ""

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDD_Edit_Q_PM_P_TK_CANVAS_basic [P_L_methodes_set_CometGDD_Edit_Q]       {} {}
Methodes_get_LC CometGDD_Edit_Q_PM_P_TK_CANVAS_basic [P_L_methodes_get_CometGDD_Edit_Q_LM_LP] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometGDD_Edit_Q_PM_P_TK_CANVAS_basic [P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_LP]

#___________________________________________________________________________________________________________________________________________
Generate_accessors CometGDD_Edit_Q_PM_P_TK_CANVAS_basic [list GDD_rel GDD_type]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic set_LM {LM} {
 # Test the existence or not of a related proxy graph generator 
 if {$LM != ""} {
   set this(proxy_graph_builder) [$LM get_proxy_graph_builder]
   $this(proxy_graph_builder) Subscribe_to_New_canvas_descr_available $objName [list $objName Update_canvas] UNIQUE
  } else {set this(proxy_graph_builder) ""}
 
 return [this inherited $LM]
}

Trace CometGDD_Edit_Q_PM_P_TK_CANVAS_basic set_LM

#___________________________________________________________________________________________________________________________________________
Inject_code CometGDD_Edit_Q_PM_P_TK_CANVAS_basic set_dot_descr {} {
 $this(proxy_graph_builder) get_canvas_descr
} __GET_A_CANVAS_GRAPH_RELATED_TO_DOT_DESCRIPTION__

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic get_or_create_prims {C_canvas} {
 puts "C_canvas : $C_canvas"
 if {$C_canvas == ""} {return [this inherited ""]}
 
# Define the handle
 set canvas [$C_canvas get_canvas]
 this set_canvas $canvas
 
 this Add_MetaData PRIM_STYLE_CLASS [list $objName "COMPO COMPONENT" \
                                    ]

# Create TK items
 $this(proxy_graph_builder) get_canvas_descr
 								
 this set_root_for_daughters $C_canvas
 return [this set_prim_handle $C_canvas]
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Update_canvas {} {
 set c [this get_canvas]
 $c delete $objName
 
 set rep [$this(proxy_graph_builder) get_canvas_descr]
 
 set str ""
 foreach line [split $rep "\n"] {
   if {[regexp "^(.*) -tags \{(.*)\}.*\$" $line reco prefix tags]} {
     lappend tags $objName
	 set tags [string map [list TEXT TEXT_$objName] $tags]
	 append str $prefix " -tags {$tags}\n"
    } else {append str $line "\n"
	       }
  }

 set __tkgen_smooth_type true
 #puts [string range $str 0 [string first "\$c create" $str]]
 #puts "$objName EVAL !"
 eval [string range $str [string first "\$c create" $str] end]
 
 this Update_interaction
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Update_interaction {} {
 set canvas   [this get_canvas]
 
# Bindings for drag 
 $canvas bind $objName <ButtonPress>   "$objName Button_press   %b %x %y"
 $canvas bind $objName <ButtonRelease> "$objName Button_release %b %x %y"
 
# Bindings for zoom
 set this(zoom_factor) 1
 set b [bind [winfo toplevel $canvas] <MouseWheel>]
 set new_binding ""
 foreach line [split $b "\n"] {if {[lindex $line 0] != $objName} {append new_binding $line "\n"}}
 
 bind [winfo toplevel $canvas] <MouseWheel> $new_binding
 bind [winfo toplevel $canvas] <MouseWheel> "+ $objName trigger %W %X %Y %D"

 bind $canvas <<Wheel>> "$objName Zoom %x %y \[$objName get_delta\]"
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic get_delta {} {return $this(delta)}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic trigger {W X Y D} {
    set w [winfo containing -displayof $W $X $Y]
    if { $w == [this get_canvas] } {
        #puts "CometGDD_Edit_Q_PM_P_TK_CANVAS_basic : w = $w"
		set x [expr {$X-[winfo rootx $w]}]
        set y [expr {$Y-[winfo rooty $w]}]
        if {$D > 0} {
		  set D [expr $D / 100.0]
		 } else {set D [expr 100.0 / (-$D)]}
		set this(delta) $D
	event generate $w <<Wheel>> -rootx $X -rooty $Y -x $x -y $y
    }
 }
 
#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Button_press {b x y} {
 set C_canvas [this get_root_for_daughters]
 
 switch $b {
   1 {$C_canvas set_current_element $objName $x $y}
  }
  
 set canvas   [this get_canvas]
 set item [lindex [$canvas find overlapping $x $y $x $y] end]
 if {$item != ""} {
   set L_tags [$canvas gettags $item]
   set obj    [lindex $L_tags 0]
   if {[gmlObject info exists object $obj]} {
	  if {[lindex [gmlObject info classes $obj] 0] == "GDD_Node"} {
		switch $b {
		        1 {this prim_set_L_selected_nodes $obj}
		  default {this Display_drop_down_menu $obj $x $y}
		 }
	   }
	 }
   }
 
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Button_release {b x y} {
 set C_canvas [this get_root_for_daughters]
 set factor 1.1
 switch $b {
   1 {$C_canvas set_current_element {} 0 0}
   4 {$objName Zoom %x %y $factor}
   5 {$objName Zoom %x %y [expr 1.0/$factor]}
  }
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Zoom {x y factor} {
 set C_canvas [this get_root_for_daughters]
 set canvas   [this get_canvas]
 set this(zoom_factor) [expr $this(zoom_factor) * $factor]
 $C_canvas Zoom $objName [expr 1.0/$factor] $x $y
 $canvas itemconfigure TEXT_$objName -font "Times [expr int(12.0 / $this(zoom_factor))] normal"
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometGDD_Edit_Q_PM_P_TK_CANVAS_basic set_GDD_rel  {} {global ${objName}_choice_rel ; set ${objName}_choice_rel  $v}
Inject_code CometGDD_Edit_Q_PM_P_TK_CANVAS_basic set_GDD_type {} {global ${objName}_choice_type; set ${objName}_choice_type $v}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Display_drop_down_menu {obj x y} {
 set top ._toplevel_${objName}_${obj}
 if {![winfo exists $top]} {
   lassign [winfo pointerxy $this(canvas)] x y

   toplevel $top; 
   set b $top.destroy
   button $b -text "Destroy component" -command "puts BOUM!; destroy $top"
     pack $b -side top -fill x
   
   set f_add_node ${top}.f_add_node
   frame $f_add_node
     pack $f_add_node -side top -expand 0 -fill x
	 label ${f_add_node}.lab -text "Add a node to $obj"; pack ${f_add_node}.lab -side top
	 set f_name ${f_add_node}.f_name; frame $f_name; pack $f_name -side top -fill x
		 label $f_name.lab -text "Name : "; pack $f_name.lab -side left
		 entry $f_name.ent -textvariable ${objName}_text_var_name; pack $f_name.ent -side left -expand 1 -fill x
	 set f_rel ${f_add_node}.f_rel; frame $f_rel; pack $f_rel -side top -fill x
	     label $f_rel.lab -text "Relation type : "; pack $f_rel.lab -side left
		 set menu_rel ${f_rel}.menu_rel
		   tk_optionMenu $menu_rel ${objName}_choice_rel GDD_concretization
		   $menu_rel.menu delete 0 last
		   pack $menu_rel -side left -fill x
		   foreach T_rel [list GDD_composition GDD_concretization GDD_encapsulation GDD_extension GDD_implementation GDD_inheritance GDD_restriction GDD_specialization GDD_use] {
			 $menu_rel.menu add radiobutton -label $T_rel -command [list $objName set_GDD_rel $T_rel]
			}
	 
	 set f_type ${f_add_node}.f_type; frame $f_type; pack $f_type -side top -fill x
	     label $f_type.lab -text "Node type : "; pack $f_type.lab -side left
		 set menu_type ${f_type}.menu_type
		   tk_optionMenu $menu_type ${objName}_choice_type GDD_C&T
		   $menu_type.menu delete 0 last
		   pack $menu_type -side left -fill x
		   foreach T_type [list GDD_C&T GDD_AUI GDD_CUI GDD_FUI] {
			 $menu_type.menu add radiobutton -label $T_type -command [list $objName set_GDD_type $T_type]
			}
	 button ${f_add_node}.bt -text "ADD NEW NODE" -command [list $objName Add_a_node $obj]; pack ${f_add_node}.bt -side right

   # Let's manage the node itself !
   set f_factories ${top}.f_factories
   frame $f_factories
     pack $f_factories -side top -expand 0 -fill x
	 label ${f_factories}.lab -text "Factories :"; pack ${f_factories}.lab -side top
	 text  ${f_factories}.text -width 50 -height 4
	   ${f_factories}.text insert 0.0 [join [$obj get_L_factories] "\n"]
	   pack ${f_factories}.text -side top -fill both -expand 1
	 frame ${f_factories}.f_ptf; pack ${f_factories}.f_ptf -side top -expand 1 -fill x 
	   label ${f_factories}.f_ptf.lab -text "Plateform : "; pack ${f_factories}.f_ptf.lab -side left
	   entry ${f_factories}.f_ptf.ent -textvariable ${objName}_text_var_ptf; pack ${f_factories}.f_ptf.ent -side left -fill x -expand 1
	   global ${objName}_text_var_ptf
	   set ${objName}_text_var_ptf [$obj get_ptf]
	 
	 button ${f_factories}.bt_update -text "UPDATE NODE" -command [list $objName Update_factories $obj $f_factories]
	 pack ${f_factories}.bt_update -side right
   
   set    cmd "lassign \[split \[wm geometry $top\] +\] dim tmp tmp; lassign \[split \$dim x\] tx ty; "
   append cmd "wm geometry $top \$dim+\[expr $x - \$tx / 2\]+$y"
   after 10 $cmd
  }
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Update_factories {obj f_factories} {
 $obj set_L_factories [split [${f_factories}.text get 0.0 end] "\n"]
 
 global ${objName}_text_var_ptf
 set ptf  [set ${objName}_text_var_ptf]
 $obj set_ptf $ptf
}

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Add_a_node {obj} {
 global ${objName}_text_var_name
 global ${objName}_choice_rel
 global ${objName}_choice_type
  
 set name [set ${objName}_text_var_name]
 set type [set ${objName}_choice_type]
 set rel  [set ${objName}_choice_rel]
 
 puts "$objName Add_a_node to $obj <$name ; $type ; $rel>"
 
# Create the new node
 GDD_Node $name
 $name set_type $type

# Do we still have a relationship of the right type?
 set dest_rel ""
 foreach R [$obj get_L_dest_rel] {
   #puts "$R : [$R get_type] == $rel"
   if {[$R get_type] == $rel} {set dest_rel $R}
  }
 if {$dest_rel == ""} {set dest_rel ${obj}_rel_${rel}_for_$name
                       GDD_Relationship $dest_rel
					   $dest_rel set_name $dest_rel; $dest_rel set_type $rel
					   $dest_rel set_L_dest_nodes $obj
					   $obj Add_L_dest_rel $dest_rel
					  }

 #puts "$dest_rel Add_L_source_nodes $name"
 #puts "$name set_L_source_rel $dest_rel"
 $dest_rel Add_L_source_nodes $name
 $name set_L_source_rel $dest_rel
 
# Ask to update the graph
 this prim_Query [this get_last_query]
}



