// ====================================================================
//  Class:  UnrealGame.CinematicHud
//  Parent: Engine.HUD
//
//  This is the hud used for Cinematic sequences
// ====================================================================

class CinematicHud extends HUD;

// #exec OBJ LOAD FILE=..\textures\ScopeOverlay.utx PACKAGE=ScopeOverlay

var float Delta;
var bool  bHideScope;
var float xOffsets[2];
var float xRates[2];
var float yOffsets[2];
var float yRates[2];
var bool  bInitialized;
var float Scale;

var string SubTitle;
var float SubTitleKillTime;



simulated event PostRender( canvas Canvas )
{
	local float xl,yl;
	Super.PostRender(Canvas);

    if ( Level.TimeSeconds > SubTitleKillTime )
    	SubTitle = "";

    if (SubTitle != "")
    {
    	Canvas.SetDrawColor(255,255,0,255);
		Canvas.Font = LoadFontStatic(6);

  		Canvas.StrLen(SubTitle,xl,yl);
        if (xl>=Canvas.ClipX)
        	xl = 0;
        else
        	xl = (Canvas.ClipX / 2) - (xl / 2);

//        Canvas.SetPos(XL,Canvas.ClipY*0.85);
        Canvas.SetPos(0, Canvas.ClipY*0.85);
        Canvas.bCenter = true;
        Canvas.DrawText(SubTitle,false);
    }

}

simulated function DrawHUD(canvas Canvas)
{
	// Setup Timing


	if (!bInitialized)
	{
		Initialize(Canvas);
	}


	Scale = Canvas.ClipX / 1024;

	Super.DrawHud(Canvas);

	// Draw any specific sequences here
}

simulated function Initialize(canvas Canvas)
{

	if (Scale == 0)
		return;

	xOffsets[0] = -123.0*Scale;
	xRates[0]   = 512.0*Scale;
	xOffsets[1] = Canvas.ClipY+1;
	xRates[1]   = 512.0*Scale;


	yOffsets[0] = (Canvas.ClipY / 2) - (64.0*Scale);
	yOffsets[1] = yOffsets[0];
	yRates[0]   = -200.0*Scale;
	yRates[1]   = +256.0*Scale;

	bInitialized = true;

}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
    SubTitle = Message.static.GetString(switch);
    SubTitleKillTime = Level.TimeSeconds + Message.static.GetLifeTime(switch);
}

defaultproperties
{
     bHideScope=True
     FontArrayNames(0)="UT2003Fonts.jFontLarge1024x768"
     FontArrayNames(1)="UT2003Fonts.jFontLarge800x600"
     FontArrayNames(2)="UT2003Fonts.jFontLarge"
     FontArrayNames(3)="UT2003Fonts.jFontMedium1024x768"
     FontArrayNames(4)="UT2003Fonts.jFontMedium800x600"
     FontArrayNames(5)="UT2003Fonts.jFontMedium"
     FontArrayNames(6)="UT2003Fonts.jFontSmall"
     FontArrayNames(7)="UT2003Fonts.jFontSmallText800x600"
     FontArrayNames(8)="UT2003Fonts.FontSmallText"
}
