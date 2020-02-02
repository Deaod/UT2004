class HudBase extends HUD
    config(user)
    native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EScaleMode
{
    SM_None,
    SM_Up,
    SM_Down,
    SM_Left,
    SM_Right
};

struct native DigitSet
{
    var Material DigitTexture;
    var IntBox TextureCoords[11]; // 0-9, 11th element is negative sign
};

struct native SpriteWidget
{
    var Material WidgetTexture;

    var ERenderStyle RenderStyle;

    var IntBox TextureCoords;
    var float TextureScale;

    var EDrawPivot DrawPivot;
    var float PosX, PosY;
    var int OffsetX, OffsetY;

    var EScaleMode ScaleMode;
    var float Scale;

    var Color Tints[2];
};

struct native NumericWidget
{
    var ERenderStyle RenderStyle;

    var int MinDigitCount;

    var float TextureScale;

    var EDrawPivot DrawPivot;
    var float PosX, PosY;
    var int OffsetX, OffsetY;

    var Color Tints[2];

    var int bPadWithZeroes;

    var transient int Value;
};

var() transient int TeamIndex;

var() transient ERenderStyle PassStyle; // For debugging.

struct native HudLocalizedMessage
{
    // The following block of variables are set when the message is entered;
    // (Message being set indicates that a message is in the list).

	var class<LocalMessage> Message;
	var String StringMessage;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI, RelatedPRI2;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;

    // The following block of variables are cached on first render;
    // (StringFont being set indicates that they've been rendered).

	var Font StringFont;
	var Color DrawColor;
    var EDrawPivot DrawPivot;
    var LocalMessage.EStackMode StackMode;
	var float PosX, PosY;
	var float DX, DY;

	var bool Drawn;
};

var() transient HudLocalizedMessage LocalMessages[8];
var() class<Actor> VoteMenuClass;						// hook for mod authors

// targeting
var Material TargetMaterial;
var transient bool bShowTargeting;
var transient Vector TargetingLocation;
var transient float TargetingSize;

// instruction
var() string InstructionText;
var() string InstructionKeyText;
var() float InstructTextBorderX;
var() float InstructTextBorderY;
var() float InstrDelta;
var() float InstrRate;
var() localized string InstructionFontName;
var() font InstructionFontFont;

var bool bUsingCustomHUDColor;
var() bool DoCropping;
var bool bIsCinematic;

var   byte FontsPrecached;
var globalconfig bool bHideWeaponName;

var() float CroppingAmount;
var() Material CroppingMaterial;

var string LastWeaponName;
var float  WeaponDrawTimer;
var color  WeaponDrawColor;

var() localized String text;
var() localized String LevelActionLoading, LevelActionPaused;
var() localized String LevelActionFontName;
var localized string WonMatchPrefix, WonMatchPostFix, WaitingToSpawn, AtMenus;
var localized string YouveWonTheMatch, YouveLostTheMatch, NowViewing,ScoreText;
var localized string InitialViewingString;

var Material LocationDot;

var color DamageFlash[4];
var float DamageTime[4];
var() byte Emphasized[4];

var() array<SpriteWidget> Crosshairs;
var globalconfig color CustomHUDColor;
var globalconfig bool bUseCustomWeaponCrosshairs;

// Derived HUDs override UpdateHud to update variables before rendering;
// NO draw code should be in derived DrawHud's; they should instead override
// DrawHudPass[A-D] and call their base class' DrawHudPass[A-D] (This cuts
// down on render state changes).

simulated function UpdateHud();

simulated function DrawHudPassA (Canvas C); // Alpha Pass
simulated function DrawHudPassB (Canvas C); // Additive Pass
simulated function DrawHudPassC (Canvas C); // Alpha Pass
simulated function DrawHudPassD (Canvas C); // Alternate Texture Pass

simulated function PrecacheFonts(Canvas C)
{
	FontsPrecached++;
	C.Font = GetConsoleFont(C);
	C.SetPos(0,0);
	C.DrawText("<>_Aa1");

	C.Font = GetFontSizeIndex(C,-2);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,-4);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,MessageFontOffset);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,1 + MessageFontOffset);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,2 + MessageFontOffset);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,3 + MessageFontOffset);
	C.SetPos(0,0);
	C.DrawText("Aa1");
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (CustomHUDColorAllowed())
		SetCustomHUDColor();
}

