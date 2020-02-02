//=============================================================================
// Sniper Rifle
//=============================================================================
class SniperRifle extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=HudContent.utx
#exec OBJ LOAD FILE=XGameShaders.utx

var(Gfx) float testX;
var(Gfx) float testY;

var(Gfx) float borderX;
var(Gfx) float borderY;

var(Gfx) float focusX;
var(Gfx) float focusY;
var(Gfx) float innerArrowsX;
var(Gfx) float innerArrowsY;

var(Gfx) Color ArrowColor;
var(Gfx) Color TargetColor;
var(Gfx) Color NoTargetColor;
var(Gfx) Color FocusColor;
var(Gfx) Color ChargeColor;

var(Gfx) vector RechargeOrigin;
var(Gfx) vector RechargeSize;

var transient float LastFOV;
var() bool zoomed;
var() xEmitter  chargeEmitter;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
}

simulated function Destroyed()
{
    if (chargeEmitter != None)
        chargeEmitter.Destroy();

    Super.Destroyed();
}

simulated function ClientWeaponThrown()
{
    if( (Instigator != None) && (PlayerController(Instigator.Controller) != None) )
        PlayerController(Instigator.Controller).EndZoom();
    Super.ClientWeaponThrown();
}

simulated function IncrementFlashCount(int Mode)
{
	if ( Mode == 1 )
		return;
	Super.IncrementFlashCount(Mode);
}

// compensate for bright fog
simulated function SetZoomBlendColor(Canvas c)
{
    local Byte    val;
    local Color   clr;
    local Color   fog;

    clr.R = 255;
    clr.G = 255;
    clr.B = 255;
    clr.A = 255;

    if( Instigator.Region.Zone.bDistanceFog )
    {
        fog = Instigator.Region.Zone.DistanceFogColor;
        val = 0;
        val = Max( val, fog.R);
        val = Max( val, fog.G);
        val = Max( val, fog.B);

        if( val > 128 )
        {
            val -= 128;
            clr.R -= val;
            clr.G -= val;
            clr.B -= val;
        }
    }
    c.DrawColor = clr;
}

simulated event RenderOverlays( Canvas Canvas )
{
	local float tileScaleX;
	local float tileScaleY;
	local float bX;
	local float bY;
	local float fX;
	local float fY;
	local float ChargeBar;

	local float tX;
	local float tY;

	local float barOrgX;
	local float barOrgY;
	local float barSizeX;
	local float barSizeY;

	if ( PlayerController(Instigator.Controller) == None )
	{
        Super.RenderOverlays(Canvas);
		zoomed=false;
		return;
	}

    if ( LastFOV > PlayerController(Instigator.Controller).DesiredFOV )
    {
        PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,,false);
    }
    else if ( LastFOV < PlayerController(Instigator.Controller).DesiredFOV )
    {
        PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomOut', SLOT_Misc,,,,,false);
    }
    LastFOV = PlayerController(Instigator.Controller).DesiredFOV;

    if ( PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV )
	{
        Super.RenderOverlays(Canvas);
		zoomed=false;
	}
	else
    {
		if ( FireMode[0].NextFireTime <= Level.TimeSeconds )
		{
			ChargeBar = 1.0;
		}
		else
		{
			ChargeBar = 1.0 - ((FireMode[0].NextFireTime-Level.TimeSeconds) / FireMode[0].FireRate);
		}

		tileScaleX = Canvas.SizeX / 640.0f;
		tileScaleY = Canvas.SizeY / 480.0f;

		bX = borderX * tileScaleX;
		bY = borderY * tileScaleY;
		fX = 2*focusX * tileScaleX;
		fY = 2*focusY * tileScaleX;

		tX = testX * tileScaleX;
		tY = testY * tileScaleX;

		barOrgX = RechargeOrigin.X * tileScaleX;
		barOrgY = RechargeOrigin.Y * tileScaleY;

		barSizeX = RechargeSize.X * tileScaleX;
		barSizeY = RechargeSize.Y * tileScaleY;

        SetZoomBlendColor(Canvas);

        Canvas.Style = 255;
		Canvas.SetPos(0,0);
        Canvas.DrawTile( Material'ZoomFB', Canvas.SizeX, Canvas.SizeY, 128, 128, 256, 256 ); // !! hardcoded size

		Canvas.DrawColor = FocusColor;
        Canvas.DrawColor.A = 255; // 255 was the original -asp. WTF??!?!?!
		Canvas.Style = ERenderStyle.STY_Alpha;

		Canvas.SetPos((Canvas.SizeX*0.5)-fX,(Canvas.SizeY*0.5)-fY);
		Canvas.DrawTile( Texture'SniperFocus', fX*2.0, fY*2.0, 0.0, 0.0, Texture'SniperFocus'.USize, Texture'SniperFocus'.VSize );

        fX = innerArrowsX * tileScaleX;
		fY = innerArrowsY * tileScaleY;

        Canvas.DrawColor = ArrowColor;
		Canvas.SetPos((Canvas.SizeX*0.5)-fX,(Canvas.SizeY*0.5)-fY);
		Canvas.DrawTile( Texture'SniperArrows', fX*2.0, fY*2.0, 0.0, 0.0, Texture'SniperArrows'.USize, Texture'SniperArrows'.VSize );

		// Draw the Charging meter  -AsP
		Canvas.DrawColor = ChargeColor;
        Canvas.DrawColor.A = 255;

		if(ChargeBar <1)
		    Canvas.DrawColor.R = 255*ChargeBar;
		else
        {
            Canvas.DrawColor.R = 0;
		    Canvas.DrawColor.B = 0;
        }

		if(ChargeBar == 1)
		    Canvas.DrawColor.G = 255;
		else
		    Canvas.DrawColor.G = 0;

		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetPos( barOrgX, barOrgY );
		Canvas.DrawTile(Texture'Engine.WhiteTexture',barSizeX,barSizeY*ChargeBar, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize,Texture'Engine.WhiteTexture'.VSize*ChargeBar);
		zoomed = true;
	}
}

