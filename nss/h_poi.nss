#include "h_util"
#include "h_class"

/* File: h_poi - Memetic Points of Interest (Dynamic Trigger Areas)
 * Author: William Bull
 * Date: Copyright April, 2003
 */

// ----- Points of Interest Emitters (Dynamic Tigger Areas) --------------------

//  MeDefineEmitter
//  Define a dynamic trigger area, to be used by points of interest (locations and creatures).
//  This does not create any objects; it only registers a datastructure to be used, later
//  by the MeAddEmitter*() functions. Think of this function as something which defines
//  a named template.
//
//  [Note: Anywhere you see Point of Interest (PoI) just assume I means emitter. The difference
//   shouldn't concern you at this point in time.]
//
//
//  sName:      This is a unique name for these settings. If you define another emitter with
//              the same name, you will overwrite these values. There is no way to delete
//              an emitter definition, at this time.
//
//  sResRef:    The string of the dialog to present to the user. If empty, no dialog is created.
//
//  sTestFunction: This is the name of a Library Function. (see MeLibraryImplements())
//              The function receives one argument - the player or NPC that entered the area.
//              The function decides if this creature should receive the PoI notification
//              (sEnterText, sResRef, iSignal, etc.).
//              If the function returns OBJECT_INVALID, the creature is not notified. Anything
//              other return result is considered true. This is a filter function, several samples
//              filters can be found in lib_filter
//
//  sActivationFunction: This is the name of a Library Function. (see MeLibraryImplements())
//              The argument of the function is the entering creature. This will only be called
//              if the creature has passed the sFilter check and is withing the emitter area.
//
//  sExitFunction: This is the name of a Library Function. (see MeLibraryImplements())
//              The argument of the function is the entering creature. This will only be called
//              if the creature has passed the sFilter check and is withing the emitter area.
//
//  sEnterText: A string which will appear over the head of the player and in their log.
//              This does nothing to NPCs which enter into the area.
//
//  sExitText:  The opposite of enter text - shown when the player leaves the area.
//
//  iFlags:     This controls who will receive the PoI information. These can be masked
//              together. For example, all non-npcs would be: ( EMIT_TO_PC | EMIT_TO_DM )
//              EMIT_TO_PC  - Players
//              EMIT_TO_NPC - Creatures
//              EMIT_TO_DM  - Dungeon Masters
//
//  fDistance:  The size of the PoI area. It is highly recommended that you try and only
//              use 10m PoI's. Otherwise, the area will poll - equivalent to a heartbeat script.
//              This will take up CPU time, tracking the creature after it comes within 10m.
//              Unfortunately you cannot have a PoI that is greater than 10m.
//
//  fCacheTest: As a creature enters the PoI, it may be tested with fFilter. The result of this
//              may be cached. This defines the length of time, in seconds,  to cache this value.
//
//              1. If the value is negative (-1): the value is permenantly cached.
//              2. If the value is zero (0): the value is never stored. [DEFAULT]
//              3. If the value is positive (30): this is the number of seconds before the creature will be retested.
//
//  fCacheNotify: As the creature enters the PoI, it may be notified via a dialog or floaty text.
//                According to this value, the emitter can remember when the creature is last notified:
//
//              1. If the value is negative (-1): the creature is only notified once, ever.
//              2. If the value is zero (0): the creature will always be notified. [DEFAULT]
//              3. If the value is positive (30): this is number of seconds before they are notified again.
//
void MeDefineEmitter(string sName, string sTestFunction = "", string sActivationFunction = "", string sExitFunction = "",string sResRef = "", string sEnterText = "", string sExitText = "", int iFlags = EMIT_TO_PC, float fDistance = POI_SMALL, int fCacheTest = 0, int fCacheNotify = 0);

// MeDefineEmitterMessage
// Cause the emitter to send a message to the NPC that enters and exits the dynamic trigger area.
//
// sName: The sName should match the name of a previously defined emitter.
// stEnterMsg: A message defining the message name, channel and data.
// stExitMsg: A message defining the message name, channel and data.
void MeDefineEmitterMessage(string sName, struct message stEnterMsg, struct message stExitMsg);

// MeAddEmitterToCreature
// Attach a dynamic trigger area, previously defined by MeDefineEmitter(), to a creature.
// (It is not possible to attach an emitter to an object, only creatures and locations.)
void MeAddEmitterToCreature(object oCreature, string sName); // You can attach multiple emitters to a creature.

