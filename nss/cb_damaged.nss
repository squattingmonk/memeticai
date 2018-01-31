/*  Script:  Damaged Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the damaged generators.
 *  Timing:  This should be attached to Bioware's OnDamaged callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 */

 #include "h_ai"

void main()
{
    _Start("OnDamaged", DEBUG_COREAI);

    MeExecuteGenerators("_dmg");
    MeUpdateActions();

    _End("OnDamaged", DEBUG_COREAI);
}