function bool CustomHUDColorAllowed()
{
	return false;
}

function SetCustomHUDColor();

/* DisplayHit()
Directions are
0 = top
1 = bottom
2 = right
3 = left
*/
function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	local int i;
	local vector X,Y,Z;
	local byte Ignore[4];
	local rotator LookDir;
	local float NewDamageTime,Forward,Left;

	LookDir = PawnOwner.Rotation;
	LookDir.Pitch = 0;
	GetAxes(LookDir, X,Y,Z);
	HitDir.Z = 0;
	HitDir = Normal(HitDir);

	Forward = HitDir Dot X;
	Left = HitDir Dot Y;

	if ( Forward > 0 )
	{
		if ( Forward > 0.7 )
			Emphasized[0] = 1;
		Ignore[1] = 1;
	}
	else
	{
		if ( Forward < -0.7 )
			Emphasized[1] = 1;
		Ignore[0] = 1;
	}
	if ( Left > 0 )
	{
		if ( Left > 0.7 )
			Emphasized[3] = 1;
		Ignore[2] = 1;
	}
	else
	{
		if ( Left < -0.7 )
			Emphasized[2] = 1;
		Ignore[3] = 1;
	}

	NewDamageTime = 5 * Clamp(Damage,20,30);
	for ( i=0; i<4; i++ )
		if ( Ignore[i] != 1 )
		{
			DamageFlash[i].R = 255;
			DamageTime[i] = NewDamageTime;
		}
}

function DrawDamageIndicators(Canvas C)
{
	if ( DamageTime[0] > 0 )
	{
		C.SetPos(0,0);
		C.DrawColor = DamageFlash[0];
		C.DrawColor.A = DamageTime[0];
		if ( Emphasized[0] == 1 )
			C.DrawTile( Texture'HudContent.HUD', C.ClipX, 0.15*C.ClipY, 395, 219, 21, -10);
		else
			C.DrawTile( Texture'HudContent.HUD', C.ClipX, 0.05*C.ClipY, 395, 219, 21, -10);
	}
	else
		Emphasized[0] = 0;

	if ( DamageTime[1] > 0 )
	{
		C.DrawColor = DamageFlash[1];
		C.DrawColor.A = DamageTime[1];
		if ( Emphasized[1] == 1 )
		{
			C.SetPos(0,0.85*C.ClipY);
			C.DrawTile( Texture'HudContent.HUD', C.ClipX, 0.15*C.ClipY, 395, 209, 21, 10);
		}
		else
		{
			C.SetPos(0,0.9*C.ClipY);
			C.DrawTile( Texture'HudContent.HUD', C.ClipX, 0.1*C.ClipY, 395, 209, 21, 10);
		}
	}
	else
		Emphasized[1] = 0;

	if ( DamageTime[2] > 0 )
	{
		C.SetPos(0,0);
		C.DrawColor = DamageFlash[2];
		C.DrawColor.A = DamageTime[2];
		if ( Emphasized[2] == 1 )
			C.DrawTile( Texture'HudContent.HUD', 0.15*C.ClipX, C.ClipY, 404, 182, 12, 21);
		else
			C.DrawTile( Texture'HudContent.HUD', 0.05*C.ClipX, C.ClipY, 404, 182, 12, 21);
	}
	else
		Emphasized[2] = 0;

	if ( DamageTime[3] > 0 )
	{
		C.DrawColor = DamageFlash[3];
		C.DrawColor.A = DamageTime[3];
		if ( Emphasized[3] == 1 )
		{
			C.SetPos(0.85*C.ClipX,0);
			C.DrawTile( Texture'HudContent.HUD', 0.15*C.ClipX, C.ClipY, 416, 182, -12, 21);
		}
		else
		{
			C.SetPos(0.95*C.ClipX,0);
			C.DrawTile( Texture'HudContent.HUD', 0.05*C.ClipX, C.ClipY, 416, 182, -12, 21);
		}
	}
	else
		Emphasized[3] = 0;
}

simulated function Tick(float deltaTime)
{
	local int i;

	for ( i=0; i<4; i++ )
		if ( DamageTime[i] > 0 )
		{
			DamageTime[i] -= 120 * DeltaTime;
			if ( DamageTime[i] < 1 )
				DamageTime[i] = 0;
		}
}

