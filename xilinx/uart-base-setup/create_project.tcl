create_project -force -part xc7z010clg400-1 Zybo-Z7-10-UART-base

add_files -fileset sources_1 rtl/top.v
add_files -fileset sources_1 rtl/areset.v
add_files -fileset sources_1 rtl/pmod_ssd.v
add_files -fileset sources_1 rtl/mmcm.v
add_files -fileset sources_1 ../../lib/uart_rx.v
add_files -fileset sources_1 ../../lib/uart_tx.v

add_files -fileset constrs_1 constr/Zybo-Z7-Master.xdc

exit

