/*  Script:  Spellcast Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the spellcast generators.
 *  Timing:  This should be attached to Bioware's OnSpellcast callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 */

#include "h_ai"

void main()
{
    _Start("OnSpellCast", DEBUG_COREAI);

    MeExecuteGenerators("_mgk");
    MeUpdateActions();

    _End("OnSpellCast", DEBUG_COREAI);
}


