//=============================================================================
// ASTurret_BallTurret
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASTurret_BallTurret extends ASTurret;

#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

simulated function DrawWeaponInfo( Canvas C, HUD H )
{
	local float		XL, YL;
	local float		Energy, XO, YO, myfPulse;

	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * 0.5 * H.ResScaleX * H.HUDScale;
	YL = 128 * 0.5 * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey', XL, YL, 0, 0, 256, 128);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(WeaponInfoTexture, XL, YL, 0, 0, 256, 128);

	// Shield Energy
	if ( Weapon != None )
		Energy = FClamp( Weapon.AmmoStatus(1), 0.f, 1.f);
	else
		Energy = 1.f;

	XL = 53 * 0.5 * H.ResScaleX * H.HUDScale;
	YL = 10 * 0.5 * H.ResScaleY * H.HUDScale;
	XO = C.ClipX - 57 * 0.5 * H.ResScaleX * H.HUDScale;
	YO = C.ClipY - 63 * 0.5 * H.ResScaleY * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( Energy );
	C.DrawColor.A = 96;

	if ( Energy == 1.f )
	{
		// Ugly hack FIXME
		if ( HUD_Assault(H) != None )
			myfPulse = HUD_Assault(H).fPulse;
		else
			myfPulse = 1.f;

		C.DrawColor = C.DrawColor * myfPulse + class'Canvas'.Static.MakeColor(255, 255, 255) * (1.f-myfPulse);
		C.DrawColor.A = 128 + 127 * ( 1.f - myfPulse );
	}

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL*Energy, YL, 0, 0, 8, 8);
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Base' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Canon' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( default.WeaponInfoTexture );
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );		// Fire Effect
	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASTurret_Base' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASTurret_Base' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Base' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Canon' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( default.WeaponInfoTexture );
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );		// Fire Effect

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     TurretBaseClass=Class'UT2k4AssaultFull.ASTurret_BallTurret_Base'
     WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj'
     DefaultWeaponClassName="UT2k4AssaultFull.Weapon_Turret"
     bRelativeExitPos=False
     bHasRadar=True
     bHideRemoteDriver=True
     Mesh=SkeletalMesh'AS_VehiclesFull_M.ASTurret_MotherShip2'
}
