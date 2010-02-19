# Grammar                                                                       #
# QUERY       : '?'List_var_nodes ':' root ':' EXPR                             #
# EXPR        : NODE | NODE ARROW "NOREL" | NODE ARROW RELATION                 #
# NODE        : "Node" '(' COND_NODE ')'                                        #
#             | '$'var_node                                                     #
# RELATION    : REL_OR ARROW EXPR                                               #
# REL_OR      : REL_SUCC | REL_SUCC '|' REL_OR                                  #
# REL_SUCC    : SIMPLE_REL | SIMPLE_REL OP_SIMPLE_REL_SUCC REL_SUCC             #
# OP_SIMPLE_REL_SUCC : '>' | '<'                                                #
# SIMPLE_REL  : "Rel" '(' COND_REL ')' [*]                                      #
#             | '(' RELATION ')'                                                #
# C'est SGQ, un DSL issue d'un GPL qui parcours le GDD. De sorte qu'on peut dire que c'est un ATL... #
#___________________________________________________________________________________________________________________________________________
proc Afficher_hierarchy {L {dec {}}} {
 if {[llength $L]==0} {return}
 if {[llength [lindex $L 0]]==1} {
   puts "$dec[lindex $L 0] ([lindex $L 1])"
   Afficher_hierarchy [lindex $L 2] "$dec  "
  } else {foreach e $L {Afficher_hierarchy $e $dec}
         }
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#____________________________________________________ DSL for querying the GDD _____________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY constructor {} {
 set this(dico_query) [dict create "" ""]

 set this(dec) ""
 set this(lexic,left_arrow)  {<-}
 set this(lexic,right_arrow) {->}
 set this(lexic,succ_left)   {<}
 set this(lexic,succ_right)  {<}
 set this(lexic,letters)     {[a-zA-Z0-9_"]}
 set this(lexic,spaces)      {[ \n\t]}
 set this(lexic,op_cmp)      {[!~=]}
 set this(ERROR)             {}

 set this(L_vars) {}
 set this(current_var_name) {}
 set this(current_var_vals) {}

 set this(rel_bidon)  "${objName}_rel_bidon" ; GDD_Relationship $this(rel_bidon) ; $this(rel_bidon) set_type GDD_inheritance
 set this(node_bidon) "${objName}_node_bidon"; GDD_Node         $this(node_bidon); $this(rel_bidon) set_type GDD_CUI
 
 set this(propagate_node) 0
}
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY destructor {} {
 $this(rel_bidon)  dispose
 $this(node_bidon) dispose
 this inherited
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors DSL_GDD_QUERY ERROR
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)*<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)<REL(type~=GDD_inheritance)<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)*<REL(type~=GDD_inheritance)<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       ## if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)|REL(type~=GDD_inheritance)*<REL(type~=GDD_inheritance)<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)*<-$n()<-NOREL}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type~=GDD_inheritance)*<-$n()<-REL()<-NODE()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n : Choice : NODE()<-REL(type==GDD_implementation)|REL(type~=GDD_inheritance)*<REL(type==GDD_implementation)<-$n()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n,s : Interleaving : NODE()<-REL(type==GDD_concretization)|REL(type~=GDD_inheritance&&type!~=GDD_concretization)*<REL(type==GDD_concretization)<-$n(type==GDD_AUI)<-REL(type~=GDD_inheritance)*<-$s()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
# if {[dsl_q QUERY {?n,s : Interleaving : NODE()<-REL(type~=GDD_inheritance&&type!~=GDD_concretization)*<REL(type==GDD_concretization)<-$n(type==GDD_AUI)<-REL(type~=GDD_inheritance)*<-$s()}]} {puts "Result : [dsl_q get_Result]"} else {puts "ERROR : [dsl_q get_ERROR]"}       #
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY QUERY {str} {
 if {[dict exists $this(dico_query) $str]} {
   set this(L_vars) [dict get $this(dico_query) $str]
   return 1
  }


 set this(ERROR)  {}
 set this(L_vars) {}
 set this(L_var_names) {}
 set this(current_pos_var_names) -1
 set this(current_var_name) {}
 set this(current_var_vals) {}

 this get_new_mark
 #puts "$objName:\n$str"
 if {[regexp "^$this(lexic,spaces)*\?$this(lexic,spaces)*(.*)$this(lexic,spaces)*:$this(lexic,spaces)(.*)$this(lexic,spaces):$this(lexic,spaces)(.*)\$" $str reco str_L_vars root str]} {
   this L_VAR_NODES str_L_vars
   this EXPR str $root this(L_vars)
   if {[llength [lindex $this(L_vars) 2]]==0} {set this(L_vars) [list $this(L_vars)]}
  }
# puts "Rest:\n$str"
 if {$this(ERROR) == ""} {
   dict set this(dico_query) $str [this get_Result]
   return 1
  } else {return 0}
}

