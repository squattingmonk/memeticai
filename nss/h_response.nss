/* Note: This will produce is a table driven response system that
 *       merges tables across classes.
 *       Each class represents a behavior trait that might draw
 *       in memetic objects or enhance their response tables with
 *       additional functions. Generally these response functions
 *       create child memes to solve a problem or react to a situation.
 *       The tables are broken up into five bands. The start band is
 *       used to evaluate a situation and switch tables in response to
 *       the situation at hand. All entries in the table are executed
 *       and their return results are ignored. The next three bands
 *       high, medium, and low contain responses to a problem. It is
 *       possible to preserve where you left off in the band, so you can
 *       resume later. One of the bands is chosen, each entry in the
 *       band is tried until one returns a valid object. At which
 *       point the table's fifth band, end, runs. All of these
 *       functions are executed. If any band function returns a valid object,
 *       the processing is complete, otherwise the next class is selected
 *       and the process starts over.
 */

/* File: h_response - Response Tables
 * Author: William Bull
 * Date: March 23, 2004
 *
 * Description
 *
 * These are the functions used to build response tables. These tables
 * hold lists of library functions that are used to solve problems.
 * The core memetic toolkit includes memetic objects which ask and NPC
 * to solve a recognized problems or situations. At this time, this includes
 * bordem, combat and blocked doors. In the future this may be expanded
 * to the observation of enemies, friends, and acts of lawlessness.
 *
 * A nice use of this system is to have NPCs change their idle table according
 * to a schedule. The result is that NPCs will efficiently perform work behaviors
 * possibly interleved with common idle behaviors.
 *
 * Response tables may be contained within class objects or on an NPC. When a
 * problem is attempted to be resolved response on the NPC is tried, then on
 * each class. The order of the class instanciation reflects the trial order.
 *
 * Refer to the documentation within this script for more information.
 */

#include "h_util"
#include "h_class"

// 1. Function Tables
//
// This script registers functions stored in memetic libraries. This script
// assumes you know how to add a function to a library. These tables hold
// the names of your registered funciton and the % chance is it tried organized
// into bands that represent a % chance the set of responses are tried.
// Classes are tied in order of the call to MeInstanceOf.

// 2. Frequencey Bands
//
// Response tables are broken up into five bands: start, high, medium, low, end.
// All the functions in the high and low bands always run, if the table is being
// processed. The one of the middle bands is selected and each function is tried.
// When one returns a valid object, the band is complete. The NPC and all of its
// classes can each have a table which responds to a situation.
//
// These consts register the response to be run regardless of the band, before or
// after any other functions are executed. These are commonly used to evaluate
// the situation and change the table. If a first response changes the table,
// the high, medium, or low responses of the *new* table are used. If a response
// in the either band returns a valid object then no other class tables are run.
// If the first band returns a value then the middle bands are skipped.
//
// const string RESPONSE_START = "MEME_RTS_";
// const string RESPONSE_END   = "MEME_RTE_";
//
// These flags partition up the responses 60%, 30%, 10%. The table responses
// are immediately paired down to one of these bands before responding.
// So 60% of the time, the NPC will draw from the high probability band.
// That doesn't mean that a single response has a 60% chance of be choosen --
// just that 60% of the time the pool of responses is looked at, sequentially.
// If a response in this band returns a valid object then no other responses in
// this band is processed -- the ending responses are then processed.
// If a response in this band returns a valid object then no other responses in
// other class tables are evaluated. We assume the response is beind handled.
// If a response in this band changes the active response table, this table
// change will not be noticed until the next time the problem is resolved.
//
// const string RESPONSE_HIGH   = "MEME_RTH_";
// const string RESPONSE_MEDIUM = "MEME_RTM_";
// const string RESPONSE_LOW    = "MEME_RTL_";

