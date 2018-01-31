/*  Script:  Point of Interest Emitter Callback: Enter
 *           Copyright (c) 2002 William Bull
 *    Info:  This is called when a creature walks close to a location or
 *           creature that has an area of effect emitter, created by
 *           calls to the functions MeDefineEmitter() and MeAddEmitterTo*().
 *           It handles notifying the incoming creature of the PoI.
 *  Timing:  You should never need to use this. Ever. It is handled internally.
 *  Author:  William Bull
 *    Date:  April, 2003
 *
 */

#include "h_ai"

/*  This script is called when a creature enters into the general viscinity
 *  of a creature or location that is emitting PoI information.
 *  This script determines if the creature is a viable recepter of the information
 *  then records this value, and causes the cb_poi_hb to run. This evaluates
 *  the players to see if they are within the PoI emitter area and notifies
 *  them accordingly.
 */

const int POI_FAILED = 2;
const int POI_PASSED = 1;

void _DestroyCachedInt(object oEmitter, string sVarName, string sIteratorName);

void main()
{

    object oEmitter = GetAreaOfEffectCreator();
    object oCreature = GetEnteringObject();
    object oModule = GetModule();
    string sFunction;
    string sName;
    struct message stMsg;
    string sID = ObjectToString(oCreature);
    int    flags = 0;
    int    mask = 0;
    int    i;
    int    iModified = 0;
    int    iSuccessCache;
    int    iSuccess = POI_FAILED;
    int    success = 0;

    // These are used to cache the players value and allow them to expire
    // after some fixed period of time.
    int    testCacheDuration;
    int    gcIterator;
    string sVarName;
    string sIteratorName;

    // If the PoI is cast on a creature, it will trigger the AoE -- we can ignore this creature.
    if (oCreature == GetLocalObject(oEmitter, "MEME_Target")) return;

    _Start("EnterEmitterArea", DEBUG_TOOLKIT);

    _PrintString("Entering object is "+_GetName(oCreature)+".", DEBUG_TOOLKIT);

    // Iterate over the emitter chain on the emitter object. This is a list of
    // emitter definition names which have been defined on the module, describing
    // the rules for the emitter -- such as what it emits and to whom.
    for (i = MeGetStringCount(oEmitter, "MEME_Emitter") - 1; i >= 0; i--)
    {
        sName = MeGetStringByIndex(oEmitter, i, "MEME_Emitter");

        _PrintString("Processing '"+sName+"' emitter.", DEBUG_TOOLKIT);

        // There are three flags which say if this PoI is restricted to Players, NPCs, or creatures
        // if this creature does not match at least one of these flags, it can discount this PoI immediately.
        flags = GetLocalInt(oModule, "MEME_Emitter_"+sName+"Flags");
        if (GetIsPC(oCreature))
        {
            _PrintString("PC Entered");
            mask = EMIT_TO_PC;
        }
        else if (GetIsDM(oCreature))
        {
            _PrintString("DM Entered");
            mask = EMIT_TO_DM;
        }
        else
        {
            _PrintString("NPC Entered");
            mask = EMIT_TO_NPC;
        }
        if (!(mask & flags)) break;

        // This value records objects that have been evaluated and processed.
        // Just becuase they have entered into the area, doesn't mean that they
        // should have a chance to observe the information. Sometimes they get
        // one shot, and that's it. If that's the case, they will have a non-zero
        // value on the emitter, like MEME_ODOR_TESTCACHE_0x02332.
        sVarName = "MEME_"+sName+"_TESTCACHE_"+sID;
        iSuccessCache = GetLocalInt(oEmitter, sVarName);
        if (iSuccessCache == 0)
        {
            _PrintString("I don't remember checking if this creature can see this PoI.", DEBUG_TOOLKIT);

            sFunction = GetLocalString(oModule, "MEME_Emitter_"+sName+"EnterFilter");
            _PrintString("Test function is named: "+sFunction, DEBUG_TOOLKIT);

            // If this function succeeds, this person can perceive the PoI.
            if (sFunction == "") success = 1;
            else if (MeCallFunction(sFunction, oCreature, oEmitter) != OBJECT_INVALID) success = 1;
            else success = 0;

            if (success)
            {
                // Now add them to a list of people to be notified via cb_poi_hb
                MeAddObjectRef(oEmitter, oCreature, sName);
                iModified = 1;
                iSuccess = POI_PASSED;
            }
            else iSuccess = POI_FAILED;

            // ** START CACHE **
            // Depending on the flags of this emitter, we may need to record
            // that this creature attempted - but failed to notice the PoI.
            testCacheDuration = GetLocalInt(oModule, "MEME_Emitter_"+sName+"TestCache");
            _PrintString("This has a cache duration of "+IntToString(testCacheDuration)+" seconds.", DEBUG_TOOLKIT);

            // If it's zero, we never record the value, meanining we always retest them.
            // (For example, "did you solve the quest yet?" The results are not assumed to
            //  be deterministic.)
            if (testCacheDuration != 0)
            {
                _PrintString("Caching the success value: "+IntToString(iSuccess), DEBUG_TOOLKIT);
                SetLocalInt(oEmitter, sVarName, iSuccess);
            }

            // If it's not-negative, we will destroy the value that may have been recorded.
            // We use a rather contrived process to ensure that if the value is updated, old
            // calls to DelayCommand are invalidate.
            else if (testCacheDuration > 0)
            {
                sIteratorName = "MEME_"+sName+"_TESTCACHEITERATOR_"+sID;
                gcIterator = GetLocalInt(oEmitter, sIteratorName);
                SetLocalInt(oEmitter, sIteratorName, gcIterator+1);
                DelayCommand(IntToFloat(testCacheDuration), _DestroyCachedInt(oEmitter, sVarName, sIteratorName)); // _DestroyCachedInt() can be found in h_util
            }
            // ** END CACHE **
        }
        /* We have cached the result of this creature's filter test. Use it. */
        else
        {
            _PrintString("Oh, I've seen this critter before. I remember it's value.", DEBUG_TOOLKIT);
            if (iSuccessCache == POI_PASSED)
            {
                _PrintString("It's allowed to sense this PoI emitter.", DEBUG_TOOLKIT);
                MeAddObjectRef(oEmitter, oCreature, sName);
                iModified = 1;
                iSuccess = POI_FAILED;
            }
            else _PrintString("It's not allowed to sense this PoI emitter.", DEBUG_TOOLKIT);
        }
    }

    if (iModified)
    {
        if (GetLocalInt(oEmitter, "MEME_Scheulder") == 0)
        {
            SetLocalInt(oEmitter, "MEME_Scheduler", 1);
            DelayCommand(0.1, ExecuteScript("cb_poi_hbt", oEmitter));
        }
    }

    _End("EnterEmitterArea", DEBUG_TOOLKIT);
}
