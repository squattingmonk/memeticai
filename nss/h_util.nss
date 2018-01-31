#include "h_list"
#include "h_private"
#include "h_debug"
#include "h_constants"

/* File: h_util - Memetic Utility File
 * Author: William Bull, Daryl Low, Lucllo
 * Date: Copyright April, 2003
 *
 * Description
 *
 * These are the foundation functions which are used to manipulate memetic
 * data structures. The vast majority of these are not specific to the
 * memetic toolkit and are generally useful to everyone out there in la la land.
 *
 * Many thanks go to Lucullo for his improvements to the Me*Ref functions.
 * Much more work will be done to allow for variable inheritance and garbage
 * collection. We hope to make your eyes pop out of your head, Real Soon Now.
 *
 */

// ----- Prototypes ------------------------------------------------------------

// ------ Core Memetics --------------------------------------------------------

// MeLoadLibrary
// File: h_util
// This loads a library with a given name, like "lib_ai". This should be done once
// within the module's startup. The scripts inside the lib are registered and are
// accessible via a call to MeExecuteScript().
//
// sLib: The name of the script that is a library.
void   MeLoadLibrary      (string sLib);

// MeInit
// File: h_util
// This sets up the data structures to initialize a Memetic NPC
//
// This function creates a memetic store object that holds all of the NPC's memetic datastructures.
// It also initializes the global variable, NPC_SELF. This is where all memetic variables should
// be stored. This object is inspected by other memetic scripts and will be saved, when NPC saving
// is supported. It is you memetic equivalent to OBJECT_SELF.
object MeInit(object oTarget = OBJECT_INVALID);

// MeExecuteScript
// File: h_util
// This is an internal function to the MemeticAI Toolkit.
//
// This function calls ExecuteScript on the appropriate script. It also handles
// dispatching into a library, if the script is registered as a lib-script. This
// also sets up a MEME_SELF global so the script can set local data on a private object.
//
// sScript: The name of the memetic object.
// sMethod: The name of the callback to the memetic object.
//          It must match a method name registered in a library, or it must be
//          a suffix that is appended to sScript (like "_go").
//          If the sScript is not in a library, a standard ExecuteScript is called
//          on sScript+sMethod.
// oSelf:   This defines who actaully executes the script. If the script performs
//          Actions*(), it will be on this object's action queue.
// oInstance: This is the memetic object. It sets what will the MEME_SELF global
//            variable is. This allows the memetic callback to get access to
//            local data.
void   MeExecuteScript(string sScript, string sMethod, object oSelf = OBJECT_SELF, object oInstance = OBJECT_INVALID);

// MeCallFunction
// File: h_util
// Dynamically calls a Function that is defined in a Library Script.
//
// The function returns an object result. This object must be defined by the
// Function script via a call to MeSetResult(anObject).
//
// sFunction: The name of the to be called. It must either be exported from
//            a pre-loaded library, or it will attempt to automatically load
//            a library with the same name as the function.
// oArg: This is an object that may be passed to the function. The function
//       can get at this object via the global variable, MEME_ARGUMENT or by
//       using MeGetArgument().
object MeCallFunction(string sFunction, object oArg=OBJECT_INVALID, object oSelf = OBJECT_SELF, object oInstance = OBJECT_INVALID);


// _MeMakeObject
// File: h_util
// This is an internal function to the MemeticAI Toolkit.
//
// This creates an object within the memetic store. To track these objects, reference
// variables are setup - these are safe guards against the failure of Bioware's scripts.
object _MeMakeObject(object oContainer, string sName,   int iType, string sPrefix = "");

// _MeMoveObject
// File: h_util
// This is an internal function to the MemeticAI Toolkit.
//
// This moves an object within the memetic store. To track these objects, reference
// variables are setup - these are safe guards against the failure of Bioware's scripts.
void   _MeMoveObject(object oContainer, object oObject, object oDestContainer, string sPrefix = "");

// _MeRemoveObject
// File: h_util
// This is an internal function to the MemeticAI Toolkit.
//
// This removes an object within the memetic store. To track these objects, reference
// variables are setup - these are safe guards against the failure of Bioware's scripts.
void   _MeRemoveObject(object oContainer, object oObject, string sPrefix = "");


// ----- Datastructure Utilities ------------------------------------------------

// MeGetNPCSelf
// File: h_util
//
// This will get the memetic store for the taget NPC. If the NPC is not memetic,
// this will return an invalid object. The memetic store is where you should
// store all your memetic data about a creature. That way, if you would like
// to create  a new creature (for appearance's sake, or to chage stastics), you
// can reattach it to use this store.
//
// As a convention, you should not set data on any memetic creature. Instead
// set it on the NPCSelf object.
object MeGetNPCSelf(object oTarget = OBJECT_SELF);

// MeGetNPCSelfOwner
// File: h_util
//
// Returns the actual creature object that an NPC_SELF belongs to.
object MeGetNPCSelfOwner(object oNPCSelf);

// ----- Variable Binding Routines ------------------------------------------------

// MeUpdateLocals
// File: h_util
//
// This will cause the target to copy variables from a source to the target.
// The source and target variable are defined via the MeBind*() functions.
//
// oTarget: an object that was the "target" parameter to MeBind*().
//          If this object is a memetic sequence, the command to update will
//          be propogated to each item in the sequence.
//
//    Note: This allows a sequence S to have children C1, C2, ... Cn
//          Each child can bind some parameters to the sequence's variable. S <-> Cn
//          Then several of the children can be adjusted by changing the
//          variables on the sequence and calling MeUpdateLocals().
void MeUpdateLocals(object oTarget);

// MeBindLocalObject
// File: h_util
// This instructs the target object to copy the variable from the source object
// to a local variable on the target object, whenever MeUpdateLocals() is called.
//
// oSource:         The object which owns the object variable, which will be copied.
// sSourceVariable: The name of the variable on the source object.
// oTarget:         The object which take the new value from the source.
// sTargetVariable: The name of the variable which the copy will be applied to.
void MeBindLocalObject   (object oSource, string sSourceVariable, object oTarget, string sTargetVariable);

// MeBindLocalFloat
// File: h_util
// This instructs the target object to copy the variable from the source object
// to a local variable on the target object, whenever MeUpdateLocals() is called.
//
// oSource:         The object which owns the object variable, which will be copied.
// sSourceVariable: The name of the variable on the source object.
// oTarget:         The object which take the new value from the source.
// sTargetVariable: The name of the variable which the copy will be applied to.
void MeBindLocalFloat    (object oSource, string sSourceVariable, object oTarget, string sTargetVariable);

