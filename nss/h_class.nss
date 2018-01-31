#include "h_util"

/* File: h_class - Class
 * Author: William Bull, Daryl Low, Lucllo
 * Date: Copyright April, 2003
 *
 * Description
 *
 * These are the class functions which will be added to h_util.
 * This provides the ability to define a class and an instance.
 * When an object is declared an instance of a class, the class
 * constructor is run.
 *
 */

// MeGetActiveClass
// File: h_class
//
// This tries to determine the class that is causing the current code to run.
// If this function is called within a meme it will return the class object
// that caused this meme to be created. This is especially useful when you
// want to get variables directly from that class, bypassing any possible
// inheritance overrides.
//
// If there is no active class, OBJECT_SELF is returned.
object MeGetActiveClass();

// MeDeclareResponseTable
// File: h_class
//
// This explicitly defines response table variables so that it may be inherited
// automatically, destroyed or eventually saved to a database.
//
// This is generally used inside of a class constructor (_ini)
// Once a variable is declared on a class, all instances will share these variables.
// If this is used on an object that is an instance of a class, then this
// function will use its local, overriding value, shadowing the inherited value.
void MeDeclareResponseTable(string sTable, object oTarget = OBJECT_INVALID);

// MeDeclareInt
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// These functions are generally used inside of a class constructor (_ini)
// Once a variable is declared on a class, all instances will share these variables.
//
// If this is used on an object that is an instance of a class, then this
// function will use its local, overriding value, shadowing the inherited value.
//
// Undeclaring is not supported at this time.
//
//    sName:  The name of the variable.
//  oTarget:  The object which owns the variable. If the object is invalid, the
//            function will try and use the global MEME_SELF. This global is
//            defined inside of the class constructor _ini. It is generally
//            assumed that the object is either a class or an instance that
//            wants to override an inherited value.
//    flags:  These control how the variable is used. At this time, these flags
//            are exclusive, or'ing ( A | B ) will not make sense.
//
//            VAR_INHERIT       This variable should be inherited by its children.
//            VAR_INHERIT_COPY  This variable should be copied to the instances,
//                              but not shared. The variable will be automatically
//                              declared on the instance.
//
void MeDeclareInt(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareIntRef
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareIntRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareFloat
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareFloat(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareFloatRef
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareFloatRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareString
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareString(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareStringRef
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareStringRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareObject
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareObject(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareObjectRef
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareObjectRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareLocation
// File: h_class
//
// Explicitly defines a variable so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// For the full documentation, refer to MeDeclareInt.
void MeDeclareLocation(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/);

// MeDeclareLocalMessage
// File: h_class
//
// Explicitly defines a message so that it may be inherited, automatically
// destroyed or eventually saved to a database.
//
// This function is generally used inside of a class constructor (_ini)
// Once a variable is declared on a class, all instances will share these variables.
//
// If this is used on an object that is an instance of a class, then this
// function will cause the object to use its local, overriding value, shadowing
// the inherited value.
void MeDeclareLocalMessage(string sMessageName, object oTarget = OBJECT_INVALID);

// MeGetConfString
// File: h_list
//
// Get Configuration String
// Get a string from an object and as a convience - get the value from the
// module if the string starts with an @ symbol. This allows NPC's to share
// strings and lists of strings by storing the actual value on the module
// and storing the name of module-variable on the NPC.
//
// If the index is passed, a space and a number is appended to the string.
//
// For example, you may have tables of names of areas, or spoken-strings that
// you want many NPC's to use. Instead of copying them onto every NPC you can
// add them, using the GUI toolset, to the module, once.
//
// If this function detects the @ symbol on the first item of a list, it will
// assume the rest of value is the name of the string shared on the module.
//
// NPC variables may be named things like: "Enemy Greeting 1"
// Additionally, users may set these variables on the module, and tell these
// functions to go look there for the values. For example:
//
// On the module: "MyVariable 1" = "Hello"
//                "MyVariable 2" = "Hi There!"
//                "MyVariable 3" = "Wow!"
//
// On the NPC:    "Friendly Greeting 1" = "@MyVariable"
//                "Friendly Greeting 2" = "ignored"
//                "Friendly Greeting 3" = "ignored"
//                 ...
//
// MeGetConfString("MT: Friendly Greeting", 2) returns "Hi There!".
// Notice that the final space and number are not part of the name.
//
string MeGetConfString(object oTarget, string sName, int iIndex=0);

// MeInheritFrom
// File: h_class
//
// This causes the target object to inherit the variables declared by a parent.
// If the parent inherits, or is an instace of a class,
// the target does NOT inherit these variables -- only the ones explicitly
// declared on the parent with the MeDeclare*().
//
// oTarget: the object that wants to relegate control of some of it undeclared
//          variables. (i.e. the child.)
// oParent: the object that has declared variables to be inherited
//          (i.e. the parent.)
void   MeInheritFrom(object oTarget, object oParent);

// MeInstanceOf
// File: h_class
//
// This causes the target object to inherit the variables of the class
// that was created with a call to MeRegisterClass(). A class instanciation script
// <classname>+_go will be executed. In this script, the global, MEME_SELF
// will be oTarget.
//
// This is used to allow a general class of objects to be constructed.
// The class's _go script is used to setup the instance's declared variables,
// default local values. If the target is a creature (or NPC_SELF) the class
// would use the _go script as an opportunity to add generators and event
// handlers on the NPC.
//
// The toolkit supports multiple inheritance. But to conserve memory, it is
// highly recommended that you call this function on an object, once, with
// a single comma-delimited list of class names. The system will merge the
// inheritance declaration tables into one efficient table for the combination
// of classes. For example, I you call f(a), f(b), f(c), f(d) you will have
// created the tables: a, b, c, d, ab, abc, abcd. The tables ab and abc would
// be unnecessary.
//
//  oTarget: the object that wants to be an instance of the given class(es).
//   sClass: the name or list of names of classes.
//           "vermin, sorcerer,child_of_dark"
//           "base,pickle"
//    iBias: this is an amount that is added to the modifier parameter of any
//           calls to MeCreateMeme by any objects created by this class. If you
//           list a number of classes, this bias increases for each class entry
//           you list, one point at a time.
//           For example, if you call MeInstanceOf(oSelf, "baker", 5);
//           Then all memes created by the baker class or memes created by
//           objects that the baker class made, will have +5 added to their
//           modifiers. If you call MeInstanceOf(oSelf, "generic, fighter");
//           Then generic's memes get +0 and fighter's memes get +1.
//           Memes can be created with MEME_NOBIAS to avoid this modifier.
void   MeInstanceOf(object oTarget, string sClass, int iBias=0);

// MeGetClassByIndex
// File: h_class
// An object that is an instance of a class has a number of objects that
// it is associated to. This function gets the class object.
//
// This is not a function most people need to know about or use.
//
//  iIndex: Since an object can belong to more than one class, this is an
//          index representing which class name you want. This is a 0-based
//          index.
// oObject: the NPC this is an instance of a class.
object MeGetClassByIndex(int iIndex = 0, object oObject = OBJECT_SELF);

// MeGetClassCount
// File: h_class
// Returns the number of classes this NPC belongs to.
//
// oObject: the NPC this is an instance of a class.
int MeGetClassCount(object oObject = OBJECT_SELF);

// MeGetClassObject
// File: h_class
// Class objects are related to a set of objects that are an "instance" of a
// class -- see MeInstanceOf() for more detail on this process.
// These "class objects" hold variables that are shared amongst the instances
// of the class when they are created. It is possible to adjust values on a
// class object and automatically impact all memebers of the class.
//
// Note: This is not a function most people need to know about or use.
//       Additionally, the class object is not created until the first instance
//       of the class is made.
//
//  sClassName: This is the name of the class that you are looking for, like
//              "generic" or "fighter" or "bartender".
//
object MeGetClassObject(string sClassName);

// ---- INHERITED VARIABLE ACCESS FUNCTIONS-------------------------------------

// MeSetLocalInt
// File: h_class
// This sets an integer variable on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalInt(object oObject, string sVarName, int nValue);

// MeSetLocalFloat
// File: h_class
// This sets a float variable on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalFloat(object oObject, string sVarName, float fValue);

// MeSetLocalString
// File: h_class
// This sets a string variable on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalString(object oObject, string sVarName, string sValue);

// MeSetLocalObject
// File: h_class
// This sets an object variable on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalObject(object oObject, string sVarName, object oValue);

// MeSetLocalLocation
// File: h_class
// This sets a location variable on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalLocation(object oObject, string sVarName, location lValue);

// MeSetLocalMessage
// File: h_class
// This sets a memetic message on an object. If the object inherits data from another
// object, or from a class, the value is stored locally, overriding the source of the inheritance.
void MeSetLocalMessage(object oTarget, string sMessageName, struct message sMessage);

// MeGetLocalInt
// File: h_class
// This gets an integer variable from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
int      MeGetLocalInt(object oObject, string sVarName);

// MeGetLocalFloat
// File: h_class
// This gets a float variable from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
float    MeGetLocalFloat(object oObject, string sVarName);

// MeGetLocalString
// File: h_class
// This gets an string variable from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
string   MeGetLocalString(object oObject, string sVarName);

// MeGetLocalObject
// File: h_class
// This gets an object variable from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
object   MeGetLocalObject(object oObject, string sVarName);

// MeGetLocalLocation
// File: h_class
// This gets a location variable from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
location MeGetLocalLocation(object oObject, string sVarName);

// MeGetLocalMessage
// File: h_class
// This gets a memetic message from an object with a given name. If the object inherits
// data from another object or is an instance of a class, this function will get
// the value from source of the inheritance. Of course, if the value has been
// changed on this object, the overidden value is retrieved, instead.
struct message MeGetLocalMessage(object oTarget, string sMessageName);

// MeDeleteLocalMessage
// File: h_class
// This deletes the memetic message datastructure from an object. It doesn't
// have anything to do with classes or inheritance. It just removes the
// variable like a call to DeleteLocalInt or DeleteLocalString.
void MeDeleteLocalMessage(object oTarget, string sMessageName);

// ---- INHERITED VARIABLE ACCESS FUNCTIONS-------------------------------------

// MeMapInt
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapInt(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapIntRef
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapIntRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapFloat
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapFloat(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapFloatRef
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapFloatRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapString
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapString(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapStringRef
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapStringRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapObject
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapObject(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapObjectRef
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapObjectRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// MeMapLocation
// File: h_class
// This causes  a variable on one object to be retrieved on another object with
// a different name. This is used so that meme/generator/event writers can
// talk about a local variable like "Flag" that may actually be on the NPC
// with a name like "MT: Do XYZ".
//
// This assumes that the object has MeInheritsFrom() called. To get the value
// you must use MeGetLocal*() not the Bioware GetLocal*().
void MeMapLocation(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID);

// ---- DECLARATION IMPLEMENTATION ---------------------------------------------

// Variable declarations tables look like: DECL_<type>:<varname> where type is:
// I: Int,      IF: Int Flags,      IL: Int List,      ILF: Int List Flags
// O: Object,   OF: Object Flags,   OL: Object List,   OLF: Object List Flags
// S: String,   SF: String Flags,   SL: String List,   SLF: String List Flags
// F: Float,    FF: Float Flags,    FL: Float List,    FLF: Float List Flags
// L: Location, LF: Location Flags, LL: Location List, LLF: Location List Flags

void MeDeclareInt(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    // This is the index to the declaration table, it's used to support
    // multiple inheritance. This table will be merged with other tables.
    // Since Bioware doesn't support intraspection, this also allows us to track
    // the variables we have on the object.
    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_I*:");
    // This is the declaration table, used to find the owner
    SetLocalObject(oTarget, "DECL_I:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_IF:"+sName, flags);
}

void MeDeclareIntRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    // This is the index to the declaration table, it's used to support
    // multiple inheritance. This table will be merged with other tables.
    // Since Bioware doesn't support intraspection, this also allows us to track
    // the variables we have on the object.
    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_IL*:");
    // This is the declaration table, used to find the owner
    SetLocalObject(oTarget, "DECL_IL:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_ILF:"+sName, flags);
}

void MeDeclareFloat(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_F*:");
    SetLocalObject(oTarget, "DECL_F:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_FF:"+sName, flags);
}

void MeDeclareFloatRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_FL*:");
    SetLocalObject(oTarget, "DECL_FL:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_FLF:"+sName, flags);
}

void MeDeclareString(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_S*:");
    SetLocalObject(oTarget, "DECL_S:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_SF:"+sName, flags);
}

void MeDeclareStringRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_SL*:");
    SetLocalObject(oTarget, "DECL_SL:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_SLF:"+sName, flags);
}

void MeDeclareObject(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_O*:");
    SetLocalObject(oTarget, "DECL_O:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_OF:"+sName, flags);
}

void MeDeclareObjectRef(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_OL*");
    SetLocalObject(oTarget, "DECL_OL:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_OLF:"+sName, flags);
}

void MeDeclareLocation(string sName, object oTarget = OBJECT_INVALID, int flags = 0x01 /*VAR_INHERIT*/)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    if (flags & VAR_INHERIT) MeAddStringRef(oTarget, sName, "DECL_L*");
    SetLocalObject(oTarget, "DECL_L:"+sName, oTarget);
    SetLocalInt(oTarget, "DECL_LF:"+sName, flags);
}

void MeDeclareResponseTable(string sTable, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    // Declare start table
    string sFullTable = RESPONSE_START+sTable;
    MeDeclareStringRef(sFullTable, oTarget);

    // Declare end table
    sFullTable = RESPONSE_END+sTable;
    MeDeclareStringRef(sFullTable, oTarget);

    // Declare high priority response band
    sFullTable = RESPONSE_HIGH+sTable;
    MeDeclareStringRef(sFullTable, oTarget);
    MeDeclareIntRef(sFullTable,oTarget);

    // Declare medium priority response band
    sFullTable = RESPONSE_MEDIUM+sTable;
    MeDeclareStringRef(sFullTable, oTarget);
    MeDeclareIntRef(sFullTable,oTarget);

    // Declare low priority response band
    sFullTable = RESPONSE_LOW+sTable;
    MeDeclareStringRef(sFullTable, oTarget);
    MeDeclareIntRef(sFullTable,oTarget);
}

void MeDeclareLocalMessage(string sMessageName, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    MeDeclareString  ("MEME_Msg_"+sMessageName, oTarget);
    MeDeclareInt     ("MEME_Msg_"+sMessageName, oTarget);
    MeDeclareFloat   ("MEME_Msg_"+sMessageName, oTarget);
    MeDeclareLocation("MEME_Msg_"+sMessageName, oTarget);
    MeDeclareObject  ("MEME_Msg_"+sMessageName, oTarget);

    MeDeclareString  ("MEME_Msg_"+sMessageName, oTarget);
    MeDeclareString  ("MEME_Msg_"+sMessageName, oTarget);

    MeDeclareObject  ("MEME_MsgSnd_"+sMessageName, oTarget);
    MeDeclareObject  ("MEME_MsgRcv_"+sMessageName, oTarget);
}

// ---- MAPPING IMPLEMENTATION -------------------------------------------------

void MeMapInt(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_I:"+sLocalVar, sInheritedVar);
}

void MeMapIntRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_IL:"+sLocalVar, sInheritedVar);
}

void MeMapFloat(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_F:"+sLocalVar, sInheritedVar);
}

void MeMapFloatRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_FL:"+sLocalVar, sInheritedVar);
}

void MeMapString(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_S:"+sLocalVar, sInheritedVar);
}

void MeMapStringRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_SL:"+sLocalVar, sInheritedVar);
}

void MeMapObject(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_O:"+sLocalVar, sInheritedVar);
}

void MeMapObjectRef(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_OL:"+sLocalVar, sInheritedVar);
}

void MeMapLocation(string sLocalVar, string sInheritedVar, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = MEME_SELF;
    if (oTarget == OBJECT_INVALID) oTarget = OBJECT_SELF;

    SetLocalString(oTarget, "VMAP_L:"+sLocalVar, sInheritedVar);
}

// ---- GET INHERITED IMPLEMENTATION -------------------------------------------

// Variable declarations tables look like: DECL_<type>:<varname> where type is:
// F: Float,    FF: Float Flags,    FL: Float List,    FLF: Float List Flags     F*: Float Declation Table     FL*: Float List Declaration Table
// O: Object,   OF: Object Flags,   OL: Object List,   OLF: Object List Flags    O*: Object Declation Table    OL*: Object List Declaration Table
// I: Int,      IF: Int Flags,      IL: Int List,      ILF: Int List Flags       I*: Int Declation Table       IL*: Int List Declaration Table
// L: Location, LF: Location Flags, LL: Location List, LLF: Location List Flags  L*: Location Declation Table  LL*: Location List Declaration Table
// S: String,   SF: String Flags,   SL: String List,   SLF: String List Flags    S*: String Declation Table    SL*: String List Declaration Table

int MeGetLocalInt(object oObject, string sVarName)
{
    // 1. There will be a declaration entry if:
    //    * oObject is a class or merged class - merge class entries point to the owner class - order is dependent to solve collisions from multiple inheritance.
    //    * oObject is an instance with an overriding variable
    object oDeclarationTarget = GetLocalObject(oObject, "DECL_I:"+sVarName);
    string sMapName;
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        return GetLocalInt(oDeclarationTarget, sVarName);
    }
    // 2. There will be a parent if:
    //    * This is a class that inherits a value from another class
    //    * This is an object which directly inherits from another object
    object oParent = GetLocalObject(oObject, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        // 2a. Is the variable name remapped to a new name on the parent object?
        sMapName = GetLocalString(oObject, "VMAP_I:"+sVarName);
        if (sMapName != "") sVarName = sMapName;

        // Now this is expensive - but rarely occurs. I tried to avoid
        // walking a inheritance tree, wherever possible.
        return MeGetLocalInt(oParent, sVarName);
    }
    // 3. Otherwise just return the usual value.
    return GetLocalInt(oObject, sVarName);
}