#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY get_Result {} {
 if {[llength [lindex $this(L_vars) 0]] != 3} {set this(L_vars) [list $this(L_vars)]}
 return $this(L_vars)
}
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY L_VAR_NODES {str_name} {
 upvar $str_name str

 set L [split $str ,]
 foreach v $L {
   regexp "^$this(lexic,spaces)*($this(lexic,letters)*)$this(lexic,spaces)*$" $v reco v
   #puts "Ajout de la variable '$v'"
#   lappend this(L_vars) $v
  }
}

#___________________________________________________________________________________________________________________________________________
# EXPR        : NODE | NODE ARROW "NOREL" | NODE ARROW RELATION                           #
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY EXPR {str_name node L_vars_name} {
 upvar $str_name str
 upvar $L_vars_name L_vars

 #puts "EXPR:\n  str  : $str\n  node : $node"
 set L_var_tmp  {}
 set L_bidon {}
 # XXX EVITONS LES RECURSIONS INFINIES
   set this(current_node) $node
 # X_________________________________X

 set node [this NODE str $node L_var_tmp]
 #if {[string length $L_var_tmp]>0} {puts "Trouvé en premier passage : \{$L_var_tmp\}"}
 if {[llength $node]==0} {
   if {[regexp "^$this(lexic,left_arrow)(.*)$" $str reco str]} {
     if {[regexp "^$this(lexic,spaces)*NOREL(.*)$" $str reco str]} {
    } else {this RELATION str $this(rel_bidon) L_bidon}
  } else {if {[regexp "^$this(lexic,right_arrow)(.*)$" $str reco str]} {
            if {[regexp "^$this(lexic,spaces)*NOREL(.*)$" $str reco str]} {
             } else {this RELATION str $this(rel_bidon) L_bidon}
           }
         }
   set L_vars {}
   return {}
  }

 # XXX EVITONS LES RECURSIONS INFINIES
   set this(current_node) $node
 # X_________________________________X

 set new_L_nodes {}
 set str_rel $str
 set L_vars_svt {}
 if {[regexp "^$this(lexic,left_arrow)(.*)$" $str reco str]} {
   if {[regexp "^$this(lexic,spaces)*NOREL(.*)$" $str reco str]} {
     if {[llength [$node get_L_dest_rel]]==0} {set new_L_nodes $node} else {set new_L_nodes {}}
    } else {
            set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
            foreach r [$node get_L_dest_rel] {
              set str_rel $str
              set L_var_svt_tmp {}
                Add_list new_L_nodes [this RELATION str_rel $r L_var_svt_tmp]
                # XXX EVITONS LES RECURSIONS INFINIES
                  set this(current_node) $node
                # X_________________________________X
              this Update_L_vars L_vars_svt L_var_svt_tmp
              set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
             }
            # Just to parse correctly...
            this RELATION str $this(rel_bidon) L_bidon
            # XXX EVITONS LES RECURSIONS INFINIES
              set this(current_node) $node
            # X_________________________________X

           }
  } else {if {[regexp "^$this(lexic,right_arrow)(.*)$" $str reco str]} {
            if {[regexp "^$this(lexic,spaces)*NOREL(.*)$" $str reco str]} {
              if {[llength [$node get_L_source_rel]]==0} {set new_L_nodes $node} else {set new_L_nodes {}}
             } else {set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
                     foreach r [$node get_L_source_rel] {
                       set str_rel $str
                       set L_var_svt_tmp {}
                         Add_list new_L_nodes [this RELATION str_rel $r L_var_svt_tmp]
                         # XXX EVITONS LES RECURSIONS INFINIES
                           set this(current_node) $node
                         # X_________________________________X

                       this Update_L_vars L_vars_svt L_var_svt_tmp
                       set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
                      }
                     # Just to parse correctly...
                     this RELATION str $this(rel_bidon) L_bidon
                     # XXX EVITONS LES RECURSIONS INFINIES
                       set this(current_node) $node
                     # X_________________________________X
                    }
           } else {set new_L_nodes $node}
         }

 # Managing variables.
 if {[string equal $new_L_nodes {}]} {} else {
   if {[string length $L_var_tmp]==0} {
     #puts "Initialisation de L_vars=\{$L_vars\} avec \{$L_vars_svt\}"
     set L_vars $L_vars_svt
    } else {#puts "Update de L_vars=\{$L_vars\} avec L_tmp=\{$L_var_tmp\} et L_svt=\{$L_vars_svt\}"
            set L_to_add $L_var_tmp
            set L_to_add [lreplace $L_to_add 2 2 $L_vars_svt]
            this Update_L_vars L_vars L_to_add
            #puts "  \{$L_vars\}"
           }
  }

 return $new_L_nodes
}

