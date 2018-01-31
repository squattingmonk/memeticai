#include "h_debug"

/* File: h_list - List Datastructure Functions
 * Author: William Bull
 * Date: Copyright July, 2003
 *
 * Description
 *
 * These are public functions for managing basic, efficient lists.
 */

// IMPORTANT: When removing entries, order is NOT preserved.

// NOTE: Several of these utility functions have now been inlined in h_private,
//       for the sake of efficiency. If you are doing maintenance on this file,
//       please keep the functions in h_private in sync.


// ----- List Utilities --------------------------------------------------------

// MeAddObjectRef
// File: h_list
// Adds an object to an object list on the target given the list name.
// There can be multiple lists of different types with the same name on the same object.
void MeAddObjectRef(object oTarget, object oObject, string sListName = "", int bAddUnique = FALSE);

// MeRemoveObjectRef
// File: h_list
// Removes the object from the list on the target. If this object was added twice, the first
// reference is removed. The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveObjectRef(object oTarget, object oObject, string sListName = "");

// MeRemoveObjectByIndex
// File: h_list
// Removes the specified object from the list, given the index. The first item in the list is 0.
// The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveObjectByIndex(object oTarget, int iIndex, string sListName = "");

// MeGetObjectByName
// File: h_list
// Searches through the list with the given list name and looks for the object
// with the given name. It looks for the local variable "Name" on each object to
// find the name. If there are more than one, an index may be provided.
object MeGetObjectByName(object oTarget, string sName, string sListName = "", int iIndex = 0);

// MeSetObjectByIndex
// File: h_list
// Replaces one object in a list, with another. The position is determined by index
// 0 is the first item. If the index is at the end of the list, it will be added.
// If it exceeds the length of the list, an error may be written to the log and
// nothing is added.
void MeSetObjectByIndex(object oTarget, int iIndex, object oValue, string sListName = "");

// MeHasObjectRef
// File: h_list
// Searches through the list and returns the index in the list or -1 if
// the object is not found.
int MeHasObjectRef(object oTarget, object oObject, string sListName = "");

// MeGetObjectByIndex
// File: h_list
// Returns an object at the given index. If no object is found at that index,
// OBJECT_INVALID is returned.
object MeGetObjectByIndex(object oTarget, int iIndex=0, string sListName = "");

// MeGetObjectCount
// File: h_list
// Returns the number of items in the object list with the given list name.
int MeGetObjectCount(object oTarget,    string sListName = "");

// MeDeleteObjectRefs
// File: h_list
// Removes the entire object list with the given name on the target object.
void MeDeleteObjectRefs(object oTarget,    string sListName = "", int iDeleteDeclaration = 0);

// MeAddStringRef
// File: h_list
// Adds a string to a string list on the target given the list name.
// There can be multiple lists of different types with the same name on the same object.
void MeAddStringRef(object oTarget, string oString, string sListName = "", int bAddUnique = FALSE);

// MeRemoveStringRef
// File: h_list
// Removes the string from the list on the target. If this string was added twice, the first
// reference is removed. The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveStringRef(object oTarget, string sString, string sListName = "");

// MeRemoveStringByIndex
// File: h_list
// Removes the specified string from the list, given the index. The first item in the list is 0.
// The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveStringByIndex(object oTarget, int iIndex, string sListName = "");

// MeGetStringByIndex
// File: h_list
// Returns an string at the given index. If no string is found at that index, "" is returned.
string MeGetStringByIndex(object oTarget, int iIndex=0, string sListName = "");

// MeGetStringCount
// File: h_list
// Returns the number of items in the string list with the given list name.
int MeGetStringCount(object oTarget, string sListName = "");

// MeFindStringRef
// File: h_list
// Returns the index of sString in the list named sListName.
int MeFindStringRef(object oTarget, string sString, string sListName = "");

// MeSetStringByIndex
// File: h_list
// Replaces one string in a list, with another. The position is determined by index
// 0 is the first item. If the index is at the end of the list, it will be added.
// If it exceeds the length of the list, an error may be written to the log and
// nothing is added.
void MeSetStringByIndex(object oTarget, int iIndex,     string sValue,       string sListName = "");

// MeDeleteStringRefs
// File: h_list
// Removes the entire string list with the given name on the target object.
void MeDeleteStringRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0);

// MeAddIntRef
// File: h_list
// Adds an integer to an integer list on the target given the list name and namespace.
// There can be multiple lists of different types with the same name on the same object.
void MeAddIntRef(object oTarget, int iValue, string sListName = "", int bAddUnique = FALSE);

// MeSetIntByIndex
// File: h_list
// Replaces one integer in a list, with another. The position is determined by index
// 0 is the first item. If the index is at the end of the list, it will be added.
// If it exceeds the length of the list, an error may be written to the log and
// nothing is added.
void MeSetIntByIndex(object oTarget, int iIndex, int iValue, string sListName = "");

// MeRemoveIntRef
// File: h_list
// Removes the integer from the list on the target. If this integer was added twice, the first
// reference is removed. The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveIntRef(object oTarget, int iValue, string sListName = "");

// MeRemoveIntByIndex
// File: h_list
// Removes the specified integer from the list, given the index. The first item in the list is 0.
// The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveIntByIndex(object oTarget, int iIndex, string sListName = "");

