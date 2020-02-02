class xRosterEntry extends RosterEntry
	    dependsOn(xUtil) transient;

// FIXME - xRosterEntry is transient as quick fix for save games.  Really should change new(None) below to new(xLevel),
// but no easy way to do that without breaking compatibility

var() xUtil.PlayerRecord PlrProfile;

static function xRosterEntry CreateRosterEntry(int prIdx)
{
    local xRosterEntry xre;
    local xUtil.PlayerRecord pr;

    pr = class'xUtil'.static.GetPlayerRecord(prIdx);

    xre = new(None) class'xRosterEntry';
    xre.PlayerName = pr.DefaultName;
    xre.PawnClassName = "xGame.xPawn"; 
    xre.PlrProfile = pr;
    xre.Init();

    return xre;
}

static function xRosterEntry CreateRosterEntryCharacter(string CharName)
{
    local xRosterEntry xre;
    local xUtil.PlayerRecord pr;

    pr = class'xUtil'.static.FindPlayerRecord(CharName);

    xre = new(None) class'xRosterEntry';
    xre.PlayerName = pr.DefaultName;
    xre.PawnClassName = "xGame.xPawn"; 
    xre.PlrProfile = pr;
    xre.Init();

    return xre;
}

function PrecacheRosterFor(UnrealTeamInfo T)
{
     if ( PlrProfile.Species == None )
    {
		warn("Could not load species "$PlrProfile.Species$" for "$PlrProfile.DefaultName);
		return;
	}

	PlrProfile.Species.static.LoadResources( PlrProfile, T.Level, None, T.TeamIndex );
}

function InitBot(Bot B)
{
    B.SetPawnClass(PawnClassName, PlayerName);
		
    // Set bot attributes based on the PlayerRecord
    CombatStyle    = FClamp(class'Bot'.Default.CombatStyle + float(PlrProfile.CombatStyle),-1,1);    
    Aggressiveness = FClamp(class'Bot'.Default.BaseAggressiveness +float(PlrProfile.Aggressiveness),0,1);
    Accuracy        = FClamp(float(PlrProfile.Accuracy),-4,4);
    StrafingAbility = FClamp(float(PlrProfile.StrafingAbility),-4,4);
    Tactics         = FClamp(float(PlrProfile.Tactics),-4,4);
    ReactionTime    = FClamp(float(PlrProfile.ReactionTime),-4,4);
    if ( PlrProfile.FavoriteWeapon == "" )
		FavoriteWeapon = None;
	else
	    FavoriteWeapon = class<Weapon>(DynamicLoadObject(PlrProfile.FavoriteWeapon,class'Class'));
    Jumpiness = float(PlrProfile.Jumpiness);
    
   	Super.InitBot(B);
}

defaultproperties
{
}