// 3. Usage
//
// Generally, inside of a class _ini responses are added to tables and
// a table is assigned to handle a response.
// A meme will eventually cause a situation to be responded to. Each
// table defined on the NPC and all of its classes is processed.
// Generally, a response function in the table should create a child meme,
// where the parent is MEME_SELF - aka the meme that called MeRespond().
// This gives the calling meme the opportunity to know if the child meme
// succeeded. It is also legal to directly call actions within the table.
// Unfortunately this does not allow the response meme to know if the attempted
// response was a success. The approach to implementing this varies if you
// are trying to solve a problem and want to search through your response
// table (like opening a door) or if you want to simply react (like in combat)
// at the start of your table, anew.


// MeRespond
// File: h_response
//
// This activates the NPC's response tables that are bound to a specific situation.
// Each class can set its own preferred response table, and the tables can be
// changed at any time for a specific context. For example, if a meme calls
// MeRespond() and the class tables decide to change the tables they use to
// respond to the situation, this is kept local to the meme. More than one meme
// responding to a situation will have their own local response context.
//
// This selects a probability band and activates each table in each class.
// It also activates the NPC's local response table, allowing each NPC to build
// a custom overriding personality trait. For example, if combat occurs, you
// can add a custom response to a single NPC by calling:
//
//    Note: the 0% is ignored for RESPONSE_START and RESPONSE_END bands -- they always run.
//    MeAddResponse(OBJECT_SELF, "MyCombatTable", "MyFunction", 0, RESPONSE_START);
//    MeSetResponseTable(OBJECT_SELF, "Combat", "MyCombatTable", "");
//
// Now, whenever MeResponse("Combat") is called, MyFunction will be called first.
//
// If the NPC's response table doesn't respond, its class responses are processed.
// The order is dependent on the order in which the NPC becomes an instance of
// a class. The most recently added instance is executed last.
//
//  sSitutation: this is the name of the table to execute.
// oResponseArg: this is an argument (and object) that is passed to the functions
//               in the response table. This allows a situation to pass a object
//               to be acted upon. For example, a door might be passed or the
//               last combat target.
//      bResume: a flag to determine if the table should evaluate where it
//               last finished. The last band select is remember as well as which
//               class table was last processed. This is useful when you want to
//               search through a response table to solve problems. This is being
//               used to solve problems like door handling.
//
// This returns "" if no responses were choosen successful otherwise it returns
// the name of a function that was tried. It's possible that more than one function
// executed during the start and end bands.
//
string MeRespond(string sSituation, object oResponseArg=OBJECT_INVALID, int bResume=FALSE);

// MeSetResponseTable
// File: h_response
//
// This defines the table that should be used to solve a specific problem.
// The problem name should be known in advance. This allows NPCs to prepare
// several response tables and switch them to change solution tactics.
//
// sSituation: this the name of the problem your table solves. This is what
//             is passed to MeRespond.
//     sTable: this is ht ename of the table with the responses.
//     sClass: this is name of the class whose table is being changed. If you
//             set this to "" then you will be changing the NPC's default table
//             overriding all the classes. If you leave this as "*" it will detect
//             the class that your code context is working on behalf of. For
//             example, if you are writing a function in a response table that
//             wants to switch the table, you may not know which class your
//             table belongs to -- the "*" will detect this automatically.
//    oTarget: this is the object that the table is set on. If you leave this
//             invalid it will try and set the table change on the most local
//             context -- probably the meme. It is possile to pass the NPC
//             or NPC_SELF to set an overriding response definition.
void MeSetActiveResponseTable(string sSituation, string sTable, string sClass="*", object oTarget = OBJECT_INVALID);

// MeGetResponseTable
// File: h_response
//
// This gets the currently active response table for a given situation.
// This does not take any class inheritance into account. It only returns
// local tables.
//
// sSitutation: this is the situation whose table you want.
//      sClass: this is the name of the class whose table you want. It is possible
//              to pass "" to look for the NPC's overriding response or leave
//              the value as "*" to find a class.
string MeGetActiveResponseTable(string sSituation, string sClass="*", object oTarget = OBJECT_INVALID);

