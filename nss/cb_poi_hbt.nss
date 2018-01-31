/*  Script:  Point of Interest Emitter Callback: Heartbeat
 *           Copyright (c) 2002 William Bull
 *    Info:  This is periodically called when an emitter is of a size < 10m
 *           and a creature has entered the 10m area to check to see if
 *           they are close. Once they are close, they may be notified of
 *           the point of interested by emitting various information, etc.
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
    if (GetLocalInt(OBJECT_SELF, "MEME_Paused") != 0) return;

    _Start("EmitterAreaHeartbeat", DEBUG_TOOLKIT);

    int isValid = 0;  // Is the given creature within the radius for the given emitter
    float fDistance;  // The distance the creature must be within to be notified
    object oCreature; // The creature in the AoE which may be near enough
    string sName;     // The name of the emitter which is being expressed
    location lLoc;    // The location of the emitter or the emitting creature
    object oModule = GetModule();
    int i, j;
    int iRespawn = 0;
    string sFunction;
    string sID;
    int iUniqueSize = 0;

    // These are used to cache the players value and allow them to expire
    // after some fixed period of time.
    int    notifyCacheDuration;
    int    gcIterator;
    string sVarName;
    string sIteratorName;

    if (!GetIsObjectValid(OBJECT_SELF)) return;

    SetLocalInt(OBJECT_SELF, "MEME_Scheduler", 0);

    // Let's find out where we are -- unfortunately we have to recompute this every time
    // as the emitter owner could be moving.
    object oTarget = GetLocalObject(OBJECT_SELF, "MEME_Target");
    if (oTarget == OBJECT_INVALID) lLoc = GetLocation(OBJECT_SELF); // This is a location based emitter.
    else lLoc = GetLocation(oTarget); // This is a creature based emitter.

    // There is great room for optimization in these loops - but as I don't know how
    // aggressively PoIs are going to be used, I will concentrate on functionalist, first.

    // In this context, OBJECT_SELF is the emitter object, it has a list of emitter names
    for (i = MeGetStringCount(OBJECT_SELF, "MEME_Emitter") - 1; i >= 0; i--)
    {
        // Let's evaluate all the creatures which haven't gotten close enough but can notice the PoI
        // If they're on this list and in the emitting area, notify them.
        sName = MeGetStringByIndex(OBJECT_SELF, i, "MEME_Emitter");

        fDistance = GetLocalFloat(oModule, "MEME_Emitter_"+sName+"Distance");
        if (fDistance != POI_LARGE && fDistance != POI_SMALL) iUniqueSize = 1;
        _PrintString("Emitter distance is "+FloatToString(fDistance)+".", DEBUG_TOOLKIT);

        // If this emitter is paused, don't bother - move to the next emitter.
        if (GetLocalInt(OBJECT_SELF, "MEME_Paused"+sName) != 0) break;

        _PrintString("Checking emitter '"+sName+"'", DEBUG_TOOLKIT);

        for (j = MeGetObjectCount(OBJECT_SELF, sName) - 1; j >= 0; j--)
        {
            oCreature = MeGetObjectByIndex(OBJECT_SELF, j, sName);
            sID = ObjectToString(oCreature);

            _PrintString("Checking to see if this critter is close enough to sense the emitter.", DEBUG_TOOLKIT);

            // 10m and 5m Distances are auto-notified; other distances must be manually verified.
            if ((fDistance == POI_LARGE || fDistance == POI_SMALL)) isValid = 1;
            else if (GetDistanceBetweenLocations(GetLocation(oCreature),lLoc) <= fDistance) isValid = 1;
            else isValid = 0;

            _PrintString("Is in range = "+IntToString(isValid), DEBUG_TOOLKIT);

            // So if the creature is on the list and within the distance, emit to it.
            if (isValid /* Is in vicinity */
                && (GetLocalInt(OBJECT_SELF, "MEME_"+sName+"_NOTIFYCACHE_"+sID) != 1 /* Can be emitted to */))
            {
                if (GetLocalInt(oCreature, "MEME_EMITTER"+sName) != 2 /* Not Inside Area */ )
                {
                    SetLocalInt(oCreature, "MEME_EMITTER"+sName, 2); // Notate that the player has visited and is in the area

                    _PrintString("This guy is in the sensory area and hasn't sensed it earlier than the notification cache duration.", DEBUG_TOOLKIT);

                    // Execute a function
                    sFunction = GetLocalString(oModule, "MEME_Emitter_"+sName+"ActivateFunction");
                    if (sFunction != "")
                    {
                        _PrintString("An activation function is scheduled to execture.", DEBUG_TOOLKIT);
                        DelayCommand(0.0, _MePOICallFunction(sFunction, oCreature, OBJECT_SELF));
                    }

                    if (GetIsPC(oCreature) || GetIsDM(oCreature))
                    {
                        _PrintString("Emitting PoI sensory notification to a player.", DEBUG_TOOLKIT);

                        string sResRef    = GetLocalString(oModule, "MEME_Emitter_"+sName+"ResRef");
                        string sEnterText = GetLocalString(oModule, "MEME_Emitter_"+sName+"EnterText");

                        // Automatically do some floating text.
                        if (sEnterText != "") FloatingTextStringOnCreature(sEnterText, oCreature, FALSE);

                        // Start a dialog which may being a conversation, run a script, etc.
                        if (sResRef != "" )
                        {
                            _PrintString("Starting Dialog "+sResRef+"with "+GetName(oCreature), DEBUG_TOOLKIT);
                            // Set up some globals for the resref
                            SetLocalObject(oModule, "MEME_EmitterSelf", OBJECT_SELF);
                            SetLocalObject(oModule, "MEME_EmitterOwner", oTarget);
                            SetLocalObject(oModule, "MEME_EmitterTarget", oCreature);
                            // Start the conversation
                            ActionStartConversation(oCreature, sResRef, TRUE);
                        }
                    }
                    else
                    {
                        _PrintString("Emitting PoI (entering) sensory notification message to a creature.", DEBUG_TOOLKIT);
                        struct message stEnterMsg = MeGetLocalMessage(oModule, "MEME_Emitter_In"+sName);
                        object oOwner = GetLocalObject(OBJECT_SELF, "MEME_Target");
                        if (!GetIsObjectValid(oOwner)) oOwner = OBJECT_SELF;
                        MeSendMessage(stEnterMsg, stEnterMsg.sChannelName, oCreature, oOwner);
                    }

                    // ** START CACHE **
                    // We may want to notate that this creature has been notified of the PoI Emitter

                    notifyCacheDuration = GetLocalInt(oModule, "MEME_Emitter_"+sName+"NotifyCache");
                    sVarName = "MEME_"+sName+"_NOTIFYCACHE_"+sID;

                    // If it's zero, we never record the value.
                    if (notifyCacheDuration != 0)
                    {
                        _PrintString("We have notified this critter about the PoI, now we cache that fact.", DEBUG_TOOLKIT);
                        SetLocalInt(OBJECT_SELF, sVarName, 1); // Any non-zero value will do
                    }

                    // If it's not-negative, we will destroy the value that may have been recorded.
                    // We use a rather contrived process to ensure that if the value is updated, old
                    // calls to DelayCommand are invalidate.
                    if (notifyCacheDuration > 0)
                    {
                        sIteratorName = "MEME_"+sName+"_NOTIFYCACHEITERATOR_"+sID;
                        gcIterator = GetLocalInt(OBJECT_SELF, sIteratorName);
                        SetLocalInt(OBJECT_SELF, sIteratorName, gcIterator+1);
                        DelayCommand(IntToFloat(notifyCacheDuration), _DestroyCachedInt(OBJECT_SELF, sVarName, sIteratorName)); // _DestroyCachedInt() can be found in h_util
                    }
                    // ** END CACHE **
                }
            }
            // Otherwise the creature is not in the area, but was just in the area...
            // This block is equivalent to cb_poi_exit for areas that are < 10.0m or 5.0m
            // One issue is that they may walk back into the area - so they should stil be tracked
            else if (GetLocalInt(oCreature, "MEME_EMITTER"+sName) == 2 /* Was Inside Area -- I think */)
            {
                SetLocalInt(oCreature, "MEME_EMITTER"+sName, 1); // Notate that the player has visited but is not in the area

                // Keep the creature on the list. This list represents creatures which should be
                // tracked. We should only remove them when they fully leave the PoI area. Otherwise,
                // we should still track them, in case they return.
                // MeAddObjectRef(OBJECT_SELF, oCreature, sName);

                _PrintString("The creature is not in the area and has been notified earlier.", DEBUG_UTILITY);
                // Float exit text -- only needed if the radius != 10 or 5, and we can't do this in cb_poi_exit.
                string sExitText = GetLocalString(GetModule(), "MEME_Emitter_"+sName+"ExitText");

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

        if (MeGetObjectCount(OBJECT_SELF, sName) != 0) iRespawn = 1;
    }

    // Respawn this script if there are players on the list and the distance of one of the emitters
    // is less than 5m or 10m. All the 5m or 10m emitters will have been notified and removed from the list.
    // The other ones will need to be watched by creating a polling loop. The durating on this
    // DelayCommand will effect the responsiveness of the PoI Emitter.
    if (iRespawn && iUniqueSize) {
        SetLocalInt(OBJECT_SELF, "MEME_Scheduler", 1);
        DelayCommand(2.0+IntToFloat(Random(2)) /* What the heck, let's give this a try. */, ExecuteScript("cb_poi_hbt", OBJECT_SELF));
    }

    _End("EmitterAreaHeartbeat", DEBUG_TOOLKIT);
}