// MeGetIntByIndex
// File: h_list
// Returns an integer at the given index. If no integer is found at that index, 0 is returned.
int MeGetIntByIndex(object oTarget, int iIndex=0, string sListName = "");

// MeGetIntCount
// File: h_list
// Returns the number of items in the integer list with the given list name.
int MeGetIntCount(object oTarget, string sListName = "");

// MeDeleteIntRefs
// File: h_list
// Removes the entire integer list with the given name on the target object.
void MeDeleteIntRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0);

// MeAddFloatRef
// File: h_list
// Adds a float to a float list on the target given the list name and namespace.
// There can be multiple lists of different types with the same name on the same object.
void MeAddFloatRef(object oTarget, float iValue, string sListName = "", int bAddUnique = FALSE);

// MeRemoveFloatRef
// File: h_list
// Removes the float from the list on the target. If this float was added twice, the first
// reference is removed. The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveFloatRef(object oTarget, float iValue, string sListName = "");

// MeRemoveFloatByIndex
// File: h_list
// Removes the float from the list on the target. If this integer was added twice, the first
// reference is removed. The order of the list is NOT preserved. For efficiency, the
// last item is moved to the empty spot.
void MeRemoveFloatByIndex(object oTarget, int iIndex, string sListName = "");

// MeGetFloatByIndex
// File: h_list
// Returns an float at the given index. If no float is found at that index, 0.0 is returned.
float MeGetFloatByIndex(object oTarget, int iIndex = 0, string sListName = "");

// MeGetFloatCount
// File: h_list
// Returns the number of items in the float list with the given list name.
int MeGetFloatCount(object oTarget, string sListName = "");

// MeSetFloatByIndex
// File: h_list
// Replaces one float in a list, with another. The position is determined by index
// 0 is the first item. If the index is at the end of the list, it will be added.
// If it exceeds the length of the list, an error may be written to the log and
// nothing is added.
void MeSetFloatByIndex(object oTarget, int iIndex, float fValue, string sListName = "");

// MeDeleteFloatRefs
// File: h_list
// Removes the entire float list with the given name on the target object.
void MeDeleteFloatRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0);

// MeCopyObjectRef
// File: h_list
// Copy a list from one object to another.
void MeCopyObjectRef(object oSource, object oDest, string sSourceName, string sTargetName);

// MeCopyFloatRef
// File: h_list
// Copy a list from one object to another.
void MeCopyFloatRef(object oSource, object oDest, string sSourceName, string sTargetName);

// MeCopyIntRef
// File: h_list
// Copy a list from one object to another.
void MeCopyIntRef(object oSource, object oDest, string sSourceName, string sTargetName);

// MeCopyStringRef
// File: h_list
// Copy a list from one object to another.
void MeCopyStringRef(object oSource, object oDest, string sSourceName, string sTargetName);

// _GetObjectOwner
// File: h_list
// This is an internal function to the memetic toolkit's variable inheritance system.
// You should never have to use it.
// Find the object that actually owns the variable given a declaration table.
object _GetObjectOwner(object oTarget, string sDeclEntry);

object _GetObjectOwner(object oTarget, string sDeclEntry)
{
    //_Start("_GetObjectOwner oTarget='"+_GetName(oTarget)+"' sDeclEntry='"+sDeclEntry+"'", DEBUG_UTILITY);
    object oDeclarationTarget = GetLocalObject(oTarget, sDeclEntry);
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        //_PrintString(_GetName(oTarget)+" has a declaration table entry ("+sDeclEntry+") pointing to object "+_GetName(oDeclarationTarget), DEBUG_UTILITY);
        //_End("_GetObjectOwner", DEBUG_UTILITY);
        return oDeclarationTarget;
    }
    else
    {
        //_PrintString(_GetName(oTarget)+" does not have a declaration entry for "+sDeclEntry);
    }
    object oParent = GetLocalObject(oTarget, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        //_PrintString(_GetName(oTarget)+" is inheriting ("+sDeclEntry+") from the object "+_GetName(oParent), DEBUG_UTILITY);
        //_End("_GetObjectOwner", DEBUG_UTILITY);
        return _GetObjectOwner(oParent, sDeclEntry);
    }
    //_PrintString(_GetName(oTarget)+" is not inheriting and will handle its own variables.", DEBUG_UTILITY);
    //_End("_GetObjectOwner", DEBUG_UTILITY);
    return oTarget;
}

// ----- MeAdd* Functions ------------------------------------------------------

// When you are adding items to an inherited list, it is necessary to copy
// the list locally, then apply the changes. If the name is mapped to an
// inherited variable with a different name, it is copied from the list,
// with the mapped name.

// When you set a variable on an object, that variable stops being inherited.
// The object now manages the variable on its own, but it will still
// inherit any other unmodified variables.

