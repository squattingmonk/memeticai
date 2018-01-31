/*  Script:  Blocked Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the blocked generators.
 *  Timing:  This should be attached to Bioware's OnBlocked callback
 *  Author:  William Bull
 *    Date:  September, 2002
 */

#include "h_ai"

void main()
{
    _Start("OnBlocked", DEBUG_COREAI);

    MeExecuteGenerators("_blk");
    MeUpdateActions();

    _End("OnBlocked", DEBUG_COREAI);
}