// MeAddEmitterToLocation
// Attach a dynamic trigger area, previously defined by MeDefineEmitter(), to a location.
// (It is not possible to attach an emitter to an object, only creatures and locations.)
// This returns an object that represents the emitter. Use this object for all other
// functions which want to start or stop an emitter.
object MeAddEmitterToLocation(location lLocation, string sName); // Returns an object representing the emitter effect.

//  MeRemoveEmitter
//  Removes a dynamic trigger area from a creature, given the emitter name -- defined by MeDefineEmitter().
//
//  oTarget: The creature which is emitting, or the object returned from MeAddEmitterToLocation.
//  sName:   The name of the specific emitter. Remember, a creature or emitter object at a location
//           may hold multiple emitters. If none is provided, it will clean up all emitter data.
//           It will also destroy the object created by MeAddEmitterToLocation. The creature's
//           MEME_Emitter local variable will be set to OBJECT_INVALID.
void MeRemoveEmitter(object oTarget, string sName = ""); // No name, removes all of them.

//  MePauseEmitter
//  Causes the named emitter to stop notifying creatures, although it will still check to see if
//  they pass the filter test and cache the result.
//
//  oTarget: The creature which is emitting, or the object returned from MeAddEmitterToLocation.
//  sName:   The name of the specific emitter. Remember, a creature or emitter object at a location
//           may hold multiple emitters. If none is provided all will be paused, automatically.
//           In this case, resuming them automatically will NOT work. You must call MeResumeEmitter
//           with
void MePauseEmitter(object oTarget, string sName = "");

//  MeResumeEmitter
//  Causes a paused named emitter to resume. If anyone is in the viscinity they are processed, like
//  normal.
//
//  oTarget: The creature which is emitting, or the object returned from MeAddEmitterToLocation.
//  sName:   The name of the specific emitter. Remember, a creature or emitter object at a location
//           may hold multiple emitters. If none is provided all will be paused, automatically.
//           In this case, resuming them automatically will NOT work. You must call MeResumeEmitter
//           with
void MeResumeEmitter(object oTarget, string sName);

//  MeAddEmitterByTag
//  This adds PoI Emitters to every object in the game, with a given tag. This relationship is
//  defined with the function.
void MeAddEmitterByTag(string sTagName, string sEmitter);

// -------- PoI Binding Utilities ----------------------------------------------

//  MeBindEmitterToTag
//  This says which objects with the given tag should recieve an emitter.
//  It is used in conjunction with MeInitEmitters();
void MeBindEmitterToTag(string sTag, string sEmitter);

//  MeAddEmitterByTag
void MeAddEmitterByTag(string sTagName, string sEmitter);

/* PoI Emitter Functions
 * Used to automate the process of defining dynamic trigger areas that start
 * conversions or emit signals.
 */

void _CreatePoIAtLocation(location lLocation, string sName)
{
    _Start("_CreatePoIAtLocation", DEBUG_UTILITY);

    float fDistance = GetLocalFloat(GetModule(), "MEME_Emitter_"+sName+"Distance");
    int   aoeID;

    if (fDistance <= POI_SMALL) aoeID = AOE_SMALL_POI;
    else aoeID = AOE_LARGE_POI;

    // poi stands for Point of Interest, in case you missed that somewhere...
    effect poi_effect = EffectAreaOfEffect(aoeID, "cb_poi_enter", "****", "cb_poi_exit"); // Do NOT call cb_poi_hb here -- I call it manually to control the polling.
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, poi_effect, lLocation);

    // We have to do some odd things to keep access to this particular AoE
    // This will be used when you want to remove the effect
    object oAoE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lLocation);
    SetLocalObject(OBJECT_SELF, "MEME_AoE", oAoE);

    _End("_CreatePoIAtLocation", DEBUG_UTILITY);
}

void _CreatePoI(object oTarget, string sName)
{
    _Start("CreatingPoI", DEBUG_UTILITY);

    float fDistance = GetLocalFloat(GetModule(), "MEME_Emitter_"+sName+"Distance");
    int   aoeID;

    if (fDistance <= POI_SMALL) aoeID = AOE_SMALL_POI;
    else aoeID = AOE_LARGE_POI;

    // poi stands for Point of Interest, in case you missed that somewhere...
    effect poi_effect = EffectAreaOfEffect(aoeID, "cb_poi_enter", "****", "cb_poi_exit");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, poi_effect, oTarget);

    // We have to do some odd things to keep access to this particular AoE
    // This will be used when you want to remove
    //OBJECT_TYPE_AREA_OF_EFFECT
    object oAoE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, GetLocation(oTarget));
    SetLocalObject(OBJECT_SELF, "MEME_AoE", oAoE);

    _End("CreatingPoI", DEBUG_UTILITY);
}