simulated function DrawHeadShotSphere() // Dave@Psyonix
{
    local coords CO;
    local Pawn P;
    local vector HeadLoc;

    foreach DynamicActors(class'Pawn', P)
    {
        if (P != None && P.HeadBone != '')
        {
            CO = P.GetBoneCoords(P.HeadBone);
            HeadLoc = CO.Origin + (P.HeadHeight * P.HeadScale * CO.XAxis);
            P.DrawDebugSphere(HeadLoc, P.HeadRadius * P.HeadScale, 10, 0, 255, 0);
        }
    }
}

simulated function DrawHud (Canvas C)
{
	if ( FontsPrecached < 2 )
		PrecacheFonts(C);
    Super.DrawHud(C);

    UpdateHud();

    if( bShowTargeting )
        DrawTargeting(C);

    PassStyle = STY_Alpha;
	DrawDamageIndicators(C);
    DrawHudPassA(C);
    PassStyle = STY_Additive;
    DrawHudPassB(C);
    PassStyle = STY_Alpha;
    DrawHudPassC(C);
    PassStyle = STY_None;
    DrawHudPassD(C);

    DisplayLocalMessages(C);
    DrawWeaponName(C);
    DrawVehicleName(C);
//    DrawHeadShotSphere();
}

native simulated function DrawSpriteWidget (Canvas C, out SpriteWidget W);
native simulated function DrawNumericWidget (Canvas C, out NumericWidget W, out DigitSet D);

simulated function ClearMessage( out HudLocalizedMessage M )
{
	M.Message = None;
    M.StringFont = None;
}

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local Class<LocalMessage> LocalMessageClass;

	switch( MsgType )
	{
		case 'Say':
			if ( PRI == None )
				return;
			Msg = PRI.PlayerName$": "$Msg;
			LocalMessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			if ( PRI == None )
				return;
			Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
			LocalMessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			LocalMessageClass = class'CriticalEventPlus';
			LocalizedMessage( LocalMessageClass, 0, None, None, None, Msg );
			return;
		case 'DeathMessage':
			LocalMessageClass = class'xDeathMessage';
			break;
		default:
			LocalMessageClass = class'StringMessagePlus';
			break;
	}

	AddTextMessage(Msg,LocalMessageClass,PRI);
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	local int i;
	local PlayerReplicationInfo HUDPRI;

    if( Message == None )
        return;

    if( bIsCinematic && !ClassIsChildOf(Message,class'ActionMessage') )
		return;

    if( CriticalString == "" )
    {
		if ( (PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None) )
			HUDPRI = PawnOwner.PlayerReplicationInfo;
		else
			HUDPRI = PlayerOwner.PlayerReplicationInfo;
		if ( HUDPRI == RelatedPRI_1 )
			CriticalString = Message.static.GetRelatedString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		else
			CriticalString = Message.static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	}

	if( bMessageBeep && Message.default.bBeep )
		PlayerOwner.PlayBeepSound();

    if( !Message.default.bIsSpecial )
    {
		if ( PlayerOwner.bDemoOwner )
		{
			for( i=0; i<ConsoleMessageCount; i++ )
				if ( i >= ArrayCount(TextMessages) || TextMessages[i].Text == "" )
					break;

			if ( i > 0 && TextMessages[i-1].Text == CriticalString )
				return;
		}
	    AddTextMessage( CriticalString, Message,RelatedPRI_1 );
        return;
    }

    i = ArrayCount(LocalMessages);
	if( Message.default.bIsUnique )
	{
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
		    if( LocalMessages[i].Message == None )
                continue;

		    if( LocalMessages[i].Message == Message )
                break;
		}
	}
	else if ( Message.default.bIsPartiallyUnique || PlayerOwner.bDemoOwner )
	{
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
		    if( LocalMessages[i].Message == None )
                continue;

		    if( ( LocalMessages[i].Message == Message ) && ( LocalMessages[i].Switch == Switch ) )
                break;
        }
	}

    if( i == ArrayCount(LocalMessages) )
    {
	    for( i = 0; i < ArrayCount(LocalMessages); i++ )
	    {
		    if( LocalMessages[i].Message == None )
                break;
	    }
    }

    if( i == ArrayCount(LocalMessages) )
    {
	    for( i = 0; i < ArrayCount(LocalMessages) - 1; i++ )
		    LocalMessages[i] = LocalMessages[i+1];
    }

    ClearMessage( LocalMessages[i] );

	LocalMessages[i].Message = Message;
	LocalMessages[i].Switch = Switch;
	LocalMessages[i].RelatedPRI = RelatedPRI_1;
	LocalMessages[i].RelatedPRI2 = RelatedPRI_2;
	LocalMessages[i].OptionalObject = OptionalObject;
	LocalMessages[i].EndOfLife = Message.static.GetLifetime(Switch) + Level.TimeSeconds;
	LocalMessages[i].StringMessage = CriticalString;
	LocalMessages[i].LifeTime = Message.static.GetLifetime(Switch);
}