// MeBindLocalInt
// File: h_util
// This instructs the target object to copy the variable from the source object
// to a local variable on the target object, whenever MeUpdateLocals() is called.
//
// oSource:         The object which owns the object variable, which will be copied.
// sSourceVariable: The name of the variable on the source object.
// oTarget:         The object which take the new value from the source.
// sTargetVariable: The name of the variable which the copy will be applied to.
void MeBindLocalInt      (object oSource, string sSourceVariable, object oTarget, string sTargetVariable);

// MeBindLocalString
// File: h_util
// This instructs the target object to copy the variable from the source object
// to a local variable on the target object, whenever MeUpdateLocals() is called.
//
// oSource:         The object which owns the object variable, which will be copied.
// sSourceVariable: The name of the variable on the source object.
// oTarget:         The object which take the new value from the source.
// sTargetVariable: The name of the variable which the copy will be applied to.
void MeBindLocalString   (object oSource, string sSourceVariable, object oTarget, string sTargetVariable);

// MeBindLocalObject
// File: h_util
// This instructs the target object to copy the variable from the source object
// to a local variable on the target object, whenever MeUpdateLocals() is called.
//
// oSource:         The object which owns the object variable, which will be copied.
// sSourceVariable: The name of the variable on the source object.
// oTarget:         The object which take the new value from the source.
// sTargetVariable: The name of the variable which the copy will be applied to.
void MeBindLocalLocation (object oSource, string sSourceVariable, object oTarget, string sTargetVariable);

// ----- Auto Adjusting Variables- ------------------------------------------------

// MeSetTemporaryFlag
// File: h_util
// Create a flag that will be set to zero after a duration.
// This will not collide with any other variables named sVarName.
//
// oObject: The target object which will hold the temporary variable.
// sVarName: The name of the variable.
// iValue: The value you want to be set on the variable.
// iDurationInSeconds: The number of seconds from now until the variable should be
//                     set to zero. If you pass a duration of 0, the variable will
//                     stay at that value until you call this function again with
//                     a non-zero duration.
void MeSetTemporaryFlag(object oObject, string sVarName, int iValue, int iDurationInSeconds);

// MeGetTemporaryFlag
// File: h_util
// Get the value of a temporary flag variable, given the sVarName.
//
// oObject: The target object which holds a temporary varible, set by a call to MeSetTemporaryFlag.
// sVarName:The name of the variable.
int MeGetTemporaryFlag(object oObject, string sVarName);

// MeSetDecayingInt
// File: h_util
// Set an Integer variable that is gradually reduced to zero.
//
// This does not use DelayCommand and does not destroy the variable. The decay
// does not take any CPU resources.
//
// oObject:  The object which holds the decaying integer.
// sVarName: The name of the decaying integer variable.
// iValue:   The current value, which will start to decay immediately.
//           The value may be positive or negative.
// fSlope:   The amount of change over time which will cause the int to reach 0.
//           The decrease will follow the downward slope of a bell-shaped curve
//           A (0 or positive) Slope value can be supplied to change the speed of the decay:
//           - if fSlope is 1 (default) an Int starting at 100 will decay to 0 in 100 seconds
//           - a Slope more then 1 will accelerate the decay
//           - a Slope less then 1 will slow the decay
//           - if Slope is 0 then the Int will remain constant
void MeSetDecayingInt(object oObject, string sVarName, int iValue, float fSlope=1.0f);

// MeSetDecayingIntByTTL
// File: h_util
// Set an Integer variable that is reduced to zero within X seconds.
//
// This does not use DelayCommand and does not destroy the variable. The decay
// does not take any CPU resources. It is a cover for MeSetDecayingInt().
//
// oObject:   The object which holds the decaying integer.
// sVarName:  The name of the decaying integer variable.
// iValue:    The current value, which will start to decay immediately.
//            The value may be positive or negative.
// fLifetime: The life of the variable, in seconds. The decrease follows a
//            downwards slope after fLifetime seconds, falling towards zero.
void MeSetDecayingIntByTTL(object oObject, string sVarName, int iValue, float fLifetime);

// MeGetDecayingInt
// File: h_util
// Get the current value of the decaying Int set with MeSetDecayingInt()
//
// oObject:   The object which holds the decaying integer.
// sVarName:  The name of the decaying integer variable.
int MeGetDecayingInt(object oObject, string sVarName);

// MeClearDecayingInt
// File: h_util
// Deletes a decaying Int set with MeSetDecayingInt()
//
// oObject:   The object which holds the decaying integer.
// sVarName:  The name of the decaying integer variable.
void MeClearDecayingInt(object oObject, string sVarName);

// ----- Flag Utilities --------------------------------------------------------

// MeAddMemeFlag
// File: h_util
// Sets an internal flag on a memetic object. These flags are using for defining
// how a behavior is scheduled.
//
// For example, if you wanted a meme to start repeating, you could call
// MeAddMemeFlag(oMeme, MEME_REPEAT);
void   MeAddMemeFlag(object oObject, int iFlag);

// MeClearMemeFlag
// File: h_util
// Removes an internal flag on a memetic object.
void   MeClearMemeFlag(object oObject, int iFlag);

// MeGetMemeFlag
// File: h_util
// Checks to set if the flag or set of flags are set on an object.
//
// For example, if you wanted to see if a meme resumed and repeated, you call:
// if (MeGetMemeFlag(oMeme, MEME_RESUME & MEME_REPEAT)) { ... }
int    MeGetMemeFlag(object oObject, int iFlag);

// MeSetMemeFlag
// File: h_util
// Clears all of the flags on the memetic object and sets just the given flags.
// This is an efficient  combination of Clear and Add.
void   MeSetMemeFlag(object oObject, int iFlag);

// ----- Class & Inheritance Functions -----------------------------------------

// MeRegisterClass
// File: h_util
// This creates the datastructures needed to represent a class in the game.
// A class object is an object which has "declared" variables on it.
//
// This will also execute the class initialization script <classname>_ini.
// This script may declared in a library. It is commonly used to declare
// variables on the class that may be inherited by instances of the class.
//
// sClassName:  A unique class name. I *highly* recommend you prefix these
//              with c_<name>. This name will prefix the class scripts
//              c_vermin_ini, c_vermin_go, c_vermin_end, etc.
//
// oClassObject: You may provide your own class object. If you do not,
//               the an invisible storage object will be created for you.
object MeRegisterClass(string sClassName, object oClassObject = OBJECT_INVALID);

// ----- Other Utilities -------------------------------------------------------

