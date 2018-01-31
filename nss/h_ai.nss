#include "h_time"
#include "h_landmark_cli"
#include "h_event"
#include "h_response"

/* File: h_ai - Memetic Artificial Intelligence Toolkit
 * Author: William Bull, Daryl Low
 * Date: Copyright April, 2003
 *
 * Description
 *
 * These functions allow for the construction of a modular behavior response
 * system. This script is part of a complete replacement of Bioware's generic AI.
 *
 */

// MeCreateMeme
// File: h_ai
// Create a behavior that is defined in a file or library.
//
// You can attach variables to this meme object. When the meme runs, it can access
// this data through the use of the global variable MEME_SELF.
//
// sName:     The name of the meme, for example "i_wait"
// iPriority: The importance of this behavior:
//            PRIO_HIGH, PRIO_LOW, PRIO_MEDIUM, PRIO_HIGH, PRIO_VERYHIGH
//            The highest priority meme at a given moment will actually run.
// iModifier: The value within a priority band, a number from -100 to 100.
// iFlags:    These control if the behavior of meme through its lifecycle. Some memes will
//            automatically turn on or off flags their own flags, once it is created.
//            MEME_RESUME:  if the meme is interrupted, auto resume the behavior, otherwise destroy it.
//            MEME_REPEAT:  this causes the meme to loop, some memes *must* loop to work, like i_walkwp
//            MEME_INSTANT: do not create this meme, if there are existing higher priority memes
//            MEME_IMMEDIATE: create this meme but don't interrupt the current meme
//            MEME_CHILDREN: Allow multiple children to run, regardless of their return result.
//                           Normally, only one successful child to runs. All other children are destroyed
//                           once a children ends without returning FALSE via a call to MeSetMemeResult();
//                           If the meme ends without calling MeSetMemeResult(FALSE) the toolkit assumes
//                           the child meme succeeds.
//            You can mask flags together, for example: MEME_RESUME | MEME_REPEAT
// oParent:   This is either a generator or another meme.
object MeCreateMeme(string sName, int iPriority = 2, int iModifier = 0, int iFlags = 0x10 /*MEME_RESUME*/, object oParent = OBJECT_INVALID);

// MeSetMemeResult
// File: h_ai
// This defines whether or not the meme completed successfully.
// For example, if the meme represents going somewhere, this function should
// be called if for some reason it cannot get there.
//
// NOTE: If this function is not called, the system assumes the meme succeeded.
//       At this time you really only need to call MeSetMemeResult(FALSE);
//
// This result will be used to evaluate child memes -- these are memes which
// are created with a parent meme parameter. If the meme succeeds, the other
// child memes may be destroyed if this is called with a result of TRUE.
//
// iResult: TRUE or FALSE
void MeSetMemeResult(int iResult, object oMeme = OBJECT_INVALID);

// MeGetMemeResult
// File: h_ai
// This tells you if the child meme has succeeded or failed. If the meme
// does not set a result via MeSetMemeResult then the child is assumed to
// have succeeded.
int MeGetMemeResult(object oMeme = OBJECT_INVALID);

// MeSetPriority
// File: h_ai
// Change the priority of an existing memetic object, This can include memes, generators,
// and events. In fact any object that has an ObjectRef list named ChildMeme.
//
// oTarget:    The meme to be adjusted.
// iPriority:  The importance of this behavior:
//             PRIO_HIGH, PRIO_LOW, PRIO_MEDIUM, PRIO_HIGH, PRIO_VERYHIGH
// iModifier:  An optional value within a priority band, a number from -100 to 100.
// bPropogate: A boolean (0 or 1) to signify that the value set on oTarget should
//             also be set on all the memes refered to in the ChildMeme object ref list.
//             For example a generator that creates a set of memes and is associated
//             to those memes can have its default priority changed. This could
//             cause those previously created memes' priority to change as well.
//
// Notes:      You must call MeUpdateActions(); after calling this function. This will
//             cause any meme priority changes to take effect.
void   MeSetPriority(object oTarget, int iPriority, int iModifier = 0, int bPropogate = 0);

// MeGetPriority
// File: h_ai
// Gets the internal priority of a memetic object. This works on memes, generators and
// event events that have been created with a priority.
int    MeGetPriority(object oMeme);

// MeGetModifier
// File: h_ai
// Gets the internal priority of a memetic object. This works on memes, generators and
// event events that have been created with a priority.
int    MeGetModifier(object oMeme);

// MeDestroyMeme
// File: h_ai
// Destroys a meme and selects the next meme to be activated.
// You may need to call MeUpdateActions() to cause the scheduled meme to execute.
void   MeDestroyMeme(object oMeme);

// MeDestroyChildMemes
// File: h_ai
// Destroys the child memes that belong this parent.
// If this meme is suspended because of those child memes, you should
// call MeResumeMeme(), which calls this function automatically.
// This function does not notify the children with _end or _brk callbacks,
// it does not call UpdateActions() or ComputeBestMeme().
void MeDestroyChildMemes(object oParent, int iResumeParent = 1);

// MeGetActiveMeme
// File: h_ai
// Returns the currently running meme.
object MeGetActiveMeme();

// MeGetPendingMeme
// File: h_ai
// Returns a meme that is scheduled to preempt the current active meme. This
// is the meme that will run as soon as UpdateActions() is called. Its was
// choosen by the internal function, ComputeBestMeme().
object MeGetPendingMeme();

// MeGetMeme
// File: h_ai
// Find a meme on the current NPC with a given name and priority.
// sName:     An optional meme name, like "i_attacK'
// iIndex:    A zero based index into the list of matches
// iPriority: The priority of the meme, PRIO_DEFAULT (0) will match any priority
object MeGetMeme(string sName = "", int iIndex = 0, int iPriority = 0);


// MeGetParentGenerator
// File: h_ai
// If the meme was created by a generator and the generator is associated to it,
// this function returns that generator.
object MeGetParentGenerator(object oMeme);

// MeGetParentMeme
// File: h_ai
// If the meme was created as a child of another meme, this will return that parent meme
// or OBJECT_INVALID if there is no parent.
object MeGetParentMeme(object oMeme);

// MeRestartMeme
// File: h_ai
// This causes the action queue to be cleared, the meme to be interrupted with
// a _brk call, then reinitialized with an _ini call and restarted with a _go call.
//
// oMeme:     The active meme that should be restarted.
// bCallInit: A TRUE or FALSE flag which causes _ini to be called.
void   MeRestartMeme(object oMeme, int bCallInit = 0, float fDelay = 0.0);

// MeStopMeme
// File: h_ai
// This causes the action queue to be cleared, the meme to be interrupted with
// a _brk call, then ended naturally. If the meme is MEME_REPEAT it will likely
// start over, if not it will be destroyed and a the next meme will execute.
void   MeStopMeme(object oMeme, float fDelay = 0.0);

// MeCreateGenerator
// File: h_ai
// This creates a specific generator to respond to NWN callbacks to generate
// memetic objects and signals. The generator is not immediately started.
// You may need to configure the generator's behavior by setting variables on
// the object which this function returns. You will need to start the generator
// by calling MeStartGenerator().
//
// sName:     The string name of the generator. This must match with a name of a
//            generator script (i.e. g_attack) or a generator name in a library.
// iPriority: The priority to be passed to memes this generator creates.
// iModifier: The modifier to be passed to memes this generator creates.
// iFlags:    There are no officially supported generator flags, at this time.
object MeCreateGenerator(string sName, int iPriority = 0, int iModifier = 0, int iFlags = 0);

// MeStartGenerator
// File: h_ai
// This will start the generator and start processing NWN callbacks.
// Each generator may be attached to many NWN callbacks. Once started, a
// generator may respond to these callbacks by creating a variety of memetic
// bjects or communicate via memetic signals.
void   MeStartGenerator(object oGenerator);

// MeStopGenerator
// File: h_ai
// This will stop the generator optionally remove the memetic objects the generator has created.
//
// Each generator may be attached to many NWN callbacks. Once started, a
// generator may respond to these callbacks by creating a variety of memetic
// objects or communicate via memetic signals.
//
// You can attach variables to this generator object. When the generator runs, it can access
// this data through the use of the global variable MEME_SELF.
//
// oGenerator:       an active generator that will be stopped.
// iRemoveChildren:  set of flags to signify which child objects to destroy:
//                   TYPE_MEME:  remove all memes - including sequences which have been started
//                   TYPE_SEQUENCE:  remove all definitions of sequences registered to this generator
void   MeStopGenerator(object oGenerator, int iRemoveChildren = 0x01 /* TYPE_MEME */);

// MeDestroyGenerator
// File: h_ai
// This will destroy a generator.
// Each generator may be attached to many NWN callbacks. Once started, a
// generator may respond to these callbacks by creating a variety of memetic
// objects or communicate via memetic signals. This function ca automatically
// destroy the sequences and memes created by the generater.
//
// oGenerator:       an active generator that will be stopped.
// iRemoveChildren:  set of flags to signify which child objects to destroy:
//                   TYPE_MEME:  if the meme is interrupted, auto resume the behavior, otherwise destroy it.
//                   TYPE_SEQUENCE:  this causes the meme to loop, some memes *must* loop to work, like i_walkwp
void   MeDestroyGenerator(object oGenerator, int iRemoveChildren = 0x11 /* TYPE_MEME | TYPE_SEQUENCE */);

// MeGetGenerator
// File: h_ai
// This gets a generator with the given name or by count.
// You can provide as many or as few of these parameters as you like to query the internal memetic store.
//
// sName:  The name of the generator, like "g_comabt".
// iIndex: The 0 based index of the generator - if there are more than one with the same name.
object MeGetGenerator(string sName = "", int iIndex = 0);

// MeGetChildMeme
// File: h_ai
// This gets the iIndex meme that was created by the given generator or
// meme. Returns OBJECT_INVALID if none exist.
//
// oTarget: The generator or meme that may have an associated child meme.
// iIndex:  The 0 based index of memes it has created.
object MeGetChildMeme(object oTarget, int iIndex = 0);

// MeSuspendMeme
// File: h_ai
// Suspends an active meme, optionally calling the _brk callback.
// This causes the toolkit to start the next highest priority meme.
//
// oMeme:    The meme to be suspended.
// bCallBrk: pass TRUE or FALSE to signal that the _brk script should be called.
void MeSuspendMeme(object oMeme, int bCallBrk = 1);

// MeResumeMeme
// File: h_ai
// Resumes a suspended meme; causes it to be prioritized and potentially activated.
// A meme with children cannot be resumed.
//
// oMeme: A meme that has been suspended and does not have children.
void MeResumeMeme(object oMeme, int bUpdateActions = 1, int bComputeBestMeme = 1);

