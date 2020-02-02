class xDMRoster extends DMRoster
    DependsOn(xUtil);

function Initialize(int TeamBots)
{
	local int i;

	for ( i=Roster.Length; i<TeamBots; i++ )
		AddRandomPlayer();
		
	for ( i=0; i<TeamBots; i++ )
		Roster[i].PrecacheRosterFor(self);
}
	
function PostBeginPlay()
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local int i,j;
	
	Super.PostBeginPlay();

	// add RosterNames to roster
	class'xUtil'.static.GetPlayerList(PlayerRecords);	
	for ( i=0; i<RosterNames.Length; i++ )
	{
		j = Roster.Length;
		Roster.Length = Roster.Length + 1;
		Roster[j] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(RosterNames[i]);
	}
}	

function RosterEntry GetRandomPlayer()
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local int RND,i, num;
	local int max, total;
	
	class'xUtil'.static.GetPlayerList(PlayerRecords);	
	for ( i=0; i<PlayerRecords.Length; i++ )
		max += PlayerRecords[i].BotUse;
	RND = Rand(Max);

	for ( i=0; i<PlayerRecords.Length; i++ )
	{
		total += PlayerRecords[i].BotUse;
		if ( total >= RND )
			break;
	}
	
	num = i;	

	if ( AvailableRecord(PlayerRecords[num].Menu) && !AlreadyExistsEntry(PlayerRecords[num].DefaultName,true) )
		return class'xRosterEntry'.Static.CreateRosterEntry(num);
		
	for ( i=num; i<PlayerRecords.Length; i++ )
		if ( AvailableRecord(PlayerRecords[i].Menu) && (PlayerRecords[i].BotUse > 0) && !AlreadyExistsEntry(PlayerRecords[i].DefaultName,true) )
			return class'xRosterEntry'.Static.CreateRosterEntry(i);
	
	for ( i=0; i<num; i++ )
		if ( AvailableRecord(PlayerRecords[i].Menu) && (PlayerRecords[i].BotUse > 0) && !AlreadyExistsEntry(PlayerRecords[i].DefaultName,true) )
			return class'xRosterEntry'.Static.CreateRosterEntry(i);
	
	return GetNamedBot("Jakob");
}

function bool AvailableRecord(string MenuString)
{
	return ( (MenuString ~= "DUP") || (MenuString ~= "SP") || (MenuString ~= "") || (MenuString ~= "UNLOCK") );
}

function RosterEntry GetNamedBot(string botName)
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local xUtil.PlayerRecord PR;
	
	class'xUtil'.static.GetPlayerList(PlayerRecords);	
	PR = class'xUtil'.static.FindPlayerRecord(botName);
	return class'xRosterEntry'.Static.CreateRosterEntry(PR.RecordIndex);
}

function bool AlreadyExistsEntry(string CharacterName, bool bNoRecursion)
{
	local int i;
	
	for ( i=0; i<Roster.Length; i++ )
		if ( (xRosterEntry(Roster[i]) != None) && (xRosterEntry(Roster[i]).PlayerName == CharacterName) )
			return true;
			
	return false;
}

function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	return true;
}

defaultproperties
{
}