// MeGetRGB
// File: h_util
// Returns a special character which will cause speech text o be colorized.
// NWN allows this character to be concatenated with the speech string to set
// the color. This works for a variety of text strings which appear over the
// head of the NPC or PC.
//
// For Example: SendMessageToPC(pc,GetRGB(15,15,1)+ "Help, I'm on fire!"); will produce yellow text.
// For Example: FloatingTextStringOnCreature(GetRGB(15,1,1)+ "20 Points", pc, FALSE); will produce red text.
//
//  GetRGB()        : WHITE
//  GetRGB(15,15,1) : YELLOW
//  GetRGB(15,5,1)  : ORANGE
//  GetRGB(15,1,1)  : RED
//  GetRGB(7,7,15)  : BLUE
//  GetRGB(1,15,1)  : NEON GREEN
//  GetRGB(1,11,1)  : GREEN
//  GetRGB(9,6,1)   : BROWN
//  GetRGB(11,9,11) : LIGHT PURPLE
//  GetRGB(12,10,7) : TAN
//  GetRGB(8,1,8)   : PURPLE
//  GetRGB(13,9,13) : PLUM
//  GetRGB(1,7,7)   : TEAL
//  GetRGB(1,15,15) : CYAN
//  GetRGB(1,1,15)  : BRIGHT BLUE
string MeGetRGB(int red = 15,int green = 15,int blue = 15);

// MeGetIsVisible
// File: h_util
// A basic evaluation function to check if oSource can see oTarget.
int MeGetIsVisible(object oTarget, object oSource = OBJECT_SELF);

int    MeGetTime();
float  MeGetFloatTime();

// _RemoveQuotes
// File: h_util
// This is an internal function used by the toolkit for debugging, etc.
// Given a string, remove the quotes.
string _RemoveQuotes(string tag);

// _RemoveSpaces
// File: h_util
// This is an internal function used by the toolkit for debugging, etc.
// This function properly normalize thes xml tag string. It will assume you
// may pass a name-value attribute pair. It is used by _GetName().
//
// Mr. Jack attrib=value  --->  Mr.Jack attrib=value
// Old Mibbs Thickney     --->  OldMibbsThickney
// a b c d = 123          --->  abc d = 123
string _RemoveSpaces(string tag);

// _MeKeyCombine
// File: h_util
// This is an internal function to the class system. Its job is to combine
// two unique keys into a new unique a+b key. This allows the toolkit to track
// multiple inheritance with a single unique identifier.
string _MeKeyCombine (string a, string b);

// _MeNewKey
// File: h_util
// This is an internal function to the class system. Its job is to create
// a unique key that can be combined with _MeKeyCombine.
string _MeNewKey ();

// -----------------------------------------------------------------------------
// ----- Source ----------------------------------------------------------------
// -----------------------------------------------------------------------------

// ---- Auto-expiring integer variables ----------------------------------------

void _MeClearTemporaryFlag(object oObject, string sVarName, int iTimeStamp, string sClassName)
{
    _Start("_MeClearTemporaryFlag", DEBUG_UTILITY);
    if (GetLocalInt(oObject, "MEME_TemporaryVarTimeStamp"+sVarName) == iTimeStamp)
    {
        //_PrintString("Deleting automatic variable: MEME_TemporaryVariable_"+sVarName);
        DeleteLocalInt(oObject, "MEME_TemporaryVariable_"+sVarName);
    }
    _End("_MeClearTemporaryFlag", DEBUG_UTILITY);
}

void MeSetTemporaryFlag(object oObject, string sVarName, int iValue, int iDurationInSeconds)
{
    _Start("MeSetTemporaryFlag", DEBUG_UTILITY);
    // The namespace variable allows several creatures to store their flag on the same creature
    string sClassName = ObjectToString(OBJECT_SELF);
    int iTimeStamp = GetLocalInt(oObject, "MEME_TemporaryVarTimeStamp"+sClassName) + 1;
    SetLocalInt(oObject, "MEME_TemporaryVarTimeStamp"+sVarName, iTimeStamp);
    //_PrintString("Setting automatic timestamp: MEME_TemporaryVarTimeStamp"+sVarName, DEBUG_UTILITY);
    //_PrintString("Setting automatic variable: MEME_TemporaryVariable_"+sVarName, DEBUG_UTILITY);
    SetLocalInt(oObject, "MEME_TemporaryVariable_"+sVarName, iValue);
    // If you pass a 0 time, this will lock in the value as "on".
    if (iDurationInSeconds > 0)
    {
        DelayCommand(IntToFloat(iDurationInSeconds), _MeClearTemporaryFlag(oObject, sVarName, iTimeStamp, sClassName));
    }
    _End("MeSetTemporaryFlag", DEBUG_UTILITY);
}

int    MeGetTemporaryFlag(object oObject, string sVarName)
{
    _Start("MeGetTemporaryFlag", DEBUG_UTILITY);
    int iResult = GetLocalInt(oObject, "MEME_TemporaryVariable_"+ObjectToString(OBJECT_SELF)+sVarName);
    //_PrintString("Getting automatic variable: MEME_TemporaryVariable_"+ObjectToString(OBJECT_SELF)+sVarName+" ("+IntToString(iResult)+")");
    _End("MeGetTemporaryFlag", DEBUG_UTILITY);
    return iResult;
}

void MeClearDecayingInt(object oObject, string sVarName)
{
    _Start("MeClearDecayingInt", DEBUG_UTILITY);
    DeleteLocalInt(oObject, "MEME_DecayingVariable_"+sVarName);
    DeleteLocalFloat(oObject, "MEME_DecayingVariableStart_"+sVarName);
    DeleteLocalFloat(oObject, "MEME_DecayingVariableSlope_"+sVarName);
    _End("MeClearDecayingInt", DEBUG_UTILITY);
}

void MeSetDecayingInt(object oObject, string sVarName, int iValue, float fSlope=1.0f)
{
    _Start("MeSetDecayingInt", DEBUG_UTILITY);
    if (!iValue)                                // zero value, just drop the variable
        MeClearDecayingInt(oObject, sVarName);
    else
    {
        float fNow = GetTimeSecond()       +
                    (GetTimeMinute() * 60) +
                     HoursToSeconds(GetTimeHour() + ((GetCalendarDay() - 1) * 24));
        SetLocalInt(oObject, "MEME_DecayingVariable_"+sVarName, iValue);
        SetLocalFloat(oObject, "MEME_DecayingVariableStart_"+sVarName, fNow);
        SetLocalFloat(oObject, "MEME_DecayingVariableSlope_"+sVarName, fSlope);
    }
    _End("MeSetDecayingInt", DEBUG_UTILITY);
}