// MeIsMemeSuspended
// File: h_ai
// Returns TRUE if the meme is currently suspended.
int MeIsMemeSuspended(object oMeme);

// MeCreateSequence
// File: h_ai
// This creates a named sequence which can be reused by calling MeStartSequence().
// Creating a sequence is only the first step - see: MeCreateSequenceMeme().
// A sequence encapsulates a collection of memes. It operates on each meme and possibly changes
// its priority based on the active meme. For an overview on sequences refer to the User's Guide.
//
// sName:     The name of the sequence -- you make this up, arbitrarily. It doesn't correspond to
//            any script name, it's so you can get access to your sequences, later.
// iPriority: The importance of this behavior --
//            PRIO_DEFAULT, PRIO_HIGH, PRIO_LOW, PRIO_MEDIUM, PRIO_HIGH, PRIO_VERYHIGH
//            Using PRIO_DEFAULT will cause the sequence to change its priority to match the meme at each step.
// iModifier: The value within a priority band, a number from -100 to 100.
// iFlags:    These control if the behavior of meme through its lifecycle. Some memes will
//            automatically turn on or off flags their own flags, once it is created.
//            Note:             MEME_RESUME and MEME_REPEAT are not used when you create a sequence.
//            SEQ_REPEAT:       This the sequences version of MEME_REPEAT, you should never clear the MEME_REPEAT
//                              flag on a sequence -- clear the SEQ_REPEAT flag if you want to stop the sequence from repeating.
//            SEQ_RESUME_FIRST: This allows the sequence to resume after being preempted by
//                              another meme. The sequence will restart at the first meme.
//                              If a meme in the sequence has the MEME_CHECKPOINT flag and it is executed,
//                              the sequence will resume at this meme.
//            SEQ_RESUME_LAST:  This allows the sequence to resume after being
//                              preempted by another meme. The sequence will restart
//                              at the last completed meme. If a meme in the sequence has
//                              the MEME_CHECKPOINT flag and it is executed, the sequence will resume at this meme.
//            MEME_INSTANT:     Do not create this meme, if there are existing higher priority memes
//            MEME_IMMEDIATE:   Create this meme but don't interrupt the current meme
//            MEME_CHILDREN: Allow multiple children to run, regardless of their return result.
//                           Normally, only one successful child to runs. All other children are destroyed
//                           once a children ends without returning FALSE via a call to MeSetMemeResult();
//                           If the meme ends without calling MeSetMemeResult(FALSE) the toolkit assumes
//                           the child meme succeeds.
//            You can mask flags together, for example: MEME_RESUME | MEME_REPEAT
object MeCreateSequence(string sName,      int iPriority = 0, int iModifier = 0, int iFlags = 5 /*SEQ_REPEAT | SEQ_RESUME_LAST*/, object oGenerator = OBJECT_INVALID);

// MeCreateSequenceMeme
// File: h_ai
// Create a behavior that is defined in a file or library that will be used in a sequence.
// The primary difference between this and MeCreateMeme is the new flag, MEME_CHECKPOINT,
// described below:
//
// oSequence: The sequence this meme will belong to.
// sName:     The name of the meme, for example "i_wait"(This must corrsepond to a meme script or meme name, in a library.)
// iPriority: The importance of this behavior:
//            PRIO_HIGH, PRIO_LOW, PRIO_MEDIUM, PRIO_HIGH, PRIO_VERYHIGH
//            The highest priority meme at a given moment will actually run.
// iModifier: The value within a priority band, a number from -100 to 100.
// iFlags:    These control if the behavior of meme through its lifecycle. Some memes will
//            automatically turn on or off flags their own flags, once it is created.
//            MEME_CHECKPOINT:  If this meme is part of a sequence, when the sequence resumes,
//                              restart at this point. If this meme is not part of a sequence, this flag does nothing.
//            MEME_RESUME:  if the meme is interrupted, auto resume the behavior, otherwise destroy it.
//            MEME_REPEAT:  this causes the meme to loop, some memes *must* loop to work, like i_walkwp
//            MEME_INSTANT: do not create this meme, if there are existing higher priority memes
//            MEME_IMMEDIATE: create this meme but don't interrupt the current meme
//            MEME_CHILDREN: Allow multiple children to run, regardless of their return result.
//                           Normally, only one successful child to runs. All other children are destroyed
//                           once a children ends without returning FALSE via a call to MeSetMemeResult();
//                           If the meme ends without calling MeSetMemeResult(FALSE) the toolkit assumes
//                           the child meme succeeds.
//            You can mask flags together, for example: MEME_RESUME | MEME_REPEAT
//
// Returns an object representing a sequence. Treat this like a template that can
// be started and stopped over and over again.
object MeCreateSequenceMeme(object oSequence,  string sName, int iPriority = 2, int iModifier = 0, int iFlags = 0x10 /*MEME_RESUME*/);

// object MeStartSequence
// File: h_ai
// Causes a sequence to run. Only one instance of the sequence may be running
// at a given time -- don't call this function twice.
//
// Returns a meme that represents the sequence. The priority of the meme was defined
// by the parameters used in the call to MeCreateSequence(). This object is a real
// meme that can be reprioritized, destroyed, etc.
object MeStartSequence(object oSequence);

// MeStopSequence
// File: h_ai
// Causes the sequence to stop executing, destroying the meme. The memes inside the
// sequence are not destroyed. You can call
//
// oSequenceMeme: the meme returned to you by MeStartSequence()
void   MeStopSequence(object oSequenceMeme);

// MeDestroySequence
// Destroys the sequence.
//
// oSequence: the object returned from MeCreateSequence(). If this sequence is started,
//            it will be stopped before it's destroyed.
void   MeDestroySequence(object oSequence);

// MeGetSequence
// File: h_ai
// Returns a sequence with a given name. This is a sequence created by the NPC, the
// name must match the string passed to MeCreateSequence(). This name doesn't correspond
// to any script - it's just a name you make up.
object MeGetSequence(string sName = "");

// MeExecuteGenerators
// File: h_ai
// This is an internal function to the MemeticAI Toolkit.
void   MeExecuteGenerators(string sSuffix);

// MeComputeBestMeme
// File: h_ai
// This is an internal function to the MemeticAI Toolkit.
void   MeComputeBestMeme(object oMeme = OBJECT_INVALID);

// MeUpdateActions
// File: h_ai
// This causes the highest priority meme to become active.
//
// This is the primary function for starting the memetic behavior of an NPC.
// Normally this is used in an onSpawn script for the creature after a series of
// memes or generators have been created. Multiple calls to this function will
// not break the flow of the normal behavior.
//
// Generator scripts (g_) do not normally need to call this function.
// It is called immediately after all generators are executed.
//
// This function should be called after a meme is reprioritized.
void   MeUpdateActions();

// MeResetSystem
// File: h_ai
// This is called to jump start a stall memetic NPC. This usually happens if
// a script calls ClearAllActions. It will also cancel any current conversation
// because it calls ClearAllActions and restarts the active meme.
void MeRestartSystem();

// MePauseSystem
// File: h_ai
//
// This causes the NPC to stop behaving memetically.***
void MePauseSystem();

// MeHasScheduledMeme
// File: h_ai
// This is an internal function to the MemeticAI Toolkit.
//
// This function checks to see if there is a meme with *at least* the given priority
// and modifier. It is used to see if memes with the MEME_INSTANT flag are allowed to run.
// An optional object may be passed to tell the test function to skip a meme.
// This is used when child memes are created with MEME_INSTANT. The parent meme is being
// suspended, but is still active while the child is being created. This parameter
// allows the function to overlook the value of the given meme and compare all other
// memes.
//
// iPriority: this is the priority to compare it against, like PRIO_LOW, PRIO_HIGH, etc.
// iModifier: this is the modifier from -100 to +100
// oExcludeMeme: this is the meme to overlook -- used to pass up memes that are being suspended.
int    MeHasScheduledMeme(int iPriority, int iModifier, object oExcludeMeme=OBJECT_INVALID);

// -- Implementation -----------------------------------------------------------

void _MemeDone(object oActiveMeme, int iRunInstance);

// ------ Generator Functions---------------------------------------------------

object MeCreateGenerator(string sName, int iPriority = 0, int iModifier = 0, int iFlags = 0)
{
    _Start("MeCreateGenerator name='"+sName+"' priority='"+IntToString(iPriority)+"' modifier = '"+IntToString(iModifier)+"'", DEBUG_TOOLKIT);

    object oGenerator = OBJECT_INVALID;
    object oBag       = OBJECT_INVALID;

    if (!GetIsObjectValid(NPC_SELF)) MeInit();

    oBag = GetLocalObject(NPC_SELF, "MEME_GeneratorBag");
    oGenerator = _MeMakeObject(oBag, sName, TYPE_GENERATOR);

    // Inherit the class of the context that's creating this generator.
    SetLocalString(oGenerator, "MEME_ActiveClass", GetLocalString(MEME_SELF, "MEME_ActiveClass"));

    SetLocalInt(oGenerator, "MEME_Priority", iPriority);
    SetLocalInt(oGenerator, "MEME_Modifier", iModifier);
    SetLocalInt(oGenerator, "MEME_Flags",    iFlags);

    MeExecuteScript(sName,"_ini", OBJECT_SELF, oGenerator);

    _End();
    return oGenerator;
}

void MeStartGenerator(object oGenerator)
{
    _Start("MeStartGenerator name = '"+GetLocalString(oGenerator, "Name")+"'", DEBUG_TOOLKIT);

    SetLocalInt(oGenerator, "MEME_Active", 1);

    _End();
}

void MeStopGenerator(object oGenerator, int iRemoveMemes = 0x01)
{
    _Start("MeStopGenerator name = '"+GetLocalString(oGenerator, "Name")+"'", DEBUG_TOOLKIT);
    SetLocalInt(oGenerator, "MEME_Active", 0);
    int i = 0;
    object oMeme = OBJECT_INVALID;
    int count;
    if (iRemoveMemes & TYPE_MEME)
    {
        count = MeGetObjectCount(oGenerator, "ChildMeme");
        _PrintString("Destroying the meme's created by this generator.");
        for (i = count - 1; i >= 0; i--)
        {
            oMeme = MeGetObjectByIndex(oGenerator, i, "ChildMeme");
            MeDestroyMeme(oMeme);
        }
    }
    if (iRemoveMemes & TYPE_SEQUENCE)
    {
        count = MeGetObjectCount(oGenerator, "ChildSequence");
        _PrintString("Destroying the sequence templates's created by this generator.");
        for (i = count - 1; i >= 0; i--)
        {
            oMeme = MeGetObjectByIndex(oGenerator, i, "ChildSequence");
            MeDestroySequence(oMeme);
        }
    }
    _End();
}