#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY Update_L_vars {L_name L_tmp_name} {
 upvar $L_name L
 upvar $L_tmp_name L_tmp

 if {[string length $L_tmp]==0} {return}
 if {[string length $L]==0}     {set L $L_tmp; return}
 if {[string equal [lindex $L 0] [lindex $L_tmp 0]]} {
   if {[string length [lindex $L 2]]==0} {
     set L_nodes [lindex $L 1]
     Add_list L_nodes [lindex $L_tmp 1]
     set L [lreplace $L 1 1 $L_nodes]
    } else {set L [list $L $L_tmp]}
  } else {if {[llength [lindex $L_tmp 0]]==1} {
            lappend L $L_tmp
           } else {foreach e $L_tmp {
                    lappend L $e
                   }
                  }
         }
}

#___________________________________________________________________________________________________________________________________________
# NODE        : "Node" '(' COND_NODE ')'                                                                                                   #
#             | '$'var_node                                                                                                                #
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY get_new_mark {} {
 set this(mark_no_loop) [clock clicks]
}

#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY NODE {str_name node L_vars_name} {
 upvar $str_name     str
 upvar $L_vars_name  L_vars

# ALlons y donc...
 if {[regexp "^NODE$this(lexic,spaces)*\\((.*)$" $str reco str]} {
   set str_cond [Compensate str ( ) 1]
   if {[string equal $node $this(node_bidon)]} {return {}}
   set str_cond_tmp $str_cond
   if {[this COND_NODE str_cond $node]} {
     #puts "RECONNU1 : $node : $str_cond_tmp"
     return $node
    }
  } else {if {[regexp "^\\\$($this(lexic,letters)*)$this(lexic,spaces)*\\((.*)$" $str reco var str]} {
            set str_cond [Compensate str ( ) 1]
            if {[string equal $node $this(node_bidon)]} {return {}}
            set str_cond_tmp $str_cond
            if {[this COND_NODE str_cond $node]} {
              set L_vars [list $var $node {}]
              #puts "RECONNU2 : $node : $str_cond_tmp"
              return $node
             }
            return {}
           }
         }

 append this(ERROR) "\n" "Wanted a node and found:\n$str"
 return {}
}

#___________________________________________________________________________________________________________________________________________
# COND_NODE : COND_NODE_AND '||' COND_NODE | COND_NODE_AND
method DSL_GDD_QUERY COND_NODE {str_name node} {
 upvar $str_name str

 if {[this COND_NODE_AND str $node]} {return 1}
 if {[regexp "^\\|\\|$this(lexic,spaces)*(.*)$" $str reco str]} {
   return [this COND_NODE str $node]
  }

 return 0
}
#___________________________________________________________________________________________________________________________________________
# COND_NODE_AND : COND_NODE_NOT '&&' COND_NODE_AND | COND_NODE_NOT
method DSL_GDD_QUERY COND_NODE_AND {str_name node} {
 upvar $str_name str

 #puts "  $objName COND_NODE_AND $str"
 if {[this COND_NODE_NOT str $node]} {} else {return 0}
 if {[regexp "^ *\\&\\&$this(lexic,spaces)*(.*)$" $str reco str]} {
   return [this COND_NODE_AND str $node]
  } else {#puts "    PAS de && détecté dans \"$str\""
         }
 return 1
}

#___________________________________________________________________________________________________________________________________________
# COND_NODE_AND : '!' COND_BASE | COND_BASE
method DSL_GDD_QUERY COND_NODE_NOT {str_name node} {
 upvar $str_name str

 if {[regexp "^!$this(lexic,spaces)*(.*)" $str reco str]} {
   if {[this COND_BASE str $node]} {return 0} else {return 1}
  } else {set rep [this COND_BASE str $node]
          #puts "    $objName COND_NODE_NOT $node {$str} => $rep"
          return $rep
         }
}

