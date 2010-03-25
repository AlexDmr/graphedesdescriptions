package require tdom

#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit GDD_Editor_PM_FC_standard Physical_model
#___________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard constructor {name descr args} {
 this inherited $name $descr
   this set_nb_max_mothers 1
   this set_cmd_placement {}
   
   set this(DSL_GDD) ${objName}_DSL_GDD 
   DSL_GDD_QUERY $this(DSL_GDD)
   socket -server "$objName QUERY" 8765

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
#________________________________________________________________ Partie serveur ___________________________________________________________
#___________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard QUERY {chan ad num} {
 fconfigure $chan -blocking 0
 fileevent $chan readable "$objName Process_QUERY $chan"
}

#___________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Process_QUERY {chan} {
 if { [eof $chan] } {close $chan
                     return
                    }

 set txt [read $chan]
 puts "received GDD QUERY :\n$txt"
   $this(DSL_GDD) QUERY $txt
   puts $chan [$this(DSL_GDD) get_Result]
 close $chan
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC GDD_Editor_PM_FC_standard [L_methodes_set_GDD_Editor] {}          {}
Methodes_get_LC GDD_Editor_PM_FC_standard [L_methodes_get_GDD_Editor] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Load_types_from_file {f_name} {
 set f [open $f_name]
   this Load_types [read $f]
 close $f
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Load_types {txt} {
 set this(L_types) [Generate_GDD_types $txt]
 set this(root_node_type) GDD_node
 set this(root_rel_type)  GDD_relation
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard constraint {node L_args L_daughters} {

}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard factory {node L_args L_daughters} {
 set id {}
 #puts "L_args = \{$L_args\}"
 set t [llength $L_args]
 for {set p 0} {$p<$t} {incr p 2} {
   if {[string equal [lindex $L_args $p] id]} {incr p; set id [lindex $L_args $p]; break}
  }

 if {[string equal $id {}]} {return}
 #puts "$node Add_L_factories $id"
 $node Add_L_factories $id
}

method GDD_Editor_PM_FC_standard attribut {node L_args L_daughters} {
 set id {}
 #puts "L_args = \{$L_args\}"
 set t [llength $L_args]
 for {set p 0} {$p<$t} {incr p 2} {
   if {[string equal [lindex $L_args $p] id]} {incr p; set id [lindex $L_args $p]; break}
  }

 if {[string equal $id {}]} {return}
 #puts "$node Add_L_factories $id"
 $node Add_L_attributs $id
}



#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard to_XML {L} {
 puts "$objName to_XML {$L}"
 set rep {}
 foreach balise $L {
 foreach {tag L_atts L_d} $balise {
   puts "  tag   : $tag\n  L_att : $L_atts\n  L_d   : $L_d"
   if {[string equal $tag "#text"]} {
     append rep $L_atts
	} else {append rep "<$tag"
	          foreach {att val} $L_atts {append rep " $att=\"$val\""}
			  append rep ">"
			  append rep {<![CDATA[} [this to_XML $L_d] {]]>}
	        append rep "</$tag>"
	       }
  }
  }
 return $rep
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard MetaData {node L_args L_daughters} {
 puts "MetaData:\n  node : $node\n  L_args : $L_args\n  L_daughters : $L_daughters"
 set id {}

 foreach {att val} $L_args {
   if {[string equal $att id]} {set id $att; break}
  }

 if {[string equal $id {}]} {return}
 
 puts "___$val : $L_daughters"
 $node Add_MetaData $val [this to_XML $L_daughters]
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Add_element {e} {
 set attribs [lindex $e       1]
 set id      [lindex $attribs 1]
 set cmd     {}
 set t       [llength $attribs]
 for {set i 2} {$i<$t} {incr i 2} {
   append cmd -[lrange $attribs $i [expr $i+1]] { }
  }
# Création ou mise à jour de l'objet
# puts "MAJ de $id ([lindex $e 0]) avec $cmd"
 eval "[this get_Common_FC] Add_or_update_[lindex $e 0] $id $cmd"
# Analyse des fils qui représentent des objets à créer et ajouter à l'instance du père
 foreach f [lindex $e 2] {
   set method    [lindex $f 0]
   set arguments [lindex $f 1]
   set daughters [lindex $f 2]
   set obj [eval "$objName $method $id \{$arguments\} \{$daughters\}"]
  }

# Selon que ce soit un noeud ou une relation les initialisations diffèrent
 if {[string equal [lindex $e 0] relation]} {
   return " $id"
  } else {$id set_L_source_rel {}
          $id set_L_dest_rel   {}
          return {}
         }
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Add_element_dom {e_dom} {
 return [this Add_element [$e_dom asList]]
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Load_GDD {f_name} {
 #puts "replace $f_name with gdd_dimitri.xml"
 #set f_name "gdd_dimitri.xml"
 puts "GDD_Editor_PM_FC_standard Load_GDD $f_name"
 
 set f [open $f_name]
   dom parse [read $f] doc
   $doc documentElement root
     # Old style, with xml2list 
     # set L_rep {}
     # xml2list [read $f] L_rep
	 # set L_rep [lindex $L_rep 0]
   set L_rep [$root asList]
   
   set L_rels {}
   foreach e [lindex $L_rep 2] {
     append L_rels [this Add_element $e]
    }
   set L "\[list $L_rels\]"
   set L [subst $L]
   foreach rel $L {
     foreach n [$rel get_L_source_nodes] {$n Add_L_source_rel $rel}
     foreach n [$rel get_L_dest_nodes]   {$n Add_L_dest_rel   $rel}
    }
 close $f
 return $L_rep
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Save_factory {f strm} {
 puts $strm "<factory id=\"$f\"></factory>"
}
method GDD_Editor_PM_FC_standard Save_attributs {a strm} {
	if {$a != ""} {
		puts $strm "<attribut id=\"$a\"></attribut>"
	}
}
#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Save_node {n m strm} {
 if {[$n Has_for_marks $m]} {return}
 $n set_marks $m
 puts $strm "<node id=\"[string map [list & "&amp;"] $n]\" set_type=\"[string map [list & "&amp;"] [$n get_type]]\" set_descriptions=\"[string map [list & "&amp;"] [$n get_descriptions]]\" set_ptf=\"[string map [list & "&amp;"] [$n get_ptf]]\">"
   set L_f [$n get_L_factories]
   if {[string equal $L_f {}]} {} else {
     puts "\n"
     foreach f $L_f {
       this Save_factory $f $strm
      }
    }
#sauvetgarde des attributs 
   set L_a [$n get_L_attributs]
   if {[string equal $L_a {}]} {} else {
     puts "\n"
     foreach a $L_a {
       this Save_attributs $a $strm
      }
    }

	# MetaDatas
   foreach d [$n get_MetaData] {
	 puts $strm "<MetaData id=\"[lindex $d 0]\"><!\[CDATA\[[lindex $d 1]\]\]></MetaData>"
    }
 puts $strm "</node>"

 foreach r [concat [$n get_L_source_rel] [$n get_L_dest_rel]] {
   this Save_rel $r $m $strm
  }
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Save_rel {r m strm} {
 if {[$r Has_for_marks $m]} {return}
 $r set_marks $m

 foreach n [concat [$r get_L_source_nodes] [$r get_L_dest_nodes]] {
   this Save_node $n $m $strm
  }

 puts $strm "<relation id=\"[string map [list & "&amp;"] $r]\" set_L_source_nodes=\"[string map [list & "&amp;"] [$r get_L_source_nodes]]\" set_L_dest_nodes=\"[string map [list & "&amp;"] [$r get_L_dest_nodes]]\" set_type=\"[string map [list & "&amp;"] [$r get_type]]\"></relation>"
}

#________________________________________________________________________________________________________________________________________
method GDD_Editor_PM_FC_standard Save_GDD {f_name} {
puts "saving GDD in $f_name"
 set f [open $f_name w+]
   puts $f {<GDD set_root_node="IS_root">}
   this Save_node IS_root [clock seconds] $f
   puts $f {</GDD>}
 close $f
}