// MeActivateResponseTable
// File: h_response
//
// This returns true if the table successfully executed a response function
// or if the final fucntion is executed. This is is not a success or fail
// result. It only signifies that a response has been choosen.
//
// When this called by MeRespond, the table owner will be the class object.
// This allows the response function to call MeSetResponseTable passing the
// class as the parameter.
string MeActivateResponseTable(object oTarget, string sTable, string sWhichBand, object oArgument=OBJECT_INVALID, int bResume=0);

// MeDeleteResponseTable
// File: h_response
//
// This removes a response table. If it was the active table, there will be no
// local response table on oTarget. It is your responsibility to call MeSetResponseTable()
// to reassign a new table to response to the situation.
void MeDeleteResponseTable(object oTarget, string sTable);

// MeHasResponseTable
// file: h_response
//
// This checks to see if the object has a response table with the given name.
int MeHasResponseTable(object oTarget, string sTable, string sWhichBand = "");

// MeAddResponse
// File: h_response
void MeAddResponse(object oTarget, string sTable, string sFunction, int iPercent=50, string iBand=RESPONSE_MEDIUM);

// File: h_response
void MeSetResponseChance(object oTarget, string sTable, string sFunction, int iNewPercent, string iWhichBand);

// File: h_response
void MeRemoveResponse(object oTarget, string sTable, string sFunction, string sWhichBand);


// ---- Implementation ---------------------------------------------------------

/*
    This is called within a class's _ini script when the class is first defining
    its response table. In this case, MEME_SELF is the class and there is no
    NPC_SELF. Or does this have to be called in the _go script, setting the
    active table appropriately? I assume that the shared data on the class
    must be on the class object -- which means that it must be defined in the
    _ini. In which case the call with sClass="*" gets the MEME_ActiveClass.
    This tells us the name. Now, the MEME_SELF (in this case the class) should
    have a ClassName/Situation string on it.

    This function may be called by a function in a response table. Setting the
    value on MEME_SELF puts the local table state on the actual meme which
    calls MeRespond().
*/

void MeSetActiveResponseTable(string sSituation, string sTable, string sClass="*", object oTarget = OBJECT_INVALID)
{
    if (sClass == "*") sClass = GetLocalString(MEME_SELF, "MEME_ActiveClass");
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (!GetIsObjectValid(oTarget)) oTarget = NPC_SELF;
    if (!GetIsObjectValid(oTarget)) return;

    _Start("MeSetResponseTable", DEBUG_TOOLKIT);

    _PrintString("Set response table for class: "+sClass+" situation: "+sSituation+" to respond with table: "+sTable);
    MeSetLocalString(oTarget, "MEME_RESP:"+sClass+"/"+sSituation, sTable);

    _End();
}

/*
    This function has the responsibility of looking around to find the table.
    It's possible that the current MEME has it, or the NPC has its own default,
    or the class has the real default. If oTarget is invalid, the function has
    to start looking for the value...
*/
string MeGetActiveResponseTable(string sSituation, string sClass="*", object oTarget = OBJECT_INVALID)
{
    _Start("MeGetResponseTable", DEBUG_TOOLKIT);

    // sClass * is a request to look up the class ancestory
    if (sClass == "*") sClass = GetLocalString(MEME_SELF, "MEME_ActiveClass");

    string sTable;
    string sTableName = "MEME_RESP:"+sClass+"/"+sSituation;

    // Search for the right table
    if (oTarget == OBJECT_INVALID)
    {
        sTable = MeGetLocalString(MEME_SELF, sTableName);
        if (sTable == "") sTable = MeGetLocalString(NPC_SELF, sTableName);
        if (sTable == "") sTable = MeGetLocalString(OBJECT_SELF, sTableName);
        if (sTable == "" && sClass != "") sTable = MeGetLocalString(MeGetClassObject(sClass), sTableName);
    }
    else
    {
        sTable = MeGetLocalString(oTarget, sTableName);
    }

    _End();
    return sTable;
}