float MeGetLocalFloat(object oObject, string sVarName)
{
    string sMapName;
    object oDeclarationTarget = GetLocalObject(oObject, "DECL_F:"+sVarName);
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        return GetLocalFloat(oDeclarationTarget, sVarName);
    }
    object oParent = GetLocalObject(oObject, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oObject, "VMAP_F:"+sVarName);
        if (sMapName != "") sVarName = sMapName;

        return MeGetLocalFloat(oParent, sVarName);
    }
    return GetLocalFloat(oObject, sVarName);
}

string MeGetLocalString(object oObject, string sVarName)
{
    string sMapName;
    object oDeclarationTarget = GetLocalObject(oObject, "DECL_S:"+sVarName);
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        return GetLocalString(oDeclarationTarget, sVarName);
    }
    object oParent = GetLocalObject(oObject, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oObject, "VMAP_S:"+sVarName);
        if (sMapName != "") sVarName = sMapName;

        return MeGetLocalString(oParent, sVarName);
    }
    return GetLocalString(oObject, sVarName);
}

location MeGetLocalLocation(object oObject, string sVarName)
{
    string sMapName;
    object oDeclarationTarget = GetLocalObject(oObject, "DECL_L:"+sVarName);
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        return GetLocalLocation(oDeclarationTarget, sVarName);
    }
    object oParent = GetLocalObject(oObject, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oObject, "VMAP_L:"+sVarName);
        if (sMapName != "") sVarName = sMapName;

        return MeGetLocalLocation(oParent, sVarName);
    }
    return GetLocalLocation(oObject, sVarName);
}

