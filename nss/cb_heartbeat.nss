/*  Script:  Heartbeat Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the heartbeat generators.
 *  Timing:  This should be attached to Bioware's OnHeartbeat callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 */

#include "h_ai"

void main()
{
    _Start("OnHeartbeat", DEBUG_COREAI);

    MeExecuteGenerators("_hbt");
    MeUpdateActions();

    _End();
}


