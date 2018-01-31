/*
    Class Ancestry

    When a table is assigned to a response, you may be setting the table for
    a class or for an NPC override.

    SetTable(object target, string situation, string table, string class="*");

    CLASS_SELF -- this is a string that represents the class that is most
    responsible for making memes at any given moment. For example



1. Memetic Global Variables

If you have done any programming with Bioware's NWScript language, you should
be familiar with the global OBJECT_SELF. This is a variable that represents
the creature or placeable that is running the current script. For example, a
script attached to a door when it is opens will be able to automatically
close the door or cause visual effects by referring to OBJECT_SELF.

When the script is fist executed, Bioware's interpreter sets up the
global variable as a convienence. The Memetic Toolkit follows this pattern,
creating several new global variables: MEME_SELF, and NPC_SELF.

1.1 MEME_SELF

All memetic objects - generators, memes, events, and classes - have a real
in-game object. This is done to allow each object to hold local data that
can be efficiently destroyed without effecting the other objects.

When you are writing a script for a memetic object you can access this object
via MEME_SELF. For example, a meme, like i_dance_around, might have parameters
on MEME_SELF that determine the type of dance, the center point for the dance,
and how long the NPC should dance for. From within the script, the data
can be accessed by calling GetLocalInt(MEME_SELF, "Dance Duration");

It's important to remember that MEME_SELF changes to point to the current
memetic object that is executing, while OBJECT_SELF is the actual creature.
As a result MEME_SELF will be an event object when a message is received, a
generator object when a callback fires, a meme object when a meme is started,
interrupted or completes; and a finally a class object when an NPC becomes
an instance of a class. MEME_SELF can only be accessed from within a
memetic script. It is useless in a generic script, like a trigger script
or module callback.

When the MEME_SELF object is destroyed, the data that you stored on it is also
destroyed.

1.2 NPC_SELF

The next memetic object represents your NPC and all the data shared by
his combination of classes. Each memetic NPC gets a hidden NPC_SELF object.
This is designed to allow you to destroy your NPC's model and reattach them
to a previously constructued NPC_SELF.

This global variable is frequently used to hold persistant private data.
Additionally, it inherits variables from each class the NPC belongs to.
This means that if your NPC is a member of a fighter class and a barmaid
class, variables set to MEME_SELF within the class script will be accessible
by calling MeGetLocalInt(NPC_SELF, "Greeting"); This is very useful if you
want a number of NPCs to share data.

In short, NPC_SELF inherits variables from each of your classes, using
multiple inheritance. Collisions are handled by the order in which your
class is added.

1.3 OBJECT_SELF

Ok, so let's revisit Bioware's self global, given what we know about the other
two memetic global variables. When should a memetic developer write variables on
OBJECT_SELF? What variables belong on there? Does it inherit variables? Do other
things inherit variables from OBJECT_SELF?

Well, let's just recap that inheritance stuff just to make sure you know what
we're talking about...

The Memetic Toolkit allows you chain objects and their variables together in an
"inheritance" relationship. This means that you can say object A inherits
variables from object B. When you call the memetic function MeGetLocalInt(...)
it will look to see if A has a the variable you are asking for - if not, it
will look on B. This can be quite neat because it means that people can set
variables on A without knowing about B -- and B can access those variables
without copying them.

So one of the common things to do is have memetic object inherit variables
from OBJECT_SELF. Builders can set some well-known variables on the NPC
without having to know anything about memes. The memes can bind common
names to the public names. Imagine a meme looking for a "speed" variable,
but failing to find one, it looks for a "Default Player Speed" variable
that may be inherited from OBJECT_SELF.



Task todo list:

    0. MeRegisterClass() now stores the MEME_ActiveClass and doesn't
    store the redundant MEME_ClassName -- it also has MEME_Name. (DONE)

    1. MeInstanceOf() should be changed to take a class bias.
    If the class to be an instance of is a list, each entry in the
    list increases the bias by 1 point. Note that colliding biases are
    allowed. The bias is stored on NPC_SELF as MEME_<Classname>_Bias. (DONE)

    2. In CreateEvent() get the MEME_ActiveClass from MEME_SELF and apply it
    to the new event object. (DONE)

    3. In CreateMeme() get the MEME_ActiveClass from MEME_SELF and apply it
    to the new meme object. Get the bias from the NPC_SELF with the given
    class name. Apply this bias to the priority if it exists. (DONE)

    4. In CreateSequence(), CreateSequenceMeme(), do the same. (DONE)

    5. In CreateGenerator() get the MEME_ActiveClass from MEME_SELF and
    apply it to the generator. (DONE)

    6. MeSetActiveTable(), MeGetActiveTable() this handles caching the
    state table on the local meme or NPC_SELF. This requires the situation,
    the table and the class.

    7. In the response table store the state, remember which item the and
    class was being processed. This allows a response table to resume.
    For each class set the MEME_ActiveClass of MEME_SELF to the class.
    When done, revert it back.

Use Cases

    1. Class creates a generator. Let's make sure that MEME_SELF represents
    the individual class object. Make sure that the class object has a variable
    called MEME_ActiveClass that matches this class name.

*/

