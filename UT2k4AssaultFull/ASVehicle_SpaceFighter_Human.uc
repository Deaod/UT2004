//=============================================================================
// ASVehicle_SpaceFighter_Human
//=============================================================================

class ASVehicle_SpaceFighter_Human extends ASVehicle_SpaceFighter;

#exec OBJ LOAD FILE=AS_FX_TX.utx
#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

simulated function SetTrailFX()
{
	// Trail FX
	if ( TrailEmitter==None && Health>0 && Team != 255  )
	{
		TrailEmitter = Spawn(class'FX_SpaceFighter_Trail_Red', Self,, Location - Vector(Rotation)*TrailOffset, Rotation);

		if ( TrailEmitter != None )
		{
			if ( Team == 1 )	// Blue version
				FX_SpaceFighter_Trail_Red(TrailEmitter).SetBlueColor();

			TrailEmitter.SetBase( Self );
		}
	}
}

simulated function AdjustFX()
{
	local float			NewSpeed, VehicleSpeed, SpeedPct;
	local int			i, averageOver;

	// Check that Trail is here
	SetTrailFX();

	// Smooth filter on velocity, which is very instable especially on Jerky frame rate.
	NewSpeed = Max(Velocity Dot Vector(Rotation), EngineMinVelocity);
	SpeedFilter[NextSpeedFilterSlot] = NewSpeed;
	NextSpeedFilterSlot++;

	if ( bSpeedFilterWarmup )
		averageOver = NextSpeedFilterSlot;
	else
		averageOver = SpeedFilterFrames;

	for (i=0; i<averageOver; i++)
		VehicleSpeed += SpeedFilter[i];

	VehicleSpeed /= float(averageOver);

	if ( NextSpeedFilterSlot == SpeedFilterFrames )
	{
		NextSpeedFilterSlot = 0;
		bSpeedFilterWarmup	= false;
	}

	SmoothedSpeedRatio = VehicleSpeed / AirSpeed;
	SpeedPct = VehicleSpeed - EngineMinVelocity*AirSpeed/1000.f;
	SpeedPct = FClamp( SpeedPct / (AirSpeed*( (1000.f-EngineMinVelocity)/1000.f )), 0.f, 1.f );

	// Adjust Engine FX depending on velocity
	if ( TrailEmitter != None )
		AdjustEngineFX( SpeedPct );

	// Animate SpaceFighter depending on velocity
	if ( bGearUp )
		AnimateSkelMesh( SpeedPct );

	UpdateEngineSound( SpeedPct );

	// Adjust FOV depending on speed
	if ( PlayerController(Controller) != None && IsLocallyControlled() )
		PlayerController(Controller).SetFOV( PlayerController(Controller).DefaultFOV + SpeedPct*SpeedPct*15  );
}

simulated function UpdateEngineSound( float SpeedPct )
{
	// Adjust Engine volume
	SoundVolume = 160 +  32 * SpeedPct;
	SoundPitch	=  64 +  16 * SpeedPct;
}

simulated function AdjustEngineFX( float SpeedPct )
{
	local SpriteEmitter	E1, E2;

	E1 = SpriteEmitter(TrailEmitter.Emitters[1]);
	E2 = SpriteEmitter(TrailEmitter.Emitters[2]);

	// Thruster
	E1.SizeScale[1].RelativeSize = 2.00 + 1.0*SpeedPct;
	E1.SizeScale[2].RelativeSize = 2.00 + 1.5*SpeedPct;
	E1.SizeScale[3].RelativeSize = 2.00 + 1.0*SpeedPct;
	E1.Opacity = 1 - SpeedPct * 0.5;

	E2.Opacity = 0.5 + SpeedPct * 0.25;
	E2.StartSizeRange.X.Min = 40 + 10 * SpeedPct;
	E2.StartSizeRange.X.Max = 50 + 25 * SpeedPct;
}

simulated function AnimateSkelMesh( float SpeedPct )
{
	SpeedPct = FClamp(1.f - SpeedPct, 0.f, 0.9);
	SetAnimFrame( SpeedPct );
}

simulated function PlayTakeOff()
{
	// Play Take Off animation
	PlayAnim('TakeOff', 0.75);
}

//
// HUD
//

simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
	super.DrawVehicleHUD( C, PC );
	DrawTargetting( C );
}

