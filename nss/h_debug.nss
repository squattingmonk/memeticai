
/*
 *  Title: Memetic AI Debugging Functions
 *  Documentation: http://www.memeticai.org/api/toc.html?prototype=true&group=3
 *  Contributors: William Bull, Lomin
 */

const int DEBUG_ACTIVE        = 1;

const int DEBUG_ALL           = -1;
const int DEBUG_NONE          =  0x00;
const int DEBUG_UTILITY       =  0x01;
const int DEBUG_TOOLKIT       =  0x02;
const int DEBUG_COREAI        =  0x04;
const int DEBUG_USERAI        =  0x08; // 0x10, 0x20, 0x40, 0x80, etc.

// MeStartDebugging
// File: h_debug
//
// Starts the XML Debugging for object which calls this function or for all objects.
// This debug information is logged by calling _Start(), _End() and //_PrintString().
//
// iDebugFlag: The amount of detail to be generated. This value corresponds to the
//             a value passed to the _PrintString() call. These values can be
//             masked
//
// bDebugAllObjects: If set to TRUE, every script will be debugged. Otherwise, only
//                   the scripts called by this object directly will be debugged.
//
// Warning: Some of the Me*() functions use a combination of  AssignCommand and ExecuteScript
//          which cause other objects to be running the scripts. You may need to debug
//          the module as well as a single creature to get a full log. Or try debugging
//          everything.
//
// Note:    To view the XML log in Internet Explorer or an equivalent XML viewer,
//          you must add <Log> to the start and </Log> to the end of your log file
//          and change the extension to .xml.
void MeStartDebugging(int iDebugFlag, int bDebugAllObjects = FALSE);

// MeAddDebugObject
// File: h_debug
// Causes the object to be debugged
void MeAddDebugObject(object oTarget = OBJECT_SELF);

// MeClearDebugObject
// File: h_debug
// Deletes the permission of oTarget to debug
void MeClearDebugObject(object oTarget = OBJECT_SELF);

// MeAddDebugFlag
// File: h_debug
// Sets the maskable debug level. If you wanted to debug the toolkit and all
// related utility functions you would call: MeAddDebugFlag(DEBUG_TOOLKIT);
void MeAddDebugFlag(int iDebugFlag);

// MeIsDebugging
// File: h_debug
// Checks to see if the given debug flag is currently being debugged.
int MeIsDebugging(int iDebugFlag=DEBUG_ALL);

// MeClearDebugFlag
// File: h_debug
// Clears iDebugFlag from the module's debug-flag
void MeClearDebugFlag(int iDebugFlag);

// _GetName
// File: h_util
// This is an internal function used by the toolkit for debugging, etc.
// This function attempts to return the best possible name for an object.
// It will use the internal name, look for the name string variable, or
// return the tag, if all else fails. It also normalizes the name to be
// used as an attribute in a call to _Start().
//
// For example _Start("MyTag target-name = "+_GetName(oTarget)+"");
// This will also ensure that the target does not have spaces or quotes in
// the name.
string _GetName(object oTarget=OBJECT_SELF);

// _Start
// File: h_debug
// Starts a debug function
// iDebugFlag: this flag decides, if the start-tag will be printed or ignored
// bAddInfo: if TRUE, additional information will be printed inside the XML tag
void _Start(string sTag, int iDebugFlag = DEBUG_USERAI, int bAddInfo = TRUE);

// _PrintString
// File: h_debug
// Prints out a debug statement to an XML log if debugging is turned on
// via the function MeStartDebugging(). See _Start and _End functions for
// folding debug statements.
//
// sNote: The string
// bInherit: If this is true it will use the value defined by _Start
// iDebugFlag: This will override the debug value
void _PrintString(string sNote, int bInherit = TRUE, int iDebugFlag = DEBUG_USERAI);

// _End
// File: h_debug
// Ends a function to be debugged, writing a closing tag to the log, like </MyFunction>.
// If _Start is called in any function, this *MUST* be called at the close } of a function
// or before any "return;" statements are executed. Otherwise, the XML will not be
// properly written to the log -- the closing tag will be missing.
//
// You no longer need to provide the debug level, this is automatically determined.
void _End(string sDepricated="", int iDepricated=0);



//--------- Implementation -------------------------------------------------------------------------------------------------------

string DeleteCharacter(string sString, int iChar)
{
    return GetStringLeft(sString, iChar)
           +
           GetStringRight(sString, GetStringLength(sString) - iChar - 1);
}

string RemoveIllegalCharacters(string sString)
{
    int i = 0;
    string sChar, sAllowedChars = "0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ_-";
    while (i < GetStringLength(sString))
    {
        sChar = GetSubString(sString, i, 1);
        if (FindSubString(sAllowedChars, sChar) == -1)
           sString = DeleteCharacter(sString, i);
        else
            i++;
    }
    return sString;
}

