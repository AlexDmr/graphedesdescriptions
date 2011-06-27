set P [pwd]
  if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)/Comets/} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
 source gml_Object.tcl
cd $P

if {[catch {package require Tcldot} err]} {puts "TclDot is not installed, good luck to find it..."}


#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator constructor {port} {
 set this(socket_server) [socket -server "$objName ClientConnection" $port]
 fconfigure $this(socket_server) -buffersize 65536
 
 set this(last_rep) {}
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator get_last_rep {} {return $this(last_rep)}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator dispose {} {
 close $this(socket_server) 
 this inherited
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator get_server_port { } {return [lindex [fconfigure $this(socket_server) -sockname] 2]}
method GraphDotGenerator set_server_port {port} {
 catch "close $this(socket_server)"
 set this(socket_server) [socket -server "$objName ClientConnection" $port]
 fconfigure $this(socket_server) -buffersize 65536
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator ClientConnection {chan ad num} {
 fconfigure $chan -blocking 0 -buffersize 65536
 fileevent $chan readable "$objName Read_graph_from $chan"
 puts "Connection de $ad;$num sur $chan"
 set this($chan,val) ""
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator Data_in {chan} {return $this($chan,val)}
#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator Read_graph_from {chan} {
 puts "$objName Read_graph_from $chan"
 if { [eof $chan] } {puts "___ EOF on $chan"; close $chan; return}
 append this($chan,val) [read $chan]
#puts "  * Received something : $this($chan,val)"
 if {![regexp "^.*\}\n*$" $this($chan,val)]} {return}
 #if {![string equal "\n\}\n\n" [string range $this($chan,val) end-3 end]]} {return}
   if {[catch {set rep [$objName Generate_TK_graph_from_txt this($chan,val)]} err]} {
     puts "\nERROR : $err\nEND_ERROR"
	 puts $chan "\n \n\n"
	 close $chan
	 return
	}
   set this(last_rep) $rep
   puts $chan $rep
   #puts $rep
 close $chan
 puts "__ close $chan"
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator Generate_TK_graph_from_txt {txt_name} {
 puts "$objName Generate_TK_graph_from_txt"
 upvar $txt_name txt
   puts -nonewline *
   set g [dotstring $txt]
   puts -nonewline *
   $g layout
   puts -nonewline *
   set rep [$g render]
   #puts $rep
  # Modification des tags pour les remplacer par les identifiants des noeuds ou des relations
   if {[catch "$objName Replace_tags rep" err]} {puts "ERROR : $err"}
   $g delete
 puts "__ END $objName Generate_TK_graph_from_txt"
 return $rep   
}

#___________________________________________________________________________________________________________________________________________
method GraphDotGenerator Replace_tags {txt_name} {
 puts "$objName Replace_tags"
 upvar $txt_name txt
 set rep {}
 set L [split $txt "\n"]
 foreach e $L {
   if {[regexp {^(.*) -tags [0-9]*(node|edge|graph)([0-9]*)$} $e reco deb n_or_e num]} {
     append rep "$deb -tags " 
	 if {[string equal -length 4 $n_or_e edge]} {
	   set L_nodes [$n_or_e$num listnodes]
	   set n_dep [[lindex $L_nodes 0] showname]
	   set n_arr [[lindex $L_nodes 1] showname]
	   append rep "{[list $n_dep $n_arr]}\n "
	  } else {if {[regexp {c create text} $e]} {
				puts "  TEXT : $e"
				append rep "{[list [$n_or_e$num showname] TEXT]} \n"
			   } else {if {$n_or_e != "graph"} {append rep "{[list [$n_or_e$num showname]]}\n"} else {append rep "{GRAPH}\n"}
			          }
			 }
    } else {append rep $e "\n"}
  }
 
 set __tkgen_smooth_type 1
 set txt $rep 
}

#___________________________________________________________________________________________________________________________________________
proc pipo_graph {} {
 set txt "digraph G {\n"
 for {set i 0} {$i <10000} {incr i} {
   append txt " N_$i -> NP_$i;\n"
  }
 append txt "}\n"
 return $txt
}