simulated function DrawHealthInfo( Canvas C, PlayerController PC )
{
	class'HUD_Assault'.static.DrawCustomHealthInfo( C, PC, false );
	DrawSpeedMeter( C, PC.myHUD, PC );
}

simulated function DrawWeaponInfo( Canvas C, HUD H )
{
	local float		XL, YL;
	local float		ReloadTime, XO, YO, myfPulse;
	local string	VehicleInfoString;
	local float		TexScale;

	TexScale = 0.6;
	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * TexScale * H.ResScaleX * H.HUDScale;
	YL = 128 * TexScale * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey', XL, YL, 0, 0, 256, 128);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(WeaponInfoTexture, XL, YL, 0, 0, 256, 128);

	// Rocket Reload time
	if ( Weapon != None )
		ReloadTime = 1.f - FClamp( (Weapon.GetFireMode(1).NextFireTime-Level.TimeSeconds) / Weapon.GetFireMode(1).FireRate, 0.f, 1.f);
	else
		ReloadTime = 0.f;

	XL = 53 * TexScale * H.ResScaleX * H.HUDScale;
	YL = 10 * TexScale * H.ResScaleY * H.HUDScale;
	XO = C.ClipX - 57 * TexScale * H.ResScaleX * H.HUDScale;
	YO = C.ClipY - 63 * TexScale * H.ResScaleY * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( ReloadTime );
	C.DrawColor.A = 96;

	if ( ReloadTime == 1.f )
	{
		if ( !bRocketLoaded )
		{
			bRocketLoaded = true;
			PlaySound( RocketLoadedSound );
		}
		// Ugly hack FIXME
		if ( HUD_Assault(H) != None )
			myfPulse = HUD_Assault(H).fPulse;
		else
			myfPulse = 1.f;

		C.DrawColor = C.DrawColor * myfPulse + class'Canvas'.Static.MakeColor(255, 255, 255) * (1.f-myfPulse);
		C.DrawColor.A = 128 + 127 * ( 1.f - myfPulse );
	}
	else
		bRocketLoaded = false;

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL*ReloadTime, YL, 0, 0, 8, 8);

	// Target Info
	if ( CurrentTarget == None || CurrentTarget.Health<1 || CurrentTarget.bDeleteMe )
		VehicleInfoString = class'HUD_Assault'.default.NoTargetString;
	else
		VehicleInfoString = CurrentTarget.VehicleNameString;

	XO = C.ClipX - 192 * TexScale * H.ResScaleX * H.HUDScale;
	YO = C.ClipY -  88 * TexScale * H.ResScaleX * H.HUDScale;
	C.Font = H.GetFontSizeIndex( C, -4 - 8 * (1-H.HUDScale) );
	C.StrLen( VehicleInfoString, XL, YL );
	C.SetPos( XO, YO - YL * 0.5 );
	C.SetDrawColor(64, 200, 64, 192);
	C.DrawText( VehicleInfoString, false );

	if ( CurrentTarget != None && CurrentTarget.Health>1 && !CurrentTarget.bDeleteMe )
	{
		if (  CurrentTarget.PlayerReplicationInfo != None )
		{
			YO += YL * 1.5;
			VehicleInfoString = CurrentTarget.PlayerReplicationInfo.PlayerName;
			C.SetPos( XO, YO - YL * 0.5 );
			C.DrawText( VehicleInfoString, false );
		}

		YO += YL * 1.5;
		VehicleInfoString = int(VSize(Location-CurrentTarget.Location)*0.01875.f*6) $ class'HUD_Assault'.default.MetersString;
		C.SetPos( XO, YO - YL * 0.5 );
		C.DrawText( VehicleInfoString, false );
	}

}

simulated function DrawSpeedMeter( Canvas C, HUD H, PlayerController PC )
{
	local float		XL, YL, XL2, YL2, YOffset, XOffset, SpeedPct;

	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * 0.5 * H.ResScaleX * H.HUDScale;
	YL =  64 * 0.5 * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Grey', XL, YL, 0, 0, 256, 64);

	// Speed Bar
	SpeedPct = DesiredVelocity - EngineMinVelocity;
	SpeedPct = FClamp( SpeedPct / (1000.f - EngineMinVelocity), 0.f, 1.f );
	XOffset =  1 * 0.5 * H.ResScaleX * H.HUDScale;
	YOffset = 27 * 0.5 * H.ResScaleY * H.HUDScale;
	XL2		= 84 * 0.5 * H.ResScaleY * H.HUDScale;
	YL2		= 18 * 0.5 * H.ResScaleX * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( SpeedPct );
	C.DrawColor.A = 96;

	C.SetPos( (C.ClipX - XL2) * 0.5 - XOffset, C.ClipY - YOffset - YL2 * 0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL2*SpeedPct, YL2, 0, 0, 8, 8);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(SpeedInfoTexture, XL, YL, 0, 0, 256, 64);
}

