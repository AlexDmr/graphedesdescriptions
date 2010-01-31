inherit CometGDD_Edit_Q_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_CFC constructor {} {
 set this(dot_descr)    {}
 set this(last_query)   {}
 
 set this(L_selected_nodes) [list]
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors     CometGDD_Edit_Q_CFC [list dot_descr canvas_descr]
Generate_List_accessor CometGDD_Edit_Q_CFC L_selected_nodes L_selected_nodes

#___________________________________________________________________________________________________________________________________________
method CometGDD_Edit_Q_CFC Query          {v} {set this(last_query) $v}
method CometGDD_Edit_Q_CFC get_last_query { } {return $this(last_query)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_CometGDD_Edit_Q {} {return [list {get_L_selected_nodes { }} {get_dot_descr { }} {get_last_query { }} ]}
proc P_L_methodes_set_CometGDD_Edit_Q {} {return [list {set_L_selected_nodes {L}} \
                                                       {Add_L_selected_nodes {L}} \
													   {Sub_L_selected_nodes {L}} {set_dot_descr {v}} {Query {v}} ]}

