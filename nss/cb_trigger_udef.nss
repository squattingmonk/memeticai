#include "h_ai"

void main()
{
    _Start("Trigger timing='UserDefined'", DEBUG_COREAI);

    int iEventNum;

    iEventNum = GetUserDefinedEventNumber();

    /* Do your own stuff here */

    _End("OnUserDefined", DEBUG_COREAI);
}