int MeGetDecayingInt(object oObject, string sVarName)
{
    _Start("MeGetDecayingInt", DEBUG_UTILITY);
    int iResult = GetLocalInt(oObject, "MEME_DecayingVariable_"+sVarName);
    if (iResult) // skip if zero
    {
        float fX =   GetTimeSecond()       +
                    (GetTimeMinute() * 60) +
                     HoursToSeconds(GetTimeHour() + ((GetCalendarDay() - 1) * 24));
        fX -= GetLocalFloat(oObject, "MEME_DecayingVariableStart_"+sVarName);
        if (fX < 0.0)                           // wrapped around end-of-month
            fX += HoursToSeconds(672);          // hours in a month 24 * 28
        fX *= 0.02145966f;          // adjustment factor = sqrt(ln(100)) / 100
        float fSlope = GetLocalFloat(oObject, "MEME_DecayingVariableSlope_"+sVarName);
        float fFactor = pow(2.71828182845904523536028747135266 ,   // e
                           (fSlope * fX * fX));
        iResult = FloatToInt(iResult / fFactor);
        if (!iResult)                           // became zero, drop the variable
            MeClearDecayingInt(oObject, sVarName);
    }
    _End("MeGetDecayingInt", DEBUG_UTILITY);
    return iResult;
}

void MeSetDecayingIntByTTL(object oObject, string sVarName, int iValue, float fGameTimeToLive)
{
    _Start("MeSetDecayingIntByTTL", DEBUG_UTILITY);
    float fSlope = log(IntToFloat(abs(iValue)));
    fSlope /= pow((fGameTimeToLive * 0.02145966f ), 2.0f);
    MeSetDecayingInt(oObject, sVarName, iValue, fSlope);
    _End("MeSetDecayingIntByTTL", DEBUG_UTILITY);
}

/*  This function will likely be tweaked as the system improves. It is the
 *  reusable function for determinining if an NPC sees another creature. This
 *  should take into account a variety of internal states (like the use of a
 *  feat, or a natural detection ability). At this time it is pretty simple.
 *  -W. Bull, June 2000
 */
int MeGetIsVisible(object oTarget, object oSource = OBJECT_SELF)
{
    _Start("MeGetIsVisible", DEBUG_UTILITY);

    if (!GetObjectSeen(oTarget, oSource))
    {
        _End("MeGetIsVisible", DEBUG_UTILITY);
        return 0;
    }

    if (GetHasSpellEffect(SPELL_INVISIBILITY_SPHERE, oTarget) ||
        GetHasSpellEffect(SPELL_INVISIBILITY, oTarget))
    {
        if (GetHasSpellEffect(SPELL_TRUE_SEEING, oSource) ||
            GetHasSpellEffect(SPELL_SEE_INVISIBILITY, oSource))
        {
            _End("MeGetIsVisible", DEBUG_UTILITY);
            return 1;
        }

        _End("MeGetIsVisible", DEBUG_UTILITY);
        return 0;
    }

    _End("MeGetIsVisible", DEBUG_UTILITY);
    return 1;

    /* Notes - some things which may be an issue, later:
    Blindness? Darkness?
    Smell?
    Lighting Conditions
    Invisibility
    Distance
    Hidden / Stealth
    Special Cases (A cannot see B)
    Field of Vision
    Size of creature
    Motion tracking "T-Rex"

    EffectDarkness
    EffectBlindness
    EffectInvisibility
    EffectSeeInvisible
    GetCreatureSize
    GetStealthMode
    EffectDisappear
    EffectDeath
    EffectTrueSeeing
    EffectUltravision
    GetDetectMode
    FEAT_ALERTNESS
    FEAT_KEEN_SENSE
    FEAT_LOWLIGHTVISION
    FEAT_LUCKY
    FEAT_NATURE_SENSE
    FEAT_PARTIAL_SKILL_AFFINITY_SPOT
    FEAT_PARTIAL_SKILL_AFFINITY_SEARCH
    FEAT_SKILL_AFFINITY_SPOT
    FEAT_SKILL_AFFINITY_SEARCH
    FEAT_SKILL_AFFINITY_MOVE_SILENTLY
    FEAT_SKILL_FOCUS_HIDE
    FEAT_PARTIAL_SKILL_AFFINITY_LISTEN
    FEAT_SKILL_AFFINITY_CONCENTRATION
    FEAT_SKILL_FOCUS_LISTEN
    FEAT_SKILL_FOCUS_SEARCH
    */
}

// -----------------------------------------------------------------------------

object MeGetNPCSelf(object oTarget = OBJECT_SELF)
{
    return GetLocalObject(oTarget, "MEME_NPCSelf");
}

object MeGetNPCSelfOwner(object oNPCSelf)
{
    return GetLocalObject(oNPCSelf, "MEME_Owner");
}

/* Setup Meme Bags
 * Used to construct the containers which hold memetic objects.
 * Warning: if you call MeInit on another creature, your global NPC_SELF
 *          is screwed. Beware.
 */
object MeInit(object oTarget = OBJECT_INVALID)
{
    _Start("MeInit", DEBUG_TOOLKIT);

    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;
    object oSelf = GetLocalObject(oTarget, "MEME_NPCSelf");

