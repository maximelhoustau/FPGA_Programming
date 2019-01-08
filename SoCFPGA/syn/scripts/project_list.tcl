set PROJECT_DIR  $env(PROJECT_DIR)

#Definition des fichiers sources vga
$PROJECT_DIR/ips/interfaces/video_if.sv
$PROJECT_DIR/SoCFPGA/src/vga.sv

# Placer ici la liste des modules complémentaires nécessaires à la synthèse
# Tout ce qui concerne le "hw_support" est décrit dans un fichier a part
set_global_assignment -name QIP_FILE           $PROJECT_DIR/ips/sys_pll/sys_pll.qip
set_global_assignment -name SYSTEMVERILOG_FILE $PROJECT_DIR/SoCFPGA/src/Top.sv

