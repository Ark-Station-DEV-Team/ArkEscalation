/obj/item/device/whistle
	name = "\improper whistle"
	desc = "A metal pea-whistle. Can be blown while held, or worn in the mouth"
	icon = 'icons/obj/coldwar/items.dmi'
	icon_state = "whistle"
	var/wearable = 1
	slot_flags = SLOT_EARS
	w_class = ITEM_SIZE_TINY

	var/volume = 60
	var/spamcheck = 0

/obj/item/device/whistle/attack_self(mob/user as mob)
	whistle_playsound(user)
	add_fingerprint(user)
	return

/obj/item/device/whistle/attack_hand(mob/user)
	if(user.wear_mask == src)
		whistle_playsound(user)
	else
		..()

/obj/item/device/whistle/proc/whistle_playsound(mob/user as mob)
	if (spamcheck)
		return

	user.visible_message("<span class='warning'>[user] blows into [src]!</span>")
	playsound(get_turf(src), 'sound/items/whistle.ogg', volume, 1, vary = 0)

	spamcheck = 1
	spawn(30)
		spamcheck = 0


/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = ITEM_SIZE_TINY
	flags = CONDUCT

	var/use_message = "Halt! Security!"
	var/spamcheck = 0
	var/insults

/obj/item/device/hailer/verb/set_message()
	set name = "Set Hailer Message"
	set category = "Object"
	set desc = "Alter the message shouted by your hailer."

	if(!isnull(insults))
		to_chat(usr, "The hailer is fried. The tiny input screen just shows a waving ASCII penis.")
		return

	var/new_message = input(usr, "Please enter new message (leave blank to reset).") as text
	if(!new_message || new_message == "")
		use_message = "Halt! Security!"
	else
		use_message = capitalize(copytext_char(sanitize(new_message), 1, MAX_MESSAGE_LEN))

	to_chat(usr, "You configure the hailer to shout \"[use_message]\".")
/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if (spamcheck)
		return

	if(isnull(insults))
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
		user.audible_message("<span class='warning'>[user]'s [name] rasps, \"[use_message]\"</span>", null, "<span class='warning'>\The [user] holds up \the [name].</span>")
	else
		if(insults > 0)
			playsound(get_turf(src), 'sound/voice/binsult.ogg', 100, 1, vary = 0)
			// Yes, it used to show the transcription of the sound clip. That was a) inaccurate b) immature as shit.
			user.audible_message("<span class='warning'>[user]'s [name] gurgles something indecipherable and deeply offensive.</span>", null, "<span class='warning'>\The [user] holds up \the [name].</span>")
			insults--
		else
			to_chat(user, "<span class='danger'>*BZZZZZZZZT*</span>")

	spamcheck = 1
	spawn(20)
		spamcheck = 0

/obj/item/device/hailer/emag_act(var/remaining_charges, var/mob/user)
	if(isnull(insults))
		to_chat(user, "<span class='danger'>You overload \the [src]'s voice synthesizer.</span>")
		insults = rand(1, 3)//to prevent dickflooding
		return 1
	else
		to_chat(user, "The hailer is fried. You can't even fit the sequencer into the input slot.")
