# Makefile for Memetic AI Toolkit
# Author: Marty Shannon (a.k.a. Olias of Sunhillow); 2004/05/29.

# Note: in order to make use of this makefile, you must obtain & install libnw
#	(from sourceforge.net/projects/openknights), NWNTools (a.k.a. Torlack's
#	compiler; from the same place), and Nwn2Xml (from
#	sourceforge.net/projects/Leto).  The resulting executables must be in
#	your $PATH, as well.

# the libnw tools that care expect the game directory name in environment
#	variable NWN_GAME_DIR.	we use that value here to tell nwnnsscomp
#	where it is.  if you don't have it in your environment already,
#	you should specify it here.
#NWN_GAME_DIR=

# these are the output compiled scripts
SCROBJ=cb_area_enter.ncs cb_area_exit.ncs cb_attacked.ncs cb_blocked.ncs \
	cb_combatend.ncs cb_conversation.ncs cb_damaged.ncs cb_death.ncs \
	cb_disturbed.ncs cb_heartbeat.ncs cb_item_drop.ncs cb_item_equip.ncs \
	cb_item_get.ncs cb_item_unequip.ncs cb_item_use.ncs cb_lever_used.ncs \
	cb_mod_onload.ncs cb_ondoor.ncs cb_perception.ncs cb_poi_enter.ncs \
	cb_poi_exit.ncs cb_poi_hbt.ncs cb_rested.ncs cb_spawn.ncs \
	cb_spellcast.ncs cb_talk_abort.ncs cb_talk_end.ncs cb_trigger_click.ncs \
	cb_trigger_enter.ncs cb_trigger_exit.ncs cb_trigger_hbeat.ncs \
	cb_trigger_udef.ncs cb_userdefined.ncs \
	lib_animation.ncs lib_avoidlight.ncs lib_bartender.ncs lib_combat_f.ncs \
	lib_combat.ncs lib_converse.ncs lib_death.ncs lib_debug.ncs lib_door.ncs \
	lib_examples.ncs lib_generic.ncs lib_group.ncs lib_landmark2.ncs \
	lib_landmark.ncs lib_memes.ncs lib_movement.ncs lib_observer.ncs \
	lib_skillcheck.ncs \
	s_archer.ncs s_areawalker.ncs s_bear.ncs s_boy.ncs s_cleric.ncs \
	s_debug.ncs s_fighter.ncs s_generic.ncs s_guide.ncs s_mage.ncs \
	s_mbartender.ncs s_mcommoner.ncs s_moment.ncs s_rat.ncs

# these are the input scripts
SCRSRC=cb_area_enter.nss cb_area_exit.nss cb_attacked.nss cb_blocked.nss \
	cb_combatend.nss cb_conversation.nss cb_damaged.nss cb_death.nss \
	cb_disturbed.nss cb_heartbeat.nss cb_item_drop.nss cb_item_equip.nss \
	cb_item_get.nss cb_item_unequip.nss cb_item_use.nss cb_lever_used.nss \
	cb_mod_onload.nss cb_ondoor.nss cb_perception.nss cb_poi_enter.nss \
	cb_poi_exit.nss cb_poi_hbt.nss cb_rested.nss cb_spawn.nss \
	cb_spellcast.nss cb_talk_abort.nss cb_talk_end.nss cb_trigger_click.nss \
	cb_trigger_enter.nss cb_trigger_exit.nss cb_trigger_hbeat.nss \
	cb_trigger_udef.nss cb_userdefined.nss \
	h_ai.nss h_class.nss h_constants.nss h_debug.nss h_event.nss \
	h_globals_notes.nss h_group.nss h_item.nss h_landmark_cli.nss \
	h_landmark_com.nss h_landmark_init.nss h_library.nss h_list.nss \
	h_poi.nss h_private.nss h_response_notes.nss h_response.nss \
	h_setweapons.nss h_time.nss h_util_combat.nss h_util.nss \
	lib_animation.nss lib_avoidlight.nss lib_combat_f.nss lib_combat.nss \
	lib_converse.nss lib_death.nss lib_debug.nss lib_door.nss \
	lib_examples.nss lib_generic.nss lib_group.nss lib_landmark2.nss \
	lib_landmark.nss lib_memes.nss lib_movement.nss lib_observer.nss \
	lib_skillcheck.nss \
	s_archer.nss s_areawalker.nss s_bear.nss s_boy.nss s_cleric.nss \
	s_debug.nss s_fighter.nss s_generic.nss s_guide.nss s_mage.nss \
	s_moment.nss s_rat.nss \
	sc_false.nss \
	todo.nss variable_notes.nss

