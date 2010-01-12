#______________________________________________________________________________________________________________________
#______________________________________________________________________________________________________________________
#______________________________________________________________________________________________________________________
method GDD_type constructor {descr args} {
 set this(descr) $descr
 set this(L_mothers)   {}
 set this(L_daughters) {}

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________________________________________________________________________
Generate_List_accessor GDD_type L_mothers   mothers
Generate_List_accessor GDD_type L_daughters daughters

#______________________________________________________________________________________________________________________
method GDD_type configure args {
 set L_cmd [split $args -]
 foreach cmd $L_cmd {
   if {[string equal $cmd {}]} {continue}
   if {[string equal [string index $cmd 0] | ]} {
     set cmd [string range $cmd 1 end]
     eval $cmd
    } else {eval "$objName $cmd"}
  }
}

#______________________________________________________________________________________________________________________
method GDD_type Is_a {type} {
 return [expr [lsearch [this get_super_types] $type] != -1]
}

#______________________________________________________________________________________________________________________
method GDD_type get_sub_types {} {
 set rep [this get_daughters]
 foreach t [this get_daughters] {
   set rep [concat $rep [$t get_sub_types]]
  }
 return $rep
}

#______________________________________________________________________________________________________________________
method GDD_type get_super_types {} {
 set rep $objName
 foreach t [this get_mothers] {
   set rep [concat $rep [$t get_super_types]]
  }
 return $rep
}

#______________________________________________________________________________________________________________________
#_ Utilisation de l'indentation pour définir la hiérarchie                                                            _
#______________________________________________________________________________________________________________________
proc Generate_GDD_types {str} {
 set lettre  {[a-z|A-Z|0-9|&|_]}
 set L_roots {}
 set L_rep {}

 while {[regexp "^( *)($lettre*) *\n(.*)$" $str reco dec type str]} {
   puts "$L_roots\n$dec$type"
   set t_dec [string length $dec]
   set e [list $type $t_dec]
   while {[llength $L_roots]} {
     set prev_type [lindex $L_roots end]
     if {$t_dec <= [lindex $prev_type 1]} {set L_roots [lreplace $L_roots end end]} else {break}
    }
   GDD_type $type "NO DESCRIPTION"
   if {[catch "[lindex [lindex $L_roots end] 0] Add_daughters $type; $type Add_mothers [lindex [lindex $L_roots end] 0]" res]} {puts "$res\n  $L_roots"}
   lappend L_roots $e
   lappend L_rep $type
  }

 return $L_rep
}

if {[info exists GDD_gogo]} {} else {
  set GDD_gogo 1
  set f [open GDD_types_def.txt]; set txt [read $f]; close $f
 }

return {set L_types [Generate_GDD_types $txt]}