/* Implementation Notes

   Each class can define a response table. The table is composed of five
   bands: start, high, medium, low, end. The high, medium and low bands
   have a matching probability entry. The start and end bands do not have
   probabilities. The are executed in order.

   MEME_RTS_<tablename>  string list            (function)
   MEME_RTH_<tablename>  string list, int list  (function, probability)
   MEME_RTM_<tablename>  string list, int list  (function, probability)
   MEME_RTL_<tablename>  string list, int list  (function, probability)
   MEME_RTE_<tablename>  string list            (function)

   MeRespond() is responsible for recording which table it's processing.
   This includes which band and which class (or the npc if it's just starting)
   so that it can resume by calling MeActivateTable() with

   MeActivateTable just sets a single int index on MEME_SELF -- "MEME_LastResponse"

   MeGetActiveResponseTable is called by MeRespond for each class or NPC that
   should respond to the situation. It gets the table to be activated. This
   information is stored on the MEME_SELF and can be changed by the functions
   to switch the activate table.
*/
string MeRespond(string sSituation, object oArgument=OBJECT_INVALID, int bResume=FALSE)
{
	_Start("MeResponse", DEBUG_TOOLKIT);
    int i, count;
    string sBand;
    string sTable;
    string sNewTable;
    string sResult;
    string sEnd;
    string sClass;
    object oClass;
    object oModule;
    string sAncestor  = GetLocalString(MEME_SELF, "MEME_ActiveClass");

    if (bResume == TRUE)
    {
        sBand  = GetLocalString(MEME_SELF, "MEME_LastResponseBand");
    }

    if (sBand == "")
    {
        i = Random(100);
        if (i > 40) sBand = RESPONSE_HIGH;
        else if (i > 10) sBand = RESPONSE_MEDIUM;
        else sBand = RESPONSE_LOW;

        if (bResume == TRUE) SetLocalString(MEME_SELF, "MEME_LastResponseBand", sBand);
    }

    // Does this NPC react to this situation in his own special way, regardless of his class?
    sTable = MeGetActiveResponseTable(sSituation, "");
    if (sTable != "")
    {
        _PrintString("NPC has a local response table (" + sTable + ") for '" + sSituation + "'.", DEBUG_COREAI);

        // This table is not acting on behalf of any class, so active class
        // is cleared.
        SetLocalString(MEME_SELF, "MEME_ActiveClass", "");

        // Process the Start band.
        sResult = MeActivateResponseTable(OBJECT_SELF, sTable, RESPONSE_START, oArgument);

        // The start functions are allowed to change the table on us.
        sTable = MeGetActiveResponseTable(sSituation, "");

        // Process the middle bands.
        if (sResult == "") sResult = MeActivateResponseTable(OBJECT_SELF, sTable, sBand, oArgument, bResume);

        // Process the End band.
        if (sResult == "") sResult = MeActivateResponseTable(OBJECT_SELF, sTable, RESPONSE_END, oArgument);

        if (sResult != "")
        {
            _PrintString("The NPC itself had a response table that returned a successful function: "+sResult+" so I'm stopping.", DEBUG_COREAI);
        }
    }

    // If the NPC didn't respond
    if (sResult == "")
    {
        oModule = GetModule();

        // Do each class band, in order
        count = MeGetStringCount(NPC_SELF, "MEME_Parents");
        _PrintString("This NPC belongs to " + IntToString(count) + " classes.", DEBUG_COREAI);

        if (bResume == TRUE)
        {
            i  = GetLocalInt(MEME_SELF, "MEME_LastResponseClass");
        }

        for (i=0; i<count; i++)
        {
            sClass = MeGetStringByIndex(NPC_SELF, i, "MEME_Parents");
            _PrintString("I am processing class " + sClass, DEBUG_COREAI);

            if (bResume == TRUE) SetLocalInt(MEME_SELF, "MEME_LastResponseClass", i);

            // The functions within the table are acting on behalf of this class.
            SetLocalString(MEME_SELF, "MEME_ActiveClass", sClass);
            oClass = GetLocalObject(oModule, "MEME_Class_"+sClass);
            sTable = MeGetActiveResponseTable(sSituation, sClass);

            // Process the Start band
            sResult = MeActivateResponseTable(oClass, sTable, RESPONSE_START, oArgument);

            // The start functions are allowed to change the table on us.
            sTable = MeGetActiveResponseTable(sSituation);

            // Execute the middle bands.
            if (sResult == "") sResult = MeActivateResponseTable(oClass, sTable, sBand, oArgument, bResume);

            // Process the End band.
            if (sResult == "") sResult = MeActivateResponseTable(oClass, sTable, RESPONSE_END, oArgument);

            if (sResult != "")
            {
                _PrintString("This class had a response table that returned a successful function: "+sResult+" so I'm stopping.", DEBUG_COREAI);
                break;
            }
        }
    }

    // Restore this meme to its original owner class -- this allows class bias to be applied correctly.
    _PrintString("Resetting Active class to " + sAncestor, DEBUG_COREAI);
    SetLocalString(MEME_SELF, "MEME_ActiveClass", sAncestor);

	_End();
    return sResult;
}