void   MeAddEmitterToCreature(object oCreature, string sName) // You can attach multiple emitters to a creature.
{
    _Start("MeAddEmitterToCreature", DEBUG_UTILITY);

    if (GetObjectType(oCreature) != OBJECT_TYPE_CREATURE) {
        //_PrintString("ERROR: MeAddEmitterToCreature called on non-creature.", DEBUG_UTILITY);
        _End("MeAddEmitterToCreature", DEBUG_UTILITY);
        return;
    }

    // We must have the emitter object create the PoI.
    // The script will call GetAreaOfEffectCreator() to get this object.
    // It will hold the list of active emitters.
    // Yes, this is actually a hack because I cannot get the object an effect is tied to via the effect object.
    object oEmitter = GetLocalObject(oCreature, "MEME_Emitter");

    if (!GetIsObjectValid(oEmitter))
    {
        //_PrintString("Created proxy emitter object.", DEBUG_UTILITY);
        oEmitter = CreateObject(OBJECT_TYPE_PLACEABLE, "poi_observation", GetLocation(oCreature));
        if (!GetIsObjectValid(oEmitter))
        {
            //_PrintString("Emitter object not created.", DEBUG_UTILITY);
        }
        SetLocalObject(oCreature, "MEME_Emitter", oEmitter); // Point to the emitter source
        SetLocalObject(oEmitter, "MEME_Target", oCreature);  // Point from the source to the actual emitting object
        SetLocalObject(oEmitter, "MEME_Emitter", oEmitter);  // Circular - you can always get MEME_Emitter to get the emitter
    }

    // New we store the PoI name and make sure the emitter starts the AoE, if necessary
    MeAddStringRef(oEmitter, sName, "MEME_Emitter");
    //_PrintString("There are "+IntToString(MeGetStringCount(oEmitter, "MEME_Emitter"))+" PoI emitters on this object.", DEBUG_UTILITY);
    if (MeGetStringCount(oEmitter, "MEME_Emitter") == 1)
    {
        //_PrintString("Creating initial AreaOfEffect.", DEBUG_UTILITY);
        // poi stands for Point of Interest, in case you missed that somewhere...
        AssignCommand(oEmitter, _CreatePoI(oCreature, sName));
    }
    _End("MeAddEmitterToCreature", DEBUG_UTILITY);
}