    if (!GetIsObjectValid(oSelf))
    {
        location l = GetLocation(oTarget);
        object area = GetAreaFromLocation(l);
        //_PrintString("NPC is in area "+_GetName(area), DEBUG_UTILITY);

        object oMemeMagicWP = GetObjectByTag("Magic_Memetic_WP");
        if (oMemeMagicWP == OBJECT_INVALID) PrintString("<Assert>Cannot find the waypoint - Magic_Memetic_WP - this used to be called MemeVault.</Assert>");
        else
        {
            _PrintString("Magic Memetic WP is present, good.", DEBUG_TOOLKIT);
        }

        // This is what I wanted to do, but it doesn't appear to work.
        // If you can get it working, please let me know. It's late and I'm
        // tired and don't have much more time to waste on such foolishness.
        //oSelf = CopyObject(GetObjectByTag("Magic_Memetic_Store"), GetLocation(oTarget), OBJECT_INVALID, "Memetic NPC Self");
        //oSelf = CreateObject(OBJECT_TYPE_ITEM, "NW_IT_CONTAIN006", GetLocation(oMemeMagicWP));
        //oSelf = CreateObject(OBJECT_TYPE_STORE, "NW_STORGENRAL001", GetLocation(oTarget));

        // This has been changed to create the hidden stores in the hidden vault area.
        // There appear to be bugs with the destruction of stores in populated areas.
        // In particular destroying stores can cause the game to crash.
        oSelf = CreateObject(OBJECT_TYPE_STORE, "Magic_Memetic_Store", GetLocation(oMemeMagicWP));
        SetLocalInt(oSelf, "MEME_Type", TYPE_NPC_SELF);
        if (!GetIsObjectValid(oSelf))
        {
            _PrintString("Assert: Failed to create NPC_SELF on object:"+_GetName(oTarget));
        }
        else
        {
            _PrintString("NPC_SELF initialized, store successfully created.", DEBUG_TOOLKIT);
        }

        if (oTarget == OBJECT_SELF) NPC_SELF = oSelf;

        SetLocalObject(oTarget, "MEME_NPCSelf", oSelf);
        SetLocalObject(oSelf,   "MEME_Owner",   oTarget);
        SetLocalString(oSelf,   "Name", GetName(oTarget)+"s Store");

        object oBag = OBJECT_INVALID;

        oBag = _MeMakeObject(oSelf, "GeneratorBag",  TYPE_GENERATOR_BAG);
        SetLocalObject(oSelf, "MEME_GeneratorBag", oBag);
        oBag = _MeMakeObject(oSelf, "EventBag",  TYPE_EVENT_BAG);
        SetLocalObject(oSelf, "MEME_EventBag", oBag);
        oBag = _MeMakeObject(oSelf, "PrioBag1", TYPE_PRIO_BAG1);
        SetLocalObject(oSelf, "MEME_PrioBag1", oBag);
        oBag = _MeMakeObject(oSelf, "PrioBag2", TYPE_PRIO_BAG2);
        SetLocalObject(oSelf, "MEME_PrioBag2", oBag);
        oBag = _MeMakeObject(oSelf, "PrioBag3", TYPE_PRIO_BAG3);
        SetLocalObject(oSelf, "MEME_PrioBag3", oBag);
        oBag = _MeMakeObject(oSelf, "PrioBag4", TYPE_PRIO_BAG4);
        SetLocalObject(oSelf, "MEME_PrioBag4", oBag);
        oBag = _MeMakeObject(oSelf, "PrioBag5", TYPE_PRIO_BAG5);
        SetLocalObject(oSelf, "MEME_PrioBag5", oBag);

        oBag = _MeMakeObject(oSelf, "SuspendBag", TYPE_PRIO_SUSPEND);
        SetLocalObject(oSelf, "MEME_SuspendBag", oBag);
    }

    // NPC_SELF is a global that represents the memetic self (as opposed to OBJECT_SELF).
    // This is the object that should hold your variables and will be saved, when saving
    // NPCs is supported.
    if (oTarget == OBJECT_SELF) NPC_SELF = oSelf;

    _End("MeInit", DEBUG_TOOLKIT);
    return oSelf;
}

/* Run a Memetic Script
 * This executes a script such as i_attack_go and constructs a Self object
 * for storing local data to the script.
 */
void MeExecuteScript(string sScript, string sMethod, object oSelf = OBJECT_SELF, object oInstance = OBJECT_INVALID)
{
    if (sScript == "") return;

    _Start("MeExecuteScript script = '"+sScript+sMethod+"'", DEBUG_TOOLKIT);

    object oModule = GetModule();
    string sLib = GetLocalString(oModule, "MEME_Script_"+sScript);
    int iEntry;

    if (sLib == "")                 // not in library, first call (runs once)
    {
        MeLoadLibrary(sScript);       // Attempt to Autoload "same-name library"
        sLib = GetLocalString(oModule, "MEME_Script_"+sScript);
        if (sLib == "")
        {
            sLib = "*nolib*";
            SetLocalString(oModule, "MEME_Script_"+sScript, sLib);
        }
    }

    if (sLib == "*nolib*")      // the meme is not in a library
    {
        sLib = sScript+sMethod;   // try the old way
    }
    else
    {
        iEntry = GetLocalInt(oModule, "MEME_Entry_"+sLib+sScript+sMethod);
        if (!iEntry)         // meme doesn't implement this method
        {
            _End("MeExecuteScript", DEBUG_TOOLKIT);
            return;
        }
    }

    SetLocalString(oModule, "MEME_LastExec", sLib);
    SetLocalString(oModule, "MEME_LastCalled", sScript);
    SetLocalString(oModule, "MEME_LastMethod", sMethod);
    SetLocalInt(oModule, "MEME_LastEntryPoint", iEntry);
    object self = GetLocalObject(oSelf, "MEME_ObjectSelf");
    if (oInstance != OBJECT_INVALID) SetLocalObject(oSelf, "MEME_ObjectSelf", oInstance);
    ExecuteScript(sLib, oSelf);
    if (oInstance != OBJECT_INVALID) SetLocalObject(oSelf, "MEME_ObjectSelf", self);
    _End("MeExecuteScript", DEBUG_TOOLKIT);
}

/* Library Functions
 * Used for Meme-code Libraries maintenance
 * Lucullo 2003
 */

void MeLoadLibrary(string sLib)
{
    _Start("MeLoadLibrary library = '"+sLib+"'", DEBUG_TOOLKIT);

    object oModule = GetModule();
    SetLocalString(oModule, "MEME_LastExec", sLib);
    SetLocalString(oModule, "MEME_LastCalled", sLib);
    SetLocalString(oModule, "MEME_LastMethod", "_load");
    SetLocalInt(oModule, "MEME_LastEntryPoint", 0);
    ExecuteScript(sLib, oModule);

    _End("MeLoadLibrary", DEBUG_TOOLKIT);
}

/* Dynamically calls a Function in a Library
 * Lucullo 2003
 */
object MeCallFunction(string sFunction, object oArg=OBJECT_INVALID, object oSelf = OBJECT_SELF, object oInstance = OBJECT_INVALID)
{
    _Start("MeCallFunction function = '"+sFunction+"'", DEBUG_TOOLKIT);

    object oModule = GetModule();
    string sLib = GetLocalString(oModule, "MEME_Script_"+sFunction);
    int iEntry;

    if (sLib == "")                 // not in library, first call (runs once)
    {
        MeLoadLibrary(sFunction);       // Attempt to Autoload "same-name library"
        sLib = GetLocalString(oModule, "MEME_Script_"+sFunction);
        if (sLib == "")
        {
            sLib = "*nolib*";
            SetLocalString(oModule, "MEME_Script_"+sFunction, sLib);
        }
    }

