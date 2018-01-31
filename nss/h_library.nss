#include "h_ai"

// ----- Library-related Globals -----------------------------------------------

string MEME_LIBRARY         = GetLocalString(GetModule(), "MEME_LastExec");
string MEME_CALLED          = GetLocalString(GetModule(), "MEME_LastCalled");
string MEME_METHOD          = GetLocalString(GetModule(), "MEME_LastMethod");
int    MEME_ENTRYPOINT      = GetLocalInt(GetModule(),    "MEME_LastEntryPoint");
int    MEME_DECLARE_LIBRARY = !MEME_ENTRYPOINT;
object MEME_ARGUMENT        = GetLocalObject(GetModule(), "MEME_FunctionArg");

// ----- Library Setup Functions -----------------------------------------------

// MeLibraryImplements
// File: h_library
//
// This registers an object callback that is inside a library script. It is used
// to tell the system that your function is available and has a
// unique number. You must provide a string that defines that timing for the
// callback. For example, if you are writing a class you may register a timing
// of _ini, or _go. These timing strings correspond to calls to MeExecuteScript().
// This is an internal function that is used by the Memetic Toolkit to make
// things happen at the right time. It is our equivalent to calling
// BiowareFunction_CallCallback(oObject, "OnBlocked"); <-- which doesn't exist.
//
// It is recommended that you look at an example to understand how this works,
// in conjunction with the switch statmement that dispatches to the functions
// inside the script. Go into any lib_* file and look at the void main() function.
//
// sMeme:   The string name for the memetic object.
//          It is used during a call to MeCreateMeme();
// sMethod: The string that represents the callback for the memetic object.
//          There are fixed sMethod strings, for each type of memetic object.
//          Memes have _brk, _go, _end
//          Generators have _see, _atk, _blk, and many others.
// iEntry:  This is a number that the library code uses to denote which
//          function should be called. When the library is activated, the
//          global MEME_ENTRYPOINT may have this number. If it does, then the
//          library script knows it is being asked to run this exported function.
void MeLibraryImplements(string sMeme, string sMethod, int iEntry= 0xffffffff);

// MeLibraryFunction
// File: h_library
//
// This exports a function defined in a script that returns a result.
// It is not a function or method of a memetic object -- just a simple function.
//
// It is recommended that you look at an example to understand how this works,
// in conjunction with the switch statmement that dispatches to the functions
// inside the script. Go into any lib_* file and look at the void main() function.
//
// sFunction: This is the name you want others to call your function with.
//            It is used when they call MeCallFunction().
// iEntry:    This is a number that is the library code uses to denote which
//            function is called. The global MEME_ENTRYPOINT may have this
//            number when the script is executed. If it does, that means this
//            expoted function should be run.
void MeLibraryFunction(string sFunction, int iEntry = 0xffffffff);


// MeGetArgument
// File: h_library
//
// This is used by library "functions", can be called via MeCallFunction().
// This function gets the object that was optionally passed into the library
// function using MeCallFunction(). This should only be used inside of a library.
object MeGetArgument();

// MeSetResult
// File: h_library
//
// Sets an object that can be retrieved by a call to MeCallFunction().
// It is up to you to creatively create a new object or use an existing object to
// pass your data with this function. When someone calls MeCallFunction(), the
// library function is called and is expected to call MeSetResult(), otherwise
// MeCallFunction() returns OBJECT_INVALID.
void MeSetResult(object oResult);

// ----- Implementation -------- -----------------------------------------------

void MeLibraryImplements(string sMeme, string sMethod, int iEntry= 0xffffffff)
{
    _Start("MeLibraryImplements meme = '"+sMeme+"'"+
                            " method = '"+sMethod+"'"+
                             " entry = '"+IntToString(iEntry)+"'",
                                        DEBUG_TOOLKIT);
    object oModule  = GetModule();
    string sLib     = GetLocalString(oModule, "MEME_LastExec");
    string sExist   = GetLocalString(oModule, "MEME_Script_"+sMeme);
    if (sLib != sExist)
    {
        if (sExist != "")
            _PrintString("Warning! Library "+sLib+" is overriding "+sMeme+
                            " implementation by Library "+sExist);
        SetLocalString(oModule, "MEME_Script_"+sMeme, sLib);
    }

    int iOldEntry   = GetLocalInt(oModule, "MEME_Entry_"+sLib+sMeme+sMethod);
    if (iOldEntry)
        _PrintString("Warning! Library"+sLib+ " method "+sMethod+" of "+sMeme+
                            " already declared. Old EP="+IntToString(iOldEntry)+
                            " new EP="+IntToString(iEntry));

    SetLocalInt(oModule, "MEME_Entry_"+sLib+sMeme+sMethod, iEntry);


    _End("MeLibraryImplements", DEBUG_TOOLKIT);
}

void MeLibraryFunction(string sFunction, int iEntry = 0xffffffff)
{
    _Start("MeLibraryFunction function = '"+sFunction+"'"+
                            " entry = '"+IntToString(iEntry)+"'",
                                        DEBUG_TOOLKIT);
    object oModule  = GetModule();
    string sLib     = GetLocalString(oModule, "MEME_LastExec");
    string sExist   = GetLocalString(oModule, "MEME_Script_"+sFunction);
    if (sLib != sExist)
    {
        if (sExist != "")
            _PrintString("Warning! Library "+sLib+" is overriding "+sFunction+
                            " implementation by Library "+sExist);
        SetLocalString(oModule, "MEME_Script_"+sFunction, sLib);
    }

    int iOldEntry   = GetLocalInt(oModule, "MEME_Entry_"+sLib+sFunction);
    if (iOldEntry)
        _PrintString("Warning! Library"+sLib+ " function "+sFunction+
                            " already declared. Old EP="+IntToString(iOldEntry)+
                            " new EP="+IntToString(iEntry));

    SetLocalInt(oModule, "MEME_Entry_"+sLib+sFunction, iEntry);


    _End("MeLibraryFunction", DEBUG_TOOLKIT);
}

object MeGetArgument()
{
    return MEME_ARGUMENT;
}

void MeSetResult(object oResult)
{
    object oModule  = GetModule();
    SetLocalObject(oModule, "MEME_FunctionResult", oResult);
}