#___________________________________________________________________________________________________________________________________________
# COND_BASE : '(' COND_NODE ')' | accessor OP val
# OP        : == | != | ~=
method DSL_GDD_QUERY COND_BASE {str_name node} {
 upvar $str_name str

 if {[string equal $str {}]} {return 1}
 if {[regexp "^\\((.*)$" $str reco str]} {
   set str_inside [Compensate str ( ) 1]
   set str [regexp "^$this(lexic,spaces)*(.*)$" $str reco str]
   return [this COND_NODE str_inside $node]
  }
 if {[regexp "^($this(lexic,letters)*)$this(lexic,spaces)*($this(lexic,op_cmp)*)$this(lexic,spaces)*($this(lexic,letters)*)$this(lexic,spaces)*(.*)$" $str reco acc op val str]} {
   # Rattraper le coup du & simple...utile pour GDD_C&T
     if {[string equal -length 1 $str &] && ![string equal -length 2 $str &&]} {
       #puts "    CAS DU & simple ou double !!!\n        AVANT rattrapage : $str"
       regexp "^(&$this(lexic,letters)*)$this(lexic,spaces)*(.*)$" $str reco val_s str
       #puts "        APRES rattrapage : $str"
       set val $val$val_s
      }
   # OK on avance
   if {[catch "set rep \[$node get_$acc\]" res]} {append this(ERROR) "\n" "Invalid accessor ($acc) for NODE or REL ($node).\n  acc : $acc\n   op : $op\n  val : $val\n$res"; return 0}
   switch $op {
     ==  {return [string equal $rep $val]}
     !=  {return [expr ![string equal $rep $val]]}
     ~=  {switch $acc {
            type {if {[catch "set r \[$rep Is_a $val\]" res]} {
                    append this(ERROR) "\n" "Invalid operation ~= between $rep and $acc. Maybe $acc is not a GDD type ($acc return $rep for NODE or REL $node) \n$res"
                    return 0
                   } else {return $r}
                 }
            ptf  {if {[catch "set r \[$val Accept_for_daughter $rep\]" res]} {
                    append this(ERROR) "\n" "Invalid operation ~= between $rep and $acc. Maybe $acc is not a plateform\n$res"
                    return 0
                   } else {return $r}
                 }
            default {return [expr [lsearch $rep $val]!=-1]
                    }
           }
         }
     !~= {switch $acc {
            type {if {[catch "set r \[$rep Is_a $val\]" res]} {
                    append this(ERROR) "\n" "Invalid operation !~= between $rep and $acc. Maybe $acc is not a GDD type ($acc return $rep for NODE or REL $node) \n$res"
                    return 0
                   } else {return [expr 1-$r]}
                 }
            ptf  {if {[catch "set r \[$val Accept_for_daughter $rep\]" res]} {
                    append this(ERROR) "\n" "Invalid operation ~= between $rep and $acc. Maybe $acc is not a plateform\n$res"
                    return 0
                   } else {return [expr 1-$r]}
                 }
            default {return [expr [lsearch $rep $val]==-1]
                    }
           }
         }
     default {puts "Operator unknown : \"$op\""}
    }

   append this(ERROR) "\n" "Invalid condition:\n$str"
   return 0
  } else {return 0}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
# RELATION    : REL_OR ARROW EXPR                                               #
# REL_OR      : REL_SUCC | REL_SUCC '|' REL_OR                                  #
# REL_SUCC    : SIMPLE_REL | SIMPLE_REL OP_SIMPLE_REL_SUCC REL_SUCC             #
# OP_SIMPLE_REL_SUCC : '>' | '<'                                                #
# SIMPLE_REL  : "Rel" '(' COND_REL ')' [*]                                      #
#             | '(' RELATION ')'                                                #
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY RELATION {str_name rel L_vars_name} {
 upvar $str_name str
 upvar $L_vars_name L_vars

 #puts "RELATION $rel\n  str : $str"
 set L_rels [this REL_OR str $rel]
 #puts "$objName a retenu \{$L_rels\}, reste à parcourir \"$str\""
 set L_bidon {}
 if {[string equal $L_rels {}]} {
     if {[regexp "^$this(lexic,left_arrow)$this(lexic,spaces)*(.*)" $str reco str]} {
       this EXPR str $this(node_bidon) L_bidon
      } else {if {[regexp "^$this(lexic,right_arrow)$this(lexic,spaces)*(.*)" $str reco str]} {this EXPR str $this(node_bidon) L_bidon}
             }
   set L_vars {}
   return {}
  }

 set L_rep {}
 set str_tmp $str
 if {[regexp "^$this(lexic,left_arrow)$this(lexic,spaces)*(.*)$" $str reco str]} {
   set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
   foreach r $L_rels {
     foreach n [$r get_L_source_nodes] {
       set str_tmp $str
#XXX
#       Add_list L_rep [this EXPR str_tmp $n L_vars]
       set L_var_svt_tmp {}
         Add_list L_rep [this EXPR str_tmp $n L_var_svt_tmp]
       this Update_L_vars L_vars L_var_svt_tmp
#XXX
       set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
      }
    }
   # Just to parse correctly...
   set L_bidon {}
   this EXPR str $this(node_bidon) L_bidon
  } else {if {[regexp "^$this(lexic,right_arrow)$this(lexic,spaces)*(.*)$" $str reco str]} {
            set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
            foreach r $L_rels {
            foreach n [$r get_L_dest_nodes] {
              set str_tmp $str
#XXX
#              Add_list L_rep [this EXPR str_tmp $n L_vars]
              set L_var_svt_tmp {}
                Add_list L_rep [this EXPR str_tmp $n L_var_svt_tmp]
              this Update_L_vars L_vars L_var_svt_tmp
#XXX
                set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
               }
             }
            # Just to parse correctly...
            set L_bidon {}
            this EXPR str $this(node_bidon) L_bidon
           } else {append this(ERROR) "\n" "Invalid relation operator, should be <- or -> but found:\n$str\n  rel : $rel"
                   return {}
                  }
         }

 return $L_rep
}

#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY REL_OR {str_name rel} {
 upvar $str_name str

 #puts "REL_OR $rel \"$str\""
 set L_rels [this REL_SUCC str $rel]
 if {[regexp "^\\|$this(lexic,spaces)*(.*)$" $str reco str]} {
   Add_list L_rels [this REL_OR str $rel]
  }

# XXX PB XXX On vide...
# set p1 [string first -> $str]
# set p2 [string first <- $str]
# set p  [expr ($p1<$p2?$p1:$p2)]
# set str [string range $str $p end]

# Renvoyer le résultat
 return $L_rels
}

