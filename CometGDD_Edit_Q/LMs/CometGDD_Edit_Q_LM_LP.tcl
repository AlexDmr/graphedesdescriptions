inherit CometGDD_Edit_Q_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_LM_LP constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this Add_PM_factories [Generate_factories_for_PM_type [list {CometGDD_Edit_Q_PM_P_TK_CANVAS_basic Ptf_TK_to_CANVAS} \
                                                       ] $objName]
 
 this Init_proxy_graph_builder 127.0.0.1 10010
 
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometGDD_Edit_Q_LM_LP [P_L_methodes_set_CometGDD_Edit_Q] {} {$this(L_actives_PM)}
Methodes_get_LC CometGDD_Edit_Q_LM_LP [P_L_methodes_get_CometGDD_Edit_Q] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_LP {} {return [P_L_methodes_set_CometGDD_Edit_Q]}
Generate_LM_setters CometGDD_Edit_Q_LM_LP [P_L_methodes_set_CometGDD_Edit_Q_COMET_RE_LP]

#___________________________________________________________________________________________________________________________________________
Generate_accessors CometGDD_Edit_Q_LM_LP [list proxy_graph_builder]

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_LM_LP Init_proxy_graph_builder {IP port} {
 set this(proxy_graph_builder) ${objName}_GDD_PROXY_FOR_GRAPH
 PROXY_GRAPH_BUILDER $this(proxy_graph_builder) $objName $IP $port
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometGDD_Edit_Q_LM_LP set_dot_descr {
 $this(proxy_graph_builder) set_is_up_to_date 0
} {} __CANVAS_DESCRIPTION_IS_NO_MORE_UP_TO_DATE__

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PROXY_GRAPH_BUILDER constructor {LM IP port} {
 set this(LM)            $LM
 set this(IP)            $IP
 set this(port)          $port
 set this(is_up_to_date) 0
 set this(canvas_descr)  ""
 
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors PROXY_GRAPH_BUILDER [list is_up_to_date canvas_descr]

#___________________________________________________________________________________________________________________________________________
method PROXY_GRAPH_BUILDER get_canvas_descr {} {
 if {$this(is_up_to_date)} {return $this(canvas_descr)}
 
 set descr [$this(LM) get_dot_descr]
 if {$descr != ""} {
	 if {![catch {set s [socket $this(IP) $this(port)]} err]} {
	   puts "  Transmited : \[$this(LM) get_dot_descr\]"
	   puts $s $descr; flush $s
	   fconfigure $s -blocking 0
	   set this(canvas_descr) ""
	   fileevent $s readable "$objName Update_canvas_descr $s"
	  } else {puts "  $objName PROXY_GRAPH_BUILDER::get_canvas_descr ERROR !!!\n$err "
	         }
  } 
 return ""
}
#___________________________________________________________________________________________________________________________________________
method PROXY_GRAPH_BUILDER Update_canvas_descr {chan} {
 if {[eof $chan]} {close $chan 
                   this New_canvas_descr_available
				   return
				  }
 append this(canvas_descr) [read $chan]
}

#___________________________________________________________________________________________________________________________________________
method PROXY_GRAPH_BUILDER New_canvas_descr_available {} {
 set this(is_up_to_date) 1
}

#___________________________________________________________________________________________________________________________________________
Manage_CallbackList PROXY_GRAPH_BUILDER [list New_canvas_descr_available] end