void MeStartDebugging(int iDebugFlag, int bDebugAllObjects)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        if(bDebugAllObjects)
            SetLocalInt(oModule, "MEME_debug_all_objects", TRUE);
        SetLocalInt(oModule, "MEME_debug_flag", iDebugFlag);
    }
}

void MeAddDebugObject(object oTarget = OBJECT_SELF)
{
    if (DEBUG_ACTIVE)
    {
        SetLocalInt(oTarget, "MEME_debug_active", TRUE);
    }
}

void MeClearDebugObject(object oTarget = OBJECT_SELF)
{
    if (DEBUG_ACTIVE)
    {
        DeleteLocalInt(oTarget, "MEME_debug_active");
    }
}

void MeAddDebugFlag(int iDebugFlag)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        SetLocalInt(oModule, "MEME_debug_flag", GetLocalInt(oModule, "MEME_debug_flag") | iDebugFlag);
    }
}

int MeIsDebugging(int iDebugFlag=DEBUG_ALL)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        if (GetLocalInt(oModule, "MEME_debug_flag") & iDebugFlag) return TRUE;
    }
    return FALSE;
}

void MeClearDebugFlag(int iDebugFlag)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        SetLocalInt(oModule, "MEME_debug_flag", GetLocalInt(oModule, "MEME_debug_flag") & (~iDebugFlag));
    }
}

string _GetName(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return "InvalidObject";
    string sName = GetLocalString(oTarget, "Name");
    if (sName == "") sName = GetName(oTarget);
    if (sName == "")
        return "UnnamedObject";
    else
        return RemoveIllegalCharacters(sName);
}

void _Start(string sTag, int iDebugFlag = DEBUG_USERAI, int bAddInfo = FALSE)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        if (GetLocalInt(oModule, "MEME_debug_all_objects") || GetLocalInt(OBJECT_SELF, "MEME_debug_active"))
        {
            int iTagNumber = GetLocalInt(oModule, "MEME_debug_tag_number");
            SetLocalInt(oModule, "MEME_debug_tag_number", ++iTagNumber);
            if ((GetLocalInt(oModule, "MEME_debug_flag") & iDebugFlag) == iDebugFlag)
            {
                string sTagSuffix = IntToString(iTagNumber);
                int iSpace = FindSubString(sTag, " ");
                if (iSpace != -1)
                    SetLocalString(oModule, "MEME_debug_tag_" + sTagSuffix, GetSubString(sTag, 0, iSpace));
                else
                    SetLocalString(oModule, "MEME_debug_tag_" + sTagSuffix, sTag);
                SetLocalInt(oModule, "MEME_debug_tag_" + sTagSuffix, TRUE);
                string sInfo = "";
                if (bAddInfo)
                    sInfo = " Name = '"
                            + _GetName(OBJECT_SELF)
                            + "' Tag = '"
                            + GetTag(OBJECT_SELF)
                            + "'";
                PrintString("<" + sTag + sInfo + ">");
            }
            //else PrintString("error1");
        }
    }
    //else PrintString("error1");
}

void _PrintString(string sNote, int bInherit = TRUE, int iDebugFlag = DEBUG_USERAI)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        if (bInherit)
        {
            if (GetLocalInt(oModule, "MEME_debug_tag_" + IntToString(GetLocalInt(oModule, "MEME_debug_tag_number"))))
                PrintString("<Note>" + sNote + "</Note>");
        }
        else if (GetLocalInt(oModule, "MEME_debug_all_objects") || GetLocalInt(OBJECT_SELF, "MEME_debug_active"))
                 if ((GetLocalInt(oModule, "MEME_debug_flag") & iDebugFlag) == iDebugFlag)
                     PrintString("<Note>" + sNote + "</Note>");
    }
}

void _End(string sDepricated="", int iDepricated=0)
{
    if (DEBUG_ACTIVE)
    {
        object oModule = GetModule();
        int iTagNumber = GetLocalInt(oModule, "MEME_debug_tag_number");
        string sTagSuffix = IntToString(iTagNumber);
        SetLocalInt(oModule, "MEME_debug_tag_number", --iTagNumber);
        if (GetLocalInt(oModule, "MEME_debug_tag_" + sTagSuffix))
        {
            string sTag = GetLocalString(oModule, "MEME_debug_tag_" + sTagSuffix);
            DeleteLocalString(oModule, "MEME_debug_tag_" + sTagSuffix);
            DeleteLocalInt(oModule, "MEME_debug_tag_" + sTagSuffix);
            PrintString("</" + sTag + ">");
        }
    }
}
