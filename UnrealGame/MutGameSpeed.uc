class MutGameSpeed extends Mutator;

var globalconfig float NewGameSpeed;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.Game.bAllowMPGameSpeed = true;
	Level.Game.SetGameSpeed(NewGameSpeed);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "NewGameSpeed", class'GameInfo'.default.GIPropsDisplayText[3], 0, 0, "Text",   "8;0.1:3.5");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NewGameSpeed":	return class'GameInfo'.default.GIPropDescText[3];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     NewGameSpeed=1.000000
     GroupName="GameSpeed"
     FriendlyName="Game Speed"
     Description="Modify the game speed."
}