static function color GetTeamColor(byte TeamNum)
{
	return Default.BlackColor;
}

function GetLocalStatsScreen()
{
	if ( (PlayerOwner != None) && (TeamPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo) != None)
		&& (TeamPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).LocalStatsScreenClass != None) )
		LocalStatsScreen = spawn(TeamPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).LocalStatsScreenClass, Owner);
}

simulated function LayoutMessage( out HudLocalizedMessage Message, Canvas C )
{
    local int FontSize;

    FontSize = Message.Message.static.GetFontSize( Message.Switch, Message.RelatedPRI, Message.RelatedPRI2, PlayerOwner.PlayerReplicationInfo );
    FontSize += MessageFontOffset;
    Message.StringFont = GetFontSizeIndex(C,FontSize);
	Message.DrawColor = Message.Message.static.GetColor( Message.Switch, Message.RelatedPRI, Message.RelatedPRI2 );
    Message.Message.static.GetPos( Message.Switch, Message.DrawPivot, Message.StackMode, Message.PosX, Message.PosY );
    C.Font = Message.StringFont;
    C.TextSize( Message.StringMessage, Message.DX, Message.DY );
}

simulated function GetScreenCoords(float PosX, float PosY, out float ScreenX, out float ScreenY, out HudLocalizedMessage Message, Canvas C )
{
    ScreenX = (PosX * HudCanvasScale * C.ClipX) + (((1.0f - HudCanvasScale) * 0.5f) * C.ClipX);
    ScreenY = (PosY * HudCanvasScale * C.ClipY) + (((1.0f - HudCanvasScale) * 0.5f) * C.ClipY);

    switch( Message.DrawPivot )
    {
        case DP_UpperLeft:
            break;

        case DP_UpperMiddle:
            ScreenX -= Message.DX * 0.5;
            break;

        case DP_UpperRight:
            ScreenX -= Message.DX;
            break;

        case DP_MiddleRight:
            ScreenX -= Message.DX;
            ScreenY -= Message.DY * 0.5;
            break;

        case DP_LowerRight:
            ScreenX -= Message.DX;
            ScreenY -= Message.DY;
            break;

        case DP_LowerMiddle:
            ScreenX -= Message.DX * 0.5;
            ScreenY -= Message.DY;
            break;

        case DP_LowerLeft:
            ScreenY -= Message.DY;
            break;

        case DP_MiddleLeft:
            ScreenY -= Message.DY * 0.5;
            break;

        case DP_MiddleMiddle:
            ScreenX -= Message.DX * 0.5;
            ScreenY -= Message.DY * 0.5;
            break;

    }
}

simulated function DrawMessage( Canvas C, int i, float PosX, float PosY, out float DX, out float DY )
{
    local float FadeValue;
    local float ScreenX, ScreenY;

	if ( !LocalMessages[i].Message.default.bFadeMessage )
		C.DrawColor = LocalMessages[i].DrawColor;
	else
	{
		FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
		C.DrawColor = LocalMessages[i].DrawColor;
		C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue/LocalMessages[i].LifeTime);
	}

	C.Font = LocalMessages[i].StringFont;
	GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
	C.SetPos( ScreenX, ScreenY );
	DX = LocalMessages[i].DX / C.ClipX;
    DY = LocalMessages[i].DY / C.ClipY;

	if ( LocalMessages[i].Message.default.bComplexString )
	{
		LocalMessages[i].Message.static.RenderComplexMessage( C, LocalMessages[i].DX, LocalMessages[i].DY,
			LocalMessages[i].StringMessage, LocalMessages[i].Switch, LocalMessages[i].RelatedPRI,
			LocalMessages[i].RelatedPRI2, LocalMessages[i].OptionalObject );
	}
	else
	{
		C.DrawTextClipped( LocalMessages[i].StringMessage, false );
	}

    LocalMessages[i].Drawn = true;
}

