//
// A Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the DamageType Class.
//

class xDeathMessage extends LocalMessage
	config(user);

var(Message) localized string KilledString, SomeoneString;
var config bool bNoConsoleDeathMessages;

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return class'HUD'.Default.GreenColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local string KillerName, VictimName;

	if (Class<DamageType>(OptionalObject) == None)
		return "";

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.PlayerName;

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName, 
			VictimName,
			Class<DamageType>(OptionalObject).Static.SuicideMessage(RelatedPRI_2) );
	}

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.PlayerName;

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName, 
		VictimName,
		Class<DamageType>(OptionalObject).Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
	{
		if ( !Default.bNoConsoleDeathMessages )
			Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		return;
	}
	if ( (RelatedPRI_1 == P.PlayerReplicationInfo) 
		|| (P.PlayerReplicationInfo.bOnlySpectator && (Pawn(P.ViewTarget) != None) && (Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)) )
	{
		// Interdict and send the child message instead.
		P.myHUD.LocalizedMessage( Default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		if ( !Default.bNoConsoleDeathMessages )
			P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

        // check multikills
        if ( P.Role == ROLE_Authority )
        {
			// multikills checked already in LogMultiKills()
			if ( UnrealPlayer(P).MultiKillLevel > 0 )
				P.ReceiveLocalizedMessage( class'MultiKillMessage', UnrealPlayer(P).MultiKillLevel );
		}
        else
        {
			if ( ( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None)
				&& ((RelatedPRI_2.Team == None) || (RelatedPRI_1.Team != RelatedPRI_2.Team)) )
			{
				if ( (P.Level.TimeSeconds - UnrealPlayer(P).LastKillTime < 4) && (Switch != 1) )
				{
					UnrealPlayer(P).MultiKillLevel++;
					P.ReceiveLocalizedMessage( class'MultiKillMessage', xPlayer(P).MultiKillLevel );
				} 
				else
					UnrealPlayer(P).MultiKillLevel = 0;
				UnrealPlayer(P).LastKillTime = P.Level.TimeSeconds;
			}
			else
				UnrealPlayer(P).MultiKillLevel = 0;
		}
	} 
	else if (RelatedPRI_2 == P.PlayerReplicationInfo) 
	{
		P.ReceiveLocalizedMessage( class'xVictimMessage', 0, RelatedPRI_1 );
		if ( !Default.bNoConsoleDeathMessages )
			Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	} 
	else if ( !Default.bNoConsoleDeathMessages )
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     KilledString="was killed by"
     SomeoneString="someone"
     bIsSpecial=False
     ChildMessage=Class'XGame.xKillerMessagePlus'
     DrawColor=(B=0,G=0)
}
