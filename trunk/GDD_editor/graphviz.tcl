#package require Tcldot
#source Pie_menu.tcl

#_________________________________________________________________________________________________________
proc display_graph {f_name c} {
 set f [open $f_name]
   set g [dotread $f]
 close $f
 $g layout
 eval [$g render]

 return [$g  render]
}

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method GraphComet constructor args {
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

Generate_accessors GraphComet [list txt_viz txt_gdd size js_fct]

#_________________________________________________________________________________________________________
method GraphComet Canvas_to_postscript {root c f} {
 destroy $c
 canvas $c
 pack $c -expand 1 -fill both
   this GDD_to_graph $root $c
 set b [.c bbox all]
 $c postscript -file $f -x [lindex $b 0] -y [lindex $b 1] -width [expr [lindex $b 2]-[lindex $b 0]] -height [expr [lindex $b 3]-[lindex $b 1]]
}

#_________________________________________________________________________________________________________
method GraphComet get_color {t}   {return $this(${t},color)}
method GraphComet set_color {t c} {set this(${t},color) $c}

#_________________________________________________________________________________________________________
method GraphComet write_GDD_graph {f_name} {
 set f [open $f_name w]
   puts $f $this(txt_gdd)
 close $f
}
#_________________________________________________________________________________________________________
method GraphComet write_comets_graph {f_name} {
 set f [open $f_name w]
   puts $f $this(txt_viz)
 close $f
}

#_________________________________________________________________________________________________________
method GraphComet get_a_cluster {} {
 set rep "cluster_$this(num_cluster)"
 incr this(num_cluster)
 return $rep
}

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method GraphComet GDD_query_to_canvas_commands {gdd tag IP port Q} {
 set s [socket $IP $port]
   puts $s [this GDD_query_to_dot $gdd $Q]
   flush $s
   set rep [read $s]
 close $s
 
 set str ""
 foreach line [split $rep "\n"] {
   if {[regexp "^(.*) -tags \{(.*)\}.*\$" $line reco prefix tags]} {
     lappend tags $tag
	 append str $prefix " -tags {$tags}\n"
    } else {append str $line "\n"
	       }
  }
  
 return $str
}

#_________________________________________________________________________________________________________
# gc GDD_query_to_dot dsl_q "?n : Container : NODE()<-REL(type ~= GDD_inheritance)*<-\$n()"
method GraphComet GDD_query_to_dot {gdd Q} {
 $gdd QUERY $Q
 set this(L_nodes_to_relate) [lindex [$gdd get_Result] 0]
 set this(L_nodes_to_relate) [lindex $this(L_nodes_to_relate) 1]
 if {[regexp {^.*: *(.*) *:.*$} $Q reco root]} {
   lappend this(L_nodes_to_relate) [lindex $root 0]
  } else {puts "  Malformation de la requête, on abandonne."
          return
		 }
  
   set    str "digraph abstract \{\n"
   append str "compound=true\;\n"
   if {[llength $this(L_nodes_to_relate)]} {this Build_sub_graph str}
   append str "\n\}\n"
 
 return $str
}

#_________________________________________________________________________________________________________
method GraphComet Build_sub_graph {str_name} {
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
     if {[llength [Liste_Intersection [$R get_L_dest_nodes  ] $this(L_nodes_to_relate)]]} {append str "  $N -> $R\;\n"}
    }
  }
}

#_________________________________________________________________________________________________________
method GraphComet GDD_to_dot {root {f_name {}}} {
 set this(txt_gdd) "digraph abstract \{\n"
   append this(txt_gdd) "compound=true;\n"
#   append this(txt_gdd) "resolution=60;\n"
   incr this(mark)
   this GDD_NODE_to_graph this(txt_gdd) $root {  }
 append this(txt_gdd) "\n\}\n"
 
 if {$f_name == ""} {return $this(txt_gdd)} else {
   return [this write_GDD_graph $f_name]
  }
}

#_________________________________________________________________________________________________________
method GraphComet GDD_to_image {root n type} {
 this GDD_to_dot $root ${n}.dot

 exec dot -T$type ${n}.dot -o ${n}.$type
}

#_________________________________________________________________________________________________________
method GraphComet GDD_to_graph {root c} {
 this GDD_to_dot $root

 set g [dotstring $this(txt_gdd)]
 $g layout
 eval [$g render $c]

 return $g
}

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method GraphComet Comets_to_dot {L_roots {f_name {}}} {
 set this(num_cluster) 0
 set this(txt_viz) "digraph abstract \{\n"
 #size = \"$this(size),$this(size)\";\n
   append this(txt_viz) "compound=true;\n"
   foreach root $L_roots {
                       #str_name      r     level do_nesting do_daughters
     this Comets_to_viz this(txt_viz) $root 999   0          1 
    }
   incr this(mark)
 append this(txt_viz) "\n\}\n"

 if {$f_name == ""} {
   return $this(txt_viz)
  } else {return [this write_comets_graph $f_name]
         }
}

