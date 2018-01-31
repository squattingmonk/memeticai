/*  Script:  Point of Interest Emitter Callback: Exit
 *           Copyright (c) 2002 William Bull
 *    Info:  This is called when a creature leaves the vicinity of a location or
 *           creature that has an area of effect emitter, created by
 *           calls to the functions MeDefineEmitter() and MeAddEmitterTo*().
 *           It handles optional exit notification to the creature walking
 *           away from the PoI.
 *  Timing:  You should never need to use this. Ever. It is handled internally.
 *  Author:  William Bull
 *    Date:  April, 2003
 *
 */

#include "h_ai"

// A void returning version of the function for DelayCommand().
void _MePOICallFunction(string sFunction, object oArg=OBJECT_INVALID, object oSelf = OBJECT_SELF, object oInstance = OBJECT_INVALID)
{
    MeCallFunction(sFunction, oArg, oSelf, oInstance);
}

void main()
{
    _Start("ExitEmitterArea", DEBUG_TOOLKIT);

    object oEmitter = GetAreaOfEffectCreator();
    object oCreature = GetExitingObject();
    int i = 0;
    string sName;
    string sFunction;
    object oModule = GetModule();

    for (i = MeGetStringCount(oEmitter, "MEME_Emitter") - 1; i >= 0; i--)
    {
        sName = MeGetStringByIndex(oEmitter, i, "MEME_Emitter");

        _PrintString("Looking at emitter "+sName, DEBUG_TOOLKIT);
        MeRemoveObjectRef(oEmitter, oCreature, sName);

        if (GetLocalInt(oCreature, "MEME_EMITTER"+sName))
        {
            string sExitText = GetLocalString(oModule, "MEME_Emitter_"+sName+"ExitText");
            _PrintString("sExitText is "+sExitText, DEBUG_TOOLKIT);

            // Automatically do some floating text.
            if (GetIsPC(oCreature) || GetIsDM(oCreature))
            {
                if (sExitText != "")
                {
                    FloatingTextStringOnCreature(sExitText, oCreature, FALSE);
                }
            }
            else
            {
                _PrintString("Emitting PoI (exiting) sensory notification to a creature.", DEBUG_TOOLKIT);
                struct message stEnterMsg = MeGetLocalMessage(oModule, "MEME_Emitter_Out"+sName);
                object oOwner = GetLocalObject(OBJECT_SELF, "MEME_Target");
                if (!GetIsObjectValid(oOwner)) oOwner = OBJECT_SELF;
                MeSendMessage(stEnterMsg, stEnterMsg.sChannelName, oCreature, oOwner);
            }

            // Run Exit Script
            sFunction = GetLocalString(oModule, "MEME_Emitter_"+sName+"ExitFunction");
            if (sFunction != "")
            {
                _PrintString("An exit function is scheduled to execture.", DEBUG_TOOLKIT);
                DelayCommand(0.0, _MePOICallFunction(sFunction, oCreature, OBJECT_SELF));
            }

            // Clean up the variable we stuck on the player.
            DeleteLocalInt(oCreature, "MEME_EMITTER"+sName);
        }
    }

    _End("ExitEmitterArea", DEBUG_TOOLKIT);
}