object MeGetLocalObject(object oObject, string sVarName)
{
    string sMapName;
    object oDeclarationTarget = GetLocalObject(oObject, "DECL_O:"+sVarName);
    if (oDeclarationTarget != OBJECT_INVALID)
    {
        return GetLocalObject(oDeclarationTarget, sVarName);
    }
    object oParent = GetLocalObject(oObject, "MEME_Parent");
    if (oParent != OBJECT_INVALID)
    {
        sMapName = GetLocalString(oObject, "VMAP_O:"+sVarName);
        if (sMapName != "") sVarName = sMapName;

        return MeGetLocalObject(oParent, sVarName);
    }
    return GetLocalObject(oObject, sVarName);
}

// Note: inheritance not supported.
struct message MeGetLocalMessage(object oTarget, string sMessageName)
{
    struct message sMessage;
    sMessage.sData = MeGetLocalString  (oTarget, "MEME_Msg_"+sMessageName);
    sMessage.iData = MeGetLocalInt     (oTarget, "MEME_Msg_"+sMessageName);
    sMessage.fData = MeGetLocalFloat   (oTarget, "MEME_Msg_"+sMessageName);
    sMessage.lData = MeGetLocalLocation(oTarget, "MEME_Msg_"+sMessageName);
    sMessage.oData = MeGetLocalObject  (oTarget, "MEME_Msg_"+sMessageName);
    sMessage.sChannelName = MeGetLocalString  (oTarget, "MEME_MsgCh_"+sMessageName);
    sMessage.sMessageName = MeGetLocalString  (oTarget, "MEME_MsgNm_"+sMessageName);
    sMessage.oSender = MeGetLocalObject  (oTarget, "MEME_MsgSnd_"+sMessageName);
    sMessage.oTarget = MeGetLocalObject  (oTarget, "MEME_MsgRcv_"+sMessageName);
    return sMessage;
}

