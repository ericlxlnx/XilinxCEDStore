# ########################################################################
# Copyright (C) 2019, Xilinx Inc - All rights reserved

# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at

 # http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
# ########################################################################

set currentFile [file normalize [info script]]
variable currentDir [file dirname $currentFile]

source -notrace "$currentDir/run.tcl"


proc getSupportedParts {} {
    return ""
}

proc getSupportedBoards {} {
    return [get_board_parts -filter {(BOARD_NAME =~"*vck190*" && VENDOR_NAME=="xilinx.com" ) || (BOARD_NAME =~"*vmk180*" && VENDOR_NAME=="xilinx.com" )}  -latest_file_version]
}


proc addOptions {DESIGNOBJ PROJECT_PARAM.BOARD_PART} {
    lappend x [dict create name "Include_LPDDR" type "bool" value "false" enabled true]
    lappend x [dict create name "Clock_Options" type "string" value "clk_out1 200.000 0 true clk_out2 100.000 1 false" enabled true]
    lappend x [dict create name "IRQS" type "string" value "32" value_list {"0 No_interrupts" "32 32_Interrupts,_single_interrupt_controller" "63 63_interrupts,_cascaded_interrupt_controller"} enabled true]
    #set components [ get_board_components -of_objects [get_boards ${PROJECT_PARAM.BOARD_PART}] ]
    ##get list of board components based on board part
    #set value {}
    #foreach { comp } $components {
    #    lappend value $comp
    #    lappend value "false"
    #}
    #lappend x [dict create name "IP_Options" type "string" value $value enabled true]
    return $x
}

proc addGUILayout {DESIGNOBJ PROJECT_PARAM.BOARD_PART} {
    set designObj $DESIGNOBJ
    set page [ced::add_page -name "Page1" -display_name "2020.3 Configuration" -designObject $designObj -layout vertical]

    set clocks [ced::add_group -name "Clocks" -display_name "Clocks"  -parent $page -visible true -designObject $designObj ]
    ced::add_custom_widget -name widget_Clocks -hierParam Clock_Options -class_name PlatformClocksWidget -parent $clocks $designObj

    ced::add_param -name IRQS -display_name "Interrupts" -parent $page -designObject $designObj -widget radioGroup

    puts "PROJECT_PARAM.BOARD_PART: ${PROJECT_PARAM.BOARD_PART}"

    set ddr [ced::add_group -name "Versal LPDDR Configurations" -display_name "Versal LPDDR Configurations"  -parent $page -visible true -designObject $designObj ]
    ced::add_param -name Include_LPDDR -display_name "Include_LPDDR" -parent $ddr -designObject $designObj -widget checkbox

    #set ip [ced::add_group -name "Board_Components" -display_name "Board Components"  -parent $page -visible true -designObject $designObj ]
    #ced::add_custom_widget -name widget_IP -hierParam IP_Options -class_name PlatformIPWidget -parent $ip $designObj

    #set imageVar [ced::add_image -name Image -parent $ddr -designObject $designObj -width 500 -height 300 -layout vertical]

}

# validater { parameters_used } { parameters_modified} { functionality }
validater { Clock_Options.VALUE } {
    puts "XXX validate"
    puts "XXX clock options = ${Clock_Options.VALUE}"
    #puts "XXX clock options = ${PARAM_VALUE.Clock_Options}"
    set_property errmsg "This here is an error message" ${PARAM_VALUE.Clock_Options}
    return false; # good
}

updater {Include_LPDDR.VALUE} {Include_LPDDR.ENABLEMENT} {

    if { ${Include_LPDDR.VALUE} == true } {
        set Include_LPDDR.ENABLEMENT true
    } else {
        set Include_LPDDR.ENABLEMENT true
    }
}

#gui_updater {PROJECT_PARAM.BOARD_PART Include_LPDDR.VALUE} {Image.IMAGE_PATH} {
gui_updater {PROJECT_PARAM.BOARD_PART Include_LPDDR.VALUE} {} {
    if { ${Include_LPDDR.VALUE} == true } {
        #set Image.IMAGE_PATH "" 
    } else {
        #set Image.IMAGE_PATH ""
    }
}