object MeGetEmitterAtLocation(location lLocation)
{
    _Start("MeGetEmitterAtLocation", DEBUG_UTILITY);
    object oEmitter = GetFirstObjectInShape(SHAPE_CUBE, 1.0, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
    object oResult = OBJECT_INVALID;

    while(oEmitter != OBJECT_INVALID)
    {
        if (MeGetStringCount(oEmitter, "MEME_Emitter") != 0)
        {
            oResult = oEmitter;
            oEmitter = OBJECT_INVALID;
        }
        else oEmitter = GetNextObjectInShape(SHAPE_CUBE, 1.0, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
    }

    return oResult;
    _End("MeGetEmitterAtLocation", DEBUG_UTILITY);
}

object MeAddEmitterToLocation(location lLocation, string sName)
{
    _Start("MeAddEmitterToLocation emitter-name='"+sName+"'", DEBUG_UTILITY);

    int count;
    object oCursor = GetFirstObjectInShape(SHAPE_CUBE, 1.0, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
    object oEmitter = OBJECT_INVALID;

    if (oCursor == OBJECT_INVALID)
    {
        //_PrintString("I haven't found any placeables at this location...", DEBUG_UTILITY);
    }
    while (oCursor != OBJECT_INVALID)
    {
        count = MeGetStringCount(oCursor, "MEME_Emitter");
        //_PrintString("I have found an object ("+_GetName(oCursor)+") with "+IntToString(count)+" emitters.", DEBUG_UTILITY);
        if (count != 0)
        {
            oEmitter = oCursor;
            oCursor = OBJECT_INVALID;
        }
        else oCursor = GetNextObjectInShape(SHAPE_CUBE, 1.0, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
    }

    if (oEmitter == OBJECT_INVALID)
    {
        //_PrintString("Creating initial emitter placeholder.", DEBUG_UTILITY);
        oEmitter = CreateObject(OBJECT_TYPE_PLACEABLE, "poi_observation", lLocation);
        SetLocalObject(oEmitter, "MEME_Emitter", oEmitter); // Circular reference intended
        SetLocalObject(oEmitter, "MEME_Target", oEmitter);  // Circular reference intended
        if (!GetIsObjectValid(oEmitter))
        {
            //_PrintString("Error: failed to create emitter placeholder.", DEBUG_UTILITY);
        }
        DelayCommand(0.0, AssignCommand(oEmitter, _CreatePoIAtLocation(lLocation, sName) ));
    }

    //_PrintString("Adding the emitter: "+sName+". ("+_GetName(oEmitter)+")", DEBUG_UTILITY);
    MeAddStringRef(oEmitter, sName, "MEME_Emitter");

    //_PrintString("There are now "+IntToString(MeGetStringCount(oEmitter, "MEME_Emitter"))+" emitters.", DEBUG_UTILITY);

    _End("MeAddEmitterToLocation", DEBUG_UTILITY);
    return oEmitter; // This is returned so that it can be easily destroyed later.
}


void MeDefineEmitter(string sName, string sTestFunc = "", string sActivateFunction = "", string sExitFunction = "",
                     string sResRef = "", string sEnterText = "", string sExitText = "",
                     int iFlags = EMIT_TO_PC, float fDistance = POI_SMALL /* 5.0 */,
                     int fCacheTest = 0, int fCacheNotify = 0)
{
    _Start("MeDefineEmitter emitter-name='"+sName+"'", DEBUG_UTILITY);

    object oModule = GetModule();
    // Just register the unique name for access, later
    // Think of the shared namespace as optimization - if six creatures register "odor",
    // it will just get set to the last creature's definition.
    SetLocalString(oModule, "MEME_Emitter_"+sName+"ResRef", sResRef);
    SetLocalString(oModule, "MEME_Emitter_"+sName+"EnterText", sEnterText);
    SetLocalString(oModule, "MEME_Emitter_"+sName+"ExitText", sExitText);
    SetLocalString(oModule, "MEME_Emitter_"+sName+"EnterFilter", sTestFunc);
    SetLocalString(oModule, "MEME_Emitter_"+sName+"ActivateFunction", sActivateFunction);
    SetLocalString(oModule, "MEME_Emitter_"+sName+"ExitFunction", sExitFunction);
    SetLocalInt(oModule, "MEME_Emitter_"+sName+"Flags", iFlags);
    SetLocalFloat(oModule, "MEME_Emitter_"+sName+"Distance", fDistance);
    SetLocalInt(oModule, "MEME_Emitter_"+sName+"TestCache", fCacheTest);
    SetLocalInt(oModule, "MEME_Emitter_"+sName+"NotifyCache", fCacheNotify);

    _End("MeDefineEmitter", DEBUG_UTILITY);
}

void MeDefineEmitterMessage(string sName, struct message stEnterMsg, struct message stExitMsg)
{
    MeSetLocalMessage(GetModule(), "MEME_Emitter_In"+sName, stEnterMsg);
    MeSetLocalMessage(GetModule(), "MEME_Emitter_Out"+sName, stExitMsg);
}

void MeRemoveEmitter(object oObject, string sName)
{
    _Start("MeRemoveEmitter name='"+sName+"'", DEBUG_UTILITY);

    int i = 0;
    string sID;
    // First, find the true emitter
    object oEmitter = GetLocalObject(oObject, "MEME_Emitter");
    object oTarget = GetLocalObject(oEmitter, "MEME_Target");
    object oAOE;

    if (!GetIsObjectValid(oEmitter))
    {
        //_PrintString("This is not an emitter, or an emitting creature.", DEBUG_UTILITY);
        _End("MeRemoveEmitter", DEBUG_UTILITY);
        return;
    }

    if (sName != "")
    {
        //_PrintString("There are currently "+IntToString(MeGetStringCount(oEmitter, sName))+" emitters.", DEBUG_UTILITY);
        //_PrintString("Removing emitter...", DEBUG_UTILITY);
        MeRemoveStringRef(oEmitter, sName,  "MEME_Emitter");
    }
    //_PrintString("There are now "+IntToString(MeGetStringCount(oEmitter, "MEME_Emitter"))+" emitters left.", DEBUG_UTILITY);

    // If possible, just destroy the emitter rather than doing garbage collection
    if ((sName == "") || (MeGetStringCount(oEmitter, "MEME_Emitter") == 0))
    {
        // First find the AOE
        oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oTarget);

        //_PrintString("Removing entire emitter.", DEBUG_UTILITY);
        if (!GetIsObjectValid(oAOE))
        {
            //_PrintString("Error: Cannot find area of effect to destroy.", DEBUG_UTILITY);
        }
        else
        {
            //_PrintString("I have the AOE to destroy ("+GetTag(oAOE)+")", DEBUG_UTILITY);
        }
        DestroyObject(oAOE);
        if (oTarget != OBJECT_INVALID) SetLocalObject(oTarget, "MEME_Emitter", OBJECT_INVALID);
        DestroyObject(oEmitter);

    }
    // Otherwise clean up the cached data the emitter collected
    else
    {
        //_PrintString("Cleaning up any potential cached information.", DEBUG_UTILITY);
        // We will only clean up what we currently know about. I leave it up to your expiration timers to do the rest.
        // If the user didn't set a duration -- it's their loss in memory. I removed alternative attempts as
        // garbage collection. Ultimately they were far more costly to the average case.
        for (i = MeGetObjectCount(oEmitter, sName) - 1; i >= 0; i--)
        {
            sID = ObjectToString(MeGetObjectByIndex(oEmitter, i, sName));
            // This value is cached to represent that the creature passed or failed the filter check
            DeleteLocalInt(oEmitter, "MEME_"+sName+"_TESTCACHE_"+sID);
            // This value is cached to represent that the creature has been emitted to -- and shouldn't be again
            DeleteLocalInt(oEmitter, "MEME_"+sName+"_NOTIFYCACHE_"+sID);
            // These values are used by pending delay commands to know if they should destroy the previous cache values.
            // If a destruction function runs and the value is 1 it will destroy the int; if 0 it does nothing; if > 0 it decrements.
            DeleteLocalInt(oEmitter, "MEME_"+sName+"_NOTIFYCACHEITERATOR_"+sID);
            DeleteLocalInt(oEmitter, "MEME_"+sName+"_TESTCACHEITERATOR_"+sID);
        }
        MeDeleteObjectRefs(oEmitter, sName);
    }

    _End("MeRemoveEmitter", DEBUG_UTILITY);
}

void MePauseEmitter(object oTarget, string sName = "")
{
    _Start("MePauseEmitter", DEBUG_UTILITY);

    // First, find the true emitter
    object oEmitter = GetLocalObject(oTarget, "MEME_Emitter");
    if (!GetIsObjectValid(oEmitter))
    {
        //_PrintString("This is not an emitter, or an emitting creature.", DEBUG_UTILITY);
        _End("MePauseEmitter", DEBUG_UTILITY);
        return;
    }

    SetLocalInt(oEmitter, "MEME_Paused"+sName, 1);
    _End("MePauseEmitter", DEBUG_UTILITY);
}

void MeResumeEmitter(object oTarget, string sName)
{
    _Start("MeResumeEmitter", DEBUG_UTILITY);

    // First, find the true emitter
    object oEmitter = GetLocalObject(oTarget, "MEME_Emitter");
    if (!GetIsObjectValid(oEmitter))
    {
        //_PrintString("This is not an emitter, or an emitting creature.", DEBUG_UTILITY);
        _End("MeResumeEmitter", DEBUG_UTILITY);
        return;
    }

    SetLocalInt(oEmitter, "MEME_Paused"+sName, 0);
    DelayCommand(0.1, ExecuteScript("cb_poi_hbt", oEmitter));

    _End("MeResumeEmitter", DEBUG_UTILITY);
}

// -------- PoI Binding Utilities ----------------------------------------------

//  MeBindEmitterToTag
//  This says which objects with the given tag should recieve an emitter.
//  It is used in conjunction with MeInitEmitters();
void MeBindEmitterToTag(string sTag, string sEmitter)
{
  MeAddStringRef(GetModule(), sEmitter, "MEME_BindE");
  MeAddStringRef(GetModule(), sTag, "MEME_BindT");
}

//  _AddEmitterToTag
//  This is an internal function that breaks up the assigning of emitters to
//  objects in stages, to avoid TMI. It calls itself for each chunk; it is
//  used by MeInitEmitters.
void _AddEmitterToTag(string sTag, string sEmitter, int Nth)
{
    location l;
    object oTarget = GetObjectByTag(sTag, Nth);
    int MAX_ITEMS_TO_PROCESS = Nth + 20;

    for (0; Nth < MAX_ITEMS_TO_PROCESS && oTarget != OBJECT_INVALID; Nth++)
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
        {
            MeAddEmitterToCreature(oTarget, sEmitter);
        }
        else
        {
            l = GetLocation(oTarget);
            MeAddEmitterToLocation(l, sEmitter);
        }
        oTarget = OBJECT_INVALID;
        oTarget = GetObjectByTag(sTag, Nth);
    }

    if (oTarget != OBJECT_INVALID)
    {
        DelayCommand(0.0, _AddEmitterToTag(sTag, sEmitter, Nth));
    }
}

//  MeAddEmitterByTag
void MeAddEmitterByTag(string sTagName, string sEmitter)
{
    DelayCommand(0.0, _AddEmitterToTag(sTagName, sEmitter, 1));
}