simulated function DisplayLocalMessages( Canvas C )
{
	local float PosX, PosY, DY, DX;
    local int i, j;
    local float FadeValue;
    local Plane OldCM;

    OldCM=C.ColorModulate;
	C.Reset();
    C.ColorModulate = OldCM;

    // Pass 1: Layout anything that needs it and cull dead stuff.

    for( i = 0; i < ArrayCount(LocalMessages); i++ )
    {
		if( LocalMessages[i].Message == None )
            break;

        LocalMessages[i].Drawn = false;

        if( LocalMessages[i].StringFont == None )
            LayoutMessage( LocalMessages[i], C );

        if( LocalMessages[i].StringFont == None )
        {
            log( "LayoutMessage("$LocalMessages[i].Message$") failed!", 'Error' );

	        for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
		        LocalMessages[j] = LocalMessages[j+1];
            ClearMessage( LocalMessages[j] );
            i--;
            continue;
        }

		if( LocalMessages[i].Message.default.bFadeMessage )
		{
			FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);

			if( FadeValue <= 0.0 )
            {
	            for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
		            LocalMessages[j] = LocalMessages[j+1];
                ClearMessage( LocalMessages[j] );
                i--;
                continue;
            }
        }
    }

    // Pass 2: Go through the list and draw each stack:

    for( i = 0; i < ArrayCount(LocalMessages); i++ )
	{
		if( LocalMessages[i].Message == None )
            break;

        if( LocalMessages[i].Drawn )
            continue;

	    PosX = LocalMessages[i].PosX;
	    PosY = LocalMessages[i].PosY;

        if( LocalMessages[i].StackMode == SM_None )
        {
            DrawMessage( C, i, PosX, PosY, DX, DY );
            continue;
        }

        for( j = i; j < ArrayCount(LocalMessages); j++ )
        {
            if( LocalMessages[j].Drawn )
                continue;

            if( LocalMessages[i].PosX != LocalMessages[j].PosX )
                continue;

            if( LocalMessages[i].PosY != LocalMessages[j].PosY )
                continue;

            if( LocalMessages[i].DrawPivot != LocalMessages[j].DrawPivot )
                continue;

            if( LocalMessages[i].StackMode != LocalMessages[j].StackMode )
                continue;

            DrawMessage( C, j, PosX, PosY, DX, DY );

            switch( LocalMessages[j].StackMode )
            {
                case SM_Up:
                    PosY -= DY;
                    break;

                case SM_Down:
                    PosY += DY;
                    break;
            }
        }
    }
}

simulated function CreateKeyMenus() // create vote/speech menus here
{
	if ( (PlayerController(Owner).PlayerReplicationInfo != None)
		&& PlayerController(Owner).PlayerReplicationInfo.bOnlySpectator )
		return;
    if( VoteMenuClass != None )
        VoteMenu = Spawn(VoteMenuClass,self);
}

function Draw2DLocationDot(Canvas C, vector Loc,float OffsetX, float OffsetY, float ScaleX, float ScaleY)
{
	local rotator Dir;
	local float Angle, Scaling;
	local Actor Start;

	if ( PawnOwner == None )
		Start = PlayerOwner;
	else
		Start = PawnOwner;

	Dir = rotator(Loc - Start.Location);
	Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(OffsetX * C.ClipX + ScaleX * C.ClipX * sin(Angle),
			OffsetY * C.ClipY - ScaleY * C.ClipY * cos(Angle));

	Scaling = 24*C.ClipX*HUDScale/1600;

	C.DrawTile(LocationDot, Scaling, Scaling,340,432,78,78);
}

simulated function SetTargeting( bool bShow, optional Vector TargetLocation, optional float Size )
{
    bShowTargeting = bShow;
    if( bShow )
    {
        TargetingLocation = TargetLocation;
        if( Size != 0.0 )
            TargetingSize = Size;
    }
}

