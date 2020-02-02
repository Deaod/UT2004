class SayMessagePlus extends StringMessagePlus;

var color RedTeamColor,BlueTeamColor;

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return;

	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawText( RelatedPRI_1.PlayerName$": ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.SetDrawColor(0,128,0);
	Canvas.DrawText( MessageString, False );
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	if ( RelatedPRI_1 == None )
		return "";
	if ( RelatedPRI_1.PlayerName == "" )
		return "";
	return RelatedPRI_1.PlayerName$": "@MessageString;
}

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
	if ( (RelatedPRI_1 == None) || (RelatedPRI_1.Team == None) )
		return Default.DrawColor;
		
	if ( RelatedPRI_1.Team.TeamIndex == 0 )
		return Default.RedTeamColor;
	else
		return Default.BlueTeamColor;
}

defaultproperties
{
     RedTeamColor=(B=64,G=64,R=255,A=255)
     BlueTeamColor=(B=255,G=192,R=64,A=255)
     bBeep=True
     Lifetime=6
     DrawColor=(B=0)
}