#_________________________________________________________________________________________________________
method GraphComet Comets_to_image {L_roots n type} {
 this Comets_to_dot $L_roots ${n}.dot

 exec dot -T$type ${n}.dot -o ${n}.$type
}

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method GraphComet GDD_REL_to_graph {str_name rel dec} {
 if {[$rel Has_for_marks $this(mark)]} {return 0}
 $rel set_marks $this(mark)

 upvar $str_name str
 append str $dec $rel {[label = "} [$rel get_type] {",style=filled,fillcolor="} [this get_color [$rel get_type]] {"}
   if {[string equal $this(js_fct) {}]} {} else {append str "URL=\"$this(js_fct)(REL, $rel)\""}
 append str {];} "\n"
 foreach n [$rel get_L_source_nodes] {
   this GDD_NODE_to_graph str $n $dec
   append str "$dec$n -> $rel;\n"
  }
 foreach n [$rel get_L_dest_nodes] {
   this GDD_NODE_to_graph str $n $dec
   append str "$dec$rel -> $n;\n"
  }

 return 1
}

#_________________________________________________________________________________________________________
method GraphComet GDD_NODE_to_graph {str_name node dec} {
 if {[$node Has_for_marks $this(mark)]} {return 0}
 $node set_marks $this(mark)

 upvar $str_name str
 append str $dec $node {[label = "} $node {",shape=box,style=filled,fillcolor="} [this get_color [$node get_type]] {"}
   if {[string equal $this(js_fct) {}]} {} else {append str "URL=\"$this(js_fct)(NODE, $node)\""}
 append str {];} "\n"

 foreach r [concat [$node get_L_dest_rel] [$node get_L_source_rel]] {
   this GDD_REL_to_graph str $r $dec
  }
 return 1
}

#_________________________________________________________________________________________________________
method GraphComet Comets_to_image {root n type} {
 this Comets_to_dot $root ${n}.dot

 exec dot -T$type ${n}.dot -o ${n}.$type
}

#_________________________________________________________________________________________________________
method GraphComet Comets_to_graph {root c level {do_nesting 0}} {
 set this(num_cluster) 0
 set this(txt_viz) "digraph abstract \{\n"
 #size = \"$this(size),$this(size)\";\n
   append this(txt_viz) "compound=true;\n"
   this Comets_to_viz this(txt_viz) $root $level $do_nesting 1
   incr this(mark)
 append this(txt_viz) "\n\}\n"

 set g [dotstring $this(txt_viz)]
 $g layout
 eval [$g render $c]

 return $g
}

#_________________________________________________________________________________________________________
method GraphComet Comets_to_viz {str_name r level do_nesting do_daughters {dec {}}} {
 if {[$r Contains_L_marks $this(mark)]!=-1} {return}
 $r set_L_marks $this(mark)

 upvar $str_name str

# Le noeud
 set do_cluster 0
 set level_cmd [lindex $this(L_levels) $level]
 if {[string equal $level_cmd {}] && !$do_nesting} {
   append str $dec $r {[shape=box, label = "} [$r get_name] {"];} "\n"
  } else {set do_cluster 1
          append str $dec "subgraph [this get_a_cluster] \{\n"
            append str "$dec  " $r {[label = "} [$r get_name] {"];} "\n"
            if {$do_nesting==1} {
              foreach n [$r get_handle_composing_comet] {
                set LC [$n get_LC]
                this Comets_to_viz str $LC 0 $do_nesting 1 "$dec  "
               }
             }
            if {[llength $level_cmd]>0} {
              foreach n [$r $level_cmd] {
                this Comets_to_viz str $n [expr $level+1] $do_nesting 0 "$dec  "
               }
             }
          append str $dec " \}\n"
         }
# Ses fils
 if {$do_daughters} {
   foreach d [$r get_daughters] {
     this Comets_to_viz str $d $level $do_nesting $do_daughters $dec
    }
  # Les relation du noeud avec ses fils
   if {$do_cluster} {
     foreach d [$r get_daughters] {
       append str $dec $r { -> } $d "\n"
      }
    } else {foreach d [$r get_daughters] {
              append str $dec $r { -> } $d ";\n"
             }
           }
  }
#
}