void MeSetLocalInt(object oTarget, string sVarName, int nValue)
{
    // Only bother with a delcaration entry if there is inheritance.
    if (GetLocalObject(oTarget, "MEME_Parent") != OBJECT_INVALID)
    {
        SetLocalObject(oTarget, "DECL_I:"+sVarName, oTarget);
    }
    SetLocalInt(oTarget, sVarName, nValue);
}

void MeSetLocalFloat(object oTarget, string sVarName, float fValue)
{
    // Only bother with a delcaration entry if there is inheritance.
    if (GetLocalObject(oTarget, "MEME_Parent") != OBJECT_INVALID)
    {
        SetLocalObject(oTarget, "DECL_F:"+sVarName, oTarget);
    }
    SetLocalFloat(oTarget, sVarName, fValue);
}

void MeSetLocalString(object oTarget, string sVarName, string sValue)
{
    // Only bother with a delcaration entry if there is inheritance.
    if (GetLocalObject(oTarget, "MEME_Parent") != OBJECT_INVALID)
    {
        SetLocalObject(oTarget, "DECL_S:"+sVarName, oTarget);
    }
    SetLocalString(oTarget, sVarName, sValue);
}

void MeSetLocalObject(object oTarget, string sVarName, object oValue)
{
    // Only bother with a delcaration entry if there is inheritance.
    if (GetLocalObject(oTarget, "MEME_Parent") != OBJECT_INVALID)
    {
        SetLocalObject(oTarget, "DECL_O:"+sVarName, oTarget);
    }
    SetLocalObject(oTarget, sVarName, oValue);
}

