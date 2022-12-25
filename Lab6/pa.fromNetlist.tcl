
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name lab6 -dir "F:/Lab6/planAhead_run_4" -part xc3s100ecp132-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "F:/Lab6/laser_surgery_sys.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {F:/Lab6} }
set_property target_constrs_file "constraint.ucf" [current_fileset -constrset]
add_files [list {constraint.ucf}] -fileset [get_property constrset [current_run]]
link_design
