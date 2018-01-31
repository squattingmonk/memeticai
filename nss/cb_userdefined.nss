/*  Script:  UserDefined Callback
 *           Copyright (c) 2002 William Bull
 *    Info:  This does nothing
 *  Timing:  This should be attached to Bioware's OnUserDefinedEvent callback
 *  Author:  William Bull
 *    Date:  September, 2002
 *
 *    Note:  You may want to implement a memetic event if you want more
 *           powerful messaging.
 */

 #include "h_ai"

void main()
{
    _Start("OnUserDefined", DEBUG_COREAI);

    int iEventNum;

    iEventNum = GetUserDefinedEventNumber();

    /* Do your own stuff here */

    _End("OnUserDefined", DEBUG_COREAI);
}
