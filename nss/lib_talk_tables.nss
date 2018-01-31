/*------------------------------------------------------------------------------
*  Core Library of Memes
*
*  This is a library for movement behaviour.
*
*  At the end of this library you will find a main() function. This contains
*  the code that registers and runs the scripts in this library. Read the
*  instructions to add your own objects to this library or to a new library.
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*    Library:  lib_talk_tables
* Created By:  Lomin Isilmelind
*       Date:  12/05/2003
*Last Update:  01/11/2004
*    Purpose:  This is a container for conversations.
*-----------------------------------------------------------------------------*/

// -- Required includes: -------------------------------------------------------

#include "h_talk"

// -- Implementation -----------------------------------------------------------

// -- Prototypes ---------------------------------------------------------------


// -- Source -------------------------------------------------------------------

void TalkTable_Answer()
{
    TalkTableInit("Answer", "?t#|Random|T");
    TalkAdd("S|I do not want to answer this question.|~");
    TalkAdd("S|Sure.|~");
}

void TalkTable_Bye()
{
    MeSetResult(_TRUE);
    TalkAdd("t#|Bye|T", "Bye");
    TalkAdd("S|Have to go. Bye!|E~");
}

void TalkTable_Greeting()
{
    TalkTableInit("Greeting", "?t#|Greeting_b|T");
    TalkAdd("S|Hi!|~");
    TalkAdd("S|Hello!|~");
}

void TalkTable_Greeting_b()
{
    TalkTableInit("Greeting_b", "?t#|Random|T");
    TalkAdd("S|Oh, hello!|~");
    TalkAdd("S|Hey, nice to see you!|~");
}

void TalkTable_Question()
{
    TalkTableInit("Question", "?t#|Answer|T");
    TalkAdd("S|Are you Santa Clause?|~");
    TalkAdd("S|Do you have some items for sale?|~");
}

void TalkTable_Random()
{
    MeSetResult(_TRUE);
    TalkAdd("?", "Random");
    TalkAdd("#|Question|");
    TalkAdd("#|Statement|");
    TalkAdd("x|TalkBye|");
}

void TalkTable_Statement()
{
    TalkTableInit("Statement", "?t#|Random|T");
    TalkAdd("S|Nice weather!|~");
    TalkAdd("S|I do not feel well today...|~");
}

void TalkRandom()
{
    MeSetResult(_TRUE);
    object oMeme = MeGetArgument();
    int iRandom = Random(2);
    string sFile;
    switch (iRandom)
    {
        case 0: sFile = "Greeting";  break;
        case 1: sFile = "Greeting_b";break;
    }
    SetLocalString(MEME_ARGUMENT, "File", sFile);
    SetLocalInt(MEME_ARGUMENT, "Line", 0);

    _Start("TalkRandom File = '" + sFile + "' Line = '0'", DEBUG_TALK_TOOLS);
    _End();
}
//Some demo function for demonstration
void TalkBye()
{
    MeSetResult(_TRUE);
    object oMeme = MEME_ARGUMENT;
    // by a chance of 10% the conversation will end
    int iRandom = Random(10);
    if (iRandom == 0)
    {
        TalkTableLoad("Bye");
        DeleteLocalInt(MEME_SELF, "Random");
        SetLocalInt(MEME_SELF, "Line", 0);
    }
}

//Demo

/*------------------------------------------------------------------------------
*   Script: Library Initialization and Scheduling
*
*   This main() defines this script as a library. The following two steps
*   handle registration and execution of the scripts inside this library. It
*   is assumed that a call to MeLoadLibrary() has occured in the ModuleLoad
*   callback. This lets the MeExecuteScript() function know how to find the
*   functions in this library. You can create your own library by copying this
*   file and editing "cb_mod_onload" to register the name of your new library.
------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    //  Step 1: Library Setup
    //
    //  This is run once to bind your scripts to a unique number.
    //  The number is composed of a top half - for the "class" and lower half
    //  for the specific "method". If you are adding your own scripts, copy
    //  the example, make sure to change the first number. Then edit the
    //  switch statement following this if statement.

    if (MEME_DECLARE_LIBRARY)
    {
            MeLibraryFunction("TalkTable_Answer",               1);
            MeLibraryFunction("TalkTable_Bye",                  2);
            MeLibraryFunction("TalkTable_Greeting",             3);
            MeLibraryFunction("TalkTable_Greeting_b",           4);
            MeLibraryFunction("TalkTable_Question",             5);
            MeLibraryFunction("TalkTable_Random",               6);
            MeLibraryFunction("TalkTable_Statement",            7);
            MeLibraryFunction("TalkBye",                        8);

            //MeLibraryFunction(<name>, <entry>);

            _End("Library");
            return;
    }

    //  Step 2: Library Dispatcher
    //
    //  These switch statements are what decide to run your scripts, based
    //  on the numbers you provided in Step 1. Notice that you only need
    //  an inner switch statement if you exported more than one method
    //  (like go and end). Also notice that the value used by the case statement
    //  is the two numbers added up.

    switch (MEME_ENTRYPOINT)
    {
            case    1: TalkTable_Answer();          break;
            case    2: TalkTable_Bye();             break;
            case    3: TalkTable_Greeting();        break;
            case    4: TalkTable_Greeting_b();      break;
            case    5: TalkTable_Question();        break;
            case    6: TalkTable_Random();          break;
            case    7: TalkTable_Statement();       break;
            case    8: TalkBye();                   break;


            /*
            case 0x??00:    switch (MEME_ENTRYPOINT & 0x00ff)
            {
            case 0x01: <name>_go();     break;
            case 0x02: <name>_brk();    break;
            case 0x03: <name>_end();    break;
            case 0xff: <name>_ini();    break;
            }
            break;
            */
    }
    _End("Library");
}