simulated function ClientStartFire(int mode)
{
    if (mode == 1)
    {
        FireMode[mode].bIsFiring = true;
        if( Instigator.Controller.IsA( 'PlayerController' ) )
            PlayerController(Instigator.Controller).ToggleZoom();
    }
    else
    {
        Super.ClientStartFire(mode);
    }
}

simulated function ClientStopFire(int mode)
{
    if (mode == 1)
    {
        FireMode[mode].bIsFiring = false;
        if( PlayerController(Instigator.Controller) != None )
            PlayerController(Instigator.Controller).StopZoom();
    }
    else
    {
        Super.ClientStopFire(mode);
    }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    if ( PlayerController(Instigator.Controller) != None )
    {
        LastFOV = PlayerController(Instigator.Controller).DesiredFOV;
		if ( Instigator.IsLocallyControlled() )
			GotoState('TickEffects');
	}
    Super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
    if( Instigator.Controller.IsA( 'PlayerController' ) )
        PlayerController(Instigator.Controller).EndZoom();
    if ( Super.PutDown() )
    {
		GotoState('');
		return true;
	}
	return false;
}

state TickEffects
{
    simulated function Tick( float t )
    {
        if (chargeEmitter == None)
        {
            chargeEmitter = Spawn(class'LightningCharge',self);
            AttachToBone(chargeEmitter, 'tip' );
        }
        chargeEmitter.mRegenPause = ( FireMode[0].NextFireTime > Level.TimeSeconds || AmmoAmount(0) == 0 );
    }
}

// AI Interface
function float SuggestAttackStyle()
{
    return -0.4;
}

function float SuggestDefenseStyle()
{
    return 0.2;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float ZDiff, dist, Result;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;
	if ( B.IsShootingObjective() )
		return AIRating - 0.15;
	if ( B.Enemy == None )
	{
		if ( (B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000 )
			return 0.95;
		return AIRating;
	}

	if ( B.Stopped() )
		result = AIRating + 0.1;
	else
		result = AIRating - 0.1;
	if ( Vehicle(B.Enemy) != None )
		result -= 0.2;
	ZDiff = Instigator.Location.Z - B.Enemy.Location.Z;
	if ( ZDiff < -200 )
		result += 0.1;
	dist = VSize(B.Enemy.Location - Instigator.Location);
	if ( dist > 2000 )
	{
		if ( !B.EnemyVisible() )
			result = result - 0.15;
		return ( FMin(2.0,result + (dist - 2000) * 0.0002) );
	}
	if ( !B.EnemyVisible() )
		return AIRating - 0.1;

	return result;
}


function bool RecommendRangedAttack()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return true;

	return ( VSize(B.Enemy.Location - Instigator.Location) > 2000 * (1 + FRand()) );
}
// end AI Interface

defaultproperties
{
     testX=100.000000
     testY=100.000000
     borderX=60.000000
     borderY=60.000000
     focusX=135.000000
     focusY=105.000000
     innerArrowsX=42.000000
     innerArrowsY=42.000000
     ArrowColor=(R=255,A=255)
     TargetColor=(B=255,G=255,R=255,A=255)
     NoTargetColor=(B=200,G=200,R=200,A=255)
     FocusColor=(B=126,G=90,R=71,A=215)
     ChargeColor=(B=255,G=255,R=255,A=255)
     RechargeOrigin=(X=600.000000,Y=330.000000)
     RechargeSize=(X=10.000000,Y=-180.000000)
     FireModeClass(0)=Class'XWeapons.SniperFire'
     FireModeClass(1)=Class'XWeapons.SniperZoom'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectAnimRate=1.250000
     BringUpTime=0.360000
     SelectSound=Sound'WeaponSounds.LightningGun.SwitchToLightningGun'
     SelectForce="SwitchToLightningGun"
     AIRating=0.690000
     CurrentRating=0.690000
     bSniping=True
     Description="The Lightning Gun is a high-power energy rifle capable of ablating even the heaviest carapace armor. Acquisition of a target at long range requires a steady hand, but the anti-jitter effect of the optical system reduces the weapon's learning curve significantly. Once the target has been acquired, the operator depresses the trigger, painting a proton 'patch' on the target. Milliseconds later the rifle emits a high voltage arc of electricity, which seeks out the charge differential and annihilates the target."
     EffectOffset=(X=100.000000,Y=28.000000,Z=-26.000000)
     DisplayFOV=60.000000
     Priority=20
     HudColor=(B=255,G=170,R=185)
     SmallViewOffset=(X=8.000000,Y=6.300000,Z=-4.000000)
     SmallEffectOffset=(X=92.000000,Y=32.000000,Z=-35.000000)
     CenteredOffsetY=0.000000
     CenteredYaw=-500
     CustomCrosshair=7
     CustomCrossHairColor=(G=170,R=185)
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     MinReloadPct=0.250000
     InventoryGroup=9
     PickupClass=Class'XWeapons.SniperRiflePickup'
     PlayerViewOffset=(Y=2.300000)
     BobDamping=2.300000
     AttachmentClass=Class'XWeapons.SniperAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=246,Y1=182,X2=331,Y2=210)
     ItemName="Lightning Gun"
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=165
     LightSaturation=170
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     Mesh=SkeletalMesh'Weapons.Sniper_1st'
     DrawScale=0.400000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