simulated function DrawTargeting( Canvas C )
{
    local int XPos, YPos;
    local vector ScreenPos;
    local vector X,Y,Z,Dir;
    local float RatioX, RatioY;
    local float tileX, tileY;
    local float Dist;

    local float SizeX;
    local float SizeY;

    SizeX = TargetingSize * 96.0;
    SizeY = TargetingSize * 96.0;

    if( !bShowTargeting )
        return;

    ScreenPos = C.WorldToScreen( TargetingLocation );

    RatioX = C.SizeX / 640.0;
    RatioY = C.SizeY / 480.0;

    tileX = sizeX * RatioX;
    tileY = sizeY * RatioX;

    GetAxes(PlayerOwner.Rotation, X,Y,Z);
	Dir = TargetingLocation - PawnOwner.Location;
	Dist = VSize(Dir);
	Dir = Dir/Dist;

    if ( (Dir Dot X) > 0.6 ) // don't draw if it's behind the eye
	{
		XPos = ScreenPos.X;
		YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Additive;
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 255;
		C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        C.DrawTile( TargetMaterial, tileX, tileY, 0.0, 0.0, 256, 256); //--- TODO : Fix HARDCODED USIZE
        //log("Drawing passtarget focus1");
	}
}

simulated function SetCropping( bool Active )
{
    DoCropping = active;
}

simulated function DrawInstructionGfx(Canvas C)
{
    local float CropHeight;

    //log("DrawInstructionGfx");

    DrawCrosshair(C);
    DrawTargeting(C);
    if( DoCropping )
    {
        // todo: lerp the crop height
        CropHeight = (C.SizeY * CroppingAmount) * 0.5;
        C.SetPos(0, 0);
        C.DrawTile( Texture'Engine.BlackTexture', C.SizeX, CropHeight, 0.0, 0.0, 64, 64 );
        C.SetPos( 0, C.SizeY-CropHeight );
        C.DrawTile( Texture'Engine.BlackTexture', C.SizeX, CropHeight, 0.0, 0.0, 64, 64 );
    }
    DrawInstructionText(C);
    DrawInstructionKeyText(C);
}

simulated function DrawInstructionText(Canvas C)
{
    if( InstructionText == "" )
        return;

    C.Font = LoadInstructionFont();

    C.SetOrigin( InstructTextBorderX, InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );
    C.SetPos(0,0);

	C.DrawText( InstructionText );

    C.SetOrigin(0.0, 0.0);
    C.SetClip( C.SizeX, C.SizeY );
}

simulated function DrawInstructionKeyText(Canvas C)
{
    local float strX;
    local float strY;

    if( InstructionKeyText == "" )
        return;

    C.Font = LoadInstructionFont();
    C.SetOrigin( InstructTextBorderX, InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );

    C.StrLen( InstructionKeyText, strX, strY );

    C.SetOrigin( InstructTextBorderX, C.SizeY-strY-InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );
    C.SetPos(0,0);

	C.DrawText( InstructionKeyText );

    C.SetOrigin(0.0, 0.0);
    C.SetClip( C.SizeX, C.SizeY );
}

simulated function SetInstructionText( string text )
{
    InstructionText = text;
}

simulated function SetInstructionKeyText( string text )
{
    InstructionKeyText = text;
}

simulated function font LoadInstructionFont()
{
	if( InstructionFontFont == None )
	{
		InstructionFontFont = Font(DynamicLoadObject(InstructionFontName, class'Font'));
		if( InstructionFontFont == None )
			Log("Warning: "$Self$" Couldn't dynamically load font "$InstructionFontName);
	}
	return InstructionFontFont;
}

simulated function DrawWeaponName(Canvas C)
{
	local string CurWeaponName;
    local float XL,YL, Fade;

	if (bHideWeaponName)
    	return;

	if (WeaponDrawTimer>Level.TimeSeconds)
    {
	    C.Font = GetMediumFontFor(C);
        C.DrawColor = WeaponDrawColor;

		Fade = WeaponDrawTimer - Level.TimeSeconds;

        if (Fade<=1)
        	C.DrawColor.A = 255 * Fade;


		C.Strlen(LastWeaponName,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), C.ClipY*0.8-YL);
        C.DrawText(LastWeaponName);
    }

	if (  PawnOwner==None || PawnOwner.PendingWeapon==None )
    	return;

	CurWeaponName = PawnOwner.PendingWeapon.GetHumanReadableName();
    if (CurWeaponName!=LastWeaponName)
    {
    	WeaponDrawTimer = Level.TimeSeconds+1.5;
        WeaponDrawColor = PawnOwner.PendingWeapon.HudColor;
    }

   	LastWeaponName = CurWeaponName;
}

function DrawVehicleName(Canvas C);

