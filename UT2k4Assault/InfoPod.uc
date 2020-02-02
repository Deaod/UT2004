//=============================================================================
// InfoPod
//=============================================================================
// Place this actor in your level to display information on HUD.
// For example to tell the destination of a Teleporter
//=============================================================================

class InfoPod extends Keypoint
	placeable;

var()	enum EIP_AssaultTeam
{
	EIP_All,
	EIP_Attackers,
	EIP_Defenders,
} Team;

var()	enum EIP_InfoType
{
	EIPT_PlainText,
	EIPT_TextBrackets,
	EIPT_Texture,
} InfoType;

var()	enum EIP_InfoEffect
{
	EIPE_Normal,
	EIPE_Blink,
	EIPE_Pulse,
} InfoEffect;

var()	bool	bIsTriggered;	// do not replicate if not triggered
var()	bool	bDisabled;
var		bool	BACKUP_bDisabled;
var()	bool	bOverrideZoneCheck;	// Override Zone check (USE DrawDistThreshold to minimize CPU resources!!)
var()	bool	bOverrideVisibilityCheck;	// No line trace
var()	float	DrawDistThreshold;	// Don't draw beyond this distance (0 = unlimited)

var()	ERenderStyle	InfoPodDrawStyle;	// Draw style used for text or textures
var()	byte			DrawOpacity;		// Opacity

var()	Material		POD_Texture;
var()	float			TextureScale;

var()	localized	string	POD_Message;
var()				byte	FontSize;		// 0 (tiny) - 16 ( huge)


replication
{
	unreliable if ( (Role==ROLE_Authority) && bNetDirty )
		bDisabled;
}


event PostBeginPlay()
{
	super.PostBeginPlay();
	BACKUP_bDisabled = bDisabled;

	if ( !bIsTriggered )
		RemoteRole = Role_None;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	bDisabled = !bDisabled;	
	TriggerEvent( Event, Self, EventInstigator );
}

function Reset()
{
	super.Reset();
	bDisabled = BACKUP_bDisabled;
}


/* Return true if InfoPod is visible */
simulated final function bool IsInfoPodVisible( Canvas C, Pawn P, vector CamLoc, rotator CamRot )
{
	local vector		TargetLocation, TargetDir;
	local float			Dist;

	// Check if in same Zone
	if ( !bOverrideZoneCheck && P.Region.Zone != Region.Zone )
		return false;

	Dist = VSize(Location - CamLoc);

	// Check Distance Threshold
	if ( (DrawDistThresHold > 0) && ( Dist > DrawDistThresHold) )
		return false;

	// Check Min Distance
	if ( Dist < CollisionRadius )
		return false;

	// Target is located behind camera
	if ((Location - CamLoc) Dot vector(CamRot) < 0)
		return false;

	if ( !bOverrideVisibilityCheck )
	{
		// Simple Line check to see if we hit geometry
		TargetDir		= Location - CamLoc;
		TargetDir.Z		= 0;
		TargetLocation	= Location - 2.f * CollisionRadius * vector(rotator(TargetDir));

		return FastTrace( Location, CamLoc );
	}

	return true;
}

/* Render Info Pod. Visibility checking and Color is done in HUD_Assault */
simulated function Render( Canvas C, Vector IPScreenPos, PlayerController PC )
{
	C.Style = InfoPodDrawStyle;

	switch ( InfoType )
	{
		case EIPT_PlainText		: DrawInfoPod_PlainText( C, IPScreenPos, PC ); break;
		case EIPT_TextBrackets	: DrawInfoPod_TextBrackets( C, IPScreenPos, PC ); break;
		case EIPT_Texture		: DrawInfoPod_Texture( C, IPScreenPos ); break;
	}
}

/* Draw InfoPod Plain Text */
simulated function DrawInfoPod_PlainText( Canvas C, Vector IPScreenPos, PlayerController PC )
{
	local float		XL, YL;
	local string	FinalString;

	FinalString = class'HUD_Assault'.default.IP_Bracket_Open @ POD_Message @ class'HUD_Assault'.default.IP_Bracket_Close;
	C.Font = PC.myHUD.GetFontSizeIndex( C, FontSize - 8 );
	C.StrLen(FinalString, XL, YL);

	// Clipping
	if ( IPScreenPos.X + XL*0.5 > C.ClipX )
		IPScreenPos.X = C.ClipX - XL*0.5;
	if ( IPScreenPos.Y + YL*0.5 > C.ClipY )
		IPScreenPos.Y = C.ClipY - YL*0.5;

	// Drawing...
	C.SetPos(IPScreenPos.X - XL*0.5, IPScreenPos.Y - YL*0.5);
	C.DrawText(FinalString, false);
}


/* Draw InfoPod Text Brackets (Draws an additional box surrounding the InfoPod's collision cylinder) */
simulated function DrawInfoPod_TextBrackets( Canvas C, Vector IPScrO, PlayerController PC )
{
	local string Description;

	// Info Pod Description
	C.Font		= PC.myHUD.GetFontSizeIndex( C, FontSize - 8 );
	Description = class'HUD_Assault'.default.IP_Bracket_Open @ POD_Message @ class'HUD_Assault'.default.IP_Bracket_Close;

	class'HUD_Assault'.static.Draw_2DCollisionBox( C, Self, IPScrO, Description, DrawScale, false );
}


/* Draw InfoPod Texture */
simulated function DrawInfoPod_Texture( Canvas C, Vector IPScrO )
{
	local float W, H;

	if ( POD_Texture != None )
	{
		W = POD_Texture.MaterialUSize() * TextureScale * C.SizeX / 640.f;
		H = POD_Texture.MaterialVSize() * TextureScale * C.SizeY / 480.f;

		C.SetPos(IPScrO.X - W*0.5, IPScrO.Y - H*0.5);
		C.DrawTile(POD_Texture, W, H, 0.f, 0.f, POD_Texture.MaterialUSize(), POD_Texture.MaterialVSize());
	}
}

defaultproperties
{
     bIsTriggered=True
     InfoPodDrawStyle=STY_Alpha
     DrawOpacity=200
     TextureScale=1.000000
     POD_Message="-= info pod =-"
     FontSize=5
     bStatic=False
     bNoDelete=True
     bStasis=True
     bReplicateMovement=False
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_DumbProxy
}