void MeSetLocalLocation(object oTarget, string sVarName, location lValue)
{
    // Only bother with a delcaration entry if there is inheritance.
    if (GetLocalObject(oTarget, "MEME_Parent") != OBJECT_INVALID)
    {
        SetLocalObject(oTarget, "DECL_L:"+sVarName, oTarget);
    }
    SetLocalLocation(oTarget, sVarName, lValue);

}

// Note: inheritance not supported.
void MeSetLocalMessage(object oTarget, string sMessageName, struct message sMessage)
{
    // First we store the five data fields, MEME_Msg_ is a prefix to avoid colliding
    // with other user variables or other data.
    MeSetLocalString  (oTarget, "MEME_Msg_"+sMessageName, sMessage.sData);
    MeSetLocalInt     (oTarget, "MEME_Msg_"+sMessageName, sMessage.iData);
    MeSetLocalFloat   (oTarget, "MEME_Msg_"+sMessageName, sMessage.fData);
    MeSetLocalLocation(oTarget, "MEME_Msg_"+sMessageName, sMessage.lData);
    MeSetLocalObject  (oTarget, "MEME_Msg_"+sMessageName, sMessage.oData);

    // Next we store the message routing information. Although these fields
    // are read only, I use this function internally and use these values.
    MeSetLocalString  (oTarget, "MEME_MsgCh_"+sMessageName, sMessage.sChannelName);
    MeSetLocalString  (oTarget, "MEME_MsgNm_"+sMessageName, sMessage.sMessageName);

    // Finally we store the transient ownership object references
    MeSetLocalObject  (oTarget, "MEME_MsgSnd_"+sMessageName, sMessage.oSender);
    MeSetLocalObject  (oTarget, "MEME_MsgRcv_"+sMessageName, sMessage.oTarget);
}