    if (sLib == "*nolib*")      // the function is not in a library
    {
        _End("MeCallFunction", DEBUG_TOOLKIT);
        return OBJECT_INVALID;
    }

    iEntry = GetLocalInt(oModule, "MEME_Entry_"+sLib+sFunction);
    if (!iEntry)                // function isn't implemented
    {
        _End("MeCallFunction", DEBUG_TOOLKIT);
        return OBJECT_INVALID;
    }

    SetLocalString(oModule, "MEME_LastExec", sLib);
    SetLocalString(oModule, "MEME_LastCalled", sFunction);
    SetLocalString(oModule, "MEME_LastMethod", "");
    SetLocalInt   (oModule, "MEME_LastEntryPoint", iEntry);
    SetLocalObject(oModule, "MEME_FunctionArg", oArg);
    object oSaveResult = GetLocalObject(oModule, "MEME_FunctionResult");
    SetLocalObject(oModule, "MEME_FunctionResult", OBJECT_INVALID);
    object self = GetLocalObject(oSelf, "MEME_ObjectSelf");
    if (oInstance != OBJECT_INVALID) SetLocalObject(oSelf, "MEME_ObjectSelf", oInstance);
    ExecuteScript(sLib, oSelf);
    if (oInstance != OBJECT_INVALID) SetLocalObject(oSelf, "MEME_ObjectSelf", self);
    object oResult = GetLocalObject(oModule, "MEME_FunctionResult");
    SetLocalObject(oModule, "MEME_FunctionResult", oSaveResult);
    _End("MeCallFunction", DEBUG_TOOLKIT);
    return oResult;
}

// ----- List Handling Functions -----------------------------------------------


// This is an internal function; it takes a list of strings and creates
// an exploded string list with the given name. This works on lists that
// look might like: "red, green,blue, dark orange, black,white"
void MeExplodeList(object oTarget, string sCompressedList, string sListName)
{
    _Start("MeExplodeList"+" input='"+sCompressedList+"'", DEBUG_UTILITY);
    int    len  = GetStringLength(sCompressedList);
    int    offset;
    string text = sCompressedList;
    string item;

    // This function parses the list "a, b,c,d, e,f" and processes each item.
    do
    {
        // Remove white space from the front of text
        // Rember, we're in a loop here so we may have just gone from:
        // "a, b" to " b" after "a," is stripped away. Since we want to
        // process "b" not " b" we strip away all spaces. Observe that
        // this does not allow for "a , b". In this case item will be "a ".
        while(FindSubString(text, " ") == 0) text = GetStringRight(text, --len);

        // Now find where the first item ends -- look for a comma.
        offset = FindSubString(text, ",");
        //_PrintString("Substring comma found at "+IntToString(offset)+".", DEBUG_UTILITY);
        // If we found a comma there's more than one item; peel it off and
        // truncate the left side of list, removing the item and its comma.
        if (offset != -1)
        {
            item  = GetStringLeft(text, offset);
            len   -= offset+1;
            text  = GetStringRight(text, len);
        }
        // Otherwise the offset is -1, we didn't find a comma - there is only one item left.
        else
        {
            item = text;
            text = "";
        }

        // Now process the next item off the list
        MeAddStringRef(oTarget, item, sListName);
        //_PrintString("Split off item '"+item+"'.", DEBUG_UTILITY);
        //_PrintString("Remaining list is '"+text+"'.", DEBUG_UTILITY);

    } while (text != "");

    _End("MeExplodeList", DEBUG_UTILITY);
}

// ----- Variable Binding Routines ---------------------------------------------

// This version does not update sequences.
void _MeUpdateLocals(object oTarget)
{
    _Start("MeUpdateLocals", DEBUG_UTILITY);
    int i;

    // Copy Object Values
    for (i = MeGetObjectCount(oTarget, "MEME_OBIND_SourceObj") - 1; i >= 0; i--)
    {
        SetLocalObject(oTarget,
                       MeGetStringByIndex(oTarget, i, "MEME_OBIND_TargetVar"),
                       GetLocalObject(MeGetObjectByIndex(oTarget, i, "MEME_OBIND_SourceObj"),
                                      MeGetStringByIndex(oTarget, i, "MEME_OBIND_SourceVar")));
    }

    // Copy Float Values
    for (i = MeGetObjectCount(oTarget, "MEME_FBIND_SourceObj") - 1; i >= 0; i--)
    {
        SetLocalFloat(oTarget,
                       MeGetStringByIndex(oTarget, i, "MEME_FBIND_TargetVar"),
                       GetLocalFloat(MeGetObjectByIndex(oTarget, i, "MEME_FBIND_SourceObj"),
                                      MeGetStringByIndex(oTarget, i, "MEME_FBIND_SourceVar")));    }

    // Copy Int Values
    for (i = MeGetObjectCount(oTarget, "MEME_IBIND_SourceObj") - 1; i >= 0; i--)
    {
        SetLocalInt(oTarget,
                       MeGetStringByIndex(oTarget, i, "MEME_IBIND_TargetVar"),
                       GetLocalInt(MeGetObjectByIndex(oTarget, i, "MEME_IBIND_SourceObj"),
                                      MeGetStringByIndex(oTarget, i, "MEME_IBIND_SourceVar")));    }

    // Copy String Values
    for (i = MeGetObjectCount(oTarget, "MEME_SBIND_SourceObj") - 1; i >= 0; i--)
    {
        SetLocalString(oTarget,
                       MeGetStringByIndex(oTarget, i, "MEME_SBIND_TargetVar"),
                       GetLocalString(MeGetObjectByIndex(oTarget, i, "MEME_SBIND_SourceObj"),
                                      MeGetStringByIndex(oTarget, i, "MEME_SBIND_SourceVar")));
    }

    // Copy Location Values
    for (i = MeGetObjectCount(oTarget, "MEME_LBIND_SourceObj") - 1; i >= 0; i--)
    {
        SetLocalLocation(oTarget,
                       MeGetStringByIndex(oTarget, i, "MEME_LBIND_TargetVar"),
                       GetLocalLocation(MeGetObjectByIndex(oTarget, i, "MEME_LBIND_SourceObj"),
                                      MeGetStringByIndex(oTarget, i, "MEME_LBIND_SourceVar")));
    }

    _End("MeUpdateLocals", DEBUG_UTILITY);
}