ARESRC=magic_memetic_ar.xml
AREOBJ=magic_memetic_ar.are

GICSRC=magic_memetic_gc.xml
GICOBJ=magic_memetic_ar.gic

GITSRC=magic_memetic_gt.xml
GITOBJ=magic_memetic_ar.git

UTISRC=magic_memetic_ba.xml
UTIOBJ=magic_memetic_ba.uti

UTMSRC=magic_memetic_st.xml
UTMOBJ=magic_memetic_st.utm

UTPSRC=poi_observation.xml
UTPOBJ=poi_observation.utp

UTWSRC=magic_memetic_wp.xml
UTWOBJ=magic_memetic_wp.utw

# Olias's bartender stuff
SCROBJ+=lib_bartender.ncs s_mbartender.ncs s_mcommoner.ncs

# Olias's bartender stuff
SCRSRC+=h_fifo.nss lib_bartender.nss s_mbartender.nss s_mcommoner.nss

# for convenience, all the non-script binary resources
RESOBJ=$(AREOBJ) $(GICOBJ) $(GITOBJ) $(UTIOBJ) $(UTMOBJ) $(UTPOBJ) $(UTWOBJ)

# we want to build everything, but only the sources go into the ERF (because
# nwnnsscomp does produce slightly different code than the toolkit compiler).
all:	$(SCROBJ) ../erf/MemeticAI.erf

# this erf is what we will import into a module
../erf/MemeticAI.erf:	$(SCRSRC) $(RESOBJ)
	nwaggext -c -t e $@ $(SCRSRC) $(RESOBJ)

# make doesn't know about these suffixes by default, so we must tell it
# about them here.
.SUFFIXES: .nss .ncs .erf .xml .gff .are .gic .git .uti .utm .utp .utw

# for this makefile, I consider compiling a file that is only intended to be
# an #include file to be an error.  the 2nd line of this rule takes care
# of that.  the 3rd line simply deletes the debugging output.
.nss.ncs:
	nwnnsscomp -c $(NWN_GAME_DIR) `basename $< .nss`
	@if [ ! -r `basename $< .nss`.ncs ];then exit 1;fi
	@rm -f `basename $< .nss`.ndb

# here are generic rules for the non-script components of the MT master ERF

.xml.are:
	xml2gff --log:3 $< $@

.xml.gff:
	xml2gff --log:3 $< $@

.xml.gic:
	xml2gff --log:3 $< $@

.xml.git:
	xml2gff --log:3 $< $@

.xml.uti:
	xml2gff --log:3 $< $@

.xml.utm:
	xml2gff --log:3 $< $@

.xml.utp:
	xml2gff --log:3 $< $@

.xml.utw:
	xml2gff --log:3 $< $@

# note that we play games with file names here, so explicit rules must be
# included here as well as the dependencies
magic_memetic_ar.are:	magic_memetic_ar.xml
	xml2gff --log:3 $< $@

magic_memetic_ar.gic:	magic_memetic_gc.xml
	xml2gff --log:3 $< $@

magic_memetic_ar.git:	magic_memetic_gt.xml
	xml2gff --log:3 $< $@

tags:	$(SCRSRC)
	ctags -h .ncs --language-force=c++ $(SCRSRC)

clean:
	rm -f *.ncs *.ndb $(RESOBJ)

clobber:	clean
	rm -f ../erf/MemeticAI.erf tags

