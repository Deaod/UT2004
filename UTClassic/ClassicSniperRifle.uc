class ClassicSniperRifle extends Weapon
    config(user);

var transient float LastFOV;
var() bool zoomed;
var color ChargeColor;

#exec OBJ LOAD FILE=NewSniperRifle.utx
#exec OBJ LOAD FILE=..\Sounds\NewWeaponSounds.uax

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	FireMode[1].FireAnim = 'Idle';
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

simulated event RenderOverlays( Canvas Canvas )
{
	local float CX,CY,Scale;
	local float chargeBar;
	local float barOrgX, barOrgY;
	local float barSizeX, barSizeY;

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
			chargeBar = 1.0;
		}
		else
		{
			chargeBar = 1.0 - ((FireMode[0].NextFireTime-Level.TimeSeconds) / FireMode[0].FireRate);
		}

		CX = Canvas.ClipX/2;
		CY = Canvas.ClipY/2;
		Scale = Canvas.ClipX/1024;

		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(0,0,0);

		// Draw the crosshair
		Canvas.SetPos(CX-169*Scale,CY-155*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',169*Scale,310*Scale, 164,35, 169,310);
		Canvas.SetPos(CX,CY-155*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',169*Scale,310*Scale, 332,345, -169,-310);

		// Draw Cornerbars
		Canvas.SetPos(160*Scale,160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 111*Scale, 111*Scale , 0 , 0, 111, 111);

		Canvas.SetPos(Canvas.ClipX-271*Scale,160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 111*Scale, 111*Scale , 111 , 0, -111, 111);

		Canvas.SetPos(160*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 111*Scale, 111*Scale, 0 , 111, 111, -111);

		Canvas.SetPos(Canvas.ClipX-271*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 111*Scale, 111*Scale , 111 , 111, -111, -111);


		// Draw the 4 corners
		Canvas.SetPos(0,0);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',160*Scale,160*Scale, 0, 274, 159, -158);

		Canvas.SetPos(Canvas.ClipX-160*Scale,0);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',160*Scale,160*Scale, 159,274, -159, -158);

		Canvas.SetPos(0,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',160*Scale,160*Scale, 0,116, 159, 158);

		Canvas.SetPos(Canvas.ClipX-160*Scale,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair',160*Scale,160*Scale, 159, 116, -159, 158);

		// Draw the Horz Borders
		Canvas.SetPos(160*Scale,0);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', Canvas.ClipX-320*Scale, 160*Scale, 284, 512, 32, -160);

		Canvas.SetPos(160*Scale,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', Canvas.ClipX-320*Scale, 160*Scale, 284, 352, 32, 160);

		// Draw the Vert Borders
		Canvas.SetPos(0,160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 160*Scale, Canvas.ClipY-320*Scale, 0,308, 160,32);

		Canvas.SetPos(Canvas.ClipX-160*Scale,160*Scale);
		Canvas.DrawTile(texture'NewSniperRifle.COGAssaultZoomedCrosshair', 160*Scale, Canvas.ClipY-320*Scale, 160,308, -160,32);

		// Draw the Charging meter
		Canvas.DrawColor = ChargeColor;
        Canvas.DrawColor.A = 255;

		if(chargeBar <1)
		    Canvas.DrawColor.R = 255*chargeBar;
		else
        {
            Canvas.DrawColor.R = 0;
		    Canvas.DrawColor.B = 0;
        }

		if(chargeBar == 1)
		    Canvas.DrawColor.G = 255;
		else
		    Canvas.DrawColor.G = 0;

		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetPos( barOrgX, barOrgY );
		Canvas.DrawTile(Texture'Engine.WhiteTexture',barSizeX,barSizeY*chargeBar, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize,Texture'Engine.WhiteTexture'.VSize*chargeBar);
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
        LastFOV = PlayerController(Instigator.Controller).DesiredFOV;
    Super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
    if( Instigator.Controller.IsA( 'PlayerController' ) )
        PlayerController(Instigator.Controller).EndZoom();
    if ( Super.PutDown() )
		return true;
	return false;
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
			return 0.78;
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

simulated function bool WantsZoomFade()
{
	return true;
}

defaultproperties
{
     ChargeColor=(B=255,G=255,R=255,A=255)
     FireModeClass(0)=Class'UTClassic.ClassicSniperFire'
     FireModeClass(1)=Class'XWeapons.SniperZoom'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectAnimRate=0.750000
     PutDownAnimRate=0.780000
     PutDownTime=0.580000
     BringUpTime=0.600000
     SelectSound=Sound'NewWeaponSounds.NewSniper_load'
     SelectForce="NewSniperLoad"
     AIRating=0.690000
     CurrentRating=0.690000
     bSniping=True
     Description="This high muzzle velocity sniper rifle with a 10X scope is a lethal weapon at any range, especially if you can land a head shot."
     EffectOffset=(X=100.000000,Y=28.000000,Z=-19.000000)
     DisplayFOV=60.000000
     Priority=22
     HudColor=(B=255,G=170,R=185)
     SmallViewOffset=(X=36.900002,Y=10.000000,Z=-14.000000)
     CenteredOffsetY=0.000000
     CenteredYaw=-500
     CustomCrosshair=7
     CustomCrossHairColor=(G=170,R=185)
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     GroupOffset=1
     PickupClass=Class'UTClassic.ClassicSniperRiflePickup'
     PlayerViewOffset=(X=27.700001,Y=5.300000,Z=-10.600000)
     PlayerViewPivot=(Yaw=16384)
     BobDamping=2.300000
     AttachmentClass=Class'UTClassic.ClassicSniperAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=420,Y1=180,X2=512,Y2=210)
     ItemName="Sniper Rifle"
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=170
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     CullDistance=5000.000000
     Mesh=SkeletalMesh'SniperAnims.SniperRifle_1st'
     DrawScale=0.480000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