void MeDestroyGenerator(object oGenerator, int iRemoveMemes = 0x11)
{
    _Start("MeDestroyGenerator name = '"+GetLocalString(oGenerator, "Name")+"'", DEBUG_TOOLKIT);

    object oBag  = OBJECT_INVALID;
    object oMeme = OBJECT_INVALID;
    int    count;
    int    i;

    if (!GetIsObjectValid(NPC_SELF)) MeInit();

    oBag = GetLocalObject(NPC_SELF, "MEME_GeneratorBag");

    if (iRemoveMemes)
    {
        if (iRemoveMemes & TYPE_MEME)
        {
            _PrintString("Destroying the meme's created by this generator.");
            count = MeGetObjectCount(oGenerator, "ChildMeme");
            for (i=0; i < count; i++)
            {
                oMeme = MeGetObjectByIndex(oGenerator, i, "ChildMeme");
                MeDestroyMeme(oMeme);
            }
        }
        if (iRemoveMemes & TYPE_SEQUENCE)
        {
            count = MeGetObjectCount(oGenerator, "SequenceMeme");
            _PrintString("Destroying the sequence templates's created by this generator.");
            for (i=0; i < count; i++)
            {
                oMeme = MeGetObjectByIndex(oGenerator, i, "SequenceMeme");
                MeDestroyMeme(oMeme);
            }
        }
    }
    else
    {
        _PrintString("Diassociating this generator from the memes it created.");
        for (i=0; i < count; i++)
        {
            oMeme = MeGetObjectByIndex(oGenerator, i, "ChildMeme");
            DeleteLocalObject(oMeme, "MEME_Generator");
        }
    }

    _MeRemoveObject(oBag, oGenerator);
    _Start("MeDestroyGenerator", DEBUG_TOOLKIT);
}

object MeGetGenerator(string sName = "", int Nth = 0)
{
    _Start("MeGetGenerator name = '"+sName+"' Nth = '"+IntToString(Nth)+"'", DEBUG_TOOLKIT);

    object oGenerator = OBJECT_INVALID;
    object oBag       = OBJECT_INVALID;
    object oMeme      = OBJECT_INVALID;
    int i             = 0;
    int count         = 0;

    if (!GetIsObjectValid(NPC_SELF)) MeInit();
    oBag = GetLocalObject(NPC_SELF, "MEME_GeneratorBag");

    while(1) {
        oMeme = MeGetObjectByIndex(oBag, i, "Meme");
        if (sName == "" || GetLocalString(oMeme, "Name") == sName) {
            if (count == Nth)
            {
                _End();
                return oMeme;
            }
            count++;
        }
        if (!GetIsObjectValid(oMeme)) break;
        i++;
    }

    _End();
    return OBJECT_INVALID;
}

object MeGetChildMeme(object oTarget, int Nth = 0)
{
    _Start("MeGetChildMeme name = '"+GetLocalString(oTarget, "Name")+"' Nth = '"+IntToString(Nth)+"'", DEBUG_TOOLKIT);

    object oMeme = OBJECT_INVALID;
    int i        = 0;
    int count    = 0;

    while(1) {
        oMeme = MeGetObjectByIndex(oTarget, i, "ChildMeme");
        if (count == Nth)
        {
            _End();
            return oMeme;
        }
        count++;
        if (!GetIsObjectValid(oMeme)) break;
        i++;
    }

    _End();
    return OBJECT_INVALID;
}

// ----- Memes Functions -------------------------------------------------------

void MeSuspendMeme(object oMeme, int bCallBrk = 1)
{
    _Start("MeSuspendMeme meme='"+_GetName(oMeme)+"'", DEBUG_TOOLKIT);

    // Only suspend an active meme.
    if (GetLocalInt(oMeme, "MEME_Suspended"))
    {
        _End();
        return;
    }
    SetLocalInt(oMeme, "MEME_Suspended", 1);

    int iPriority = GetLocalInt(oMeme, "MEME_Priority");
    object oPrioBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
    object oSuspendBag = GetLocalObject(NPC_SELF, "MEME_SuspendBag");

    _MeMoveObject(oPrioBag, oMeme, oSuspendBag);

    if (GetLocalObject(NPC_SELF, "MEME_ActiveMeme") == oMeme)
    {
        _PrintString("Suspending the active meme.");
        ClearAllActions();
        if (bCallBrk)
        {
            MeExecuteScript(GetLocalString(oMeme, "Name"),"_brk", OBJECT_SELF, oMeme);

            // January, 2004: Niveau0
            if (!GetLocalInt(oMeme, "MEME_Suspended"))
            {
                int iRunInstance = GetLocalInt(oMeme, "MEME_RunCount");
                iRunInstance++;
                SetLocalInt(oMeme, "MEME_RunCount", iRunInstance);
                //ActionDoCommand(ActionDoCommand(DelayCommand(0.0, _MemeDone(oMeme, iRunInstance))));
                ActionDoCommand(ActionDoCommand(_MemeDone(oMeme, iRunInstance)));
                _End();
                return;
            }
        }

        // If there is only one meme on the NPC and it suspends, there will
        // not be any other meme to be active when ComputeBestMeme is called.
        // ActiveMeme should be cleared to prevent this situation.
        SetLocalObject(NPC_SELF, "MEME_ActiveMeme", OBJECT_INVALID);
    }

    // MeComputeBestMeme(oMeme);
    // January, 2004: Niveau0
    MeComputeBestMeme(OBJECT_INVALID); // Changed to invalid, the suspended one should never run again
    MeUpdateActions();

    _End();
}

// This function is fairly equivalent to repriotizing a meme; it places
// the meme into the appropriate bag and computes the best meme
void MeResumeMeme(object oMeme, int bUpdateActions=1, int bComputeBestMeme=1)
{
    // Only resume a suspended meme.
    if (GetLocalInt(oMeme, "MEME_Suspended") == 0) return;

    _Start("MeResumeMeme", DEBUG_TOOLKIT);

    object oSequence = GetLocalObject(oMeme, "MEME_Sequence");
    object oSeqRef = GetLocalObject(oSequence, "MEME_SequenceRef");

    // Check to see if the parent is a sequence ref,
    // resume that meme instead.
    if (GetIsObjectValid(oSequence) && GetIsObjectValid(oSeqRef))
    {
        // Resume the parent's proxy meme, i_sequence
        _PrintString("Resuming the sequence proxy for meme, " + GetLocalString(oMeme, "Name"), DEBUG_TOOLKIT);
        oMeme = oSeqRef;
        if (GetLocalInt(oMeme, "MEME_Suspended") == 0)
        {
            _End();
            return;
        }
    }
    else
    {
        _PrintString("Resuming meme, " + _GetName(oMeme), DEBUG_TOOLKIT);
    }

    SetLocalInt(oMeme, "MEME_Suspended", 0);

    int iPriority = GetLocalInt(oMeme, "MEME_Priority");
    object oPrioBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
    object oSuspendBag = GetLocalObject(NPC_SELF, "MEME_SuspendBag");
    _MeMoveObject(oSuspendBag, oMeme, oPrioBag);

    if (bComputeBestMeme) MeComputeBestMeme();

    // January, 2004: niveau
    // make update actions optional if more than one meme gets resumed at a time, performance reasons
    // you have to call it manually then
    //MeUpdateActions();
    if (bUpdateActions) MeUpdateActions();

    _End();
}

int MeIsMemeSuspended(object oMeme)
{
    return GetLocalInt(oMeme, "MEME_Suspended");
}

object MeCreateMeme(string sName, int iPriority = 2, int iModifier = 0,
                  int iFlags = 0x10 /*MEME_RESUME*/, object oParent = OBJECT_INVALID)
{
    _Start("MeCreateMeme name = '"+sName+"' priority = '"+IntToString(iPriority)+"' modifier = '"+IntToString(iModifier)+"'", DEBUG_TOOLKIT);

    object oPrioBag, oMeme;
    int    iParentType = GetLocalInt(oParent, "MEME_Type");

    if (!GetIsObjectValid(NPC_SELF)) MeInit();
    if (!GetIsObjectValid(NPC_SELF)) _PrintString("Assert: This is not possible", DEBUG_TOOLKIT);

    // I have considered doing this, please give me feedback:
    // if (oParent == OBJECT_INVALID) oParent = MEME_SELF;

    // If you pass PRIO_DEFAULT you will copy the priority of the parent
    if (GetIsObjectValid(oParent) && iPriority == PRIO_DEFAULT)
    {
        iPriority = GetLocalInt(oParent, "MEME_Priority");
        iModifier = GetLocalInt(oParent, "MEME_Modifier");
    }

    // Adjust the modifier to match the class bais
    string sActiveClass;
    if (oParent == OBJECT_INVALID) sActiveClass = GetLocalString(MEME_SELF, "MEME_ActiveClass");
    else sActiveClass = GetLocalString(oParent, "MEME_ActiveClass");
    if (!(iFlags & MEME_NOBIAS)) iModifier += GetLocalInt(NPC_SELF, "MEME_"+sActiveClass+"_Bias");

    if (iModifier < -100) iModifier = -100;
    else if (iModifier > 100) iModifier = 100;

    if (iPriority == PRIO_DEFAULT) iPriority = PRIO_MEDIUM;

    if ((iFlags & MEME_INSTANT) && (MeHasScheduledMeme(iPriority, iModifier, oParent)))
    {
        _PrintString("Another meme is higher than you, this meme won't get created.", DEBUG_TOOLKIT);
        _End();
        // Eventually a reason can be spoken, if necessary.
        return OBJECT_INVALID;
    }

    // Get the bag which represents the priority slot
    oPrioBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
    if (!GetIsObjectValid(oPrioBag)) _PrintString("Assert: cannot find priobag.", DEBUG_TOOLKIT);

    // Create a meme at the given priority slot
    if (sName == "i_sequence") oMeme = _MeMakeObject(oPrioBag, sName, TYPE_SEQ_REF);
    else oMeme = _MeMakeObject(oPrioBag, sName, TYPE_MEME);
    if (!GetIsObjectValid(oMeme)) _PrintString("Assert: did not make meme.", DEBUG_TOOLKIT);

    // Inherit the class of the context that's creating this generator.
    SetLocalString(oMeme, "MEME_ActiveClass", GetLocalString(MEME_SELF, "MEME_ActiveClass"));

    if (oParent != OBJECT_INVALID)
    {
        // If this is the first child meme, clear the stale result value.
        if (MeGetObjectCount(oParent, "ChildMeme") == 0) SetLocalInt(oParent,"MEME_Result", 0);

        if (iParentType == TYPE_GENERATOR  || iParentType == TYPE_EVENT)
        {
            MeAddObjectRef(oParent, oMeme, "ChildMeme");
            SetLocalObject(oMeme, "MEME_Generator", oParent);
        }
        // If the parent is a meme -- or a sequence meme
        // Child memes always suspend their parent, until all children are destroyed.
        else if ((iParentType == TYPE_MEME) || (iParentType == TYPE_SEQ_REF))
        {
            MeAddObjectRef(oParent, oMeme, "ChildMeme");
            SetLocalObject(oMeme, "MEME_Parent", oParent);

            // Immediately stop the parent, do not call its _brk callback.
            // There is no real reason why I don't call _brk -- it's left here as an
            // option to toggle back, if the it turns out that it makes more sense.
            MeSuspendMeme(oParent, 0);
        }
    }
    SetLocalInt(oMeme, "MEME_Priority", iPriority);
    SetLocalInt(oMeme, "MEME_Modifier", iModifier);
    SetLocalInt(oMeme, "MEME_Flags", iFlags);

    MeExecuteScript(sName,"_ini", OBJECT_SELF, oMeme);
    _PrintString("Executing "+sName+"_ini", DEBUG_TOOLKIT);

    MeComputeBestMeme(oMeme);

    _End();
    return oMeme;
}

