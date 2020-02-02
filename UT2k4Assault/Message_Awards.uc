//==============================================================================
// Message_Awards
//==============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class Message_Awards extends LocalMessage;

var localized string MSG[2];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch( Switch )
	{
		case 0 : return default.MSG[0];
		case 1 : return RelatedPRI_1.PlayerName @ default.MSG[1];
	}

	return default.MSG[Min(Switch,1)];
}

static function RenderComplexMessage( 
    Canvas Canvas, 
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local byte	Alpha;
	local float	IconSize;

	Canvas.DrawTextClipped( MessageString, false );

	if ( Switch == 0 )
	{
		IconSize			= YL * 2;
		Alpha				= Canvas.DrawColor.A;		// Backup Alpha if message fades out
		Canvas.DrawColor	= Canvas.MakeColor(255, 255, 255);
		Canvas.DrawColor.A	= Alpha;

		Canvas.SetPos( Canvas.CurX - IconSize - YL*0.33, Canvas.CurY + YL*0.5 - IconSize*0.5 );
		Canvas.DrawTile( Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', IconSize, IconSize, 0, 0, 128, 128);
	}
}

defaultproperties
{
     Msg(0)="You have completed the Objective!"
     Msg(1)="completed the Objective!"
     bComplexString=True
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