string MeActivateResponseTable(object oTarget, string sTable, string sWhichBand, object oArgument=OBJECT_INVALID, int bResume=FALSE)
{
    string sTableName = sWhichBand+sTable;
    if (MeGetStringCount(oTarget, sTableName) == 0) return ""; // Notice if you have nothing in your band your start/end aren't run

    _Start("MeActivateResponseTable band='"+sWhichBand+"'", DEBUG_COREAI);

    int i, iChance, iChanceResult;
    int count = MeGetStringCount(oTarget, sTableName);
    string sResponse;

    if (bResume) i = GetLocalInt(MEME_SELF, "MEME_LastResponse");

    for (i; i < count; i++)
    {
        sResponse = MeGetStringByIndex( oTarget, i, sTableName );
        if (sWhichBand != RESPONSE_START && sWhichBand != RESPONSE_END)
        {
            iChance   = MeGetIntByIndex( oTarget, i, sTableName );
            iChanceResult = Random(100);
        }
        else
        {
            iChance = 1;
            iChanceResult = 0;
        }
        _PrintString(IntToString(iChanceResult)+" &lt; "+IntToString(iChance)+" --- "+sResponse, DEBUG_COREAI);

        if (iChanceResult < iChance)
        {
            if ( GetIsObjectValid(MeCallFunction(sResponse, oArgument)) )
            {
                // We should remember where we left off
                if (sWhichBand != RESPONSE_START && sWhichBand != RESPONSE_END)
                {
                    SetLocalInt(MEME_SELF, "MEME_LastResponse", i+1);
                }
                else SetLocalInt(MEME_SELF, "MEME_LastResponse", 0);

                // Stop looking
                break;
            }
        }

        // Reset the response
        sResponse = "";
    }

    _End();
    SetLocalInt(MEME_SELF, "MEME_LastResponse", 0);
    return sResponse;
}

void MeDeleteResponseTable(object oTarget, string sTable)
{
    MeDeleteStringRefs(oTarget, RESPONSE_START+sTable);
    MeDeleteStringRefs(oTarget, RESPONSE_END+sTable);

    MeDeleteStringRefs(oTarget, RESPONSE_HIGH+sTable);
    MeDeleteIntRefs(oTarget,    RESPONSE_HIGH+sTable);

    MeDeleteStringRefs(oTarget, RESPONSE_MEDIUM+sTable);
    MeDeleteIntRefs(oTarget,    RESPONSE_MEDIUM+sTable);

    MeDeleteStringRefs(oTarget, RESPONSE_LOW+sTable);
    MeDeleteIntRefs(oTarget,    RESPONSE_LOW+sTable);
}

int MeHasResponseTable(object oTarget, string sTable, string sWhichBand = "")
{
    if (sWhichBand != "") return MeGetStringCount(oTarget, sWhichBand+sTable);

    if (MeGetStringCount(oTarget, RESPONSE_START+sTable)  > 0) return 1;
    if (MeGetStringCount(oTarget, RESPONSE_END+sTable)    > 0) return 1;
    if (MeGetStringCount(oTarget, RESPONSE_HIGH+sTable)   > 0) return 1;
    if (MeGetStringCount(oTarget, RESPONSE_MEDIUM+sTable) > 0) return 1;
    if (MeGetStringCount(oTarget, RESPONSE_LOW+sTable)    > 0) return 1;

    return 0;
}

