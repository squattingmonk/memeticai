/*
 *       File: h_interact
 * Created By: Lomin Isilmelind
 *       Date: 01/24/2004
 *Last Update: 08/30/2004
 *
 *    Purpose: Interact protocol functions
 *
 */
// -- Required includes: -------------------------------------------------------
      #include "h_event"
// -- Implementation -----------------------------------------------------------

// -- Prototypes ---------------------------------------------------------------

// -- Constants ----------------------------------------------------------------
const string CONDITIONAL = "Conditional";
const string DENIAL = "Denial";
const string EXECUTE = "Execute";
const string RESPONSE = "Response";

// Returns the meme flag for a request
int IaGetMemeFlag(object oData, string sRequest);
// Returns the Modifier of a request
int IaGetModifier(object oData, string sRequest);
// Returns the priority of a request
int IaGetPriority(object oData, string sRequest);

// This is an internal function to create a unique key, which is used to distinguish between multiple requests
string _IaCreateInteractKey();
// Returns the name of the function saved on oData
// Supported types are:
//    CONDITIONAL
//    DENIAL
//    EXECUTE
//    RESPONSE
string IaGetFunction(object oData, string sType, string sRequest);
// Returns the name of the requested meme
string IaGetMemeName(object oData, string sRequest);

// This function creates a request struct, which can be started at any time by IaStartRequest
struct message IaCreateRequest(object oReciever, string sResponse = "ia_response_default", string sConditional = "ia_conditional_default", string sExecute = "ia_execute_default", string sDenial = "ia_denial_default");

// Sets the name of the function saved on oData
// Supported types are:
//    CONDITIONAL
//    DENIAL
//    EXECUTE
//    RESPONSE
void IaSetFunction(object oData, string sType, string sRequest, string sFunction);
// Sets sthe name of the requested meme
void IaSetMemeName(object oData, string sRequest, string sMeme);
// Sets the meme flag for a request
void IaSetMemeFlag(object oData, string sRequest, int iFlag);
// Sets the Modifier of a request
void IaSetModifier(object oData, string sRequest, int iModifier);
// Sets the priority of a request
void IaSetPriority(object oData, string sRequest, int iPriority);
// Starts the request created by IaCreateRequest
void IaStartRequest(object oData, struct message scMessage);

// -- Source -------------------------------------------------------------------

int IaGetMemeFlag(object oData, string sRequest)
{
    return GetLocalInt(oData, "Flag" + sRequest);
}

int IaGetPriority(object oData, string sRequest)
{
    return GetLocalInt(oData, "Priority" + sRequest);
}

int IaGetModifier(object oData, string sRequest)
{
    return GetLocalInt(oData, "Modifier" + sRequest);
}

string _IaCreateInteractKey()
{
    string sRequest = "Request started by " +
                      ObjectToString(OBJECT_SELF) +
                      " at " + FloatToString(MeGetCurrentGameTime());
    return sRequest;
}

struct message IaCreateRequest(object oReciever,
                       string sResponse = "ia_response_default",
                       string sConditional = "ia_conditional_default",
                       string sExecute = "ia_execute_default",
                       string sDenial = "ia_denial_default")
{
    string sRequest = _IaCreateInteractKey();
    IaSetFunction(NPC_SELF, RESPONSE, sRequest, sResponse);
    IaSetFunction(NPC_SELF, CONDITIONAL, sRequest, sConditional);
    IaSetFunction(NPC_SELF, DENIAL, sRequest, sDenial);
    IaSetFunction(NPC_SELF, EXECUTE, sRequest, sExecute);
    struct message scMessage;
    scMessage.sMessageName = RESPONSE;
    scMessage.sData = sRequest;
    scMessage.oData = NPC_SELF;

    return scMessage;
}

string IaGetFunction(object oData, string sType, string sRequest)
{
    return GetLocalString(oData, sType + sRequest);
}

string IaGetMemeName(object oData, string sRequest)
{
    return GetLocalString(oData, "MemeName" + sRequest);
}

void IaSetFunction(object oData, string sType, string sRequest, string sFunction)
{
    SetLocalString(oData, sType + sRequest, sFunction);
}

void IaSetMemeName(object oData, string sRequest, string sMeme)
{
    SetLocalString(oData, "MemeName" + sRequest, sMeme);
}

void IaSetMemeFlag(object oData, string sRequest, int iFlag)
{
    SetLocalInt(oData, "Flag" + sRequest, iFlag);
}

void IaSetModifier(object oData, string sRequest, int iModifier)
{
    SetLocalInt(oData, "Modifier" + sRequest, iModifier);
}

void IaSetPriority(object oData, string sRequest, int iPriority)
{
    SetLocalInt(oData, "Priority" + sRequest, iPriority);
}


void IaSetReturnMeme(object oData, string sRequest, object oMeme)
{
    SetLocalObject(oData, "Meme" + sRequest, oMeme);
}

void IaSetRequestReciever(object oData, string sRequest, object oReciever)
{
    SetLocalObject(oData, "Reciever" + sRequest, oReciever);
}

void IaSetRequestStarter(object oData, string sRequest, object oStarter)
{
    SetLocalObject(oData, "Starter" + sRequest, oStarter);
}

void IaStartRequest(object oReciever, struct message scMessage)
{
    scMessage.sMessageName = RESPONSE;
    MeSendMessage(scMessage, "", oReciever);
}

void IaCleanUp(object oData, string sRequest)
{
    DeleteLocalInt(oData, "Priority");
    DeleteLocalInt(oData, "Modifier");
    DeleteLocalInt(oData, "Flag");
    DeleteLocalInt(oData, "Priority");
    DeleteLocalInt(oData, "Priority");
}
