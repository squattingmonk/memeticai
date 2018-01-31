/*  Script:  Perception Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the perception generators.
 *  Timing:  This should be attached to Bioware's OnPerception callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 *    Note:  Bioware's perception callback may be insuffient for your needs;
 *           refer to the e_observer event and generator system.
 */

#include "h_ai"

void main()
{

   object oObject = GetLastPerceived();
   if (!GetIsObjectValid(oObject))
   {
       _PrintString("OnPerception, but Invalid object", DEBUG_COREAI);
       return;
   }

   if (GetLastPerceptionSeen())
   {
       _Start("OnPerception type='see' target='"+_GetName(oObject)+"'", DEBUG_COREAI);
       MeExecuteGenerators("_see");
   }
   else if (GetLastPerceptionVanished())
   {
       _Start("OnPerception type='vanished' target='"+_GetName(oObject)+"'", DEBUG_COREAI);
       MeExecuteGenerators("_van");
   }
   else if (GetLastPerceptionHeard())
   {
       _Start("OnPerception type='hear' target='"+_GetName(oObject)+"'", DEBUG_COREAI);
       MeExecuteGenerators("_hea");
   }
   else if (GetLastPerceptionInaudible())
   {
       _Start("OnPerception type='inaudible' target='"+_GetName(oObject)+"'", DEBUG_COREAI);
       MeExecuteGenerators("_ina");
   }

   _Start("OnPerception type='perception' target='"+_GetName(oObject)+"'", DEBUG_COREAI);
       MeExecuteGenerators("_per");
   _End();

   MeUpdateActions();

   _End();
}