#_________________________________________________________________________________________________________
method GraphComet configure args {
 set L_cmd [split $args -]
 foreach cmd $L_cmd {
   if {[string equal $cmd {}]} {continue}
   if {[string equal [string index $cmd 0] | ]} {
     set cmd [string range $cmd 1 end]
     eval $cmd
    } else {eval "$objName $cmd"}
  }
}


#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
proc Go_oval {L} {
 set X1 [lindex $L 0]
 set Y1 [lindex $L 1]
 set X2 [lindex $L 2]
 set Y2 [lindex $L 3]
 set MX [expr ($X2+$X1)/2.0]
 set MY [expr ($Y2+$Y1)/2.0]
 set DX [expr ($X2-$X1)/2.0]
 set DY [expr ($Y2-$Y1)/2.0]
 set L_rep {}
 for {set i 0} {$i<64} {incr i} {
   set a [expr 2*3.14159265*$i/64.0]
   lappend L_rep [expr $MX+$DX*cos($a)]
   lappend L_rep [expr $MY+$DY*sin($a)]
  }
 return $L_rep
}

#_________________________________________________________________________________________________________
proc Go_and_return {L} {
 set L_back {}
 set x_prcdt [lindex $L 0]
 set y_prcdt [lindex $L 1]
 foreach {x y} [lrange $L 2 end] {
   set d [expr sqrt($x*$x+$y*$y)]
   set L_back [linsert $L_back 0 [expr $x+-$y/$d] [expr $y+$x/$d]]
  }

 return [concat $L $L_back]
}

#_________________________________________________________________________________________________________
proc GOGO_canvas {args} {
 global gml_root
 set cmd {}
 regsub {\-smooth true} $args {} gogo
 puts $gogo
 set do_y_trans 0
 set dx 0
 switch [lindex $gogo 0] {
   create  {if {[regexp "^polygon (.*) (\\-fill.*)$" [lrange $gogo 1 end] reco coords rest]} {
              set    cmd {create polygon -shape [list }
              append cmd $coords {] } $rest
             } else {
            if {[regexp "^oval (.*) (\\-fill.*)$" [lrange $gogo 1 end] reco coords rest]} {
              set L_coords [eval "Go_oval \[list $coords\]"]
              set    cmd {create polygon -shape [list }
              append cmd $L_coords {] } $rest
             } else {
            if {[regexp "^line (.*) (\\-fill.*)$" [lrange $gogo 1 end] reco coords rest]} {
              set    cmd {create polygon -shape [list }
              append cmd [Go_and_return $coords] {] } $rest " -outline black"
             } else {
            if {[regexp "^text (.*) -text (.*) -fill .*(\\-font .*) \\-state disabled (.*)$" [lrange $gogo 1 end] reco coords texte fonte reste]} {
              set    cmd {create text -transfo [list }
              append cmd $coords { 0 1 -1] } $fonte { -text } $texte { -color black } $reste
              set dx [expr -[font measure {Times-Roman} -displayof .gml_c "${texte}TT"]/2.0]
              set do_y_trans 1
             }
                    }}}
           }
   default {set cmd $args}
  }
 if {[string equal $cmd {}]} {
   puts "NON reconnu : $args"
  } else {set n [eval ".gml_c $cmd -parent $gml_root"]
          if {$do_y_trans} {
            set transfo [.gml_c itemcget $n -transfo]
            set transfo [lreplace $transfo 0 1 [expr [lindex $transfo 0]+$dx] [expr [lindex $transfo 1]+12]]
            .gml_c itemconfigure $n -transfo $transfo
           }
         }
}

if {[file exists [get_B207_files_root]]} {source [get_B207_files_root]B_canvas.tcl}