# these dependencies are generated manually.  I expect to build a script to
# do this automagically one of these days.
cb_area_enter.ncs:	h_event.nss
cb_area_exit.ncs:	h_event.nss
cb_attacked.ncs:	h_ai.nss
cb_blocked.ncs:	h_ai.nss
cb_combatend.ncs:	h_ai.nss
cb_conversation.ncs:	h_ai.nss
cb_damaged.ncs: 	h_ai.nss
cb_death.ncs:	h_ai.nss
cb_disturbed.ncs: 	h_ai.nss
cb_heartbeat.ncs:	h_ai.nss
cb_item_drop.ncs:	h_ai.nss
cb_item_equip.ncs:	h_ai.nss
cb_item_get.ncs:	h_ai.nss
cb_item_unequip.ncs:	h_ai.nss
cb_item_use.ncs:	h_ai.nss
cb_lever_used.ncs:	h_ai.nss h_poi.nss
cb_mod_onload.ncs:	h_ai.nss h_landmark_init.nss
cb_perception.ncs:	h_ai.nss
cb_poi_enter.ncs:	h_ai.nss
cb_poi_exit.ncs:	h_ai.nss
cb_poi_hbt.ncs:	h_ai.nss
cb_rested.ncs: 	h_ai.nss
cb_spawn.ncs:	h_ai.nss
cb_spellcast.ncs:	h_ai.nss
cb_talk_abort.ncs:	h_ai.nss
cb_talk_end.ncs:	h_ai.nss
cb_trigger_click.ncs:	h_ai.nss
cb_trigger_enter.ncs:	h_ai.nss
cb_trigger_exit.ncs:	h_ai.nss
cb_trigger_hbeat.ncs:	h_ai.nss
cb_trigger_udef.ncs:	h_ai.nss
cb_userdefined.ncs: 	h_ai.nss
h_ai.nss:	h_time.nss h_landmark_cli.nss h_event.nss h_response.nss
h_class.nss:	h_util.nss
h_event.nss:	h_debug.nss h_class.nss h_util.nss h_constants.nss h_time.nss
h_group.nss:	h_library.nss #from NWN: x0_i0_position.nss
h_landmark_cli.nss:	h_landmark_com.nss
h_landmark_com.nss:	h_util.nss
h_landmark_init.nss:	h_landmark_com.nss
h_library.nss:	h_ai.nss
h_list.nss:	h_debug.nss
h_poi.nss:	h_util.nss h_class.nss
h_private.nss:	h_debug.nss h_list.nss
h_response.nss:	h_util.nss h_class.nss
h_util_combat.nss:	h_debug.nss h_ai.nss
h_util.nss:	h_list.nss h_private.nss h_debug.nss h_constants.nss
lib_animation.ncs:	h_util.nss h_library.nss
lib_avoidlight.ncs:	h_library.nss h_ai.nss h_event.nss
lib_combat_f.ncs:	h_library.nss h_util_combat.nss
lib_combat.ncs:	h_library.nss h_util_combat.nss h_response.nss
lib_converse.ncs:	h_library.nss #from NWN: x0_i0_anims.nss
lib_death.ncs:	h_library.nss
lib_debug.ncs:	h_library.nss h_ai.nss h_response.nss
lib_door.ncs:	h_library.nss
lib_examples.ncs:	h_library.nss h_response.nss h_library.nss
lib_generic.ncs:	h_util.nss h_library.nss h_response.nss
lib_group.ncs:	h_library.nss h_group.nss #from NWN: x0_i0_position.nss
lib_landmark2.ncs:	h_library.nss h_landmark_cli.nss
lib_landmark.ncs:	h_library.nss h_landmark_cli.nss
lib_memes.ncs:	h_library.nss
lib_movement.ncs:	h_library.nss
lib_observer.ncs:	h_library.nss
lib_skillcheck.ncs:	h_library.nss
s_archer.ncs:	h_ai.nss
s_areawalker.ncs:	h_ai.nss
s_bear.ncs:	h_ai.nss
s_boy.ncs:	h_ai.nss h_poi.nss
s_cleric.ncs:	h_ai.nss
s_debug.ncs:	h_ai.nss h_response.nss
s_fighter.ncs:	h_ai.nss
s_generic.ncs:	h_ai.nss
s_guide.ncs:	h_ai.nss
s_mage.ncs:	h_ai.nss
s_moment.ncs:	h_ai.nss h_poi.nss
s_rat.ncs:	h_ai.nss
magic_memetic_ba.uti:	magic_memetic_ba.xml
magic_memetic_st.utm:	magic_memetic_st.xml
poi_observation.utp:	poi_observation.xml
magic_memetic_wp.utw:	magic_memetic_wp.xml

# Olias's bartender stuff
lib_bartender.ncs:	h_library.nss h_fifo.nss
s_mbartender.ncs:	h_ai.nss
s_mcommoner.ncs:	h_ai.nss

# Olias's stuff; comment out for official MT
#cb_close.ncs:	h_ai.nss
#cb_lock.ncs:	h_ai.nss
#cb_open.ncs:	h_ai.nss
#cb_unlock.ncs:	h_ai.nss
#cb_used.ncs:	h_ai.nss