int MeGetPriority(object oMeme)
{
    return GetLocalInt(oMeme, "MEME_Priority");
}

int MeGetModifier(object oMeme)
{
    return GetLocalInt(oMeme, "MEME_Modifier");
}

// Private prototype
void _MeDestroyMeme(object oMeme, int iCallEndScript = 1, int iComputeBestMeme = 1, int iDestroySiblings = 1, int iRestartParent = 1);

// It's important to realize that the parameters this passes to _MeDestroyMeme
// cause this function is bypass normal meme-notifcationst that they're ended
void MeDestroyChildMemes(object oParent, int iResumeParent = 1)
{
    _Start("MeDestroyChildMemes name = '"+GetLocalString(oParent, "Name")+"'", DEBUG_TOOLKIT);
    _PrintString("This meme succeeded, we don't need its siblings.", DEBUG_TOOLKIT);
    int count = MeGetObjectCount(oParent, "ChildMeme");
    object oSibling;
    while (count)
    {
        oSibling = MeGetObjectByIndex(oParent, 0, "ChildMeme");
        MeRemoveObjectByIndex(oParent, 0, "ChildMeme");
        _MeDestroyMeme(oSibling, 0, 0, 0, iResumeParent);
        count--;
    }

    _End();
}

void _MeDestroyMeme(object oMeme, int iCallEndScript = 1, int iComputeBestMeme = 1, int iDestroySiblings = 1, int iRestartParent = 1)
{
    _Start("MeDestroyMeme name = '"+GetLocalString(oMeme, "Name")+"'", DEBUG_TOOLKIT);

    object oPrioBag;
    int iPriority;

    iPriority = GetLocalInt(oMeme, "MEME_Priority");
    oPrioBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));

    if (iCallEndScript)
    {
        _PrintString("Running destructor script for meme, "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
        MeExecuteScript(GetLocalString(oMeme, "Name"),"_end", OBJECT_SELF, oMeme);
    }

    // Object is not actually destroyed until after this script runs.
    // Note this is an oddity of NWScript -- more than likely to allow for
    // visual animations and sloppy code -- whatever gets a product out the
    // door and on the shelves, right?
    _MeRemoveObject(oPrioBag, oMeme);

    // If there is a parent, possibly resume the suspended parent
    object oParent = GetLocalObject(oMeme, "MEME_Parent");
    if (GetIsObjectValid(oParent))
    {
        _PrintString("This meme is a child!", DEBUG_TOOLKIT);
        // Evaluate and use MEME_Result
        MeRemoveObjectRef(oParent, oMeme, "ChildMeme");

        // If there are no more children, this meme can be resume.
        if ((MeGetObjectCount(oParent, "ChildMeme") == 0) && iRestartParent)
        {
            _PrintString("This meme is the last child.", DEBUG_TOOLKIT);
            MeResumeMeme(oParent, 0, 0);
        }
        else
        {
            _PrintString("This meme has siblings...", DEBUG_TOOLKIT);

            // If MEME_CHILDREN is set, then we don't care about the return
            // result. Otherwise, destroy the children when one succeeds.
            if (MeGetMemeFlag(oMeme, MEME_CHILDREN) == 0)
            {
                // Ok, in this case, 0 is pass, 1 is fail.
                // This logic is reversed because we want memes to succeed by
                // default. So 0 is the default value of a NWScript variable.
                // You must explicitly call MeSetMemeResult(FALSE) to fail and let
                // a meme's siblings execute.
                if ((GetLocalInt(oParent, "MEME_Result") == 0) && iDestroySiblings)
                {
                    // Note: This code is also done in MeDestroyChildMemes();
                    MeDestroyChildMemes(oParent);
                    MeResumeMeme(oParent, 0, 0);
                }
                else
                {
                    _PrintString("This meme didn't succeed, one of the other siblings will get its chance.", DEBUG_TOOLKIT);
                }
            }
            else
            {
                _PrintString("I'm supposed to play nice and let my siblings go.", DEBUG_TOOLKIT);
            }
        }
    }

    // If there is a generator, possibly detach from the generator's list
    object oGenerator = GetLocalObject(oMeme, "MEME_Generator");
    if (GetIsObjectValid(oGenerator))
    {
        MeRemoveObjectRef(oGenerator, oMeme, "ChildMeme");
    }

    SetLocalObject(NPC_SELF, "MEME_ActiveMeme", OBJECT_INVALID);
    SetLocalObject(NPC_SELF, "MEME_PendingMeme", OBJECT_INVALID);

    if (iComputeBestMeme) MeComputeBestMeme();

    _End();
}

void MeDestroyMeme(object oMeme)
{
    _MeDestroyMeme(oMeme);
}

object MeGetActiveMeme()
{
    return GetLocalObject(NPC_SELF, "MEME_ActiveMeme");
}

object MeGetPendingMeme()
{
    return GetLocalObject(NPC_SELF, "MEME_PendingMeme");
}

object MeGetMeme(string sName = "", int Nth = 0, int iPriority = 0)
{
    _Start("MeGetMeme name = '"+sName+"' Nth = '"+IntToString(Nth)+"'", DEBUG_UTILITY);

    object oBag       = OBJECT_INVALID;
    object oMeme      = OBJECT_INVALID;
    int i, j, nth;
    int count         = 0;

    nth = 0;
    for (i = PRIO_VERYHIGH; i >= PRIO_NONE; i--)
    {
        if (iPriority == 0 || iPriority == i)
        {
            oBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(i));

            count = MeGetObjectCount(oBag);
            oMeme = MeGetObjectByIndex(oBag, 0);
            for (j = 0; j < count; j++)
            {
                _PrintString("Looking at '"+GetLocalString(oMeme, "Name")+"' meme, number "+IntToString(j)+" in PrioBag"+IntToString(i)+".",DEBUG_UTILITY);
                if (sName == "" || GetLocalString(oMeme, "Name") == sName) {
                    if (nth == Nth)
                    {
                        _End();
                        return oMeme;
                    }
                    nth++;
                }
                oMeme = MeGetObjectByIndex(oBag, j);
            }
        }
    }

    _End();
    return OBJECT_INVALID;
}

void _MemeDone(object oActiveMeme, int iRunInstance)
{
    if (!GetIsObjectValid(oActiveMeme)) return;

    if ((oActiveMeme != GetLocalObject(NPC_SELF, "MEME_ActiveMeme")) ||
        (iRunInstance != GetLocalInt(oActiveMeme, "MEME_RunCount"))) {
        _PrintString("We have been overrun!", DEBUG_TOOLKIT);
        _End();
        return;
    }

    string sName = GetLocalString(oActiveMeme, "Name");
    _Start("MemeDone meme = '"+sName+"' run='"+IntToString(iRunInstance)+"'", DEBUG_TOOLKIT);

    // since we are not a main script, reload register for safety
    NPC_SELF           = GetLocalObject (OBJECT_SELF, "MEME_NPCSelf");

    if (GetLocalInt(NPC_SELF, "MEME_Paused")) {
        _PrintString("NPC is paused", DEBUG_TOOLKIT);
        _End();
        return;
    }

    _PrintString("Notifying meme it has completed.", DEBUG_TOOLKIT);
    MeExecuteScript(sName,"_end", OBJECT_SELF, oActiveMeme);

    // Start January, 2004: niveau0
    // Fix for suspended meme
    if (MeGetMemeFlag(oActiveMeme, MEME_REPEAT))
    {
        if (MeIsMemeSuspended(oActiveMeme) ||     // Maybe meme got suspended in _end
            MeGetPriority(oActiveMeme) == PRIO_NONE ||   // Maybe meme lost its priority in _end
            GetIsObjectValid(GetLocalObject(NPC_SELF, "MEME_PendingMeme")))
        {
            MeUpdateActions();
        }
        else
        {
            MeExecuteScript(sName,"_go", OBJECT_SELF, oActiveMeme);
            iRunInstance++;
            SetLocalInt(oActiveMeme, "MEME_RunCount", iRunInstance);
            _PrintString("Meme = "+sName+" next run ="+IntToString(iRunInstance), DEBUG_TOOLKIT);
            ActionDoCommand(ActionDoCommand(_MemeDone(oActiveMeme, iRunInstance)));
        }
        _End();
        return;
    }
    // End niveau0

    _PrintString("Meme completed, destroying.", DEBUG_TOOLKIT);
    _MeDestroyMeme(oActiveMeme, FALSE, FALSE); // Internal version doesn't call _end script.

    _PrintString("Computing next meme.", DEBUG_TOOLKIT);
    MeComputeBestMeme();
    MeUpdateActions();

    _End();
    return;
}

void _MeRestartMeme(object oMeme, int bCallInit, int iTimeStamp)
{
    if (iTimeStamp)
    {
        if (GetLocalInt(oMeme, "MEME_TimeStamp") != iTimeStamp) return;
    }

    _Start("MeRestartMeme name='"+_GetName(oMeme)+"'", DEBUG_UTILITY);

    int iTimeStamp = GetLocalInt(oMeme, "MEME_TimeStamp") + 1;
    SetLocalInt(oMeme, "MEME_TimeStamp", iTimeStamp);

    if (GetLocalObject(NPC_SELF, "MEME_ActiveMeme") == oMeme)
    {
        ClearAllActions();
        MeExecuteScript(GetLocalString(oMeme, "Name"),"_brk", OBJECT_SELF, oMeme);
        if (bCallInit) MeExecuteScript(GetLocalString(oMeme, "Name"),"_ini", OBJECT_SELF, oMeme);
        MeExecuteScript(GetLocalString(oMeme, "Name"),"_go", OBJECT_SELF, oMeme);
    }
    _End();
}

