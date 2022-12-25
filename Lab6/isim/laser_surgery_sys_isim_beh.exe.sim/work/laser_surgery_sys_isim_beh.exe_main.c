/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_00000000002470155413_1748963262_init();
    work_m_00000000001767624877_0954328892_init();
    work_m_00000000004207336048_4011914418_init();
    work_m_00000000000681435531_1899641759_init();
    work_m_00000000003525639478_2853179388_init();
    work_m_00000000001995485592_0292639408_init();
    work_m_00000000000020958277_2154721913_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000000020958277_2154721913");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