void MeAddObjectRef(object oTarget, object oObject, string sListName = "", int bAddUnique = FALSE)
{
    _Start("MeAddObjectRef target = '" + GetLocalString(oTarget,"Name") + "' object = '" + GetLocalString(oObject,"Name") + "' count = '" + IntToString(GetLocalInt(oTarget, "OC:"+ sListName )) +"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique == TRUE)
    {
        int i;
        for (i = GetLocalInt(oTarget, "OC:"+sListName)-1; i >= 0; i--)
        {
            if (GetLocalObject(oTarget, "OL:"+sListName+IntToString(i)) == oObject)
            {
                _End("MeAddObjectRef");
                return ;
            }
        }
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_OL:"+sListName, oTarget);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int count;
    count = GetLocalInt(oTarget, "OC:"+sListName);

    //_PrintString("Setting "+"OL:"+sListName+IntToString(count)+".", DEBUG_UTILITY);
    SetLocalObject(oTarget, "OL:"+sListName+IntToString(count), oObject);
    //_PrintString("Setting "+"OC:"+sListName+" to "+IntToString(count+1)+".", DEBUG_UTILITY);
    SetLocalInt(oTarget, "OC:"+sListName, count+1);

    _End("MeAddObjectRef", DEBUG_UTILITY);
}

void MeAddStringRef(object oTarget, string sString, string sListName = "", int bAddUnique = FALSE)
{
    _Start("MeAddStringRef", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique == TRUE)
    {
        int i;
        for (i = GetLocalInt(oTarget, "SC:"+sListName)-1; i >= 0; i--)
        {
            if (GetLocalString(oTarget, "SL:"+sListName+IntToString(i)) == sString)
            {
                _End("MeAddStringRef");
                return ;
            }
        }
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_SL:"+sListName, oTarget);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int count, i;
    count = GetLocalInt(oTarget, "SC:"+sListName);

    SetLocalString(oTarget, "SL:"+sListName+IntToString(count), sString);
    SetLocalInt(oTarget, "SC:"+sListName, count+1);

    //_PrintString("SetLocalInt(object:"+_GetName(oTarget)+", 'SC:"+sListName+"', "+IntToString(count+1)+");", DEBUG_UTILITY);

    _End("MeAddStringRef", DEBUG_UTILITY);
}

void MeAddIntRef(object oTarget, int iValue, string sListName = "", int bAddUnique = FALSE)
{

    _Start("MeAddIntRef target = '"+ GetLocalString(oTarget,"Name")+ "' value = '" + IntToString(iValue)+ "' count = '" + IntToString(GetLocalInt(oTarget, "IC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique == TRUE)
    {
        int i;
        for (i = GetLocalInt(oTarget, "IC:"+sListName)-1; i >= 0; i--)
        {
            if (GetLocalInt(oTarget, "IL:"+sListName+IntToString(i)) == iValue)
            {
                _End("MeAddIntRef");
                return ;
            }
        }
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_IL:"+sListName, oTarget);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int count, i;
    count = GetLocalInt(oTarget, "IC:"+sListName);

    //_PrintString("Setting "+"IL:"+sListName+IntToString(count)+".", DEBUG_UTILITY);
    SetLocalInt(oTarget, "IL:"+sListName+IntToString(count), iValue);
    //_PrintString("Setting "+"IC:"+sListName+" to "+IntToString(count+1)+".", DEBUG_UTILITY);
    SetLocalInt(oTarget, "IC:"+sListName, count+1);

    _End("MeAddIntRef", DEBUG_UTILITY);
}

void MeAddFloatRef(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE)
{

    _Start("MeAddFloatRef target = '"+ GetLocalString(oTarget,"Name")+ "' value = '" + FloatToString(fValue)+ "' count = '" + IntToString(GetLocalInt(oTarget, "FC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique == TRUE)
    {
        int i;
        for (i = GetLocalInt(oTarget, "FC:"+sListName)-1; i >= 0; i--)
        {
            if (GetLocalFloat(oTarget, "FL:"+sListName+IntToString(i)) == fValue)
            {
                _End("MeAddFloatRef");
                return ;
            }
        }
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_FL:"+sListName, oTarget);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_FL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int count, i;
    count = GetLocalInt(oTarget, "FC:"+sListName);

    //_PrintString("Setting "+"FL:"+sListName+IntToString(count)+".", DEBUG_UTILITY);
    SetLocalFloat(oTarget, "FL:"+sListName+IntToString(count), fValue);
    //_PrintString("Setting "+"FC:"+sListName+" to "+IntToString(count+1)+".", DEBUG_UTILITY);
    SetLocalInt(oTarget, "FC:"+sListName, count+1);

    _End("MeAddFloatRef", DEBUG_UTILITY);
}

// ----- MeCopy* Functions -----------------------------------------------------

// When a string is copied from a source list to a target list, the source
// list may not own the list. It may be inherited and may have remapped the
// name of the list to something else on the source's parent. The given
// list name is what will be set on the target when the function is done;
// but access to the source variable will always use the source's map name.

// Note: declaration tables always use the list name, not the mapped name.

// WARNING!! Extremely long list management can cause TMI; this list code
// is expensive. It is NOT recommended that you create long lists on classes.
// Especially if you ever forsee an instance modifying this list.
void MeCopyStringRef(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sMapName = sSourceName;

    // We only need to do stuff with declaration tables and inheritance
    // if we have a parent pointer, otherwise just skip this stuff.
    if (GetLocalObject(oSource, "MEME_Parent") != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oSource, "VMAP_SL:"+sSourceName);
        if (sMapName == "") sMapName = sSourceName;

        // Get the (possibly) inherited object that owns this list
        oSource = _GetObjectOwner(oSource, "DECL_SL:"+sSourceName);
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_SL:"+sTargetName, oTarget);

    if (oSource == oTarget) return;

    int count = GetLocalInt(oSource, "SC:"+sMapName);
    SetLocalInt(oTarget, "SC:"+sTargetName, count);
    string sItemName;

    for (count--; count >= 0; count--)
    {
        sItemName = "SL:"+sTargetName+IntToString(count);
        SetLocalString(oTarget, sItemName, GetLocalString(oSource, sMapName));
    }
}

void MeCopyIntRef(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sMapName = sSourceName;

    // We only need to do stuff with declaration tables and inheritance
    // if we have a parent pointer, otherwise just skip this stuff.
    if (GetLocalObject(oSource, "MEME_Parent") != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oSource, "VMAP_IL:"+sSourceName);
        if (sMapName == "") sMapName = sSourceName;

        // Get the (possibly) inherited object that owns this list
        oSource = _GetObjectOwner(oSource, "DECL_IL:"+sSourceName);
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_IL:"+sTargetName, oTarget);

    if (oSource == oTarget) return;

    int count = GetLocalInt(oSource, "IC:"+sMapName);
    SetLocalInt(oTarget, "IC:"+sTargetName, count);
    string sItemName;

    for (count--; count >= 0; count--)
    {
        sItemName = "IL:"+sTargetName+IntToString(count);
        SetLocalInt(oTarget, sItemName, GetLocalInt(oSource, sMapName));
    }
}

void MeCopyFloatRef(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sMapName = sSourceName;

    // We only need to do stuff with declaration tables and inheritance
    // if we have a parent pointer, otherwise just skip this stuff.
    if (GetLocalObject(oSource, "MEME_Parent") != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oSource, "VMAP_FL:"+sSourceName);
        if (sMapName == "") sMapName = sSourceName;

        // Get the (possibly) inherited object that owns this list
        oSource = _GetObjectOwner(oSource, "DECL_FL:"+sSourceName);
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_FL:"+sTargetName, oTarget);

    if (oSource == oTarget) return;

    int count = GetLocalInt(oSource, "FC:"+sMapName);
    SetLocalInt(oTarget, "FC:"+sTargetName, count);
    string sItemName;

    for (count--; count >= 0; count--)
    {
        sItemName = "FL:"+sTargetName+IntToString(count);
        SetLocalFloat(oTarget, sItemName, GetLocalFloat(oSource, sMapName));
    }
}

void MeCopyObjectRef(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sMapName = sSourceName;

    // We only need to do stuff with declaration tables and inheritance
    // if we have a parent pointer, otherwise just skip this stuff.
    if (GetLocalObject(oSource, "MEME_Parent") != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oSource, "VMAP_OL:"+sSourceName);
        if (sMapName == "") sMapName = sSourceName;

        // Get the (possibly) inherited object that owns this list
        oSource = _GetObjectOwner(oSource, "DECL_OL:"+sSourceName);
    }

    // The new owner of the list must override its inherited values
    SetLocalObject(oTarget, "DECL_OL:"+sTargetName, oTarget);

    if (oSource == oTarget) return;

    int count = GetLocalInt(oSource, "OC:"+sMapName);
    SetLocalInt(oTarget, "OC:"+sTargetName, count);
    string sItemName;

    for (count--; count >= 0; count--)
    {
        sItemName = "OL:"+sTargetName+IntToString(count);
        SetLocalObject(oTarget, sItemName, GetLocalObject(oSource, sMapName));
    }
}

// ----- MeGet* Functions ------------------------------------------------------

object MeGetObjectByIndex(object oTarget, int iIndex = 0, string sListName = "")
{
    _Start("MeGetObjectByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "OC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        object result = MeGetObjectByIndex(oParent, iIndex, sListName);
        _End("MeGetObjectByIndex", DEBUG_UTILITY);
        return result;
    }

    int count = GetLocalInt(oTarget, "OC:"+sListName);
    object oResult;

    if (iIndex >= count) {
        _End("MeGetObjectByIndex", DEBUG_UTILITY);
        return OBJECT_INVALID;
    }

    oResult = GetLocalObject(oTarget, "OL:"+sListName+IntToString(iIndex));
    _End("MeGetObjectByIndex", DEBUG_UTILITY);
    return oResult;
}

int MeGetObjectCount(object oTarget, string sListName = "")
{
    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        int result = MeGetObjectCount(oParent, sListName);
        _End("MeGetObjectCount", DEBUG_UTILITY);
        return result;
    }

    return GetLocalInt(oTarget, "OC:"+sListName);
}

object MeGetObjectByName(object oTarget, string sName, string sListName = "", int iIndex = 0)
{
    _Start("MeGetObjectByName target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "OC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        object result = MeGetObjectByName(oParent, sName, sListName, iIndex);
        _End("MeGetObjectByName", DEBUG_UTILITY);
        return result;
    }

    int count = GetLocalInt(oTarget, "OC:"+sListName);
    int i, index;
    object oResult;

    for (i = 0; i < count; i++)
    {
        oResult = GetLocalObject(oTarget, "OL:"+sListName+IntToString(i));
        if (GetLocalString(oResult, "Name") == sName || sName == "")
        {
            if (index == iIndex) {
                _End("MeGetObjectByName", DEBUG_UTILITY);
                return oResult;
            }
            index++;
        }
    }

    _End("MeGetObjectByName", DEBUG_UTILITY);
    return OBJECT_INVALID;
}

string MeGetStringByIndex(object oTarget, int iIndex = 0, string sListName = "")
{
    _Start("MeGetStringByIndex", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        string result = MeGetStringByIndex(oParent, iIndex, sListName);
        _End("MeGetStringByIndex", DEBUG_UTILITY);
        return result;
    }

    int count = GetLocalInt(oTarget, "SC:"+sListName);
    if (iIndex >= count) {
        _End("MeGetStringByIndex", DEBUG_UTILITY);
        return "";
    }

    _End("MeGetStringByIndex", DEBUG_UTILITY);
    return GetLocalString(oTarget, "SL:"+sListName+IntToString(iIndex));
}

int MeGetStringCount(object oTarget, string sListName = "")
{
    _Start("MeGetStringCount parentid='DECL_SL:"+sListName+"' countid='SC:"+sListName+"'", DEBUG_UTILITY);
    //_PrintString("sListName = "+sListName, DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);
    //_PrintString("_GetObjectOwner(object:"+_GetName(oTarget)+", DECL_SL:"+sListName+") == object:"+_GetName(oParent), DEBUG_UTILITY);
    //_PrintString(_GetName(oTarget)+" != "+_GetName(oTarget), DEBUG_UTILITY);
    if (oParent != oTarget)
    {
        //_PrintString("The variable "+sListName+" is inherited from "+_GetName(oParent)+".", DEBUG_UTILITY);
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        int result = MeGetStringCount(oParent, sListName);
        _End("MeGetStringCount", DEBUG_UTILITY);
        return result;
    }
    //_PrintString("GetLocalInt(object:"+_GetName(oTarget)+", 'SC:"+sListName+"'); = "+IntToString(GetLocalInt(oTarget, "SC:"+sListName)), DEBUG_UTILITY);

    _End("MeGetStringCount", DEBUG_UTILITY);
    return GetLocalInt(oTarget, "SC:"+sListName);
}

int MeGetIntByIndex(object oTarget, int iIndex = 0, string sListName = "")
{
    _Start("MeGetIntByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "IC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        int result = MeGetIntByIndex(oParent, iIndex, sListName);
        _End("MeGetIntByIndex", DEBUG_UTILITY);
        return result;
    }

    int count = GetLocalInt(oTarget, "IC:"+sListName);
    int iResult;

    if (iIndex >= count) {
        _End("MeGetIntByIndex", DEBUG_UTILITY);
        return 0;
    }

    iResult = GetLocalInt(oTarget, "IL:"+sListName+IntToString(iIndex));
    //_PrintString("Returning "+"IL:"+sListName+IntToString(iIndex)+" ("+IntToString(iResult)+").", DEBUG_UTILITY);
    _End("MeGetIntByIndex", DEBUG_UTILITY);
    return iResult;
}

int MeGetIntCount(object oTarget, string sListName = "")
{
    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        int result = MeGetIntCount(oParent, sListName);
        _End("MeGetIntCount", DEBUG_UTILITY);
        return result;
    }

    return GetLocalInt(oTarget, "IC:"+sListName);
}

float MeGetFloatByIndex(object oTarget, int iIndex = 0, string sListName = "")
{
    _Start("MeGetFloatByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "FC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_FL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        float result = MeGetFloatByIndex(oParent, iIndex, sListName);
        _End("MeGetFloatByIndex", DEBUG_UTILITY);
        return result;
    }

    int count = GetLocalInt(oTarget, "FC:"+sListName);
    float iResult;

    if (iIndex >= count) {
        _End("MeGetFloatByIndex", DEBUG_UTILITY);
        return 0.0;
    }

    iResult = GetLocalFloat(oTarget, "FL:"+sListName+IntToString(iIndex));
    //_PrintString("Returning "+"FL:"+sListName+IntToString(iIndex)+" ("+FloatToString(iResult)+").", DEBUG_UTILITY);
    _End("MeGetFloatByIndex", DEBUG_UTILITY);
    return iResult;
}

int MeGetFloatCount(object oTarget, string sListName = "")
{
    // Get the (possibly) inherited object that owns this list, redfine the variable's name, if remapped
    object oParent = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);
    if (oParent != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName != "") sListName = sMapName;

        int result = MeGetFloatCount(oParent, sListName);
        _End("MeGetFloatCount", DEBUG_UTILITY);
        return result;
    }

    return GetLocalInt(oTarget, "FC:"+sListName);
}

// ----- MeRemove* Functions ---------------------------------------------------

// When you remove an entry you get a local copy of the list that is modified.
// If the object is inheriting a large list the first time this function is
// called, it may take a while to copy all the values. (A while in terms of
// TMI measurement...)

void MeRemoveStringRef(object oTarget, string sValue, string sListName = "")
{
    _Start("MeRemoveStringRef", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyStringRef(oSource, oTarget, sMapName, sListName);
    }

    // Now let's remove the string ref
    int count, i;
    string sRef, sEndRef;
    count = GetLocalInt(oTarget, "SC:"+sListName);
    sEndRef = GetLocalString(oTarget, "SL:"+sListName+IntToString(count-1));

    for (i = 0; i < count; i++)
    {
        sRef = GetLocalString(oTarget, "SL:"+sListName+IntToString(i));
        if (sRef == sValue)
        {
            SetLocalString(oTarget, "SL:"+sListName+IntToString(i), sEndRef);
            count--;
            DeleteLocalString(oTarget, "SL:"+sListName+IntToString(count));
            break;
        }
    }
    SetLocalInt(oTarget, "SC:"+sListName, count);
    _End("MeRemoveStringRef", DEBUG_UTILITY);
}

void MeRemoveObjectRef(object oTarget, object oObject, string sListName = "")
{
    _Start("MeRemoveObjectRef target = '"+GetLocalString(oTarget,"Name")+"' object = '"+GetLocalString(oObject,"Name")+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

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
    _End("MeRemoveObjectRef", DEBUG_UTILITY);
}

void MeRemoveObjectByIndex(object oTarget, int iIndex, string sListName = "")
{
    _Start("MeRemoveObjectByIndex target = '"+GetLocalString(oTarget,"Name")+"' index = '"+IntToString(iIndex)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int    count;
    object endRef;

    count  = GetLocalInt(oTarget, "OC:"+sListName);
    if (iIndex >= count || iIndex < 0)
    {
        _End("MeRemoveObjectByIndex", DEBUG_UTILITY);
        return;
    }
    endRef = GetLocalObject(oTarget, "OL:"+sListName+IntToString(count-1));

    if ((iIndex < count) && (count > 0))
    {
        SetLocalObject(oTarget, "OL:"+sListName+IntToString(iIndex), endRef);
        DeleteLocalObject(oTarget, "OL:"+sListName+IntToString(count-1));
        count--;
        SetLocalInt(oTarget, "OC:"+sListName, count);
    }
    _End("MeRemoveObjectByIndex", DEBUG_UTILITY);
}

void MeRemoveStringByIndex(object oTarget, int iIndex, string sListName = "")
{
    _Start("MeRemoveStringByIndex target = '"+GetLocalString(oTarget,"Name")+"' index = '"+IntToString(iIndex)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyStringRef(oSource, oTarget, sMapName, sListName);
    }

    int    count;
    string endRef;

    count  = GetLocalInt(oTarget, "SC:"+sListName);
    if (iIndex >= count || iIndex < 0)
    {
        _End("MeRemoveStringByIndex", DEBUG_UTILITY);
        return;
    }
    endRef = GetLocalString(oTarget, "SL:"+sListName+IntToString(count-1));

    if ((iIndex < count) && (count > 0))
    {
        SetLocalString(oTarget, "SL:"+sListName+IntToString(iIndex), endRef);
        DeleteLocalString(oTarget, "SL:"+sListName+IntToString(count-1));
        SetLocalInt(oTarget, "SC:"+sListName, count-1);
    }

    _End("MeRemoveStringByIndex", DEBUG_UTILITY);
}

void MeRemoveIntRef(object oTarget, int iValue, string sListName = "")
{
    _Start("MeRemoveIntRef target = '"+GetLocalString(oTarget,"Name")+"' value = '"+IntToString(iValue)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyIntRef(oSource, oTarget, sMapName, sListName);
    }

    int count, i, endRef;
    int iRef;

    count = GetLocalInt(oTarget, "IC:"+sListName);
    endRef = GetLocalInt(oTarget, "IL:"+sListName+IntToString(count-1));

    for (i = 0; i < count; i++)
    {
        iRef = GetLocalInt(oTarget, "IL:"+sListName+IntToString(i));
        if (iRef == iValue)
        {
            SetLocalInt(oTarget, "IL:"+sListName+IntToString(i), endRef);
            count--;
            DeleteLocalInt(oTarget, "IL:"+sListName+IntToString(count));
            break;
        }
    }
    SetLocalInt(oTarget, "IC:"+sListName, count);
    _End("MeRemoveIntRef", DEBUG_UTILITY);
}

void MeRemoveIntByIndex(object oTarget, int iIndex, string sListName = "")
{
    _Start("MeRemoveIntByIndex target = '"+GetLocalString(oTarget,"Name")+"' index = '"+IntToString(iIndex)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyIntRef(oSource, oTarget, sMapName, sListName);
    }

    int count, endRef;

    count  = GetLocalInt(oTarget, "IC:"+sListName);
    if (iIndex >= count || iIndex < 0)
    {
        _End("MeRemoveIntByIndex", DEBUG_UTILITY);
        return;
    }
    endRef = GetLocalInt(oTarget, "IL:"+sListName+IntToString(count-1));

    if ((iIndex < count) && (count > 0))
    {
        SetLocalInt(oTarget, "IL:"+sListName+IntToString(iIndex), endRef);
        DeleteLocalInt(oTarget, "IL:"+sListName+IntToString(count-1));
        count--;
        SetLocalInt(oTarget, "IC:"+sListName, count);
    }

    _End("MeRemoveIntByIndex", DEBUG_UTILITY);
}

void MeRemoveFloatRef(object oTarget, float iValue, string sListName = "")
{
    _Start("MeRemoveFloatRef target = '"+GetLocalString(oTarget,"Name")+"' value = '"+FloatToString(iValue)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_FL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyFloatRef(oSource, oTarget, sMapName, sListName);
    }

    int count, i;
    float iRef, endRef;

    count = GetLocalInt(oTarget, "FC:"+sListName);
    endRef = GetLocalFloat(oTarget, "FL:"+sListName+IntToString(count-1));

    for (i = 0; i < count; i++)
    {
        iRef = GetLocalFloat(oTarget, "FL:"+sListName+IntToString(i));
        if (iRef == iValue)
        {
            SetLocalFloat(oTarget, "FL:"+sListName+IntToString(i), endRef);
            count--;
            DeleteLocalFloat(oTarget, "FL:"+sListName+IntToString(count));
            break;
        }
    }
    SetLocalInt(oTarget, "FC:"+sListName, count);
    _End("MeRemoveFloatRef", DEBUG_UTILITY);
}

void MeRemoveFloatByIndex(object oTarget, int iIndex, string sListName = "")
{
    _Start("MeRemoveFloatByIndex target = '"+GetLocalString(oTarget,"Name")+"' index = '"+IntToString(iIndex)+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_FL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyFloatRef(oSource, oTarget, sMapName, sListName);
    }

    int   count;
    float endRef;

    count  = GetLocalInt(oTarget, "FC:"+sListName);
    if (iIndex >= count || iIndex < 0)
    {
        _End("MeRemoveFloatByIndex", DEBUG_UTILITY);
        return;
    }
    endRef = GetLocalFloat(oTarget, "FL:"+sListName+IntToString(count-1));

    if ((iIndex < count) && (count > 0))
    {
        SetLocalFloat(oTarget, "FL:"+sListName+IntToString(iIndex), endRef);
        DeleteLocalFloat(oTarget, "FL:"+sListName+IntToString(count-1));
        count--;
        SetLocalInt(oTarget, "FC:"+sListName, count);
    }

    _End("MeRemoveFloatByIndex", DEBUG_UTILITY);
}

// ----- MeFind* Function ------------------------------------------------------

int MeFindStringRef(object oTarget, string sString, string sListName = "")
{
    if (sString == "") return -1;
    int i;
    _Start("MeFindStringRef target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "SC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    // If this has been redirected, check to see if this is called a different
    // name on the inherited object. (i.e. mapped)
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName == "") sMapName = sListName;
    }

    int count = GetLocalInt(oTarget, "SC:"+sListName);

    for(i=0; i<count; i++)
    {
        if (GetLocalString(oTarget, "SL:"+sListName+IntToString(i)) == sString)
        {
            _End();
            return i;
        }
    }

    return -1;

    _End();
}


// ----- MeSet* Functions ------------------------------------------------------

void MeSetStringByIndex(object oTarget, int iIndex, string sValue, string sListName = "")
{
    _Start("MeSetStringByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "SC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_SL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyStringRef(oSource, oTarget, sMapName, sListName);
    }

    int count = GetLocalInt(oTarget, "SC:"+sListName);

    if (iIndex > count) {
        //_PrintString("Error: out of bounds. Ignored", DEBUG_UTILITY);
        _End("MeSetStringByIndex", DEBUG_UTILITY);
        return;
    }

    if (iIndex == count) {
        MeAddStringRef(oTarget, sValue, sListName);
        _End("MeSetStringByIndex", DEBUG_UTILITY);
        return;
    }

    SetLocalString(oTarget, "SL:"+sListName+IntToString(iIndex), sValue);

    _End("MeSetStringByIndex", DEBUG_UTILITY);
}

void MeSetObjectByIndex(object oTarget, int iIndex, object oValue, string sListName = "")
{
    _Start("MeSetObjectByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "OC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_OL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyObjectRef(oSource, oTarget, sMapName, sListName);
    }

    int count = GetLocalInt(oTarget, "OC:"+sListName);

    if (iIndex > count) {
        //_PrintString("Error: out of bounds. Ignored", DEBUG_UTILITY);
        _End("MeSetObjectByIndex", DEBUG_UTILITY);
        return;
    }

    if (iIndex == count) {
        MeAddObjectRef(oTarget, oValue, sListName);
        _End("MeSetObjectByIndex", DEBUG_UTILITY);
        return;
    }

    SetLocalObject(oTarget, "OL:"+sListName+IntToString(iIndex), oValue);

    _End("MeSetObjectByIndex", DEBUG_UTILITY);
}


void MeSetIntByIndex(object oTarget, int iIndex, int iValue, string sListName = "")
{
    _Start("MeSetIntByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "IC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_IL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyIntRef(oSource, oTarget, sMapName, sListName);
    }

    int count = GetLocalInt(oTarget, "IC:"+sListName);

    if (iIndex > count) {
        //_PrintString("Error: out of bounds. Ignored", DEBUG_UTILITY);
        _End("MeSetIntByIndex", DEBUG_UTILITY);
        return;
    }

    if (iIndex == count) {
        MeAddIntRef(oTarget, iValue, sListName);
        _End("MeSetIntByIndex", DEBUG_UTILITY);
        return;
    }

    SetLocalInt(oTarget, "IL:"+sListName+IntToString(iIndex), iValue);

    _End("MeSetIntByIndex", DEBUG_UTILITY);
}

void MeSetFloatByIndex(object oTarget, int iIndex, float fValue, string sListName = "")
{
    _Start("MeSetFloatByIndex target = '"+GetLocalString(oTarget, "Name")+"' count = '"+IntToString(GetLocalInt(oTarget, "FC:"+sListName))+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);

    // If the list is provided elsewhere, let's copy that list here and then modify it
    if (oSource != oTarget)
    {
        string sMapName = GetLocalString(oTarget, "VMAP_FL:"+sListName);
        if (sMapName == "") sMapName = sListName;

        MeCopyFloatRef(oSource, oTarget, sMapName, sListName);
    }

    int count = GetLocalInt(oTarget, "FC:"+sListName);

    if (iIndex > count) {
        //_PrintString("Error: out of bounds. Ignored", DEBUG_UTILITY);
        _End("MeSetFloatByIndex", DEBUG_UTILITY);
        return;
    }

    if (iIndex == count) {
        MeAddFloatRef(oTarget, fValue, sListName);
        _End("MeSetFloatByIndex", DEBUG_UTILITY);
        return;
    }

    SetLocalFloat(oTarget, "FL:"+sListName+IntToString(iIndex), fValue);

    _End("MeSetFloatByIndex", DEBUG_UTILITY);
}

// ----- MeDelete* Functions ---------------------------------------------------

void MeDeleteIntRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0)
{
    _Start("MeDeleteIntRefs target = '"+GetLocalString(oTarget, "Name")+"' prefix = '"+sListName+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_IL:"+sListName);

    if (oSource == oTarget)
    {
        int count = GetLocalInt(oTarget, "IC:"+sListName);
        int i;

        for (i = 0; i < count; i++)
        {
            DeleteLocalInt(oTarget, "IL:"+sListName+IntToString(i));
        }

        DeleteLocalInt(oTarget, "IC:"+sListName);
    }
    else SetLocalObject(oTarget, "DECL_IL:"+sListName, oTarget);

    if (iDeleteDeclaration) DeleteLocalObject(oTarget, "DECL_IL:"+sListName);

    _End("MeDeleteIntRefs", DEBUG_UTILITY);
}


void MeDeleteStringRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0)
{
    _Start("MeDeleteStringRefs target = '"+GetLocalString(oTarget, "Name")+"' prefix = '"+sListName+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_SL:"+sListName);

    if (oSource == oTarget)
    {
        int count = GetLocalInt(oTarget, "SC:"+sListName);
        int i;

        for (i = 0; i < count; i++)
        {
            DeleteLocalString(oTarget, "SL:"+sListName+IntToString(i));
        }

        DeleteLocalInt(oTarget, "SC:"+sListName);
    }
    else SetLocalObject(oTarget, "DECL_SL:"+sListName, oTarget);

    if (iDeleteDeclaration) DeleteLocalObject(oTarget, "DECL_SL:"+sListName);


    _End("MeDeleteStringRefs", DEBUG_UTILITY);
}

void MeDeleteObjectRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0)
{
    _Start("MeDeleteObjectRefs target = '"+GetLocalString(oTarget, "Name")+"' prefix = '"+sListName+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    if (oSource == oTarget)
    {
        int count = GetLocalInt(oTarget, "OC:"+sListName);
        int i;

        for (i = 0; i < count; i++)
        {
            DeleteLocalObject(oTarget, "OL:"+sListName+IntToString(i));
        }

        DeleteLocalInt(oTarget, "OC:"+sListName);
    }
    else SetLocalObject(oTarget, "DECL_OL:"+sListName, oTarget);

    if (iDeleteDeclaration) DeleteLocalObject(oTarget, "DECL_OL:"+sListName);

    _End("MeDeleteObjectRefs", DEBUG_UTILITY);
}


void MeDeleteFloatRefs(object oTarget, string sListName = "", int iDeleteDeclaration = 0)
{

    _Start("MeDeleteFloatRefs target = '"+GetLocalString(oTarget, "Name")+"' prefix = '"+sListName+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    object oSource = _GetObjectOwner(oTarget, "DECL_FL:"+sListName);

    if (oSource == oTarget)
    {
        int count = GetLocalInt(oTarget, "FC:"+sListName);
        int i;

        for (i = 0; i < count; i++)
        {
            DeleteLocalString(oTarget, "FL:"+sListName+IntToString(i));
        }

        DeleteLocalInt(oTarget, "FC:"+sListName);
    }
    else SetLocalObject(oTarget, "DECL_FL:"+sListName, oTarget);

    if (iDeleteDeclaration) DeleteLocalObject(oTarget, "DECL_FL:"+sListName);


    _End("MeDeleteFloatRefs", DEBUG_UTILITY);
}

//-----------------------------------------------------------------------------

int MeHasObjectRef(object oTarget, object oObject, string sListName = "")
{
    _Start("MeHasObjectRef target = '"+GetLocalString(oTarget,"Name")+"' object = '"+GetLocalString(oObject,"Name")+"'", DEBUG_UTILITY);

    // Get the (possibly) inherited object that owns this list
    oTarget = _GetObjectOwner(oTarget, "DECL_OL:"+sListName);

    int count, i;
    object oRef, oEndRef;

    count = GetLocalInt(oTarget, "OC:"+sListName);
    oEndRef = GetLocalObject(oTarget, "OL:"+sListName+IntToString(count-1));

    //_PrintString("The object list has "+IntToString(count)+" items.", DEBUG_UTILITY);

    for (i = 0; i < count; i++)
    {
        oRef = GetLocalObject(oTarget, "OL:"+sListName+IntToString(i));
        if (oRef == oObject)
        {
            _End("MeHasObjectRef", DEBUG_UTILITY);
            return i;
        }
    }

    _End("MeHasObjectRef", DEBUG_UTILITY);
    return -1;
}
