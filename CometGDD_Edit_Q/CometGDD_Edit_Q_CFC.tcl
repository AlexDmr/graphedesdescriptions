inherit CometGDD_Edit_Q_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_CFC constructor {} {
 set this(dot_descr)    {}
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors CometGDD_Edit_Q_CFC [list dot_descr canvas_descr]

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_CFC Query {v} {}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_CometGDD_Edit_Q {} {return [list {get_dot_descr { }} ]}
proc P_L_methodes_set_CometGDD_Edit_Q {} {return [list {set_dot_descr {v}} {Query {v}} ]}