void MeRestartMeme(object oMeme, int bCallInit = 0, float fDelay = 0.0)
{
    _Start("MeRestartMeme name='"+_GetName(oMeme)+"'", DEBUG_UTILITY);

    if (fDelay > 0.0)
    {
        int iTimeStamp = GetLocalInt(oMeme, "MEME_TimeStamp") + 1;
        SetLocalInt(oMeme, "MEME_TimeStamp", iTimeStamp);
        DelayCommand(fDelay, _MeRestartMeme(oMeme, bCallInit, iTimeStamp));
    }
    else
    {
        _MeRestartMeme(oMeme, bCallInit, 0);
    }

    _End();
}


void _MeStopMeme(object oMeme, int iTimeStamp)
{
    if (iTimeStamp)
    {
        if (GetLocalInt(oMeme, "MEME_TimeStamp") != iTimeStamp) return;
    }

    _Start("MeStopMeme name='"+_GetName(oMeme)+"'", DEBUG_UTILITY);

    int iTimeStamp = GetLocalInt(oMeme, "MEME_TimeStamp") + 1;
    SetLocalInt(oMeme, "MEME_TimeStamp", iTimeStamp);

    MeDestroyChildMemes(oMeme, 0);
    MeComputeBestMeme(); // Needed since MeDestroyChildMemes does not...

    _PrintString("ActiveMeme: " + _GetName(GetLocalObject(NPC_SELF, "MEME_ActiveMeme")), DEBUG_UTILITY);
    _PrintString("PendingMeme: " + _GetName(GetLocalObject(NPC_SELF, "MEME_PendingMeme")), DEBUG_UTILITY);

    if (GetLocalObject(NPC_SELF, "MEME_ActiveMeme") == oMeme)
    {
        ClearAllActions();
        MeExecuteScript(GetLocalString(oMeme, "Name"),"_brk", OBJECT_SELF, oMeme);
        int iRunCount = GetLocalInt(oMeme, "MEME_RunCount") + 1;
        SetLocalInt(oMeme, "MEME_RunCount", iRunCount);
        _MemeDone(oMeme, iRunCount);
    }
    else
    {
        _PrintString("No active meme, updating actions.", DEBUG_UTILITY);
        MeUpdateActions();
    }
    _End();
}

void MeStopMeme(object oMeme, float fDelay = 0.0)
{
    _Start("MeStopMeme name='"+_GetName(oMeme)+"'", DEBUG_UTILITY);

    if (fDelay > 0.0)
    {
        int iTimeStamp = GetLocalInt(oMeme, "MEME_TimeStamp") + 1;
        SetLocalInt(oMeme, "MEME_TimeStamp", iTimeStamp);
        DelayCommand(fDelay, _MeStopMeme(oMeme, iTimeStamp));
    }
    else
    {
        _MeStopMeme(oMeme, 0);
    }

    _End();
}

object MeGetParentGenerator(object oMeme)
{
    _Start("MeGetParentGenerator", DEBUG_UTILITY);
    _End();

    return GetLocalObject(oMeme, "MEME_Generator");
}

object MeGetParentMeme(object oMeme)
{
    _Start("MeGetParentMeme", DEBUG_UTILITY);
    _End();

    return GetLocalObject(oMeme, "MEME_Parent");
}

int MeGetMemeResult(object oMeme = OBJECT_INVALID)
{
    if (oMeme == OBJECT_INVALID) oMeme = GetLocalObject (OBJECT_SELF, "MEME_ObjectSelf");
    // NOTICE -- I set 0 as TRUE, 1 as FALSE
    // Why? This allows me to have a default value of 0 as a success.
    return (!GetLocalInt(oMeme, "MEME_Result"));
}

void MeSetMemeResult(int iResult, object oMeme = OBJECT_INVALID)
{
    if (oMeme == OBJECT_INVALID) oMeme = GetLocalObject (OBJECT_SELF, "MEME_ObjectSelf");
    object oParent = MeGetParentMeme(oMeme);
    // NOTICE -- I set 0 as TRUE, 1 as FALSE
    // Why? This allows me to have a default value of 0 as a success.
    SetLocalInt(oParent, "MEME_Result", !iResult);
}

void MeSetPriority(object oTarget, int iPriority, int iModifier = 0, int iPropogate = 0)
{
    _Start("MeSetPriority name = '"+GetLocalString(oTarget, "Name")+"' priority = '"+IntToString(iPriority)+"' modifier = '"+IntToString(iModifier)+"'", DEBUG_TOOLKIT);

    object oActive, oPending;
    object oBag, oNewBag;
    int    iOldPriority;
    int    i, count;
    object oMeme;

    // Changing the priority of a suspended meme is easy.
    if (GetLocalInt(oTarget, "MEME_Suspended") == 1)
    {
        SetLocalInt(oTarget, "MEME_Priority", iPriority);
        SetLocalInt(oTarget, "MEME_Modifier", iModifier);
    }
    else
    {
        iOldPriority = GetLocalInt(oTarget, "MEME_Priority");
        if (iOldPriority != iPriority)
        {
            oBag    = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iOldPriority));
            oNewBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
            SetLocalInt(oTarget, "MEME_Priority", iPriority);
            if (!GetIsObjectValid(NPC_SELF)) _PrintString("ASSERT: NPC_SELF is invalid!", DEBUG_TOOLKIT);
            if (!GetIsObjectValid(oBag)) _PrintString("ASSERT: Bag ("+IntToString(iOldPriority)+") is invalid!", DEBUG_TOOLKIT);
            if (!GetIsObjectValid(oNewBag)) _PrintString("ASSERT: New bag ("+IntToString(iPriority)+") is invalid!", DEBUG_TOOLKIT);
            if (!GetIsObjectValid(oTarget)) _PrintString("ASSERT: meme is invalid!", DEBUG_TOOLKIT);
            _MeMoveObject(oBag, oTarget, oNewBag);
            if (oActive  == oTarget) SetLocalObject(NPC_SELF, "MEME_ActiveMeme", OBJECT_INVALID);
            if (oPending == oTarget) SetLocalObject(NPC_SELF, "MEME_PendingMeme", OBJECT_INVALID);
        }
        SetLocalInt(oTarget, "MEME_Modifier", iModifier);
    }

    if (iPropogate)
    {
        oActive  = GetLocalObject(NPC_SELF, "MEME_ActiveMeme");
        oPending = GetLocalObject(NPC_SELF, "MEME_PendingMeme");

        count = MeGetObjectCount(oTarget, "ChildMeme");
        for (i = 0; i < count; i++)
        {
            oMeme = MeGetObjectByIndex(oTarget, i, "ChildMeme");
            _PrintString("Propogating priority change to meme "+IntToString(i)+" ("+GetLocalString(oMeme,"Name")+").",DEBUG_TOOLKIT);
            MeSetPriority(oMeme, iPriority, iModifier, iPropogate);
        }
    }

    MeComputeBestMeme(oMeme);

    _End();
}

// ----- Sequences -------------------------------------------------------------

object MeCreateSequence(string sName, int iPriority = 0, int iModifier = 0, int iFlags = 5, object oGenerator = OBJECT_INVALID)
{
    _Start("MeCreateSequence name='"+sName+"' priority='"+IntToString(iPriority)+"' modifier = '"+IntToString(iModifier)+"'", DEBUG_TOOLKIT);

    object oSequence = OBJECT_INVALID;
    object oBag      = OBJECT_INVALID;

    if (!GetIsObjectValid(NPC_SELF)) MeInit();

    oBag = GetLocalObject(NPC_SELF, "MEME_Sequence_"+sName);
    if (GetIsObjectValid(oBag))
    {
        _PrintString("Sequence already exists!", DEBUG_TOOLKIT);
        _End();
        return OBJECT_INVALID;
    }

    oSequence = _MeMakeObject(NPC_SELF, sName, TYPE_SEQUENCE);
    SetLocalObject(NPC_SELF, "MEME_Sequence_"+sName, oSequence);

    // Get the active class
    string sActiveClass;
    if (oGenerator == OBJECT_INVALID) sActiveClass = GetLocalString(MEME_SELF, "MEME_ActiveClass");
    else sActiveClass = GetLocalString(oGenerator, "MEME_ActiveClass");

    // Inherit the class of the context that's creating this generator.
    SetLocalString(oSequence, "MEME_ActiveClass", sActiveClass);

    // adopt the priority of the generator if it is passed.
    if (GetIsObjectValid(oGenerator))
    {
        MeAddObjectRef(oGenerator, oSequence, "ChildSequence");
        SetLocalInt(oSequence, "MEME_Priority", GetLocalInt(oGenerator, "MEME_Priority"));
        SetLocalInt(oSequence, "MEME_Modifier", GetLocalInt(oGenerator, "MEME_Modifier"));
        SetLocalObject(oSequence, "MEME_Generator", oGenerator);
    }
    else
    {
        SetLocalInt(oSequence, "MEME_Priority", iPriority);
        SetLocalInt(oSequence, "MEME_Modifier", iModifier);
    }

    // When the real meme is created this modifier will be adjusted; we probably
    // don't need to modify the sequence template.
    // Adjust the modifier based on the active class -- which came from the generator or MEME_SELF
    // if (!(iFlags & MEME_NOBIAS)) iModifier += GetLocalInt(NPC_SELF, "MEME_"+sActiveClass+"_Bias");


    if (iFlags & MEME_REPEAT) iFlags |= SEQ_REPEAT;

    iFlags |= MEME_REPEAT;

    if (iFlags & (SEQ_RESUME_FIRST | SEQ_RESUME_LAST)) iFlags |= MEME_RESUME;

    SetLocalInt(oSequence, "MEME_Flags", iFlags);

    _End();
    return oSequence;
}