simulated function bool DrawCrosshair( Canvas C, out vector ScreenPos )
{
	local Vehicle	V, BestTarget;
	local float		BestDist;

	if ( !super.DrawCrosshair( C, ScreenPos ) )
		return false;

	CrosshairPos = ScreenPos;	// for HUD target tracking

	// Target closest to crosshair here because we need a Canvas to do WorldToScreen
	if ( bTargetClosestToCrosshair )
	{
		BestDist = 50000;
		foreach DynamicActors(class'Vehicle', V)
			if ( IsTargetRelevant(V) && LineOfSightTo( V )
				&& VSize(ScreenPos - C.WorldToScreen(V.Location)) < BestDist )
			{
				BestTarget = V;
				BestDist = VSize(ScreenPos - C.WorldToScreen(V.Location));
			}

		if ( BestTarget != None )
			ServerSetTarget( BestTarget );

		bTargetClosestToCrosshair = false;
	}

	return true;
}

/* Space Fighter Targetting HUD code */
simulated function 	DrawTargetting( Canvas C )
{
	local vector					CamLoc, TargetScreenPos;
	local rotator					CamRot;

	if ( CurrentTarget == None || CurrentTarget.Health<1 || CurrentTarget.bDeleteMe )
		return;

	// Target tracking
	C.GetCameraLocation( CamLoc, CamRot );

	if ( class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, CurrentTarget, TargetScreenPos, CamLoc, CamRot ) )
		DrawVisibleTarget( C, CurrentTarget, TargetScreenPos );
	else
		DrawHiddenTarget( C, CurrentTarget, CamLoc, CamRot );
}


/* Show Target's orientation */
simulated function DrawHiddenTarget( Canvas C, Vehicle V, vector CamLoc, rotator CamRot )
{
	local vector	Orientation;
	local float		X1, X2, Y1, Y2;

	Orientation = class'HUD_Assault'.static.GetTargetOrientation( V, CamLoc, CamRot );
	Orientation = class'HUD_Assault'.static.ExpandTargetOrientationToCanvas( C, Orientation );

	X1 = CrosshairPos.X;
	Y1 = CrosshairPos.Y;
	X2 = C.ClipX * 0.5 + C.ClipX * Orientation.X * 0.5;
	Y2 = C.ClipY * 0.5 - C.ClipY * Orientation.Y * 0.5;

	PlayerController(Controller).myHUD.DrawCanvasLine(X1, Y1, X2, Y2, C.MakeColor(64, 200, 64) );
}

/* Show Target and leading Target reticle */
simulated function DrawVisibleTarget( Canvas C, Vehicle V, Vector ScrPos )
{
	C.Font = class'HUD'.static.GetConsoleFont( C );
	C.DrawColor = C.MakeColor(64, 200, 64);
	C.Style = ERenderStyle.STY_Alpha;

	class'HUD_Assault'.static.Draw_2DCollisionBox( C, V, ScrPos, "", 1.5f, true );
}


static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	L.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	L.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	L.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	L.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP' );
}


simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	Level.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	Level.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	Level.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     FlyingAnim="FinsOpen"
     ShotDownFXClass=Class'UT2k4AssaultFull.FX_SpaceFighter_ShotDownEmitter'
     RocketOffset=(X=-20.000000,Z=-15.000000)
     GenericShieldEffect(0)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield_Red'
     GenericShieldEffect(1)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield'
     WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     DefaultWeaponClassName="UT2k4AssaultFull.Weapon_SpaceFighter"
     VehicleProjSpawnOffset=(X=110.000000,Y=14.000000,Z=-14.000000)
     bCustomHealthDisplay=True
     FPCamPos=(X=15.000000,Z=20.000000)
     VehiclePositionString="in a spacefighter"
     VehicleNameString="Human Spacefighter"
     AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SpaceFighter_Human'
     DrawScale=0.500000
     AmbientGlow=96
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
}
