#include "h_debug"
#include "h_list"

/* File: h_private - Memetic Artificial Intelligence Toolkit
 * Author: William Bull
 * Date: Copyright July, 2003
 *
 * Description
 *
 * These are private functions use to manipulate memetic objects inside of
 * bags. Every NPC has several bags - they have references to objects
 * that are inside the NPC's store. Instead of using the bag's inventory I
 * use the lists on the bags to determine which set an object belongs to.
 * This allows me to efficiently move and object from one bag to another
 * without actually moving it.
 */


/* Object Functions
 * These are the base functions for creating a data structure object to hold
 * varaibles -- representing various memetic objects or bags which hold these
 * objects. These functions also create the references on the bags using the
 * object ref functions.
 */

object _MeMakeObject(object oTarget, string sName, int iType, string sListName = "")
{
    string dName = _GetName(oTarget);
    object oResult;

    if (!GetIsObjectValid(NPC_SELF))
    {
        PrintString("<Assert>Assert: cannot make object, NPC_SELF invalid.</Assert>");
    }

    // Apparently you cannot copy item into stores.
    //oResult = CopyItem(GetObjectByTag("Magic_Memetic_Bag"), oTarget);

    // But you can create items in stores.
    oResult = CreateItemOnObject("Magic_Memetic_Bag", oTarget);

    if (!GetIsObjectValid(oResult))
    {
        PrintString("<Assert>Assert: failed to CreateItemOnObject.</Assert>");
    }

    SetLocalString(oResult, "Name", sName);
    SetLocalInt(oResult, "MEME_Type", iType);

    MeAddObjectRef(oTarget, oResult, sListName);
    // For efficiency this function has been inlined Below:
    /*
    int count = GetLocalInt(oTarget, "OC:"+sListName);
    SetLocalObject(oTarget, "OL:"+sListName+IntToString(count), oResult);
    SetLocalInt(oTarget, "OC:"+sListName, count+1);
    */
    _End("_MeMakeObject");
    return oResult;
}

// Do not use this; I use it. But that doesn't mean you should use it. :)
void _MeMoveObject(object oContainer, object oObject, object oDestContainer, string sListName = "")
{
    _Start("_MeMoveObject", DEBUG_UTILITY);

    NPC_SELF = GetLocalObject (OBJECT_SELF, "MEME_NPCSelf");

    if (GetIsObjectValid(oDestContainer) &&
        GetIsObjectValid(oObject) &&
        GetIsObjectValid(oContainer))
    {
        MeRemoveObjectRef(oContainer, oObject, sListName);
        // For efficiency this function has been inlined below:
//        int count, i;
//        object oRef, oEndRef;
//
//        count = GetLocalInt(oContainer, "OC:"+sListName);
//        oEndRef = GetLocalObject(oContainer, "OL:"+sListName+IntToString(count-1));
//
//        for (i = 0; i < count; i++)
//        {
//            oRef = GetLocalObject(oContainer, "OL:"+sListName+IntToString(i));
//            if (oRef == oObject)
//            {
//                SetLocalObject(oContainer, "OL:"+sListName+IntToString(i), oEndRef);
//                count--;
//                DeleteLocalObject(oContainer, "OL:"+sListName+IntToString(count));
//                break;
//            }
//        }
//        SetLocalInt(oContainer, "OC:"+sListName, count);

        MeAddObjectRef(oDestContainer, oObject, sListName);
        // For efficiency this function has been inlined below:
//        count = GetLocalInt(oContainer, "OC:"+sListName);
//        SetLocalObject(oContainer, "OL:"+sListName+IntToString(count), oObject);
//        SetLocalInt(oContainer, "OC:"+sListName, count+1);
    }
    else {
        _PrintString("Error: _MeMoveObject failed for "+_GetName(OBJECT_SELF)+"!", DEBUG_UTILITY);
    }

    _End("_MeMoveObject");
}


void _MeRemoveObject(object oTarget, object oObject, string sListName = "")
{
    _Start("MeRemoveObject name='"+_GetName(oObject)+"'", DEBUG_UTILITY);

    // MeRemoveObjectRef(oTarget, oObject, sPrefix);
    // For efficiency this function has been inlined below:
    int count, i;
    object oRef, oEndRef;

    count = GetLocalInt(oTarget, "OC:"+sListName);
    oEndRef = GetLocalObject(oTarget, "OL:"+sListName+IntToString(count-1));

    for (i = 0; i < count; i++)
    {
        oRef = GetLocalObject(oTarget, "OL:"+sListName+IntToString(i));
        if (oRef == oObject)
        {
            SetLocalObject(oTarget, "OL:"+sListName+IntToString(i), oEndRef);
            count--;
            DeleteLocalObject(oTarget, "OL:"+sListName+IntToString(count));
            break;
        }
    }
    SetLocalInt(oTarget, "OC:"+sListName, count);

    DestroyObject(oObject);

    _End("MeRemoveObject");
}