object MeCreateSequenceMeme(object oSequence,  string sName,
                          int iPriority = 2, int iModifier = 0,
                          int iFlags = 0x10)
{
    _Start("MeCreateSequenceMeme name = '"+sName+"' priority = '"+IntToString(iPriority)+"' modifier = '"+IntToString(iModifier)+"'", DEBUG_TOOLKIT);

    object oMeme;

    if (!GetIsObjectValid(oSequence))
    {
        _PrintString("No valid sequence given!", DEBUG_TOOLKIT);
        _End();
        return OBJECT_INVALID;
    }

    if (!GetIsObjectValid(NPC_SELF)) MeInit();

    if (iPriority == PRIO_DEFAULT)
    {
        iPriority = GetLocalInt(oSequence, "MEME_Priority");
        if (iPriority) iModifier = GetLocalInt(oSequence, "MEME_Modifier");
        else
        {
            iPriority = PRIO_MEDIUM;
            iModifier = 0;
        }
    }

    // Adjust the modifier to match the class bais
    string sActiveClass = GetLocalString(oSequence, "MEME_ActiveClass");
    if (sActiveClass == "") sActiveClass = GetLocalString(MEME_SELF, "MEME_ActiveClass");
    if (!(iFlags & MEME_NOBIAS)) iModifier += GetLocalInt(NPC_SELF, "MEME_"+sActiveClass+"_Bias");

    if (iModifier < -100) iModifier = -100;
    else if (iModifier > 100) iModifier = 100;

    oMeme = _MeMakeObject(oSequence, sName, TYPE_MEME);

    // Store the ActiveClass
    SetLocalString(oMeme, "MEME_ActiveClass", sActiveClass);

    SetLocalInt(oMeme, "MEME_Priority", iPriority);
    SetLocalInt(oMeme, "MEME_Modifier", iModifier);
    SetLocalInt(oMeme, "MEME_Flags", iFlags);
    SetLocalObject(oMeme, "MEME_Sequence", oSequence);

    _End();
    return oMeme;
}

object MeStartSequence(object oSequence)
{
    _Start("MeStartSequence", DEBUG_TOOLKIT);

    object oSeqRef = GetLocalObject(oSequence, "MEME_SequenceRef");
    if (GetIsObjectValid(oSeqRef))
    {
        _PrintString("Sequence already running!");
        _End();
        return oSeqRef;
    }

    oSeqRef = MeCreateMeme("i_sequence",
                         GetLocalInt(oSequence, "MEME_Priority"),
                         GetLocalInt(oSequence, "MEME_Modifier"),
                         GetLocalInt(oSequence, "MEME_Flags"),
                         GetLocalObject(oSequence, "MEME_Generator"));

    SetLocalString(oSeqRef,"MEME_SequenceName", GetLocalString(oSequence, "Name"));
    SetLocalObject(oSeqRef,"MEME_Sequence", oSequence);

    SetLocalObject(oSequence,"MEME_SequenceRef", oSeqRef);

    _End();
    return oSeqRef;
}

void MeStopSequence(object oTarget)
{
    _Start("MeStopSequence", DEBUG_UTILITY);

    object oObject;
    int iType = GetLocalInt(oTarget, "MEME_Type");

    if (iType == TYPE_SEQUENCE)
    {
        oObject = GetLocalObject(oTarget, "MEME_SequenceRef");
        if (GetIsObjectValid(oObject))
        {
            DeleteLocalObject(oTarget, "MEME_SequenceRef");
            MeDestroyMeme(oObject);
        }
    }
    else if (iType == TYPE_SEQ_REF)
    {
        oObject = GetLocalObject(oTarget, "MEME_Sequence");
        DeleteLocalObject(oObject, "MEME_SequenceRef");
        MeDestroyMeme(oTarget);
    }

    _End();
}

void MeDestroySequence(object oTarget)
{
    _Start("MeDestroySequence", DEBUG_UTILITY);

    object oSequence, oSequenceRef, oObject;
    int i = 0;

    int iType = GetLocalInt(oTarget, "MEME_Type");
    if (iType == TYPE_SEQUENCE)
    {
        oSequence = oTarget;
        oSequenceRef = GetLocalObject(oTarget, "MEME_SequenceRef");
    }
    else if (iType == TYPE_SEQ_REF)
    {
        oSequenceRef = oTarget;
        oSequence = GetLocalObject(oTarget, "MEME_Sequence");
    }
    else
    {
        _End();
        return;
    }

    MeDestroyMeme(oSequenceRef);

    object oGenerator = GetLocalObject(oSequence, "MEME_Generator");
    if (GetIsObjectValid(oGenerator))
    {
        MeRemoveObjectRef(oGenerator, oSequence, "ChildSequence");
    }

    for (i = MeGetObjectCount(oSequence) - 1; i >= 0; i--)
    {
        oObject = MeGetObjectByIndex(oSequence, i);
        DestroyObject(oObject);
    }
    DestroyObject(oSequence);

    _End();
}

object MeGetSequence(string sName = "")
{
    _Start("MeGetSequence", DEBUG_UTILITY);
    _End();

    return GetLocalObject(NPC_SELF,"MEME_Sequence_"+sName);
}


// ----- Core Toolkit ----------------------------------------------------------
void MeExecuteGenerators(string sSuffix)
{
    if (!GetIsObjectValid(NPC_SELF))
    {
        _PrintString("<Assert>This NPC has attempted to prematurely execute generators.</Assert>");
        return;
    }

    _Start("MeExecuteGenerators suffix = '"+sSuffix+"'", DEBUG_TOOLKIT);

    object oBag         = OBJECT_INVALID;
    object oGenerator   = OBJECT_INVALID;
    int    i            = 0;
    int    count        = 0;

    if (GetLocalInt(NPC_SELF, "MEME_Paused"))
    {
        _PrintString("Will not execute generators, the system is paused.", DEBUG_TOOLKIT);
        _End();
        return;
    }

    oBag = GetLocalObject(NPC_SELF, "MEME_GeneratorBag");

    count = MeGetObjectCount(oBag);
    for (i = 0; i < count; i++)
    {
        oGenerator = MeGetObjectByIndex(oBag, i);
        if (GetLocalInt(oGenerator, "MEME_Active"))
        {
            _PrintString("Starting generator "+_GetName(oGenerator)+".", DEBUG_TOOLKIT);
            MeExecuteScript(GetLocalString(oGenerator, "Name"),sSuffix, OBJECT_SELF, oGenerator);
        }

        if (GetLocalInt(oGenerator, "MEME_Flags") & GEN_SINGLEUSE)
        {
            MeDestroyGenerator(oGenerator, 0);
        }
    }
    _End();
}