// Note: inheritance not supported.
void MeDeleteLocalMessage(object oTarget, string sMessageName)
{
    DeleteLocalString  (oTarget, "MEME_Msg_"+sMessageName);
    DeleteLocalInt     (oTarget, "MEME_Msg_"+sMessageName);
    DeleteLocalFloat   (oTarget, "MEME_Msg_"+sMessageName);
    DeleteLocalLocation(oTarget, "MEME_Msg_"+sMessageName);
    DeleteLocalObject  (oTarget, "MEME_Msg_"+sMessageName);
    DeleteLocalString  (oTarget, "MEME_MsgCh_"+sMessageName);
    DeleteLocalString  (oTarget, "MEME_MsgNm_"+sMessageName);
    DeleteLocalObject  (oTarget, "MEME_MsgSnd_"+sMessageName);
    DeleteLocalObject  (oTarget, "MEME_MsgRcv_"+sMessageName);
}

//-----------------------------------------------------------------------------

object MeGetActiveClass()
{
    object oTarget =  MeGetClassObject(GetLocalString(MEME_SELF, "MEME_ActiveClass"));
    if (oTarget == OBJECT_INVALID) return OBJECT_SELF;
    else return oTarget;
}

// For example:
// For example: MeGetConfString(OBJECT_SELF, "Home Areas", 1);
//   if Home Areas 1 is @Commoner Area

string MeGetConfString(object oTarget, string sName, int iIndex=0)
{
    string sSuffix  = "";
    string sSuffix2 = "";

    // Add the suffix like " 1" ... " 19".
    if (iIndex > 0)
    {
        // We check the first item in the list for the @ symbol
        sSuffix = " 1";
        sSuffix2 = " "+IntToString(iIndex);
    }
    string sName2 = sName+sSuffix;

    string sString = MeGetLocalString(oTarget, sName2);
    if (GetStringLeft(sString, 1) == "@")
    {
        oTarget = GetModule();
        sName = GetStringRight(sString, GetStringLength(sString) - 1);
    }

    return GetLocalString(oTarget, sName+sSuffix2);
}

//------------------------------------------------------------------------------

object MeGetClassByIndex(int iIndex = 0, object oObject = OBJECT_SELF)
{
    oObject = MeGetNPCSelf(oObject);

    if (!GetIsObjectValid(oObject)) return OBJECT_INVALID;

    string sClassName = MeGetStringByIndex(oObject, iIndex, "MEME_Parents");
    return GetLocalObject(GetModule(), "MEME_Class_"+sClassName);
}

int MeGetClassCount(object oObject = OBJECT_SELF)
{
    oObject = MeGetNPCSelf(oObject);
    return MeGetObjectCount(GetModule(), "MEME_Parents");
}

object MeGetClassObject(string sClassName)
{
    return GetLocalObject(GetModule(), "MEME_Class_"+sClassName);
}

//------------------------------------------------------------------------------

// Create the relationship between child and parent
void MeInheritFrom(object oTarget, object oParentClass)
{
    _Start("MeInheritFrom", DEBUG_UTILITY);

    // Detach ourselves from any old classes - we do not track parents
    // when MeInheritFrom is used. It's an anonymous inheritance.
    MeDeleteStringRefs(oTarget, "MEME_Parents");
    // Overwrite any old inheritance
    SetLocalObject(oTarget, "MEME_Parent", oParentClass);

    _End("MeInheritFrom", DEBUG_UTILITY);
}

//------------------------------------------------------------------------------


// This is an internal function used by MeInstanceOf. Its job is to
// go to each variable in the given declaration table type and
// extract the variable name and have the new class mirror the class
// table.
void _CopyDeclTable(object oClass, object oNewClass, string sType)
{
    _Start("_CopyDeclTable", DEBUG_UTILITY);
    int count;
    string sDecl = sType+"*:"; // I think this is right.
    sType = sType+":";
    string sVar;
    object oOwner;
    count = MeGetStringCount(oClass, sDecl);
    //_PrintString("count = MeGetStringCount(object:"+_GetName(oClass)+", string:"+sDecl+") == "+IntToString(count));

    for (0; count > 0; count--)
    {
        sVar = MeGetStringByIndex(oClass, count-1, sDecl);
        //_PrintString("MeGetStringByIndex(object:"+_GetName(oClass)+", int:"+IntToString(count-1)+", string:"+sDecl+") == "+sVar);
        oOwner = GetLocalObject(oClass, sType+sVar);
        //_PrintString("oOwner = GetLocalObject(object:"+_GetName(oClass)+", "+sType+sVar+" == object:"+_GetName(oOwner));
        SetLocalObject(oNewClass, sType+sVar, oOwner);
        //_PrintString("SetLocalObject(object:"+_GetName(oNewClass)+", string:"+sType+sVar+", object:"+_GetName(oOwner)+");");
    }
    _End("_CopyDeclTable", DEBUG_UTILITY);
}