void MeUpdateLocals(object oTarget)
{
    object oSequence = OBJECT_INVALID;
    object oObject   = OBJECT_INVALID;
    int i;

    if (GetLocalInt(oTarget, "MEME_Type") == TYPE_SEQUENCE)
    {
        oSequence = oTarget;
    }
    else if (GetLocalInt(oTarget, "MEME_Type") == TYPE_SEQ_REF)
    {
        oSequence = GetLocalObject(oTarget, "MEME_Sequence");
    }


    if (oSequence != OBJECT_INVALID)
    {
        for (i = MeGetObjectCount(oSequence) - 1; i >= 0; i--)
        {
            oObject = MeGetObjectByIndex(oSequence, i);
            MeUpdateLocals(oObject);
        }
    }
    else
    {
        _MeUpdateLocals(oTarget);
    }
}

void MeBindLocalObject(object oSource, string sSourceVariable, object oTarget, string sTargetVariable)
{
    _Start("MeBindLocalObject", DEBUG_UTILITY);
    MeAddObjectRef(oTarget, oSource, "MEME_OBIND_SourceObj");
    MeAddStringRef(oTarget, sTargetVariable, "MEME_OBIND_TargetVar");
    MeAddStringRef(oTarget, sSourceVariable, "MEME_OBIND_SourceVar");
    _End("MeBindLocalObject", DEBUG_UTILITY);
}

void MeBindLocalFloat(object oSource, string sSourceVariable, object oTarget, string sTargetVariable)
{
    _Start("MeBindLocalFloat", DEBUG_UTILITY);
    MeAddObjectRef(oTarget, oSource, "MEME_FBIND_SourceObj");
    MeAddStringRef(oTarget, sTargetVariable, "MEME_FBIND_TargetVar");
    MeAddStringRef(oTarget, sSourceVariable, "MEME_FBIND_SourceVar");
    _End("MeBindLocalFloat", DEBUG_UTILITY);
}

void MeBindLocalInt(object oSource, string sSourceVariable, object oTarget, string sTargetVariable)
{
    _Start("MeBindLocalInt", DEBUG_UTILITY);
    MeAddObjectRef(oTarget, oSource, "MEME_IBIND_SourceObj");
    MeAddStringRef(oTarget, sTargetVariable, "MEME_IBIND_TargetVar");
    MeAddStringRef(oTarget, sSourceVariable, "MEME_IBIND_SourceVar");
    _End("MeBindLocalInt", DEBUG_UTILITY);
}

void MeBindLocalString(object oSource, string sSourceVariable, object oTarget, string sTargetVariable)
{
    _Start("MeBindLocalString", DEBUG_UTILITY);
    MeAddObjectRef(oTarget, oSource, "MEME_SBIND_SourceObj");
    MeAddStringRef(oTarget, sTargetVariable, "MEME_SBIND_TargetVar");
    MeAddStringRef(oTarget, sSourceVariable, "MEME_SBIND_SourceVar");
    _End("MeBindLocalString", DEBUG_UTILITY);
}

void MeBindLocalLocation(object oSource, string sSourceVariable, object oTarget, string sTargetVariable)
{
    _Start("MeBindLocalLocation", DEBUG_UTILITY);
    MeAddObjectRef(oTarget, oSource, "MEME_LBIND_SourceObj");
    MeAddStringRef(oTarget, sTargetVariable, "MEME_LBIND_TargetVar");
    MeAddStringRef(oTarget, sSourceVariable, "MEME_LBIND_SourceVar");
    _End("MeBindLocalLocation", DEBUG_UTILITY);
}


// Original implementation by Genji, Rich Dersheimer, and ADAL-Miko
string MeGetRGB(int red = 15,int green = 15,int blue = 15)
{
    object coloringBook = GetObjectByTag("coloringbook");
    if (coloringBook == OBJECT_INVALID)
        coloringBook = CreateObject(OBJECT_TYPE_ITEM,"coloringbook",GetLocation(OBJECT_SELF));
    string buffer = GetName(coloringBook);
    if(red > 15) red = 15; if(green > 15) green = 15; if(blue > 15) blue = 15;
    return "<c" + GetSubString(buffer, red - 1, 1) + GetSubString(buffer, green - 1, 1) + GetSubString(buffer, blue - 1, 1) +">";
}


/* This function properly normalize thes xml tag string:
 * Mr. Jack attrib=value  --->  Mr.Jack attrib=value
 * Old Mibbs Thickney     --->  OldMibbsThickney
 * a b c d = 123          --->  abc d = 123
 */
string _RemoveSpaces(string tag)
{
    int    len, offset;
    string left, right, original;

    offset  = FindSubString(tag, " ");
    while (offset != -1)
    {
        original = tag;
        len   = GetStringLength(tag);
        left  = GetStringLeft (tag, offset);
        right = GetStringRight(tag, len - GetStringLength(left) - 1);
        tag   = left + right;
        offset  = FindSubString(tag, " ");
    }
    return tag;
}

string _RemoveQuotes(string tag)
{
    int    len, offset;
    string left, right, original;

    offset  = FindSubString(tag, "'");
    while (offset != -1)
    {
        original = tag;
        len   = GetStringLength(tag);
        left  = GetStringLeft (tag, offset);
        right = GetStringRight(tag, len - GetStringLength(left) - 1);
        tag   = left + right;
        offset  = FindSubString(tag, "'");
    }
    return tag;
}

/* Class Functions */

// Create the virtual class object.
object MeRegisterClass(string sClassName, object oClassObject = OBJECT_INVALID)
{
    _Start("MeRegisterClass", DEBUG_UTILITY);

    string sClassKey = _MeNewKey();
    object oModule = GetModule();
    object oMemeMagicWP = GetObjectByTag("Magic_Memetic_WP");
    if (oMemeMagicWP == OBJECT_INVALID) PrintString("<Assert>The MemeticAI Toolkit was unable to initialize because a waypoint named 'Magic_Memetic_WP' was not created in this module. Please add a this in private area of your module.</Assert>");

    if (oClassObject == OBJECT_INVALID)
    {
        oClassObject = CreateObject(OBJECT_TYPE_ITEM, "NW_IT_CONTAIN006", GetLocation(oMemeMagicWP));
    }
    if (oClassObject == OBJECT_INVALID)
    {
        _PrintString("Error: Failed to make a class object! h_util: MeRegisterClass()");
    }


    // This is used so that its "class bias" can be applied to any memes that
    // it makes, or its decendents make. All decendents of this class will
    // copy this name down.
    SetLocalString(oClassObject, "MEME_ActiveClass", sClassName);