#________________________________________________________________________________________________________
#________________________________________________________________________________________________________
#________________________________________________________________________________________________________
method GraphViz constructor {root} {
 set this(gc) "${objName}_gc"
   GraphComet $this(gc)
 set this(B_graph) "${objName}_Bgraph"
 BIGre_canvas $this(B_graph) $root
 set this(fen_graph)      [$this(B_graph) get_fen]
 set this(noeud_rep_fils) [$this(fen_graph) Noeud_repere_fils]
   set this(rap_fen_graph) [B_rappel [Interp_TCL] "$this(fen_graph) Ne_pas_pre_rendre \[expr 1-\[$this(noeud_rep_fils) A_changer\]\]"]
   set n [N_i_mere Noeud_scene]
   $n abonner_a_LR_parcours [$n LR_Av_PR_fils] [$this(rap_fen_graph) Rappel]
 set this(rap_fen_graph_dim) [B_rappel [Interp_TCL] "$this(noeud_rep_fils) A_changer 1"]
   $this(fen_graph) abonner_a_dimension [$this(rap_fen_graph_dim) Rappel]
}
#________________________________________________________________________________________________________
method GraphViz get_Canvas {} {return $this(B_graph)}
method GraphViz get_graph  {} {return $this(gc)}
#________________________________________________________________________________________________________
#________________________________________________________________________________________________________
#________________________________________________________________________________________________________
inherit GraphVizComet GraphViz
method GraphVizComet constructor {root {c_root {}}} {
 this inherited $root
 if {[string equal $c_root {}]} {} else {this Represents_from_comet_root $c_root}

# Gestion Pie menu
 set L {}
 set pm_op_comet ${objName}_pm_op_comet
 Pie_menu $pm_op_comet
   set tab_oval [ProcOvale 0 0 50 50 60]
   set tab_trou [ProcOvale 0 0 40 40 60]
   set p [B_polygone]; $p Ajouter_contour 60 [$tab_oval Tab]; $p Retirer_contour 60 [$tab_trou Tab]; $p Couleur 1 0 0 1; lappend L $p
   set p_original $p
   set p [B_polygone]; $p Maj_poly $p_original; $p Couleur 0 1 0 1; lappend L $p
   set p [B_polygone]; $p Maj_poly $p_original; $p Couleur 0 0 1 1; lappend L $p
   set p [B_polygone]; $p Maj_poly $p_original; $p Couleur 1 1 0 1; lappend L $p
   set p [B_polygone]; $p Maj_poly $p_original; $p Couleur 0 1 1 1; lappend L $p
   set p [B_polygone]; $p Maj_poly $p_original; $p Couleur 1 0 1 1; lappend L $p
   $pm_op_comet set_choices $L
     set pm_root [$pm_op_comet get_root]
     set ns [N_i_mere Noeud_scene]
     set this(rap_pie) [B_rappel_Fire_Forget $ns "abonner_a_LR_parcours_deb [$ns LR_Av_PR_fils]" "$this(fen_graph) A_changer 1; [$this(fen_graph) Noeud_repere_fils] A_changer 1"]

# Gestion du clic sur les noeuds
 set this(rap_clic_graph) [B_rappel [Interp_TCL]]
   set pm $pm_op_comet
   set this(pt_tmp) [B_point]
   set    cmd "set info \[$this(rap_clic_graph) Param\]; set info \[Void_vers_info \$info\]; set n \[\$info NOEUD\];"
   append cmd {set tag [$n Val tags]; if } "\{" {[regexp "(node\[0-9\]+)" $tag reco node_viz]} "\} \{" {set comet [$node_viz showname]; puts "Clic on:\n  /BIGre node : $n\n  /GraphViz node : $node_viz\n  /comet node : $comet"; }
   append cmd "$pm UnPlug; $pm Plug_under $this(fen_graph); $pm Deploy; $this(pt_tmp) maj \[\$info Point_au_contact\]; \$n Changer_coordonnees_inverse $this(pt_tmp); \[$pm get_root\] Origine $this(pt_tmp); $ns abonner_a_LR_parcours_deb [$ns LR_Av_PR_fils] [$this(rap_pie) Rappel]; "
   append cmd "\}"
   $this(rap_clic_graph) Texte $cmd
 $this(noeud_rep_fils) abonner_a_detection_pointeur [$this(rap_clic_graph) Rappel]

}

#_________________________________________________________________________________________________________
method GraphVizComet get_rap_pie {} {return $this(rap_pie)}

#________________________________________________________________________________________________________
method GraphVizComet Represents_from_comet_root {c_root} {
 $this(B_graph) Vider
 $this(gc) Comets_to_graph $c_root $this(B_graph) 4
 $this(B_graph) Gestion_ctc
 [$this(B_graph) get_repere_fils] A_changer
}

#________________________________________________________________________________________________________
method GraphVizComet Represents_from_GDD_root {gdd_root} {
 $this(B_graph) Vider
 $this(gc) GDD_to_graph $gdd_root $this(B_graph)
 $this(B_graph) Gestion_ctc
 [$this(B_graph) get_repere_fils] A_changer
}

#________________________________________________________________________________________________________
#if {[info exist noeud_partage]} {
#  if {[gmlObject info exists object gvc]} {} else {
#                                                   #GraphVizComet gvc $noeud_partage cr
#                                                   GraphVizComet gvc $noeud_partage
#                                                   gvc Represents_from_GDD_root IS_root
#                                                  }
# }