// Create an instance of a given class, me must support:
//
// MeInstanceOf(oTarget, "class_base");
// MeInstanceOf(oTarget, "pickle, earplug");  and then...
// MeInstanceOf(oTarget, "xyzzy,schnatchzy-poo,BLEEM!!,vorgon poetry,thing-your-aunt-gave-you, ");
//
// oTarget may be a class or a non-class.
void MeInstanceOf(object oTarget, string sClass, int iBias=0)
{
    _Start("MeInstanceOf", DEBUG_UTILITY);

    // 1. First we want to build a list of the requested classes
    MeExplodeList(oTarget, sClass, "MEME_NewParents");

    // 2. Next we remove the classes we already belong to
    int count = MeGetStringCount(oTarget, "MEME_Parents");
    int count2 = MeGetStringCount(oTarget, "MEME_NewParents");
    int count3;
    string sName, sNewName;
    object oModule = GetModule();

    _Start("PruneList", DEBUG_UTILITY);
    // Iterate through the short, new list.
    for (; count2 > 0; count2--)
    {
        // Get the name of the new class
        sNewName = MeGetStringByIndex(oTarget, count2-1, "MEME_NewParents");
        // Iterate through the potentailly longer old list.
        for (count3 = count; count3 > 0; count3--)
        {
            // Get the name of one of the current classes.
            sName = MeGetStringByIndex(oTarget, count3-1, "MEME_Parents");
            // Do we already have it? if so, remove it from the new list
            if (sName == sNewName)
            {
                //_PrintString("Removing duplicate class entry, "+sNewName+".", DEBUG_UTILITY);
                MeRemoveStringByIndex(oTarget, count2-1, "MEME_NewParents");
            }
        }
    } // Now, we have removed all the classes that we already belong to, NewParents may be substantially shorter.

    // 3. Then we remove the classes that don't exist
    // (Incidently, the reason why I always count downwards is it allows me to
    //  delete the entry. If I was going up I would have to shrink the count,
    //  which is a hassle.)
    for (count = MeGetStringCount(oTarget, "MEME_NewParents"); count > 0; count--)
    {
        sNewName = MeGetStringByIndex(oTarget, count-1, "MEME_NewParents");
        if (GetLocalObject(oModule, "MEME_Class_"+sNewName) == OBJECT_INVALID)
        {
            //_PrintString("I have never head of class, "+sNewName+".", DEBUG_UTILITY);
            //_PrintString("Did you forget to initialize a class library?", DEBUG_UTILITY);
            MeRemoveStringByIndex(oTarget, count-1, "MEME_NewParents");
        }
    } // Now we have a shorter list of new classes to be added

    _End("PruneList", DEBUG_UTILITY);

    count = MeGetStringCount(oTarget, "MEME_NewParents");
    if (count == 0)
    {
        MeDeleteStringRefs(oTarget, "MEME_NewParents");
        //_PrintString("Warning: This declaration has failed, I cannot find any classes you are requesting.");
        _End("MeInstanceOf", DEBUG_UTILITY);
        return;
    }


    // 4. Add these items to the Parents list
    _Start("MergeList", DEBUG_UTILITY);
    count = MeGetStringCount(oTarget, "MEME_NewParents");
    //_PrintString("There are "+IntToString(count)+" new classes being added.", DEBUG_UTILITY);
    for (0; count > 0; count--)
    {
        sNewName = MeGetStringByIndex(oTarget, count-1, "MEME_NewParents");
        //_PrintString("Adding "+sNewName+".", DEBUG_UTILITY);
        MeAddStringRef(oTarget, sNewName, "MEME_Parents");
    }
    count = MeGetStringCount(oTarget, "MEME_Parents");
    //_PrintString("This object now belongs to "+IntToString(count)+" classes.", DEBUG_UTILITY);

    // 5. Get the class key of the current Parent
    object oParent = GetLocalObject(oTarget, "MEME_Parent");
    string sKey = GetLocalString(oParent, "MEME_ClassKey");
    string sFullName = GetLocalString(oParent, "Name");

    // 6. Merge it with each of the new class keys
    string sNewKey;
    for (count = MeGetStringCount(oTarget, "MEME_NewParents"); count > 0; count--)
    {
        sNewName = MeGetStringByIndex(oTarget, count-1, "MEME_NewParents");
        sFullName += "/"+sNewName;
        sNewKey  = GetLocalString(oModule, "MEME_ClassKey_"+sNewName);
        sKey     = _MeKeyCombine(sNewKey, sKey);


        SetLocalInt(NPC_SELF, "MEME_"+sNewName+"_Bias", iBias++);
    }
    _End("MergeList", DEBUG_UTILITY);

    // 7. Does this new class key exist? Is this a newly discovered class combination? A new breed of NPC? Could it be??
    object oNewClass = GetLocalObject(oModule, "MEME_ClassKey_"+sKey);
    object oClass, oOwner;

    if (oNewClass == OBJECT_INVALID)
    {
        _Start("NewClass", DEBUG_UTILITY);
        //_PrintString("I've never seen this combination of classes, let's set you up.", DEBUG_UTILITY);
        // 8. Create the new merged class
        object oMemeMagicWP = GetObjectByTag("Magic_Memetic_WP");

        oNewClass = CreateObject(OBJECT_TYPE_STORE, "Magic_Memetic_Store", GetLocation(oMemeMagicWP));

        if (!GetIsObjectValid(oNewClass))
        {
            _PrintString("Error: Failed to create class object represeting merged class combination.", DEBUG_UTILITY);
        }
        SetLocalString(oNewClass, "Name", sFullName);

        // (There is no _ini to call, this is a combined class.)
        // (There are no names to be stored, only key referencing.)
        SetLocalString(oNewClass, "MEME_ClassKey", sNewKey);
        SetLocalObject(oModule, "MEME_ClassKey_"+sNewKey, oNewClass);

        // 9. Copy the declaration tables from each class, in order
        //    Now honestly, this is a potential area for TMI, this may need to be
        //    split out into asynchronous copy chunks. I would just separate this
        //    whole block into a function and call DelayCommand(0.0, x(a,b,c));
        count = MeGetStringCount(oTarget, "MEME_Parents");
        //_PrintString("This object now belongs to "+IntToString(count)+" classes.", DEBUG_UTILITY);
        for (0; count > 0; count--)
        {
            sName = MeGetStringByIndex(oTarget, count-1, "MEME_Parents");
            oClass = GetLocalObject(oModule, "MEME_Class_"+sName);
            //_PrintString("Merging the declaration tables from class "+sName+".", DEBUG_UTILITY);

            // Each class may have declared variables of nine types, we
            // must transfer those definitions to the merged class.
            // This process is done once to be able to efficiently look up
            // owners of variables with a nearly-direct access lookup -
            // O(1) vs. O(n) order of complexity when calling MeGet*().
            _Start("CopyAllDeclTables", DEBUG_UTILITY);

            _CopyDeclTable(oClass, oNewClass, "DECL_F");
            _CopyDeclTable(oClass, oNewClass, "DECL_FL");
            _CopyDeclTable(oClass, oNewClass, "DECL_O");
            _CopyDeclTable(oClass, oNewClass, "DECL_OL");
            _CopyDeclTable(oClass, oNewClass, "DECL_I");
            _CopyDeclTable(oClass, oNewClass, "DECL_IL");
            _CopyDeclTable(oClass, oNewClass, "DECL_L");
            //_CopyDeclTable(oClass, oNewClass, "DECL_L"); // Lists of locations are not supported yet
            _CopyDeclTable(oClass, oNewClass, "DECL_S");
            _CopyDeclTable(oClass, oNewClass, "DECL_SL");

            _End("CopyAllDeclTables", DEBUG_UTILITY);

            // Conceivably here is where we would also assess the flags to
            // optionally copy the value instead of inheriting the value.
        }
        _End("NewClass", DEBUG_UTILITY);
    }
    else
    {
        //_PrintString("Oh, I know what class this is." , DEBUG_UTILITY);
    }

    // 10. Set the Parent to be the new merged class object
    _Start("ConnectToNewClass", DEBUG_UTILITY);
    SetLocalObject(oTarget, "MEME_Parent", oNewClass);
    if (!GetIsObjectValid(oNewClass))
    {
        //_PrintString("Error: Failed to create class object represeting merged class combination.", DEBUG_UTILITY);
    }
    //_PrintString("Now that I know about this class, I'll set your MEME_Parent to it. ("+_GetName(oTarget)+"->"+_GetName(oNewClass)+")", DEBUG_UTILITY);

    // 11. For each new class, MeExecuteScript() name_go
    count = MeGetStringCount(oTarget, "MEME_NewParents");
    //_PrintString("There are "+IntToString(count)+" classes to instantiate.", DEBUG_UTILITY);

    for (0; count > 0; count--)
    {
        sNewName = MeGetStringByIndex(oTarget, count-1, "MEME_NewParents"); // Direct access for efficiency
        oNewClass = GetLocalObject(oModule, "MEME_Class_"+sNewName);
        DelayCommand(0.0, MeExecuteScript("c_"+sNewName,"_go", OBJECT_SELF, oNewClass));
    }

    // 12. Clean up that new parent list.
    MeDeleteStringRefs(oTarget, "MEME_NewParents");
    _End("ConnectToNewClass", DEBUG_UTILITY);

    _End("MeInstanceOf", DEBUG_UTILITY);
}

/*  I support two forms of variable inheritance. This distinction is made to
 *  reduce memory consumption and increase the flexibility of the code.
 *
 *  First, an object may inherit variables from a named, shared, "class object".
 *  It will inherit all the variables on the class and the variables it inherits.
 *
 *  Alternatively, an object may inherit values from a "parent" non-class object.
 *  But this will only inherit the variables the parent has explicitly declared.
 *  If the parent inherits variables from another object, these will not be inherited.
 *
 *  Any object can have declared variables.
 *  Any object can inherit variables from parent objects.
 *  A class is an invisible object that is globally accessible by name.
 *  A class copies all the variable declarations
 *  An object inherits all the variables a class inherits -- but only a class.
 */


/*
 Class Variables
 ---------------
 1) Module Object

    int    MEME_KeyCount
    object MEME_CLASS_+<classname>

 2) Class (Parent) Objects

    string MEME_ActiveClass
    string MEME_ClassKey

 3) Inheriting (Child) Objects

    string  MEME_ActiveClass
    object  MEME_Parent

 4) Objects with Declared Variables

 5) NPC_SELF

    int MEME_+<class>+_Bias
*/
