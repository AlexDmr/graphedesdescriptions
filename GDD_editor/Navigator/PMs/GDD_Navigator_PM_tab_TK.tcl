#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_Navigator_PM_tab_TK PM_TK
#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK constructor {name descr args} {
 this inherited $name $descr
   set this(l_labels) {}
   set this(m_labels) {}
   set this(r_labels) {}
   set this(frame)    {}
   set this(is_setting) 0
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC GDD_Navigator_PM_tab_TK [L_methodes_set_GDD_Navigator] {}          {}
Methodes_get_LC GDD_Navigator_PM_tab_TK [L_methodes_get_GDD_Navigator] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK get_or_create_prims {root} {
 set this(frame) "$root.tk_${objName}_f"
 if {[winfo exists $this(frame)]} {} else {
   frame $this(frame)
     frame $this(frame).search; pack $this(frame).search -side top -fill y
       label $this(frame).search.l -text "Search for nodes : "; pack $this(frame).search.l -side left
       entry $this(frame).search.e                            ; pack $this(frame).search.e -side left -expand 1 -fill x
       bind $this(frame).search.e <Key-Return> "[this get_LC] set_mode node; [this get_LC] set_current_node \[$this(frame).search.e get\]"
     frame $this(frame).l; pack $this(frame).l -side left -expand 1 -fill y
     frame $this(frame).m; pack $this(frame).m -side left -expand 1 -fill both
     frame $this(frame).r; pack $this(frame).r -side left -expand 1 -fill y
     this update_frames
  }
 this set_root_for_daughters $root

 return [this set_prim_handle $this(frame)]
}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK update_frames {} {
 set this(is_setting) 1
 foreach l $this(l_labels) {destroy $l}
 foreach l $this(m_labels) {destroy $l}
 foreach l $this(r_labels) {destroy $l}

# puts "GDD_Navigator_PM_tab_TK update_frames (mode:[this get_mode])"
 switch [this get_mode] {
   rel  {set rel [this get_current_rel]
         $this(frame).l configure -background purple; set this(l_labels) [this Fill $this(frame).l [$rel get_L_source_nodes] purple node]
         $this(frame).m configure -background cyan ; set this(m_labels) [this Fill $this(frame).m $rel                       cyan  rel ]
         $this(frame).r configure -background purple; set this(r_labels) [this Fill $this(frame).r [$rel get_L_dest_nodes]   purple node]
        }

   node {set node [this get_current_node]
         $this(frame).l configure -background cyan ; set this(l_labels) [this Fill $this(frame).l [$node get_L_dest_rel]   cyan  rel ]
         $this(frame).m configure -background purple; set this(m_labels) [this Fill $this(frame).m $node                   purple node]
         $this(frame).r configure -background cyan ; set this(r_labels) [this Fill $this(frame).r [$node get_L_source_rel] cyan  rel ]
        }
  }
 set this(is_setting) 0
}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK Fill {f L col type} {
 set nb 0
 set L_bt {}
 foreach e $L {
   set bt $f.bt_$nb
   button $bt -text $e -background $col -command "$objName Focus_on $type $e"; pack $bt -side top -expand 1 -fill x
   lappend L_bt $f.bt_$nb
   incr nb
  }

 return $L_bt
}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK Focus_on {type e} {
 if {[string equal $e {}]} {return}
 if {[catch {set L_classes [gmlObject info classes $e]} res]} {
   return
  } else {switch $type {
            rel  {if {[lsearch $L_classes GDD_Relationship] == -1} {return}
                 }
            node {if {[lsearch $L_classes GDD_Node        ] == -1} {return}
                 }
           }
         }
 if {$this(is_setting)} {return}
# puts "GDD_Navigator_PM_tab_TK Focus_on $type $e"
 set this(is_setting) 1
 [this get_LC] set_mode $type
 switch $type {
   rel  {if {[string equal [this get_current_rel]  $e]} {
           [this get_LC] Activate_current_rel 
          } else {[this get_LC] set_current_rel  $e}
        }
   node {if {[string equal [this get_current_node] $e]} {
           [this get_LC] Activate_current_node
          } else {[this get_LC] set_current_node $e}
        }
  }
 [this get_LC] set_mode $type
 this update_frames
 set this(is_setting) 0
}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK set_current_node {n} {
 if {[winfo exists $this(frame)]} {} else {return}
 if {$this(is_setting)} {} else {this Focus_on node $n}
}

#___________________________________________________________________________________________________________________________________________
method GDD_Navigator_PM_tab_TK set_current_rel {r} {
 if {[winfo exists $this(frame)]} {} else {return}
 if {$this(is_setting)} {} else {this Focus_on rel  $r}
}
