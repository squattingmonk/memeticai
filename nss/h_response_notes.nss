/*

How to handle problems.

The Memetic Toolkit allows your NPC to react to their environment in a number
of unique ways, each with their own strengths and weaknesses. This document
will summarize the ways an NPC might recognize a problem and how a developer
can cause their NPC to react appropriately.

1. Generators

Bioware's NWN engine notifies NPCs of external situations via callbacks.
These notify your NPC when they are:

    * spawned (i.e. created)
    * attacked, finished with a single combat round
    * spoken to
    * see or hear an NPC or player
    * targetted by a spell
    * damaged
    * blocked by a creature or door
    * killed
    * resting

The Memetic Toolkit allows you to create "generators" to respond to these
situations. A generator is just a script function that is called whenever
one of these situations occur. An NPC can add or remove a generator and can
temporarily stop them from activating when the Bioware callback is activated.

*Bioware only allows one script to be attached to a callback. The Memetic
Toolkit allows you to have multiple scripts by adding generators. For example
conventionally if your NPC gets attacked Bioware only calls one script. Now
when your NPC gets attacked more than one OnAttacked script can be called.

Conventionally these generators are added to the NPC when an NPC joins a
"Memetic Class" or is spawned. A class, in the Memetic sense, represents a
behavior trait for your NPC. The job of a class is to configure or specialize
your NPC by adding memetic objects (like a generator) or setting commonly-known
variables to effect how they behave.

One of the drawbacks of with generators is that every generator runs when
the callback happens. For example, let's pretend you have an NPC that belongs to
"Friendly PC Greeter" and "Unfriendly PC Greeter" classes. Both add a generator
to the OnPerception callback, causing the NPC to say something friendly
and unpleasant. Because of the nature of generators both of their scripts run.

So how do we prevent the NPC from saying "Hi!" and "Get lost!" in succession?
One approach is the have the generators each make a "meme". A meme is an object
that represents one possible course of action -- it's an action object. Each
meme has a priority and only the highest priority meme is allowed to go.
Additionally, you can also request that a meme *not* be made unless it's the
highest priority.

To avoid the double greeting each generator can attempt to create the meme
at its preferred priority. The highest priority greeting wins; if the NPC
is busy with something more important neither of the greetings occur.

Of course this leads us to another to-be-solved problem: what priority
are these friendly/unfriendly greeting memes? At the moment it's up to the
programmer is pick the priority, arbitrarily. They can have a priority of low,
medium, high, or even very high. Perhaps more importantly, you can assign a
modifier to those levels, from 0 to 100. The priority of a meme plus its
modifier dictates which meme is executed.

Eventually the priority/modifier of the memes will probably be dictacted by the relevance
of the class that owns the generator. Think of it like this: if I am friendly
towards people, but I hate you, my hate-of-you may be a dominant trait causing
me to wave my body parts in your general direction. As a member of these
potentially contradicting classes I resolve my conflict by weighing my options
according to my behavioral preference.

To implement this in the Memetic Toolkit, we need to add a few things:

First, when an meme is created, we need to know what class caused this meme
creation. It's possible that a generator (made by a class) created this meme.
It's also possible that a meme - made by a genererator - makes another meme.
The result is the same: the final meme is still a result of membership of the
class.

Next, we need to have a convienence function that tells us the modifier
that we should apply to our meme, given a class. This function would look
at the order of the NPC class and derive a number from 0 to 100. If your NPC
belongs to "generic, fighter, townsfolk, barmaid". Your tendency to fight is
significantly lower than your tendency to calm down the bar brawl in your
"special barmaid way". Fighter memes might be +10; barmaid memes +40.

Unfortunately, this approach suffers from a number of problems. While the
class-influenced priority is very useful, the process of responding to a
callback is extremely inefficient: every generator executes. More importantly,
it's impossible for a dominant trait to lose to a recessive trait. This is
unrealistic - frequently variation from "base behaviors" is essential, or
logical. We'll address other approaches to this problem further on.

2. Signals vs. Messages

So previously we learned that Bioware has a fixed number of callbacks that
tells your NPC about the external world. But what happens when you need to
be notified about something other than these standard situations? What happens
when you want to tell your NPC that his best friend died, or that the Inn is
on fire?

Bioware does this through a "user defined event" -- it's actually just a
standard callback that sends you an integer.

*/
