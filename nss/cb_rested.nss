/*  Script:  Rest Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the rested generators.
 *  Timing:  This should be attached to Bioware's OnRest callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 */

 #include "h_ai"

void main()
{
    _Start("OnRested", DEBUG_COREAI);

    MeExecuteGenerators("_rst");
    MeUpdateActions();

    _End("OnRested", DEBUG_COREAI);
}


