/*  Script:  Conversation Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  Executes the conversation generators.
 *  Timing:  This should be attached to Bioware's OnConversation callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 *    Note:  This callback will likely change to start conversations tied
 *           to the active meme.
 */

#include "h_ai"

void main()
{
    _Start("OnConversationDialog timing='bye'", DEBUG_COREAI);

    MeExecuteGenerators("_bye");
    MeUpdateActions();

    _End("OnConversationDialog", DEBUG_COREAI);
}