/* called when viewing a Matinee cinematic */
simulated function DrawCinematicHUD(Canvas C)
{
	Super.DrawCinematicHUD(C);

	if (SubTitles != None)
		DrawIntroSubtitles(C);
	else if (bHideHUD)
		DisplayLocalMessages(C);
}

simulated function DrawIntroSubtitles( Canvas C )
{
	local String	CurrentSubTitles;
	local float		XL, YL, YO;
	local Array<String>	OutArray;
	local int		i;

	CurrentSubTitles = SubTitles.GetSubTitles();
	if ( CurrentSubTitles == "" )
		return;

	C.DrawColor = WhiteColor;
	C.Style		= ERenderStyle.STY_Alpha;
	C.Font		= GetFontSizeIndex( C, -1 );

	C.WrapStringToArray(CurrentSubTitles, OutArray, C.ClipX*0.75);
	C.StrLen( OutArray[i], XL, YL );
	YO = FMin(C.ClipY*0.9 - YL*0.5*OutArray.Length, C.ClipY - (OutArray.Length+1.1)*YL);

	for (i=0; i<OutArray.Length; i++)
	{
		C.StrLen( OutArray[i], XL, YL );
		C.SetPos( (C.ClipX-XL)*0.5, YO + YL*i );
		C.DrawText( OutArray[i], false );
	}
}

defaultproperties
{
     TargetMaterial=FinalBlend'InterfaceContent.HUD.fbBombFocus'
     InstructTextBorderX=10.000000
     InstructTextBorderY=10.000000
     InstructionFontName="UT2003Fonts.jFontMono800x600"
     CroppingAmount=0.250000
     LevelActionLoading="LOADING..."
     LevelActionPaused="PAUSED"
     LevelActionFontName="UT2003Fonts.FontMedium"
     WonMatchPostFix=" won the match!"
     WaitingToSpawn="Press [Fire] to join the match!"
     AtMenus="Press [ESC] to close menu"
     YouveWonTheMatch="You've won the match!"
     YouveLostTheMatch="You've lost the match."
     NowViewing="Now viewing"
     ScoreText="Score"
     InitialViewingString="Press Fire to View a different Player"
     LocationDot=Texture'HUDContent.Generic.HUD'
     Crosshairs(0)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Cross1',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(1)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Cross2',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(2)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Cross3',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(3)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Cross4',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(4)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Cross5',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(5)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Dot',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(6)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Pointer',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(7)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Triad1',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.700000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(8)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Triad2',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.700000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(9)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Triad3',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.700000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(10)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Bracket1',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(11)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Bracket2',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(12)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Circle1',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.400000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Crosshairs(13)=(WidgetTexture=Texture'Crosshairs.HUD.Crosshair_Circle2',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.400000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ProgressFontName="UT2003Fonts.FontMedium"
     FontArrayNames(0)="UT2003Fonts.FontEurostile37"
     FontArrayNames(1)="UT2003Fonts.FontEurostile29"
     FontArrayNames(2)="UT2003Fonts.FontEurostile24"
     FontArrayNames(3)="UT2003Fonts.FontEurostile21"
     FontArrayNames(4)="UT2003Fonts.FontEurostile17"
     FontArrayNames(5)="UT2003Fonts.FontEurostile14"
     FontArrayNames(6)="UT2003Fonts.FontEurostile12"
     FontArrayNames(7)="UT2003Fonts.FontEurostile9"
     FontArrayNames(8)="UT2003Fonts.FontSmallText"
     FontScreenWidthMedium(0)=2048
     FontScreenWidthMedium(1)=1600
     FontScreenWidthMedium(2)=1280
     FontScreenWidthMedium(3)=1024
     FontScreenWidthMedium(4)=800
     FontScreenWidthMedium(5)=640
     FontScreenWidthMedium(6)=512
     FontScreenWidthMedium(7)=400
     FontScreenWidthMedium(8)=320
     FontScreenWidthSmall(0)=4096
     FontScreenWidthSmall(1)=3200
     FontScreenWidthSmall(2)=2560
     FontScreenWidthSmall(3)=2048
     FontScreenWidthSmall(4)=1600
     FontScreenWidthSmall(5)=1280
     FontScreenWidthSmall(6)=1024
     FontScreenWidthSmall(7)=800
     FontScreenWidthSmall(8)=640
}
