//
// Switch is the note.
// RelatedPRI_1 is the player on the spree.
//
class KillingSpreeMessage extends CriticalEventPlus;

var	localized string EndSpreeNote, EndSelfSpree, EndFemaleSpree, MultiKillString;
var	localized string SpreeNote[10];
var	localized string SelfSpreeNote[10];
var	sound SpreeSound[10]; // OBSOLETE
var name SpreeSoundName[10];
var	localized string EndSpreeNoteTrailer;
 
static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	local Pawn ViewPawn;
	if ( RelatedPRI2 == None )
	{
		if ( LocalPlayer == RelatedPRI1 )
			return 2;
		if ( LocalPlayer.bOnlySpectator )
		{
			ViewPawn = Pawn(LocalPlayer.Level.GetLocalPlayerController().ViewTarget);
			if ( (ViewPawn != None) && (ViewPawn.PlayerReplicationInfo == RelatedPRI1) )
				return 2;
		}
	}
	return Default.FontSize;
}

static function string GetRelatedString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if ( RelatedPRI_2 == None )
		return Default.SelfSpreeNote[Switch];
		
    return static.GetString(Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_2 == None)
	{
		if (RelatedPRI_1 == None)
			return "";

		if (RelatedPRI_1.PlayerName != "")
			return RelatedPRI_1.PlayerName@Default.SpreeNote[Switch];
	} 
	else 
	{
		if (RelatedPRI_1 == None)
		{
			if (RelatedPRI_2.PlayerName != "")
			{
				if ( RelatedPRI_2.bIsFemale )
					return RelatedPRI_2.PlayerName@Default.EndFemaleSpree;
				else
					return RelatedPRI_2.PlayerName@Default.EndSelfSpree;
			}
		} 
		else 
		{
			return RelatedPRI_1.PlayerName$Default.EndSpreeNote@RelatedPRI_2.PlayerName@Default.EndSpreeNoteTrailer;
		}
	}
	return "";
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (RelatedPRI_2 != None)
		return;

	if ( (RelatedPRI_1 == P.PlayerReplicationInfo) 
		|| (P.PlayerReplicationInfo.bOnlySpectator && (Pawn(P.ViewTarget) != None) && (Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)) )
		P.PlayRewardAnnouncement(Default.SpreeSoundName[Switch],1,true);
	else
		P.PlayBeepSound();
}

defaultproperties
{
     EndSpreeNote="'s killing spree ended by"
     EndSelfSpree="was looking good till he killed himself!"
     EndFemaleSpree="was looking good till she killed herself!"
     SpreeNote(0)="is on a killing spree!"
     SpreeNote(1)="is on a rampage!"
     SpreeNote(2)="is dominating!"
     SpreeNote(3)="is unstoppable!"
     SpreeNote(4)="is Godlike!"
     SpreeNote(5)="is Wicked SICK!"
     SelfSpreeNote(0)="Killing Spree!"
     SelfSpreeNote(1)="Rampage!"
     SelfSpreeNote(2)="Dominating!"
     SelfSpreeNote(3)="Unstoppable!"
     SelfSpreeNote(4)="GODLIKE!"
     SelfSpreeNote(5)="WICKED SICK!"
     SpreeSoundName(0)="Killing_Spree"
     SpreeSoundName(1)="Rampage"
     SpreeSoundName(2)="Dominating"
     SpreeSoundName(3)="Unstoppable"
     SpreeSoundName(4)="GodLike"
     SpreeSoundName(5)="WhickedSick"
     FontSize=0
}
