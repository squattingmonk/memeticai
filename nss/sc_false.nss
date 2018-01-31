/* Starting Conditional: False
 * Author: William Bull
 *
 * Requirements: This is used by the conversation library, when it starts the
 *               c_null conversation.
 *
 * Purpose: This is used by the c_null conversation.
 *          It just returns false cause the conversation to be terminated
 *          before it ever starts. The c_null conversation allows other
 *          memetic behaviors to interrupt a conversation.
 *
 */

int StartingConditional()
{
    int iResult;

    iResult = 0;
    return iResult;
}