// Our list API does not preserve order when you remove them, so we will just
// blank the entries. This means that if constantly add and remove responses
// you are *leaking* memory. This will be the case until the MeRemove* functions
// are updated to pack the array after removal.
void MeRemoveResponse(object oTarget, string sTable, string sFunction, string sWhichBand)
{
    int iIndex = MeFindStringRef(oTarget, sWhichBand+sTable, sTable);
    MeSetStringByIndex(oTarget, iIndex, "", sWhichBand+sTable);
    if (sWhichBand != RESPONSE_START && sWhichBand != RESPONSE_END) MeSetIntByIndex(oTarget, iIndex, 0, sWhichBand+sTable);
}

// This will not move a function out of a band. It only adjusts the function's
// percentage. To move out of a band you must do an add and remove.
void MeSetResponseChance(object oTarget, string sTable, string sFunction, int iNewPercent, string sWhichBand)
{
    int iIndex = MeFindStringRef(oTarget, sWhichBand+sTable, sTable);
    if (iIndex != -1) MeSetIntByIndex(oTarget, iIndex, iNewPercent, sWhichBand+sTable);
}

void MeAddResponse(object oTarget, string sTable, string sFunction, int iPercent=50, string sBand=RESPONSE_MEDIUM)
{
    MeAddStringRef(oTarget, sFunction, sBand+sTable);
    if (sBand != RESPONSE_START && sBand != RESPONSE_END) MeAddIntRef(oTarget, iPercent, sBand+sTable);
}


// To be done at a later date.
//void MeMoveResponseUp(object oTarget, string sTable, string sFunction);
//void MeMoveResponseDown(object oTarget, string sTable, string sFunction);



/* Old Response Table Code:

// ---- Basic Response Tables --------------------------------------------------

void MeAddResponse(object oTarget, string sTable, string sResponseFunction, int iChance)
{
    _PrintString("Adding entry to "+sTable+" response table: "+IntToString(iChance)+"% chance "+sResponseFunction+" will occur.");
    MeAddStringRef(oTarget, sResponseFunction, "MEME_RT_"+sTable);
    MeAddIntRef(oTarget, iChance, "MEME_RT_"+sTable);
}

int MeHasResponseTable(object oTarget, string sTable)
{
    return MeGetStringCount(oTarget, "MEME_RT_"+sTable);
}

void MeDeleteResponseTable(object oTarget, string sTable, int iDeleteDeclaration = 0)
{
    MeDeleteStringRefs(oTarget, "MEME_RT_"+sTable, iDeleteDeclaration);
    MeDeleteIntRefs(oTarget, "MEME_RT_"+sTable, iDeleteDeclaration);
}

string MeActivateResponseTable(object oTarget, string sTable, object oArg = OBJECT_INVALID)
{
    sTable = "MEME_RT_"+sTable;
    int i, iChance, iChanceResult;
    int count = MeGetStringCount(oTarget, sTable);
    string sResponse;

    for (i = 0; i < count; i++)
    {
        sResponse = MeGetStringByIndex( oTarget, i, sTable );
        iChance   = MeGetIntByIndex( oTarget, i, sTable );

        iChanceResult = Random(100);
        _PrintString(IntToString(iChanceResult)+" &lt; "+IntToString(iChance)+" --- "+sResponse, DEBUG_COREAI);

        // I removed "GetLocalString(oTarget, sResponse)" because not everyone will use
        // overrides. This needs to be standardized. Personally I would advise only
        // filling the table with the values you need. An NPC overrides the table, not
        // the functions to be called.
        if (iChanceResult < iChance && GetIsObjectValid(MeCallFunction(sResponse, oArg)))
        {
            _PrintString( "Response taken for "+sTable+": " + sResponse + " by " + _GetName( OBJECT_SELF ), DEBUG_COREAI);
            return sResponse;
        }
    }
    _PrintString( "No response taken for "+sTable+".");
    return "";
}

*/