#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY REL_SUCC {str_name rel} {
 upvar $str_name str
 #puts "REL_SUCC : $rel : $str"
 set this(propagate_node) 0
 set L_rels [this REL_SIMPLE str $rel]
 #puts "REL_SUCC $rel \"$str\" => \{$L_rels\}"
 set L_bidon {}

#puts "REL_SUCC\n  str2: $str"
# if {[string equal $L_rels {}]} {
     if {[string equal -length 2 $str <-]} {if {[string equal $L_rels {}]} {return {}}} else {
       #puts "REL_SUCC\n  INFO : On parse $str"
       if {[regexp "^(\[<>\])$this(lexic,spaces)*(.*)$" $str reco sens str_tmp]} {
         if {$this(propagate_node) == 1} {
           #puts "On prend en compte l'étoile pour appliquer à partir de $rel : \"$str_tmp\"\n  L_rels : \{$L_rels\}"
           #set str_tmp "$sens$str_tmp"
           #XXX ICI PB 
           #XXX Pourquoi ajouter la relation comme ça sans rien vérifier...on doit propager la relation qu'on avait mais on est un coup trop loin...
             #set L_complement [this REL_SUCC str_tmp $rel]
             #Add_list L_rels $L_complement
             #puts "Ajout de \{$L_complement\}, reste \"$str_tmp\""
             set str $sens$str_tmp
             #return $L_complement
           #Add_list L_rels [this REL_SUCC str_tmp $rel]
           #puts "  L_rels : \{$L_rels\}"
           #return $L_rels
          } else {set str $str_tmp
                  if {[string equal $L_rels {}]} {this REL_SUCC str $this(rel_bidon)}
                 }
        }
      }
   #puts "REL_SUCC : 1 : $str\n         rel : $rel"
#   return {}
#  }

