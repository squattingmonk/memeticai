/*  Script:  Moments demo
 *           Copyright (c) 2003 Daryl Low
 *    Info:
 *  Timing:  This should be attached to a creature's OnSpawn callback
 *  Author:  Daryl Low
 *    Date:  November, 2003
 */

#include "h_ai"
#include "h_poi"

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic");

    object oEvent = MeCreateEvent("e_mimic");
    MeSubscribeMessage(oEvent, "Mimic/Hear", "Mimic_Channel");

    MeUpdateActions();

    _End("OnSpawn");
}