    SetLocalString(oClassObject, "Name", sClassName);
    DelayCommand(0.0, MeExecuteScript("c_"+sClassName,"_ini", OBJECT_SELF, oClassObject));
    _PrintString("Registering class, "+sClassName+".");
    SetLocalObject(oModule,  "MEME_Class_"+sClassName, oClassObject);
    SetLocalObject(oModule,  "MEME_ClassKey_"+sClassKey, oClassObject);
    SetLocalString(oModule,  "MEME_ClassKey_"+sClassName, sClassKey);

    // Note: something very similar to this also occurs in MeInstanceOf()
    //       but here we are just defining one class, in that function you'll
    //       see this key is combined with others and a new object is made
    //       that holds several keys. "Big Fat Whoop! De! Doo!" says Jack Hackett of Boobie Do Wha Loo Loo Loo and you know the rest. La la lee lie lee lie...'You haven't looked at me that way in years; You dreamed me up and left me here; How long was I dreaming for; What was it you wanted me for' - Tom Waits
    SetLocalString(oClassObject, "MEME_ClassKey", sClassKey);

    _End("MeRegisterClass");
    return oClassObject;
}

/* Eliminate Serial Numbers of Command Contexts
 * If I had the ability to handle action parameters I would do this.
 * But I can't, so I won't. Not unless someone at Bioware reads this.
 */

/*
object MeDelayCommand(float fSeconds, action aActionToAssign, object oCommand = OBJECT_INVALID)
{
    int count;
    if (oCommand == OBJECT_INVALID)
    {
        Command = CreateObject(OBJECT_TYPE_STORE, "NW_STORGENRAL001", GetLocation(oActionSubject));
        SetLocalInt(oCommand, "SecretContextCountName", 1);
    }
    else
    {
        count = GetLocalInt(oCommand, "SecretContextCountName");
        if (count <= 0) SetLocalInt(oCommand, "SecretContextCountName", -1);
        else SetLocalInt(oCommand, "SecretContextCountName", count+1);
    }
    DelayCommand(fSeconds, AssignCommand(OBJECT_SELF, _ExecuteAction(aActionToAssign, oCommand, iAutoDestroy)));
}

_ExecuteAction(action aActionToAssign, object oCommand, int iAutoDestroy)
{
    if (GetIsObjectValid(oCommand))
    {
        int count = GetLocalInt(oCommand, "SecretContextCountName");
        DelayCommand(0.0, aActionToAssign);
        count--;
        if (count == 0) if (iAutoDestroy && ) DestroyObject(oCommand);
        else SetLocalInt(oCommand, "SecretContextCountName", count);
    }
}
*/

void MeCancelCommand(object oCommand)
{
    DestroyObject(oCommand);
}

/* Meme Flag Functions
 * These are simple flag functions with one exception for sequences - Some meme
 * flags should not be set directly on a sequence by a user. The set flag
 * function makes sure the right flag is set.
 */

void MeAddMemeFlag(object oObject, int iFlag)
{
    int flag = GetLocalInt(oObject, "MEME_Flags");
    SetLocalInt(oObject, "MEME_Flags", flag | iFlag);
}

void MeClearMemeFlag(object oObject, int iFlag)
{
    int flag = GetLocalInt(oObject, "MEME_Flags");
    int type = GetLocalInt(oObject, "MEME_Type");

    if ((type & TYPE_SEQ_REF) && (iFlag & MEME_REPEAT))
    {
        iFlag &= ~MEME_REPEAT;
        iFlag |= SEQ_REPEAT;
    }

    SetLocalInt(oObject, "MEME_Flags", flag & ~iFlag);
}

int MeGetMemeFlag(object oObject, int iFlag)
{
    //_PrintString("Flag is "+IntToString(GetLocalInt(oObject, "MEME_Flags"))+".", DEBUG_UTILITY);
    int flag = GetLocalInt(oObject, "MEME_Flags");
    return (flag & iFlag);
}

void MeSetMemeFlag(object oObject, int iFlag)
{
    int flag = GetLocalInt(oObject, "MEME_Flags");
    SetLocalInt(oObject, "MEME_Flags", flag | iFlag);
}

/* This is an advanced convienence function. It is used in conjunction with
 * DelayCommand to safely destroy an int on a target. Before calling
 * DelayCommand(fTime, _DestroyCachedInt(...)) an iterator variable needs to
 * be incremented, such that it is starting at 1. In this way if a new timer
 * is created to destroy the int, the old expiration timers stop working.
 */
void _DestroyCachedInt(object oTarget, string sVarName, string sIteratorName)
{
    int iIterator = GetLocalInt(oTarget, sIteratorName);
    if (iIterator == 1)
    {
        DeleteLocalInt(oTarget, sVarName);
        DeleteLocalInt(oTarget, sIteratorName);
        return;
    }
    if (iIterator) SetLocalInt(oTarget, sIteratorName, iIterator - 1);
}


string _MeKeyCombine (string a, string b)
{
    string  x = "";
    int     alen = GetStringLength(a);
    int     blen = GetStringLength(b);
    int     i;

    if (alen < blen) {
        for (i = 0; i < alen; i += 3) {
            x = x + IntToString(((StringToInt(GetSubString(a, i, 3)) - 100) |
                                 (StringToInt(GetSubString(b, i, 3)) - 100)) + 100);
        }
        x = x + GetSubString(b, i, blen - i);
    } else {
        for (i = 0; i < blen; i += 3) {
            x = x + IntToString(((StringToInt(GetSubString(a, i, 3)) - 100) |
                                 (StringToInt(GetSubString(b, i, 3)) - 100)) + 100);
        }
        x = x + GetSubString(a, i, alen - i);
    }

    return x;
}

string _MeNewKey ()
{
    object  oModule = GetModule();
    string  x       = "";
    int     iKey    = GetLocalInt(oModule, "MEME_KeyCount");

    SetLocalInt(oModule, "MEME_KeyCount", iKey + 1);

    while (iKey >= 8) {
        x = x + "100";
        iKey -= 8;
    }
    x = x + IntToString((1 << iKey) + 100);

    return x;
}

int MeGetTime()
{
    return GetTimeSecond() +
           (GetTimeMinute()        * TIME_ONE_MINUTE) +
           (GetTimeHour()          * TIME_ONE_HOUR) +
           ((GetCalendarDay() - 1) * TIME_ONE_DAY);
}

float MeGetFloatTime()
{
    return IntToFloat(MeGetTime())+(IntToFloat(GetTimeMillisecond())/1000);
}

/* Generic Function
 * This is here so that the NWScript editor won't complain about the lack
 * of a main() function.
 */

int StartingConditional()
{
    return TRUE;
}
