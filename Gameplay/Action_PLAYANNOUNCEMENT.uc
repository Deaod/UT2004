class ACTION_PlayAnnouncement extends ScriptedAction;

var(Action)		sound	Sound;
var				bool	bSoundsPrecached;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController	P;
	local name				SoundName;

	if ( C.Level.NetMode == NM_StandAlone )
		SoundName = LastMinuteHack_ShipIt( C );
	else
		SoundName = Sound.Name;

	//log("ACTION_PlayAnnouncement Sound:" @ Sound @ "SoundName:" @ SoundName @ "Title:" @ C.Level.Title @ "Tag:" @ C.Tag @ "C.MyScript.Tag:" @ C.MyScript.Tag );

	ForEach C.DynamicActors(class'PlayerController', P)
		P.QueueAnnouncement( SoundName, 1, AP_Normal);

	return false;	
}

/* beautiful... */
function Name LastMinuteHack_ShipIt( ScriptedController C )
{
	local PlayerController	LocalPlayer;
	local name				SoundName;

	LocalPlayer = C.Level.GetLocalPlayerController();
	if ( Sound != None )
		SoundName = Sound.Name;

	// MotherShip Hack for Spanish translation (viva Madrid!)
	if ( Sound == None && C.Tag == 'Play_Intro3' && C.MyScript.Tag == 'Hack_RIP_Epic_MegaCar' )
		SoundName = 'MotherShip_intro';
	else if ( C.MyScript.Tag == 'Hack_I_Love_Mina' )
	{
		if ( C.Tag == 'Play_Brief4' && LocalPlayer.StatusAnnouncer.GetSound('Junkyard_brief4a') != None )
			SoundName = 'Junkyard_brief4a';
		else if ( Sound == None )
		{
			if ( C.Tag == 'Play_Brief5' )
				SoundName = 'Junkyard_brief5a';
			else if ( C.Tag == 'Play_Brief6' )
				SoundName = 'Junkyard_brief6a';
			else if ( C.Tag == 'Play_Brief7' )
				SoundName = 'Junkyard_brief7a';		
		}
	}

	return SoundName;
}

function string GetActionString()
{
	return ActionString@Sound;
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if ( !bRewardSounds && !bSoundsPrecached )
	{
		bSoundsPrecached = true;
		if ( Sound != None )
			V.PrecacheSound(Sound.Name);
	}
}

defaultproperties
{
     ActionString="play announcement"
}