void MeComputeBestMeme(object oMeme)
{
    _Start("MeComputeBestMeme name = '"+GetLocalString(oMeme, "Name")+"'", DEBUG_TOOLKIT);

    object oBag      = OBJECT_INVALID;
    object oPending  = GetLocalObject(NPC_SELF, "MEME_PendingMeme");
    object oActive   = GetLocalObject(NPC_SELF, "MEME_ActiveMeme");
    int    iPriority = 0;
    int    mPriority = 0;
    int    pPriority = 0;
    int    iModifier = 0;
    int    pModifier = 0;
    int    i = 0;
    int    j = 0;
    string sName; // Only used for debugging.

    // -1. Dead simplest case first.
    // Side Effect: If !GetIsObjectValid(oMeme), then GetLocalInt(oMeme,"MEME_Priority") == 0 != PRIO_NONE
    if (GetLocalInt(oMeme, "MEME_Priority") == PRIO_NONE)
    {
        if ((oMeme != oActive) && (oMeme != oPending))
        {
            _PrintString("No priority meme is ignored.", DEBUG_TOOLKIT);
            // Not Active nor Pending, just ignore it
            _End();
            return;
        }

        // Is Active or Pending, completely recompute pending meme
    }
    else
    {
        // 0. Simplest case first.
        if (!GetIsObjectValid(oPending) && !GetIsObjectValid(oActive) && GetIsObjectValid(oMeme))
        {
            _PrintString("Pending meme is now "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
            SetLocalObject(NPC_SELF, "MEME_PendingMeme", oMeme);

            _End();
            return;
        }

        // 0.1
        if (GetIsObjectValid(oMeme))
        {
            if (!GetIsObjectValid(oPending))
            {
                // 1. Check for case where a recently modified meme beats active meme
                if (oMeme != oActive)
                {
                    _PrintString("#1: Checking to see if meme is better than active meme (" + _GetName(oActive) + ").", DEBUG_TOOLKIT);
                    iPriority = GetLocalInt(oActive, "MEME_Priority");
                    mPriority = GetLocalInt(oMeme, "MEME_Priority");
                    _PrintString("Priority of active meme: "+IntToString(iPriority));
                    _PrintString("Priority of this meme: "+IntToString(mPriority));

                    if (iPriority < mPriority)
                    {
                        _PrintString("1. Pending meme is now "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
                        SetLocalObject(NPC_SELF, "MEME_PendingMeme", oMeme);
                    }
                    else if (iPriority == mPriority)
                    {
                        if (GetLocalInt(oActive, "MEME_Modifier") < GetLocalInt(oMeme, "MEME_Modifier"))
                        {
                            _PrintString("2. Pending meme is now "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
                            SetLocalObject(NPC_SELF, "MEME_PendingMeme", oMeme);
                        }
                    }

                    _End();
                    return;
                }
            }
            else
            {
                // 2. Check optimized case where a recently modified meme beats highest pending meme.
                if (oMeme != oPending)
                {
                    _PrintString("#2: Checking to see if meme is better than pending meme (" + _GetName(oPending) + ").", DEBUG_TOOLKIT);

                    iPriority = GetLocalInt(oPending, "MEME_Priority");
                    mPriority = GetLocalInt(oMeme, "MEME_Priority");
                    if (iPriority < mPriority)
                    {
                        _PrintString("3. Pending meme is now "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
                        SetLocalObject(NPC_SELF, "MEME_PendingMeme", oMeme);
                    }
                    else
                    {
                        iModifier = GetLocalInt(oPending, "MEME_Modifier");
                        if ((iPriority == mPriority) && (iModifier < GetLocalInt(oMeme, "MEME_Modifier")))
                        {
                            _PrintString("4. Pending meme is now "+GetLocalString(oMeme,"Name")+".", DEBUG_TOOLKIT);
                            SetLocalObject(NPC_SELF, "MEME_PendingMeme", oMeme);
                        }
                    }

                    _End();
                    return;
                }
            }
        }
    }

    // 3. Find the highest priority meme. (ignoring bag PRIO_NONE.)
    oPending = OBJECT_INVALID;
    for (i = PRIO_VERYHIGH; i > PRIO_NONE; i--)
    {
       j = 0;
       _PrintString("Looking in band "+IntToString(i)+" for next best meme.", DEBUG_TOOLKIT);
       oBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(i));

       while(1)
       {
            oMeme = MeGetObjectByIndex(oBag, j);
            if (!GetIsObjectValid(oMeme)) break;

            // Debug
            sName = GetLocalString(oMeme, "Name");
            if (sName == "i_sequence") sName = GetLocalString(oMeme, "MEME_SequenceName");
            _PrintString("Evaluating meme '"+sName+"'.", DEBUG_TOOLKIT);
            // End Debug

            iPriority = GetLocalInt(oMeme, "MEME_Priority");
            iModifier = GetLocalInt(oMeme, "MEME_Modifier");
            if (!GetIsObjectValid(oPending)
                || (iPriority > pPriority)
                || (iPriority == pPriority && iModifier > pModifier))
            {
                pPriority = iPriority;
                pModifier = iModifier;
                oPending = oMeme;
            }
            j++;
        }
        if (GetIsObjectValid(oPending)) break;
    }

    if (GetIsObjectValid(oPending))
    {
        _PrintString("5. Pending meme is now "+GetLocalString(oPending,"Name")+".", DEBUG_TOOLKIT);
    }

    if (oPending != oActive) SetLocalObject(NPC_SELF, "MEME_PendingMeme", oPending);
    else                     SetLocalObject(NPC_SELF, "MEME_PendingMeme", OBJECT_INVALID);


    _End();
}

/*
void _Tickle(object oActiveMeme)
{
    _Start("JumpStartingNPC", DEBUG_TOOLKIT);
    int iRunCount = GetLocalInt(oActiveMeme, "MEME_RunCount") + 1;
    SetLocalInt(oActiveMeme, "MEME_RunCount", iRunCount);
    _PrintString("Meme = "+GetLocalString(oActiveMeme, "Name")+" next run ="+IntToString(iRunCount), DEBUG_TOOLKIT);
    ActionDoCommand(ActionDoCommand(DelayCommand(0.0, _MemeDone(oActiveMeme, iRunCount))));
    DeleteLocalInt(OBJECT_SELF, "MEME_ScheduledForTickle");
    _End();
}
*/

void _MeUpdateActions();

void MeUpdateActions()
{
    if (GetLocalInt(NPC_SELF, "MEME_Paused") || GetLocalInt(NPC_SELF, "MeUpdateScheduled")) return;

    _Start("MeUpdateActions scheduled = 'True'", DEBUG_TOOLKIT);

    SetLocalInt(NPC_SELF, "MeUpdateScheduled", 1);

    // Toy with these see the performance difference. You might see a stuttered
    // NPC but have a less laggy system with the first one.
    DelayCommand(0.1, _MeUpdateActions());
    //DelayCommand(0.0, _MeUpdateActions());

    _End();
}

void _MeUpdateActions()
{
    _Start("MeUpdateActions", DEBUG_TOOLKIT);

    DeleteLocalInt(NPC_SELF, "MeUpdateScheduled");

    if (!GetIsObjectValid(NPC_SELF))
    {
        _PrintString("Error: attempting to update actions on a non-memetic NPC.");
        _End();
        return;
    }

    // I'm paused or the DM is using me.
    if (GetLocalInt(NPC_SELF, "MEME_Paused"))
    {
        _PrintString("Will not update actions, the system is paused.");
        _End();
        return;
    }

    object oActiveMeme;
    oActiveMeme  = GetLocalObject(NPC_SELF, "MEME_ActiveMeme");

    object oPendingMeme;
    oPendingMeme = GetLocalObject(NPC_SELF, "MEME_PendingMeme");

    if (!GetIsObjectValid(oActiveMeme) && !GetIsObjectValid(oPendingMeme)) ClearAllActions();

    if (!GetIsObjectValid(oPendingMeme))
    {
        if (GetLocalInt(oActiveMeme, "MEME_Priority") != PRIO_NONE)
        {
            _PrintString("No pending memes, the currently active behavior is fine. ("+_GetName(oActiveMeme)+")", DEBUG_TOOLKIT);
/*
            // Experimental tickle code causes the NPC to be kickstarted if
            // someone has cleared our action queue -- like the game engine
            if (GetCurrentAction() == ACTION_INVALID && oActiveMeme != OBJECT_INVALID)
            {
                if (!GetLocalInt(OBJECT_SELF, "MEME_ScheduledForTickle"))
                {
                    SetLocalInt(OBJECT_SELF, "MEME_ScheduledForTickle", 1);
                    _PrintString("NPC is stalled, restarting. Something cleared by Action Queue.");
                    DelayCommand(0.0, _Tickle(oActiveMeme));
                }
                _End();
                return;
            }
*/
            _End();
            return;
        }
    }

    ClearAllActions();

    if (GetIsObjectValid(oActiveMeme)) {
        _PrintString("Stopping active meme, "+GetLocalString(oActiveMeme,"Name")+".", DEBUG_TOOLKIT);

        // MEME_INSTANT means that this meme shouldn't cause the interruption of the current meme
        // but it will get a chance to run (seemlessly) and if a MEME_IMMEDIATE meme is created,
        // it can be scheduled even though a MEME_INSTANT meme is active. MEME_INSTANT is a short
        // duration interruption meme.

        if (!MeGetMemeFlag(oPendingMeme, MEME_IMMEDIATE))
        {
            MeExecuteScript(GetLocalString(oActiveMeme, "Name"),"_brk", OBJECT_SELF, oActiveMeme);
            if (!MeGetMemeFlag(oActiveMeme, MEME_RESUME)) {
                _PrintString("Destroying active meme,"+GetLocalString(oActiveMeme,"Name")+".", DEBUG_TOOLKIT);
                MeDestroyMeme(oActiveMeme);
            }
            else {
                _PrintString("The active meme,"+GetLocalString(oActiveMeme,"Name")+" is resumeable, it isn't being destroyed.", DEBUG_TOOLKIT);
            }
        }
    }

    SetLocalObject(NPC_SELF, "MEME_ActiveMeme", oPendingMeme);
    SetLocalObject(NPC_SELF, "MEME_PendingMeme", OBJECT_INVALID);

    _PrintString("Starting new active meme,"+GetLocalString(oPendingMeme,"Name")+".", DEBUG_TOOLKIT);
    MeExecuteScript(GetLocalString(oPendingMeme, "Name"),"_go", OBJECT_SELF,oPendingMeme);

    //if (GetLocalString(oActiveMeme, "Name") != "i_sequence") ActionDoCommand(ActionDoCommand(ExecuteScript("cb_done", OBJECT_SELF)));
    int iRunCount = GetLocalInt(oPendingMeme, "MEME_RunCount") + 1;
    SetLocalInt(oPendingMeme, "MEME_RunCount", iRunCount);
    _PrintString("Meme = "+GetLocalString(oPendingMeme, "Name")+" next run ="+IntToString(iRunCount), DEBUG_TOOLKIT);

    ActionDoCommand(ActionDoCommand(DelayCommand(0.0, _MemeDone(oPendingMeme, iRunCount))));

    _End();
}

void MeRestartSystem()
{
    _Start("MeRestartSystem", DEBUG_TOOLKIT);
    object oPendingMeme = GetLocalObject(NPC_SELF, "MEME_PendingMeme");
    object oActiveMeme  = GetLocalObject(NPC_SELF, "MEME_ActiveMeme");

    ClearAllActions();

    if (MeGetMemeFlag(oActiveMeme, MEME_RESUME) == FALSE)
    {
        _MemeDone(oActiveMeme, GetLocalInt(oActiveMeme, "MEME_RunCount"));
    }
    else
    {
        if (oPendingMeme == OBJECT_INVALID)
        {
            _PrintString("No pending meme and the active meme is resuming.", DEBUG_TOOLKIT);
            SetLocalObject(NPC_SELF, "MEME_PendingMeme", oActiveMeme);
            SetLocalObject(NPC_SELF, "MEME_ActiveMeme", OBJECT_INVALID);
        }
    }

    MeUpdateActions();

    _End();
}

void MePauseSystem()
{
    _Start("MePauseSystem", DEBUG_TOOLKIT);

    int i = 0;
    object oGen = OBJECT_INVALID;

    SetLocalInt(NPC_SELF, "MEME_Paused", 1);
    ClearAllActions();

    _End();
}

void MeResumeSystem()
{
    _Start("MeResumeSystem", DEBUG_TOOLKIT);

    int i = 0;
    object oGen = OBJECT_INVALID;

    DeleteLocalInt(NPC_SELF, "MEME_Paused");
    MeRestartSystem();

    _End();
}

int MeHasScheduledMeme(int iPriority, int iModifier, object oExcludeMeme=OBJECT_INVALID)
{
    _Start("MeHasScheduledMeme", DEBUG_TOOLKIT);

    object oBag, oMeme;
    int    i;
    int    count;

    for (i = iPriority+1; i <= PRIO_VERYHIGH; i++)
    {
        oBag  = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(i));
        switch (MeGetObjectCount(oBag))
        {
            case 0:
                break;
            case 1:
                oBag = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
                if (MeGetObjectByIndex(oBag, 0) == oExcludeMeme) break;
            default:
                _End();
                return 1;
        }
    }

    oBag  = GetLocalObject(NPC_SELF, "MEME_PrioBag"+IntToString(iPriority));
    count = MeGetObjectCount(oBag);

    for (i = 0; i < count; i++)
    {
        oMeme = MeGetObjectByIndex(oBag, i);
        if (GetIsObjectValid(oMeme) && oMeme != oExcludeMeme)
        {
            if (GetLocalInt(oMeme, "MEME_Modifier") >= iModifier)
            {
                _PrintString("Meme is: "+_GetName(MeGetObjectByIndex(oBag, 0)));
                _End();
                return 1;
            }
        }
    }

    _End();
    return 0;
}

/*------------------------------------------------------------------------------
 *    Meme:  i_sequence
 *  Author:  William Bull
 *    Date:  July, 2002
 *   Notes:  This is an internal meme that should never be used directly.
 *           Please refer to the sequence API in the online documentation.
 *------------------------------------------------------------------------------*/
void i_sequence_ini()
{
    _Start("Sequence event = 'Init'", DEBUG_TOOLKIT);

    SetLocalInt(MEME_SELF, "MEME_CurrentIndex", 0);
    // If this is set here, the sequence will always re-init the memes in
    // the sequence. This may not be the best thing if the sequence is a
    // singleton. MEME_SELF is the sequence_ref, not the sequence. The ref
    // may go away after the sequence runs its course -- since the memes are
    // not re-inited on i_sequence_end, the sequence may have stale data
    // in the memes.
    SetLocalInt(MEME_SELF, "MEME_InitSequence", 1);

    _End();
}

/* Another step towards improving script execution with DelayCommand -- unsuccessful.
void _GoMeme(object oActiveMeme)
{
    if (!GetIsObjectValid(oActiveMeme)) return;
    object oNPCSelf = MeGetNPCSelf();
    string sName = GetLocalString(oActiveMeme, "Name");

    if (GetIsObjectValid(GetLocalObject(oNPCSelf, "MEME_PendingMeme")))
    {
        MeUpdateActions();
    }
    else if (GetLocalObject(oNPCSelf, "MEME_ActiveMeme") == oActiveMeme)
    {
        MeExecuteScript(sName,"_go", OBJECT_SELF, oActiveMeme);
        ActionDoCommand(ActionDoCommand(ExecuteScript("cb_done", OBJECT_SELF)));
    }
}
*/

void i_sequence_go()
{
    _Start("Sequence event = 'Go'", DEBUG_TOOLKIT);

    object oSequence = GetLocalObject(MEME_SELF, "MEME_Sequence");
    int    iIndex    = GetLocalInt(MEME_SELF, "MEME_CurrentIndex");
    object oMeme     = MeGetObjectByIndex(oSequence, iIndex);
    int    iFlags    = GetLocalInt(MEME_SELF, "MEME_Flags");
    object oTemp;

    //ActionSpeakString("Starting "+GetLocalString(oMeme,"Name")+"...");

    if ((iIndex == 0) && (GetLocalInt(MEME_SELF, "MEME_InitSequence") > 0))
    {
        int count = 0;
        int i = 0;

        // This is the first time this has run...
        _PrintString("Running sequence for the first time.", DEBUG_TOOLKIT);

        count = MeGetObjectCount(oSequence);
        //_PrintString("Object count: " + IntToString(count), DEBUG_TOOLKIT);

        for (i = 0; i < count; i++)
        {
            oTemp = MeGetObjectByIndex(oSequence, i);
            SetLocalObject(oTemp, "MEME_Parent", MEME_SELF);

            //_PrintString("Index name: " + _GetName(oTemp), DEBUG_TOOLKIT);

            // Here is where I should check to see if the meme has a special
            // flag for seq_no_init. I'm not sure if I want this flag yet, but
            // this is where it should go. Meme _init is also called during
            // construction of the memes.
            // Note: if this is a repeating meme, MEME_InitSequence will be 2,
            // if this is the first time it's being initied, it will be 1. This
            // might be useful if I want a flag which doesn't reset a meme on
            // sequence repeats, but does on the sequence init.
            MeExecuteScript(GetLocalString(oTemp, "Name"), "_ini", OBJECT_SELF, oTemp);
        }

        oMeme = MeGetObjectByIndex(oSequence, 0);

        // Remember this is the first time this has run...
        SetLocalInt(MEME_SELF, "MEME_InitSequence", 0);
    }

    if (!GetIsObjectValid(oMeme))
    {
        SetLocalInt(MEME_SELF, "MEME_CurrentIndex", 0);
        SetLocalInt(MEME_SELF, "MEME_RestartIndex", 0);
        if (!(iFlags & SEQ_REPEAT))
        {
            _PrintString("No more child memes, and not repeating.", DEBUG_TOOLKIT);
            SetLocalInt(MEME_SELF, "MEME_Flags", iFlags & (~MEME_REPEAT));
        }

        _End();
        return;
    }

    //DelayCommand(0.0, _GoMeme(oMeme));
    MeExecuteScript(GetLocalString(oMeme, "Name"),"_go", OBJECT_SELF, oMeme);

    _End();
}

void i_sequence_brk()
{
    _Start("Sequence event = 'Interrupted'", DEBUG_TOOLKIT);

    object oSequence = GetLocalObject(MEME_SELF, "MEME_Sequence");
    int    iIndex    = GetLocalInt(MEME_SELF, "MEME_CurrentIndex");
    object oMeme     = MeGetObjectByIndex(oSequence, iIndex);
    MeExecuteScript(GetLocalString(oMeme, "Name"),"_brk", OBJECT_SELF, oMeme);
    SetLocalInt(MEME_SELF, "MEME_CurrentIndex", GetLocalInt(MEME_SELF, "MEME_RestartIndex"));

    _End();

}

/* Private Meme */

// This is accessed by the lib_ai script -- the library of memetic objects.
// It is hidden here to avoid being mixed up with common memes. It's really
// only interesting for people who tracking a bug, or are masochistic workaholics.

void i_sequence_end()
{
    _Start("Sequence event = 'Step Taken'", DEBUG_TOOLKIT);

    object oSequence = GetLocalObject(MEME_SELF, "MEME_Sequence");
    int    iIndex    = GetLocalInt(MEME_SELF, "MEME_CurrentIndex");
    object oMeme     = MeGetObjectByIndex(oSequence, iIndex);
    int    iFlags    = GetLocalInt(MEME_SELF, "MEME_Flags");
    int    mFlags    = GetLocalInt(oMeme, "MEME_Flags");
    object nextMeme  = MeGetObjectByIndex(oSequence, iIndex+1);

    MeExecuteScript(GetLocalString(oMeme, "Name"),"_end", OBJECT_SELF, oMeme);

    // First, check to see if our last meme went sour
    if (MeGetMemeResult(MEME_SELF) == FALSE)
    {
        _PrintString("A child meme returned FALSE.", DEBUG_COREAI);
        _PrintString("Stopping sequence proxy: " + _GetName(oSequence), DEBUG_COREAI);
        MeStopSequence(oSequence);
        //MeUpdateActions();
    }
    // Deal with repeating memes in the sequence
    else if (MeGetMemeFlag(oMeme, MEME_REPEAT))
    {
        _PrintString("Current sequence meme, " + _GetName(oMeme) + ", is repeating.", DEBUG_TOOLKIT); // Do nothing

    }
    // are we done? should we reset to repeat, or stop
    else if (!GetIsObjectValid(nextMeme))
    {
        SetLocalInt(MEME_SELF, "MEME_CurrentIndex", 0);
        SetLocalInt(MEME_SELF, "MEME_RestartIndex", 0);

        // This could have a sequence flag which says whether or not the sequence
        // should reset the memes -- probably the flag should be added to the
        // memes and the check should be in the i_sequence_go area.
        SetLocalInt(MEME_SELF, "MEME_InitSequence", 2);

        if (!(iFlags & SEQ_REPEAT))
        {
            _PrintString("Sequence complete.", DEBUG_TOOLKIT);
            SetLocalInt(MEME_SELF, "MEME_Flags", iFlags & (~MEME_REPEAT));
        }
        // otherwise we are repeating should we take the prio of the first item?
        else if (GetLocalInt(oSequence, "MEME_Priority") == PRIO_DEFAULT)
        {
            nextMeme = MeGetObjectByIndex(oSequence, 0);
            _PrintString("1. First Meme in sequence; priority " +
                IntToString(GetLocalInt(nextMeme, "MEME_Priority")) +
                ", modifier " + IntToString(GetLocalInt(nextMeme, "MEME_Modifier")) +
                ".", DEBUG_TOOLKIT);
            MeSetPriority(MEME_SELF, GetLocalInt(oMeme, "MEME_Priority"),
                GetLocalInt(nextMeme, "MEME_Modifier"));
        }
    }
    // otherwise we're advancing and care about next meme.
    else
    {
        _PrintString("Next meme in sequence: " + _GetName(nextMeme), DEBUG_TOOLKIT);

        // is the meme a checkpoint, if so notate it -- or if SEQ_RESUME_LAST
        if ((mFlags & MEME_CHECKPOINT) || (iFlags & SEQ_RESUME_LAST))
        {
            _PrintString("Setting RestartIndex to "+IntToString(iIndex+1)+".", DEBUG_TOOLKIT);
            SetLocalInt(MEME_SELF, "MEME_RestartIndex", iIndex+1);
        }

        // advance the current index
        SetLocalInt(MEME_SELF, "MEME_CurrentIndex", iIndex+1);

        // should I adopt the priority of the next meme, if so, reprioritize.
        if (GetLocalInt(oSequence, "MEME_Priority") == PRIO_DEFAULT)
        {
            _PrintString("2. Next Meme in sequence; priority " +
                IntToString(GetLocalInt(nextMeme, "MEME_Priority")) +
                ", modifier " + IntToString(GetLocalInt(nextMeme, "MEME_Modifier")) +
                ".", DEBUG_TOOLKIT);

            MeSetPriority(MEME_SELF, GetLocalInt(nextMeme, "MEME_Priority"),
                GetLocalInt(nextMeme, "MEME_Modifier"));
        }
    }

    _End();
}

//effect e = EffectAreaOfEffect(AOE_MOB_INVISIBILITY_PURGE, "cb_area_in", "cb_area_hb", "cb_area_out");
//ApplyEffectToObject(DURATION_TYPE_PERMANENT, e, oTarget);

/*
    Variables:

    OBJECT_SELF Specific
        MEME_NPCSelf      -- The memetic store for hold all the data
        MEME_ObjectSelf   -- The currently active memetic object

    NPC_SELF Specific
        MEME_GeneratorBag
        MEME_PrioBag1...5
        MEME_EventBag
        MEME_Sequence_<SequenceName>
        MEME_ActiveMeme
        MEME_PendingMeme

    Meme Specific:
        Name
        MEME_Type
        MEME_Priority
        MEME_Modifier
        MEME_Flags
        MEME_Event
        MEME_Generator
        MEME_Sequence
        MEME_Parent
        MEME_Generator
        Meme_Count_Meme
        MEME_ChildMeme1, MEME_ChildMeme2, ...

    Generator Secific:
        Name
        MEME_Type
        MEME_Priority
        MEME_Modifier
        MEME_ChildMeme (Memes which it has created)
        MEME_Flags
        MEME_Event
        MEME_Count_Meme
        MEME_Meme1, MEME_Meme2, ...
        Meme_Count_Meme
        MEME_ChildMeme1, MEME_ChildMeme2, ...

    Sequence Specific:
        Name
        MEME_Type
        MEME_Priority
        MEME_Modifier
        MEME_Flags
        MEME_Event
        MEME_Generator
        MEME_SequenceRef

    Sequence Ref Specific:
        Name = i_sequence
        MEME_SequenceName
        MEME_Sequence
        MEME_CurrentIndex
        MEME_RestartIndex

    Event Specific
        Name
        MEME_Type
        MEME_Active
        MEME_Flags

        MEME_Count_Meme
        MEME_Meme1, MEME_Meme2, ...

        MEME_HasEventTrigger
        MEME_Count_Event
        MEME_Event1, MEME_Event2, ...
        MEME_EventDelay1, MEME_EventDelay2, ...

        MEME_HasGlobalSignalTrigger
        MEME_Count_GlobalSignal
        MEME_GlobalSignal1, MEME_GlobalSignal2, ...
        MEME_GlobalSignalDelay1, MEME_GlobalSignalDelay2, ...

        MEME_HasSignalTrigger
        MEME_IntCount_Signal
        MEME_Signal1, MEME_Signal2, ...
        MEME_SignalDelay1, MEME_SignalDelay2, ...

        MEME_HasTimeTrigger
        MEME_TimeIndex
        MEME_TimeDelay
        MEME_TimeDelayType

    Module Specific
        int    MEME_HasBroadcastListeners <-- Not used?
        int    MEME_Count_<Channel>Listener
        object MEME_<Channel>Listener1, MEME_<Channel>Listener2, ...

    Meme Script:

        _go   You are started or restarted
        _end  You are have run to completion
        _brk  You have been interrupted
*/