# Take care of the <- because it is ambiguitous with < relation operator !
 if {[string equal -length 2 $str <-]} {return $L_rels}
 if {[regexp "^(\[<>\])$this(lexic,spaces)*(.*)$" $str reco arrow str]} {
   set L_rep {}
   set str_tmp $str
   switch $arrow {
     < {set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
        foreach rs $L_rels {
          foreach n [$rs get_L_source_nodes] {
            foreach r [$n get_L_dest_rel] {
              set str_tmp $str
              Add_list L_rep [this REL_SUCC str_tmp $r]
              set this(cmd_get_nodes) get_L_source_nodes; set this(cmd_get_rels) get_L_dest_rel
             }
           }
         }
       }
     > {set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
        foreach rs $L_rels {
          foreach n [$rs get_L_dest_nodes] {
            foreach r [$n get_L_source_rel] {
              set str_tmp $str
              Add_list L_rep [this REL_SUCC str_tmp $r]
              set this(cmd_get_nodes) get_L_dest_nodes; set this(cmd_get_rels) get_L_source_rel
             }
           }
         }
       }
     default {append this(ERROR) "\n" "Invalid relation operator, should be < or > but found:\n$str"
              return {}
             }
    }
  # Just to parse correctly...
   #puts "Après un $arrow sur $rel on passe de \n$str"
     if {$this(propagate_node) == 1} {
       #puts "2 : Prise en compte de l'*"
       Add_list L_rep [this REL_SUCC str $rel]
       #puts "2 : FIN Prise en compte de l'*"
       if {[string equal $this(ERROR) {}]} {} else {puts "  ERROR : $this(ERROR)\n  str   : $str"}
      } else {this REL_SUCC str $this(rel_bidon)}
   #puts "à\n$str"
   #puts "REL_SUCC : 2 : $str"
   return $L_rep
  } else {#puts "REL_SUCC : 3 : $str"
          return $L_rels}

 #puts "REL_SUCC : 4 : $str"
}

# SIMPLE_REL  : "Rel" '(' COND_REL ')' [*]                                      #
#             | '(' RELATION ')' [*]                                            #
#___________________________________________________________________________________________________________________________________________
method DSL_GDD_QUERY REL_SIMPLE {str_name rel} {
 upvar $str_name str
 #XXX
   set str_debug $str

 # Pour ne pas boucler
 set m "$this(current_node) $str"
 if {[$rel Has_for_marks $this(mark_no_loop)]} {
   if {[$rel Has_for_marks $m]} {
     #puts "STOP on $rel : $str"
     set rel $this(rel_bidon)
    }
   $rel Add_marks $m
  } else {$rel set_marks [list $this(mark_no_loop) $m]
         }

 #puts "REL_SIMPLE:\n  str : $str\n  rel : $rel"
 set L_rep {}
 set plus {}
 if {[regexp "^REL$this(lexic,spaces)*\\((.*)$" $str reco str]} {
   set in [Compensate str ( ) 1]
   if {[string equal $rel $this(rel_bidon)]} {} else {
     set param "REL($in)"
     set cmd REL_SIMPLE
     if {[this COND_NODE in $rel]} {set L_rep $rel}
    }
  } else {if {[regexp "^\\((.*)$" $str reco ]} {
            set in [Compensate str ( ) 1]
            if {[string equal $rel $this(rel_bidon)]} {} else {
              set param "($in)"
              set cmd RELATION
              set L_bidon {}
              set L_rep [this RELATION in $rel L_bidon]
              set plus L_bidon
             }
           } else {append this(ERROR) "\n" "Wanted a relation or an expression inside parenthesis but found:\n$str"
                   return 0
                  }
         }

 if {[regexp "^$this(lexic,spaces)*\\*$this(lexic,spaces)*(.*)$" $str reco str]} {
   #puts "On a une * suivit de $str"
  # Let's see just after the * if there is another relation <REL or >REL
   #if {[string equal -length 4 $str {<REL}]} {}
   #if {[string equal -length 4 $str {>REL}]} {}
  # Propagate the *
   if {[string equal $L_rep {}]} {} else {
     set L $L_rep
     foreach rs $L {
       #puts "passage de $rs"
       foreach n [$rs $this(cmd_get_nodes)] {
         foreach r [$n $this(cmd_get_rels)] {
           set p $param; append p *
           set L_rep_prim $L_rep
           set L_rep      [eval "$objName $cmd p $r $plus"]
           Add_list L_rep $L_rep_prim
          #Add_list L_rep [eval "$objName $cmd p $r $plus"]
          }
        }
      }
    }
   #puts "On a une * suivit de $str"
   set this(propagate_node) 1
  }

 #if {[llength $L_rep] > 0} {puts "  => $L_rep"}
 return $L_rep
}

