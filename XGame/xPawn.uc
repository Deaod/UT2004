class xPawn extends UnrealPawn
    config(User)
    dependsOn(xUtil)
    dependsOn(xPawnSoundGroup)
    dependsOn(xPawnGibGroup);

#exec OBJ LOAD FILE=GameSounds.uax
#exec OBJ LOAD FILE=PlayerSounds.uax
#exec OBJ LOAD FILE=PlayerFootSteps.uax
#exec OBJ LOAD FILE=DanFX.utx
#exec OBJ LOAD FILE=GeneralAmbience.uax
#exec OBJ LOAD FILE=GeneralImpacts.uax
#exec OBJ LOAD FILE=DeRez.utx
#exec OBJ LOAD FILE=WeaponSounds.uax

var int RepeaterDeathCount;

var Combo CurrentCombo;
var bool bBerserk;
var bool bInvis;
var bool bOldInvis;
var bool bGibbed;
var bool bCanDodgeDoubleJump;
var bool bCanBoostDodge;
var bool bAlreadySetup;
var bool bSpawnIn;
var bool bSpawnDone;
var bool bFrozenBody;
var bool bFlaming;
var bool bRubbery;
var bool bClearWeaponOffsets;		// for certain custom player models

var(UDamage) Material UDamageWeaponMaterial;         // Weapon overlay material
var(UDamage) Sound UDamageSound;
var UDamageTimer UDamageTimer;
var float UDamageTime;
var float LastUDamageSoundTime;
var Material InvisMaterial;

var(Shield) float   ShieldStrengthMax;               // max strength
var float SmallShieldStrength;	 // for preventing shieldstacking
var(Shield) Material    ShieldHitMat;
var(Shield) float       ShieldHitMatTime;

var class<SpeciesType> Species;

var(Sounds) float GruntVolume;
var(Sounds) float FootstepVolume;

var transient int   SimHitFxTicker;

var(Gib) class<xPawnGibGroup> GibGroupClass;
var(Gib) int GibCountCalf;
var(Gib) int GibCountForearm;
var(Gib) int GibCountHead;
var(Gib) int GibCountTorso;
var(Gib) int GibCountUpperArm;

var float MinTimeBetweenPainSounds;
var localized string HeadShotMessage;

// Common sounds

var(Sounds) Sound   SoundFootsteps[11]; // Indexed by ESurfaceTypes (sorry about the literal).
var(Sounds) class<xPawnSoundGroup> SoundGroupClass;

var class<Actor>    TeleportFXClass;
var class<Actor> TransEffects[2];

var xWeaponAttachment WeaponAttachment;

var ShadowProjector PlayerShadow;

var int  MultiJumpRemaining;
var int  MaxMultiJump;
var int  MultiJumpBoost; // depends on the tolerance (100)

var name WallDodgeAnims[4];
var name IdleHeavyAnim;
var name IdleRifleAnim;
var name FireHeavyRapidAnim;
var name FireHeavyBurstAnim;
var name FireRifleRapidAnim;
var name FireRifleBurstAnim;
var name FireRootBone;

var enum EFireAnimState
{
    FS_None,
    FS_PlayOnce,
    FS_Looping,
    FS_Ready
} FireState;

var Mesh SkeletonMesh;
var bool bSkeletized;
var bool bDeRes;
var float DeResTime;
var Emitter DeResFX;
var Material DeResMat0, DeResMat1;
var(DeRes) InterpCurve DeResLiftVel; // speed (over time) at which body rises
var(DeRes) InterpCurve DeResLiftSoftness; // vertical 'sprinyness' (over time) of bone lifters
var(DeRes) float  DeResGravScale; // reduce gravity on corpse during de-res
var(DeRes) float  DeResLateralFriction; // sideways friction while lifting

var(Karma) float RagdollLifeSpan; // MAXIMUM time the ragdoll will be around. De-res's early if it comes to rest.
var(Karma) float RagInvInertia; // Use to work out how much 'spin' ragdoll gets on death.
var(Karma) float RagDeathVel; // How fast ragdoll moves upon death
var(Karma) float RagShootStrength; // How much effect shooting ragdolls has. Be careful!
var(Karma) float RagSpinScale; // Increase propensity to spin around Z (up).
var(Karma) float RagDeathUpKick; // Amount of upwards kick ragdolls get when they die
var(Karma) float RagGravScale;

var(Karma) material RagConvulseMaterial;

// Ragdoll impact sounds.
var(Karma) array<sound>		RagImpactSounds;
var(Karma) float			RagImpactSoundInterval;
var(Karma) float			RagImpactVolume;
var transient float			RagLastSoundTime;

var string RagdollOverride;

// translocate effect
var class<Actor>    TransOutEffect[2];

var Controller OldController;
var Material RealSkins[4];
var class<TeamVoicePack> VoiceClass;

var(AI) globalconfig string PlacedCharacterName;
var globalconfig string PlacedFemaleCharacterName;

var byte TeamSkin;		// what team's skin is currently set

replication
{
    reliable if( Role==ROLE_Authority )
		bInvis;

	reliable if( bNetOwner && (Role==ROLE_Authority) )
		bBerserk, MaxMultiJump, MultiJumpBoost, bCanDodgeDoubleJump, bCanBoostDodge;

	reliable if( Role==ROLE_Authority )
		ClientSetUDamageTime;
}

simulated function Fire( optional float F )
{
	if ( (Weapon != None) && (Weapon.bBerserk != bBerserk) )
	{
		if ( bBerserk )
			Weapon.StartBerserk();
		else
			Weapon.StopBerserk();
	}
	Super.Fire(F);
}

simulated function AltFire( optional float F )
{
	if ( (Weapon != None) && (Weapon.bBerserk != bBerserk) )
	{
		if ( bBerserk )
			Weapon.StartBerserk();
		else
			Weapon.StopBerserk();
	}
	Super.AltFire(F);
}

simulated function PlayWaiting() {}

function RosterEntry GetPlacedRoster()
{
	PlayerReplicationInfo.CharacterName = PlacedCharacterName;
	return class'xRosterEntry'.static.CreateRosterEntryCharacter(PlacedCharacterName);
}

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
	if ( Controller != None )
		OldController = Controller;
}

// return true if was controlled by a Player (AI or human)
simulated function bool WasPlayerPawn()
{
	return ( (OldController != None) && OldController.bIsPlayer );
}

function DoTranslocateOut(Vector PrevLocation)
{
	if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 0) )
		Spawn(TransOutEffect[0], self,, PrevLocation, rotator(Location - PrevLocation));
	else
		Spawn(TransOutEffect[1], self,, PrevLocation, rotator(Location - PrevLocation));
}

// Set up default blending parameters and pose. Ensures the mesh doesn't have only a T-pose whenever it first springs into view.
simulated function AssignInitialPose()
{
    if ( DrivenVehicle != None )
    {
		if ( HasAnim(DrivenVehicle.DriveAnim) )
			LoopAnim(DrivenVehicle.DriveAnim,, 0.1);
		else
			LoopAnim('Vehicle_Driving',, 0.1);
	}
	else
		TweenAnim(MovementAnims[0],0.0);
	AnimBlendParams(1, 1.0, 0.2, 0.2, 'Bip01 Spine1');
    BoneRefresh();
}

simulated function Destroyed()
{
    if( PlayerShadow != None )
        PlayerShadow.Destroy();

    if( DeResFX != None )
	{
		DeResFX.Emitters[0].SkeletalMeshActor = None;
		DeResFX.Kill();
	}

    Super.Destroyed();
}

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for( i=0; i<Attached.length; i++ )
    {
        if( Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }
    }
}

simulated event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    if ( NewVolume.bWaterVolume )
        RemoveFlamingEffects();
    Super.PhysicsVolumeChange(NewVolume);
}

/* return a value (typically 0 to 1) adjusting pawn's perceived strength if under some special influence (like berserk)
*/
function float AdjustedStrength()
{
	if ( bBerserk )
		return 1.0;
	return 0;
}

function DeactivateSpawnProtection()
{
	if ( bSpawnDone )
		return;
	bSpawnDone = true;
	if ( Level.TimeSeconds - SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime )
	{
		bSpawnIn = true;
		if ( OverlayMaterial == ShieldHitMat )
			SetOverlayMaterial(None,0,true);
		SpawnTime = Level.TimeSeconds - DeathMatch(Level.Game).SpawnProtectionTime - 1;
	}
}

function PlayTeleportEffect( bool bOut, bool bSound)
{
	if ( !bSpawnIn && (Level.TimeSeconds - SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime) )
	{
		bSpawnIn = true;
		SetOverlayMaterial( ShieldHitMat, DeathMatch(Level.Game).SpawnProtectionTime, false );
	    if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 0) )
		    Spawn(TransEffects[0],,,Location + CollisionHeight * vect(0,0,0.75));
	    else
		    Spawn(TransEffects[1],,,Location + CollisionHeight * vect(0,0,0.75));
	}
	else if ( bOut )
		DoTranslocateOut(Location);
	else if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 0) )
		Spawn(TransEffects[0],self,,Location + CollisionHeight * vect(0,0,0.75));
	else
		Spawn(TransEffects[1],self,,Location + CollisionHeight * vect(0,0,0.75));
    Super.PlayTeleportEffect( bOut, bSound );
}

function PlayMoverHitSound()
{
	PlaySound(SoundGroupClass.static.GetHitSound(), SLOT_Interact);
}

function PlayDyingSound()
{
	// Dont play dying sound if a skeleton. Tricky without vocal chords.
	if ( bSkeletized )
		return;

	if ( bGibbed )
	{
        PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,3.5*TransientSoundVolume,true,500);
		return;
	}

    if ( HeadVolume.bWaterVolume )
    {
        PlaySound(GetSound(EST_Drown), SLOT_Pain,2.5*TransientSoundVolume,true,500);
        return;
    }

	PlaySound(SoundGroupClass.static.GetDeathSound(), SLOT_Pain,2.5*TransientSoundVolume, true,500);
}

function Gasp()
{
    if ( Role != ROLE_Authority )
        return;
    if ( BreathTime < 2 )
        PlaySound(GetSound(EST_Gasp), SLOT_Interact);
    else
        PlaySound(GetSound(EST_BreatheAgain), SLOT_Interact);
}

function Controller GetKillerController()
{
	if ( Controller != None )
		return Controller;
	if ( OldController != None )
		return OldController;
	return None;
}


simulated function int GetTeamNum()
{
	if ( Controller != None )
		return Controller.GetTeamNum();
	if ( (DrivenVehicle != None) && (DrivenVehicle.Controller != None) )
		return DrivenVehicle.Controller.GetTeamNum();
	if ( OldController != None )
		return OldController.GetTeamNum();
	if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) )
		return 255;
	return PlayerReplicationInfo.Team.TeamIndex;
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
		return DrivenVehicle.PlayerReplicationInfo.Team;
	if ( (OldController != None) && (OldController.PlayerReplicationInfo != None) )
		return OldController.PlayerReplicationInfo.Team;
	return None;
}

function RemovePowerups()
{
    if (CurrentCombo != None)
    {
		CurrentCombo.Destroy();
		if ( Controller != None )
			Controller.Adrenaline = 0;
	}
    if ( UDamageTimer != None )
    {
		UDamageTimer.Destroy();
		DisableUDamage();
	}

    Super.RemovePowerups();
}

simulated function TickFX(float DeltaTime)
{
	local int i,NumSkins;

    if ( SimHitFxTicker != HitFxTicker )
    {
        ProcessHitFX();
    }

	if(bInvis && !bOldInvis) // Going invisible
	{
		if ( Left(string(Skins[0]),21) ~= "UT2004PlayerSkins.Xan" )
			Skins[2] = Material(DynamicLoadObject("UT2004PlayerSkins.XanMk3V2_abdomen", class'Material'));

		// Save the 'real' non-invis skin
		NumSkins = Clamp(Skins.Length,2,4);

		for ( i=0; i<NumSkins; i++ )
		{
			RealSkins[i] = Skins[i];
			Skins[i] = InvisMaterial;
		}

		// Remove/disallow projectors on invisible people
		Projectors.Remove(0, Projectors.Length);
		bAcceptsProjectors = false;

		// Invisible - no shadow
		if(PlayerShadow != None)
			PlayerShadow.bShadowActive = false;

		// No giveaway flames either
		RemoveFlamingEffects();
	}
	else if(!bInvis && bOldInvis) // Going visible
	{
		NumSkins = Clamp(Skins.Length,2,4);

		for ( i=0; i<NumSkins; i++ )
			Skins[i] = RealSkins[i];

		bAcceptsProjectors = Default.bAcceptsProjectors;

		if(PlayerShadow != None)
			PlayerShadow.bShadowActive = true;
	}

	bOldInvis = bInvis;

    bDrawCorona = ( !bNoCoronas && !bInvis && (Level.NetMode != NM_DedicatedServer)	&& !bPlayedDeath && (Level.GRI != None) && Level.GRI.bAllowPlayerLights
					&& (PlayerReplicationInfo != None) );


	if ( bDrawCorona && (PlayerReplicationInfo.Team != None) )
	{
		if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
			Texture = Texture'RedMarker_t';
		else
			Texture = Texture'BlueMarker_t';
	}
}

simulated function StartDriving(Vehicle V)
{
	local int i;

	Super.StartDriving(V);

	if( PlayerShadow != None )
		PlayerShadow.bShadowActive = false;

	if ( WeaponAttachment != None )
		WeaponAttachment.Hide(true);

	//hack for sticky grenades
	for (i = 0; i < Attached.Length; i++)
		if (Projectile(Attached[i]) != None)
			Attached[i].SetBase(None);
}

simulated function StopDriving(Vehicle V)
{
	Super.StopDriving(V);

	if( PlayerShadow != None )
		PlayerShadow.bShadowActive = !bInvis;

	if ( WeaponAttachment != None )
		WeaponAttachment.Hide(false);
}

simulated function AttachEffect( class<xEmitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
{
    local Actor a;
    local int i;

    if( bSkeletized || (BoneName == 'None') )
        return;

    for( i = 0; i < Attached.Length; i++ )
    {
        if( Attached[i] == None )
            continue;

        if( Attached[i].AttachmentBone != BoneName )
            continue;

        if( ClassIsChildOf( EmitterClass, Attached[i].Class ) )
            return;
    }

    a = Spawn( EmitterClass,,, Location, Rotation );

    if( !AttachToBone( a, BoneName ) )
    {
        log( "Couldn't attach "$EmitterClass$" to "$BoneName, 'Error' );
        a.Destroy();
        return;
    }

    for( i = 0; i < Attached.length; i++ )
    {
        if( Attached[i] == a )
            break;
    }

    a.SetRelativeRotation( Rotation );
}

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
	SetBoneScale(4,HeadScale,'head');
}

simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );
    if( Giblet == None )
        return;
	Giblet.bFlaming = bFlaming;
	Giblet.SpawnTrail();

    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (250 + 260 * FRand());
    Giblet.LifeSpan = Giblet.LifeSpan + 2 * FRand() - 1;
}

simulated function ProcessHitFX()
{
    local Coords boneCoords;
    local class<xEmitter> HitEffects[4];
    local int i,j;
    local float GibPerterbation;

    if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh) )
    {
		SimHitFxTicker = HitFxTicker;
        return;
    }

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
		j++;
		if ( j > 30 )
		{
			SimHitFxTicker = HitFxTicker;
			return;
		}

        if( (HitFX[SimHitFxTicker].damtype == None) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )
            continue;

        boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

        if ( !Level.bDropDetail && !bSkeletized )
        {
			AttachEffect( GibGroupClass.static.GetBloodEmitClass(), HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

			HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

			if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
			{
				for( i = 0; i < ArrayCount(HitEffects); i++ )
				{
					if( HitEffects[i] == None )
						continue;

					AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
				}
			}
		}
        if ( class'GameInfo'.static.UseLowGore() )
			HitFX[SimHitFxTicker].bSever = false;

        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;
			bFlaming = HitFX[SimHitFxTicker].DamType.Default.bFlaming;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'lthigh':
                case 'rthigh':
                    SpawnGiblet( GetGibClass(EGT_Calf), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    SpawnGiblet( GetGibClass(EGT_Calf), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountCalf -= 2;
                    break;

                case 'rfarm':
                case 'lfarm':
                    SpawnGiblet( GetGibClass(EGT_UpperArm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    SpawnGiblet( GetGibClass(EGT_Forearm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountForearm--;
                    GibCountUpperArm--;
                    break;

                case 'head':
                    SpawnGiblet( GetGibClass(EGT_Head), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountTorso--;
                    break;

                case 'spine':
                case 'none':
                    SpawnGiblet( GetGibClass(EGT_Torso), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountTorso--;
					bGibbed = true;
                    while( GibCountHead-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_Head), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    while( GibCountForearm-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_UpperArm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    while( GibCountUpperArm-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_Forearm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
					if ( !bFlaming && !Level.bDropDetail && (Level.DetailMode != DM_Low) && PlayerCanSeeMe() )
					{
						// extra gibs!!!
						GibPerterbation = FMin(1.0, 1.5 * GibPerterbation);
						SpawnGiblet( GetGibClass(EGT_Calf), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
						SpawnGiblet( GetGibClass(EGT_Calf), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
						SpawnGiblet( GetGibClass(EGT_UpperArm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
						SpawnGiblet( GetGibClass(EGT_Forearm), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
					}
                    break;
            }

            HideBone(HitFX[SimHitFxTicker].bone);
        }
    }
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;

    if( boneName == 'lthigh' )
		boneScaleSlot = 0;
	else if ( boneName == 'rthigh' )
		boneScaleSlot = 1;
	else if( boneName == 'rfarm' )
		boneScaleSlot = 2;
	else if ( boneName == 'lfarm' )
		boneScaleSlot = 3;
	else if ( boneName == 'head' )
		boneScaleSlot = 4;
	else if ( boneName == 'spine' )
		boneScaleSlot = 5;

    SetBoneScale(BoneScaleSlot, 0.0, BoneName);
}

function CalcHitLoc( Vector hitLoc, Vector hitRay, out Name boneName, out float dist )
{
    boneName = GetClosestBone( hitLoc, hitRay, dist );
}

function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r )
{
	local float DismemberProbability;
    local bool bExtraGib;

    if ( FRand() > 0.3f || Damage > 30 || Health <= 0 )
    {
        HitFX[HitFxTicker].damtype = DamageType;

        if( Health <= 0 )
        {
            switch( boneName )
            {
                case 'lfoot':
                    boneName = 'lthigh';
                    break;

                case 'rfoot':
                    boneName = 'rthigh';
                    break;

                case 'rhand':
                    boneName = 'rfarm';
                    break;

                case 'lhand':
                    boneName = 'lfarm';
                    break;

                case 'rshoulder':
                case 'lshoulder':
                    boneName = 'spine';
                    break;
            }

			if( DamageType.default.bAlwaysSevers || (Damage == 1000) )
			{
                HitFX[HitFxTicker].bSever = true;
                if ( boneName == 'None' )
                {
					boneName = 'spine';
					bExtraGib = true;
				}
			}
            else if( (Damage*DamageType.Default.GibModifier > 50+120*FRand()) && (Damage + Health > 0) ) // total gib prob
			{
				HitFX[HitFxTicker].bSever = true;
				boneName = 'spine';
				bExtraGib = true;
			}
            else
            {
	            DismemberProbability = Abs( (Health - Damage*DamageType.Default.GibModifier) / 130.0f );
				switch( boneName )
                {
                    case 'lthigh':
                    case 'rthigh':
                    case 'rfarm':
                    case 'lfarm':
                    case 'head':
                        if( FRand() < DismemberProbability )
                            HitFX[HitFxTicker].bSever = true;
                        break;

                    case 'None':
 						boneName = 'spine';
                     case 'spine':
                        if( FRand() < DismemberProbability * 0.3 )
                        {
                            HitFX[HitFxTicker].bSever = true;
                            if ( FRand() < 0.65 )
								bExtraGib = true;
						}
                        break;
                }
            }
        }

        if ( DamageType.default.bNeverSevers || class'GameInfo'.static.UseLowGore()
	     || (Level.Game != None && Level.Game.PreventSever(self, boneName, Damage, DamageType)) )
        {
		HitFX[HitFxTicker].bSever = false;
		bExtraGib = false;
	}

        HitFX[HitFxTicker].bone = boneName;
        HitFX[HitFxTicker].rotDir = r;
        HitFxTicker = HitFxTicker + 1;
        if( HitFxTicker > ArrayCount(HitFX)-1 )
            HitFxTicker = 0;
        if ( bExtraGib )
        {
		if ( FRand() < 0.25 )
		{
			DoDamageFX('lthigh',1000,DamageType,r);
			DoDamageFX('rthigh',1000,DamageType,r);
		}
		else if ( FRand() < 0.35 )
			DoDamageFX('lthigh',1000,DamageType,r);
		else if ( FRand() < 0.5 )
			DoDamageFX('rthigh',1000,DamageType,r);
	}
    }
}

simulated function StartDeRes()
{
	local KarmaParamsSkel skelParams;
	local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

	AmbientGlow=254;
	MaxLights=0;

	DeResFX = Spawn(class'DeResPart', self, , Location);
	if ( DeResFX != None )
	{
		DeResFX.Emitters[0].SkeletalMeshActor = self;
		DeResFX.SetBase(self);
	}

	Skins[0] = DeResMat0;
	Skins[1] = DeResMat1;
	if ( Skins.Length > 2 )
	{
		for ( i=2; i<Skins.Length; i++ )
			Skins[i] = DeResMat0;
	}

    if( Physics == PHYS_KarmaRagdoll )
    {
		// Attach bone lifter to raise body
        KAddBoneLifter('bip01 Spine', DeResLiftVel, DeResLateralFriction, DeResLiftSoftness);
        KAddBoneLifter('bip01 Spine2', DeResLiftVel, DeResLateralFriction, DeResLiftSoftness);

		// Turn off gravity while de-res-ing
		KSetActorGravScale(DeResGravScale);

        // Turn off collision with the world for the ragdoll.
        KSetBlockKarma(false);

        // Turn off convulsions during de-res
        skelParams = KarmaParamsSkel(KParams);
		skelParams.bKDoConvulsions = false;
    }

    AmbientSound = Sound'GeneralAmbience.Texture19';
    SoundRadius = 40.0;

	// Turn off collision when we de-res (avoids rockets etc. hitting corpse!)
	SetCollision(false, false, false);

	// Remove/disallow projectors
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;

	// Remove shadow
	if(PlayerShadow != None)
		PlayerShadow.bShadowActive = false;

	// Remove flames
	RemoveFlamingEffects();

	// Turn off any overlays
	SetOverlayMaterial(None, 0.0f, true);

    bDeRes = true;
}

simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
	if ( Level.bDropDetail || Level.DetailMode == DM_Low )
		time *= 0.75;
	Super.SetOverlayMaterial(mat,time,bOverride);
}

simulated function TickDeRes(float DeltaTime)
{
	if(LifeSpan < 3.0)
	{
		AmbientGlow = BYTE(254.0 * (LifeSpan / 3.0)); // Scale down over time.
		//ScaleGlow = 1.0 * (LifeSpan / 3.0); // Scale down over time.
		//Log("SG:"$ScaleGlow$" AG:"$AmbientGlow);
	}
}

simulated function Tick(float DeltaTime)
{
	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Controller != None )
		OldController = Controller;

    TickFX(DeltaTime);

    if ( bDeRes )
        TickDeRes(DeltaTime);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    AssignInitialPose();

    if(bActorShadows && bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
    {
        PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
        PlayerShadow.ShadowActor = self;
        PlayerShadow.bBlobShadow = bBlobShadow;
        PlayerShadow.LightDirection = Normal(vect(1,1,3));
        PlayerShadow.LightDistance = 320;
        PlayerShadow.MaxTraceDistance = 350;
        PlayerShadow.InitShadow();
    }
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	MultiJumpRemaining = MaxMultiJump;
	bCanDoubleJump = CanMultiJump();
}

function int ShieldAbsorb( int dam )
{
	local float Interval, damage, Remaining;

	damage = dam;
	
    if ( ShieldStrength == 0 )
    {
        return damage;
    }
	SetOverlayMaterial( ShieldHitMat, ShieldHitMatTime, false );
	PlaySound(sound'WeaponSounds.ArmorHit', SLOT_Pain,2*TransientSoundVolume,,400);
    if ( ShieldStrength > 100 )
    {
		Interval = ShieldStrength - 100;
		if ( Interval >= damage )
		{
			ShieldStrength -= damage;
			return 0;
		}
		else
		{
			ShieldStrength = 100;
			damage -= Interval;
		}
	}
    if ( ShieldStrength > SmallShieldStrength )
    {
		Interval = ShieldStrength - SmallShieldStrength;
		if ( Interval >= 0.75 * damage )
		{
			ShieldStrength -= 0.75 * damage;
			if ( ShieldStrength < SmallShieldStrength )
				SmallShieldStrength = ShieldStrength;
			return (0.25 * Damage);
		}
		else
		{
			ShieldStrength = SmallShieldStrength;
			damage -= Interval;
			Remaining = 0.33 * Interval;
			if ( Remaining <= damage )
				return damage;
			damage -= Remaining;
		}
	}
	if ( ShieldStrength >= 0.5 * damage )
	{
		ShieldStrength -= 0.5 * damage;
		SmallShieldStrength = ShieldStrength;
		return Remaining + (0.5 * damage);
	}
	else
	{
		damage -= ShieldStrength;
		ShieldStrength = 0;
		SmallShieldStrength = 0;
	}
	return damage + Remaining;
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
    local Vector HitNormal;
    local Vector HitRay;
    local Name HitBone;
    local float HitBoneDist;
    local PlayerController PC;
	local bool bShowEffects, bRecentHit;
	local BloodSpurt BloodHit;

	bRecentHit = Level.TimeSeconds - LastPainTime < 0.5;
	Super.PlayHit(Damage,InstigatedBy,HitLocation,DamageType,Momentum);
    if ( Damage <= 0 )
		return;

    PC = PlayerController(Controller);
	bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 2.5)
					|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None))
					|| (PC != None) );
	if ( !bShowEffects )
		return;

    HitRay = vect(0,0,0);
    if( InstigatedBy != None )
        HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));

    if( DamageType.default.bLocationalHit )
        CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );
    else
    {
        HitLocation = Location;
        HitBone = 'None';
        HitBoneDist = 0.0f;
    }

    if( DamageType.default.bAlwaysSevers && DamageType.default.bSpecial )
        HitBone = 'head';

	if( InstigatedBy != None )
		HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
	else
		HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

	if ( DamageType.Default.bCausesBlood )
	{
		if ( class'GameInfo'.static.UseLowGore() )
		{
			if ( class'GameInfo'.static.NoBlood() )
				BloodHit = BloodSpurt(Spawn( GibGroupClass.default.NoBloodHitClass,InstigatedBy,, HitLocation ));
			else
				BloodHit = BloodSpurt(Spawn( GibGroupClass.default.LowGoreBloodHitClass,InstigatedBy,, HitLocation ));
		}
		else
			BloodHit = BloodSpurt(Spawn(GibGroupClass.default.BloodHitClass,InstigatedBy,, HitLocation, Rotator(HitNormal)));
		if ( BloodHit != None )
		{
			BloodHit.bMustShow = !bRecentHit;
			if ( Momentum != vect(0,0,0) )
				BloodHit.HitDir = Momentum;
			else
			{
				if ( InstigatedBy != None )
					BloodHit.HitDir = Location - InstigatedBy.Location;
				else
					BloodHit.HitDir = Location - HitLocation;
				BloodHit.HitDir.Z = 0;
			}
		}
	}

	// hack for flak cannon gibbing
	if ( (DamageType.name == 'DamTypeFlakChunk') && (Health < 0) && (InstigatedBy != None) && (VSize(InstigatedBy.Location - Location) < 350) )
		DoDamageFX( HitBone, 8*Damage, DamageType, Rotator(HitNormal) );
	else
		DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );

	if (DamageType.default.DamageOverlayMaterial != None && Damage > 0 ) // additional check in case shield absorbed
				SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false );
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    if (Weapon != None)
        return Weapon.CheckReflect( HitLocation, RefNormal, Damage );
    else
        return false;
}

function name GetWeaponBoneFor(Inventory I)
{
     return 'righthand';
}

function name GetOffhandBoneFor(Inventory I)
{
     return 'bip01 l hand';
}

event Landed(vector HitNormal)
{
    super.Landed( HitNormal );
    MultiJumpRemaining = MaxMultiJump;

    if ( (Health > 0) && !bHidden && (Level.TimeSeconds - SplashTime > 0.25) )
        PlayOwnedSound(GetSound(EST_Land), SLOT_Interact, FMin(1,-0.3 * Velocity.Z/JumpZ));
}

// ----- animation ----- //

simulated function name GetAnimSequence()
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
    return anim;
}

simulated function PlayDoubleJump()
{
    local name Anim;

    Anim = DoubleJumpAnims[Get4WayDirection()];
    if ( PlayAnim(Anim, 1.0, 0.1) )
        bWaitForAnim = true;
    AnimAction = Anim;
}

simulated function bool FindValidTaunt( out name Sequence )
{
	local int i,j;

	for( i=0; i<TauntAnims.Length; i++ )
	{
		if( Sequence == TauntAnims[i] )
			return true;
	}
	
	// see if a valid alias exists
	j = class'SpeciesType'.static.GetOffsetForSequence(Sequence);
	if ( (j < 0) || (j >= TauntAnims.Length) )
		return false;
		
	Sequence = TauntAnims[j];
	return (Sequence != '' );
}

simulated event SetAnimAction(name NewAction)
{
    if (!bWaitForAnim)
    {
	    AnimAction = NewAction;
		if ( AnimAction == 'Weapon_Switch' )
        {
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
        }
        else if ( ((Physics == PHYS_None)|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')))
				&& (DrivenVehicle == None) )
        {
            PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (DrivenVehicle != None) || (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
		{
			if ( CheckTauntValid(AnimAction) )
			{
				if (FireState == FS_None || FireState == FS_Ready)
				{
					AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
					PlayAnim(NewAction,, 0.1, 1);
					FireState = FS_Ready;
				}
			}
			else if ( PlayAnim(AnimAction) )
			{
				if ( Physics != PHYS_None )
					bWaitForAnim = true;
			}
			else
				AnimAction = '';
		}
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {
            PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
            if (FireState == FS_None || FireState == FS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
            }
        }
    }
}

simulated function StartFiring(bool bHeavy, bool bRapid)
{
    local name FireAnim;

    if ( HasUDamage() && (Level.TimeSeconds - LastUDamageSoundTime > 0.25) )
    {
        LastUDamageSoundTime = Level.TimeSeconds;
        PlaySound(UDamageSound, SLOT_None, 1.5*TransientSoundVolume,,700);
    }

    if (Physics == PHYS_Swimming)
        return;

    if (bHeavy)
    {
        if (bRapid)
            FireAnim = FireHeavyRapidAnim;
        else
            FireAnim = FireHeavyBurstAnim;
    }
    else
    {
        if (bRapid)
            FireAnim = FireRifleRapidAnim;
        else
            FireAnim = FireRifleBurstAnim;
    }

    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

    if (bRapid)
    {
        if (FireState != FS_Looping)
        {
            LoopAnim(FireAnim,, 0.0, 1);
            FireState = FS_Looping;
        }
    }
    else
    {
        PlayAnim(FireAnim,, 0.0, 1);
        FireState = FS_PlayOnce;
    }

    IdleTime = Level.TimeSeconds;
}

simulated function StopFiring()
{
    if (FireState == FS_Looping)
    {
        FireState = FS_PlayOnce;
    }
    IdleTime = Level.TimeSeconds;
}

simulated function AnimEnd(int Channel)
{
    if (Channel == 1)
    {
        if (FireState == FS_Ready)
        {
            AnimBlendToAlpha(1, 0.0, 0.12);
            FireState = FS_None;
        }
        else if (FireState == FS_PlayOnce)
        {
            PlayAnim(IdleWeaponAnim,, 0.2, 1);
            FireState = FS_Ready;
            IdleTime = Level.TimeSeconds;
        }
        else
            AnimBlendToAlpha(1, 0.0, 0.12);
    }
    else if ( bKeepTaunting && (Channel == 0) )
		PlayVictoryAnimation();
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
    SetAnimAction('Weapon_Switch');
}

function PlayVictoryAnimation()
{
	local int tauntNum;

	// First 4 taunts are 'order' anims. Don't pick them.
	tauntNum = Rand(TauntAnims.Length - 3);
	SetAnimAction(TauntAnims[3 + tauntNum]);
}

simulated function SetWeaponAttachment(xWeaponAttachment NewAtt)
{
    WeaponAttachment = NewAtt;
    if (WeaponAttachment.bHeavy)
        IdleWeaponAnim = IdleHeavyAnim;
    else
        IdleWeaponAnim = IdleRifleAnim;
}

// Event called whenever ragdoll convulses
event KSkelConvulse()
{
	if(RagConvulseMaterial != None)
		SetOverlayMaterial(RagConvulseMaterial, 0.4, true);
}

simulated final function RandSpin(float spinRate)
{
    DesiredRotation = RotRand(true);
    RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
    RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
    RotationRate.Roll = spinRate * 2 *FRand() - spinRate;

    bFixedRotationDir = true;
    bRotateToDesired = false;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local float frame, rate;
    local name seq;
	local LavaDeath LD;
	local BodyEffect BE;

	AmbientSound = None;
    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    if (CurrentCombo != None)
        CurrentCombo.Destroy();

	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    if ( DamageType != None )
    {
		if ( DamageType.default.bSkeletize )
		{
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 4.0, true);
			if (!bSkeletized)
			{
				if ( (Level.NetMode != NM_DedicatedServer) && (SkeletonMesh != None) )
				{
					if ( DamageType.default.bLeaveBodyEffect )
					{
						BE = spawn(class'BodyEffect',self);
						if ( BE != None )
						{
							BE.DamageType = DamageType;
							BE.HitLoc = HitLoc;
							bFrozenBody = true;
						}
					}
					GetAnimParams( 0, seq, frame, rate );
					LinkMesh(SkeletonMesh, true);
					Skins.Length = 0;
					PlayAnim(seq, 0, 0);
					SetAnimFrame(frame);
				}
				if (Physics == PHYS_Walking)
					Velocity = Vect(0,0,0);
				TearOffMomentum *= 0.25;
				bSkeletized = true;
				if ( (Level.NetMode != NM_DedicatedServer) && (DamageType == class'FellLava') )
				{
					LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
					if ( LD != None )
						LD.SetBase(self);
					PlaySound( sound'WeaponSounds.BExplosion5', SLOT_None, 1.5*TransientSoundVolume );
				}
			}
		}
		else if ( DamageType.Default.DeathOverlayMaterial != None )
			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
		else if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 2*DamageType.default.DamageOverlayTime, true);
	}

    // stop shooting
    AnimBlendParams(1, 0.0);
    FireState = FS_None;
	LifeSpan = RagdollLifeSpan;

    GotoState('Dying');
    if ( BE != None )
		return;

	PlayDyingAnimation(DamageType, HitLoc);
}

function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != None && pc.ViewTarget == self )
			PlayersRagdoll = true;

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.
		if( (Level.PhysicsDetailLevel != PDL_High) && !PlayersRagdoll && (Level.TimeSeconds - LastRenderTime > 3) )
		{
			Destroy();
			return;
		}

		// Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else if(Species != None)
			RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
		else
			Log("xPawn.PlayDying: No Species");

		// If we managed to find a name, try and make a rag-doll slot availbale.
		if( RagSkelName != "" )
		{
			KMakeRagdollAvailable();
		}

		if( KIsRagdollAvailable() && RagSkelName != "" )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;

			// Stop animation playing.
			StopAnimating(true);

			if( DamageType != None )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(TearOffMomentum);
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;

			// We scale the hit location out sideways a bit, to get more spin around Z.
			hitLocRel.X *= RagSpinScale;
			hitLocRel.Y *= RagSpinScale;

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(TearOffMomentum) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else
			{
				deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);
			}

    		// Set initial angular and linear velocity for ragdoll.
			// Scale horizontal velocity for characters - they run really fast!
			if ( DamageType.Default.bRubbery )
				skelParams.KStartLinVel = vect(0,0,0);
			if ( Damagetype.default.bKUseTearOffMomentum )
				skelParams.KStartLinVel = TearOffMomentum + Velocity;
			else
			{
				skelParams.KStartLinVel.X = 0.6 * Velocity.X;
				skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
				skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
    				skelParams.KStartLinVel += shotStrength;
			}
			// If not moving downwards - give extra upward kick
			if( !DamageType.default.bLeaveBodyEffect && !DamageType.Default.bRubbery && (Velocity.Z > -10) )
				skelParams.KStartLinVel.Z += RagDeathUpKick;

			if ( DamageType.Default.bRubbery )
			{
				Velocity = vect(0,0,0);
    			skelParams.KStartAngVel = vect(0,0,0);
    		}
			else
			{
    			skelParams.KStartAngVel = deathAngVel;

    			// Set up deferred shot-bone impulse
				maxDim = Max(CollisionRadius, CollisionHeight);

    			skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
    			skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
    			skelParams.KShotStrength = RagShootStrength;
			}

    		// If this damage type causes convulsions, turn them on here.
    		if(DamageType != None && DamageType.default.bCauseConvulsions)
    		{
    			RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
    			skelParams.bKDoConvulsions = true;
		    }

    		// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);

			// Set physics mode to ragdoll.
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			// If viewing this ragdoll, set the flag to indicate that it is 'important'
			if( PlayersRagdoll )
				skelParams.bKImportantRagdoll = true;

			skelParams.bRubbery = DamageType.Default.bRubbery;
			bRubbery = DamageType.Default.bRubbery;

			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}

	// non-ragdoll death fallback
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	PlayDyingSound();
    if( GibCountTorso+GibCountHead+GibCountForearm+GibCountUpperArm > 3 )
    {
        if ( class'GameInfo'.static.UseLowGore() )
        {
        	if ( !class'GameInfo'.static.NoBlood() )
	            Spawn( GibGroupClass.default.LowGoreBloodGibClass,,,Location );
	    }
        else
            Spawn( GibGroupClass.default.BloodGibClass,,,Location );
    }
    if ( class'GameInfo'.static.UseLowGore() )
		return;

    SpawnGiblet( GetGibClass(EGT_Torso), Location, HitRotation, ChunkPerterbation );
    GibCountTorso--;

    while( GibCountTorso-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Torso), Location, HitRotation, ChunkPerterbation );
    while( GibCountHead-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Head), Location, HitRotation, ChunkPerterbation );
    while( GibCountForearm-- > 0 )
        SpawnGiblet( GetGibClass(EGT_UpperArm), Location, HitRotation, ChunkPerterbation );
    while( GibCountUpperArm-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Forearm), Location, HitRotation, ChunkPerterbation );
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    PlayDirectionalHit(HitLocation);

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;

    if( HeadVolume.bWaterVolume )
    {
        if( DamageType.IsA('Drowned') )
            PlaySound( GetSound(EST_Drown), SLOT_Pain,1.5*TransientSoundVolume );
        else
            PlaySound( GetSound(EST_HitUnderwater), SLOT_Pain,1.5*TransientSoundVolume );
        return;
    }

    PlaySound(SoundGroupClass.static.GetHitSound(), SLOT_Pain,2*TransientSoundVolume,,200);
}

// jag
// Called when in Ragdoll when we hit something over a certain threshold velocity
// Used to play impact sounds.
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds, soundNum;
	numSounds = RagImpactSounds.Length;

	//log("ouch! iv:"$VSize(impactVel));

	if(numSounds > 0 && Level.TimeSeconds > RagLastSoundTime + RagImpactSoundInterval)
	{
		soundNum = Rand(numSounds);
		//Log("Play Sound:"$soundNum);
		PlaySound(RagImpactSounds[soundNum], SLOT_Pain, RagImpactVolume);
		RagLastSoundTime = Level.TimeSeconds;
	}
}
//jag

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Velocity) < 10.0 && VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // velocity based
    else if ( VSize(Velocity) > 0.0 )
    {
        Dir = Normal(Velocity*Vect(1,1,0));
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
        PlayAnim('DeathB',, 0.2);
    else if ( Dir Dot X < -0.7 )
         PlayAnim('DeathF',, 0.2);
    else if ( Dir Dot Y > 0 )
        PlayAnim('DeathL',, 0.2);
    else if ( HasAnim('DeathR') )
        PlayAnim('DeathR',, 0.2);
    else
        PlayAnim('DeathF',, 0.2);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

	if ( DrivenVehicle != None )
		return;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim('HitF',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('HitB',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('HitR',, 0.1);
    }
    else
    {
        PlayAnim('HitL',, 0.1);
    }
}

simulated function FootStepping(int Side)
{
    local int SurfaceNum, i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End,HitLocation,HitNormal;

    SurfaceNum = 0;

    for ( i=0; i<Touching.Length; i++ )
		if ( ((PhysicsVolume(Touching[i]) != None) && PhysicsVolume(Touching[i]).bWaterVolume)
			|| (FluidSurfaceInfo(Touching[i]) != None) )
		{
			if ( FRand() < 0.5 )
				PlaySound(sound'PlayerSounds.FootStepWater2', SLOT_Interact, FootstepVolume );
			else
				PlaySound(sound'PlayerSounds.FootStepWater1', SLOT_Interact, FootstepVolume );
				
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.NetMode != NM_DedicatedServer)
				&& !Touching[i].TraceThisActor(HitLocation, HitNormal,Location - CollisionHeight*vect(0,0,1.1), Location) )
					Spawn(class'WaterRing',,,HitLocation,rot(16384,0,0));
			return;
		}

	if ( bIsCrouched || bIsWalking )
		return;

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceNum = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,16);
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if (FloorMat !=None)
			SurfaceNum = FloorMat.SurfaceType;
	}
	PlaySound(SoundFootsteps[SurfaceNum], SLOT_Interact, FootstepVolume,,400 );
}

simulated function PlayFootStepLeft()
{
    PlayFootStep(-1);
}

simulated function PlayFootStepRight()
{
    PlayFootStep(1);
}

// ----- shield control ----- //
function float GetShieldStrengthMax()
{
    return ShieldStrengthMax;
}

function float GetShieldStrength()
{
    // could return max if it's active right now, which make it unable to be recharged while it's on...
    return ShieldStrength;
}

function int CanUseShield(int ShieldAmount)
{
	ShieldStrength = Max(ShieldStrength,0);
	if ( ShieldStrength < ShieldStrengthMax )
	{
		if ( ShieldAmount == 50 )
			ShieldAmount = 50 - SmallShieldStrength;
		return (Min(ShieldStrengthMax, ShieldStrength + ShieldAmount) - ShieldStrength);
	}
    return 0;
}

function bool AddShieldStrength(int ShieldAmount)
{
	local int OldShieldStrength;

	OldShieldStrength = ShieldStrength;
	ShieldStrength += CanUseShield(ShieldAmount);
	if ( ShieldAmount == 50 )
	{
		SmallShieldStrength = 50;
		if ( ShieldStrength < 50 )
			ShieldStrength = 50;
	}
	return (ShieldStrength != OldShieldStrength);
}

function bool InCurrentCombo()
{
	return (CurrentCombo != None);
}

// used by bots doing combos
function DoComboName( string ComboClassName )
{
    local class<Combo> ComboClass;

    ComboClass = class<Combo>( DynamicLoadObject( ComboClassName, class'Class' ) );
    if ( ComboClass != None )
			DoCombo( ComboClass );
	else
		log("WARNING - Couldn't create combo "$ComboClassName);
}

function DoCombo( class<Combo> ComboClass )
{
	local int i;

    if ( ComboClass != None )
    {
        if (CurrentCombo == None)
        {
	        CurrentCombo = Spawn( ComboClass, self );

			// Record stats for using the combo
			UnrealMPGameInfo(Level.Game).SpecialEvent(PlayerReplicationInfo,""$CurrentCombo.Class);
			if ( ComboClass.Name == 'ComboSpeed' )
				i = 0;
			else if ( ComboClass.Name == 'ComboBerserk' )
				i = 1;
			else if ( ComboClass.Name == 'ComboDefensive' )
				i = 2;
			else if ( ComboClass.Name == 'ComboInvis' )
				i = 3;
			else
				i = 4;
			TeamPlayerReplicationInfo(PlayerReplicationInfo).Combos[i] += 1;
        }
    }
}

simulated function bool HasUDamage()
{
    return (UDamageTime > Level.TimeSeconds);
}

function ClientSetUDamageTime(float NewUDam)
{
	UDamageTime = Level.TimeSeconds + NewUDam;
}

function EnableUDamage(float amount)
{
    UDamageTime = FMax(UDamageTime, Level.TimeSeconds+amount);
    ClientSetUDamageTime(UDamageTime - Level.TimeSeconds);
    if ( UDamageTimer == None )
		UDamageTimer = Spawn(class'UDamageTimer',self);
	UDamageTimer.SetTimer(UDamageTime - Level.TimeSeconds - 3,false);
	LightType = LT_Steady;
	bDynamicLight = true;
    SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, false);
}

function DisableUDamage()
{
	LightType = LT_None;
	bDynamicLight = false;
	UDamageTime = Level.TimeSeconds - 1;
	ClientSetUDamageTime(-1);
    SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, false);
}

function SetWeaponOverlay(Material mat, float time, bool override)
{
    if (Weapon != None)
    {
        Weapon.SetOverlayMaterial(mat, time, override);
        if (WeaponAttachment(Weapon.ThirdPersonActor) != None)
            WeaponAttachment(Weapon.ThirdPersonActor).SetOverlayMaterial(mat, time, override);
    }
}

function ChangedWeapon()
{
    Super.ChangedWeapon();
    if (Weapon != None && Role < ROLE_Authority)
    {
        if (bBerserk)
            Weapon.StartBerserk();
        else if ( Weapon.bBerserk )
			Weapon.StopBerserk();
    }
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
	local float InvisTime;

	if ( bInvis )
	{
	    if ( (OldWeapon != None) && (OldWeapon.OverlayMaterial == InvisMaterial) )
		    InvisTime = OldWeapon.ClientOverlayCounter;
	    else
		    InvisTime = 20000;
	}
    if (HasUDamage() || bInvis)
        SetWeaponOverlay(None, 0.f, true);

    Super.ServerChangedWeapon(OldWeapon, NewWeapon);

    if (bInvis)
        SetWeaponOverlay(InvisMaterial, InvisTime, true);
    else if (HasUDamage())
        SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, false);

    if (bBerserk)
        Weapon.StartBerserk();
    else if ( Weapon.bBerserk )
		Weapon.StopBerserk();
}

function SetInvisibility(float time)
{
    bInvis = (time > 0.0);
    if (Role == ROLE_Authority)
    {
        if (bInvis)
		{
			if ( (time == 2000000.0) && Level.Game.IsA('xMutantGame') ) // for mutant game
				Visibility = Default.Visibility;
			else
				Visibility = 1;
            SetWeaponOverlay(InvisMaterial, time, true);
        }
        else
        {
			Visibility = Default.Visibility;
            if (HasUDamage())
                SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, true);
            else
                SetWeaponOverlay(None, 0.0, true);
        }
    }
}

/* BotDodge()
returns appropriate vector for dodge in direction Dir (which should be normalized)
*/
function vector BotDodge(Vector Dir)
{
	local vector Vel;

	Vel = DodgeSpeedFactor*GroundSpeed*Dir;
	Vel.Z = DodgeSpeedZ;
	return Vel;
}


function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z, TraceStart, TraceEnd, Dir, Cross, HitLocation, HitNormal;
    local Actor HitActor;
	local rotator TurnRot;

    if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking && Physics != PHYS_Falling) )
        return false;

	TurnRot.Yaw = Rotation.Yaw;
    GetAxes(TurnRot,X,Y,Z);

    if ( Physics == PHYS_Falling )
    {
		if ( !bCanWallDodge )
			return false;
        if (DoubleClickMove == DCLICK_Forward)
            TraceEnd = -X;
        else if (DoubleClickMove == DCLICK_Back)
            TraceEnd = X;
        else if (DoubleClickMove == DCLICK_Left)
            TraceEnd = Y;
        else if (DoubleClickMove == DCLICK_Right)
            TraceEnd = -Y;
        TraceStart = Location - CollisionHeight*Vect(0,0,1) + TraceEnd*CollisionRadius;
        TraceEnd = TraceStart + TraceEnd*32.0;
        HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(1,1,1));
        if ( (HitActor == None) || (!HitActor.bWorldGeometry && (Mover(HitActor) == None)) )
             return false;
	}
    if (DoubleClickMove == DCLICK_Forward)
    {
		Dir = X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Back)
    {
		Dir = -1 * X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Left)
    {
		Dir = -1 * Y;
		Cross = X;
	}
    else if (DoubleClickMove == DCLICK_Right)
    {
		Dir = Y;
		Cross = X;
	}
	if ( AIController(Controller) != None )
		Cross = vect(0,0,0);
	return PerformDodge(DoubleClickMove, Dir,Cross);
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
    local float VelocityZ;
    local name Anim;

    if ( Physics == PHYS_Falling )
    {
        if (DoubleClickMove == DCLICK_Forward)
            Anim = WallDodgeAnims[0];
        else if (DoubleClickMove == DCLICK_Back)
            Anim = WallDodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = WallDodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = WallDodgeAnims[3];

        if ( PlayAnim(Anim, 1.0, 0.1) )
            bWaitForAnim = true;
            AnimAction = Anim;
            
		TakeFallingDamage();
        if (Velocity.Z < -DodgeSpeedZ*0.5)
			Velocity.Z += DodgeSpeedZ*0.5;
    }

    VelocityZ = Velocity.Z;
    Velocity = DodgeSpeedFactor*GroundSpeed*Dir + (Velocity Dot Cross)*Cross;

	if ( !bCanDodgeDoubleJump )
		MultiJumpRemaining = 0;
	if ( bCanBoostDodge || (Velocity.Z < -100) )
		Velocity.Z = VelocityZ + DodgeSpeedZ;
	else
		Velocity.Z = DodgeSpeedZ;

    CurrentDir = DoubleClickMove;
    SetPhysics(PHYS_Falling);
    PlayOwnedSound(GetSound(EST_Dodge), SLOT_Pain, GruntVolume,,80);
    return true;
}

function DoDoubleJump( bool bUpdating )
{
    PlayDoubleJump();

    if ( !bIsCrouched && !bWantsToCrouch )
    {
		if ( !IsLocallyControlled() || (AIController(Controller) != None) )
			MultiJumpRemaining -= 1;
        Velocity.Z = JumpZ + MultiJumpBoost;
        SetPhysics(PHYS_Falling);
        if ( !bUpdating )
			PlayOwnedSound(GetSound(EST_DoubleJump), SLOT_Pain, GruntVolume,,80);
    }
}

function bool CanDoubleJump()
{
	return ( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) );
}

function bool CanMultiJump()
{
	return ( MaxMultiJump > 0 );
}

function bool DoJump( bool bUpdating )
{
    // This extra jump allows a jumping or dodging pawn to jump again mid-air
    // (via thrusters). The pawn must be within +/- 100 velocity units of the
    // apex of the jump to do this special move.
    if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < 100) && IsLocallyControlled() )
    {
		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
        DoDoubleJump(bUpdating);
        MultiJumpRemaining -= 1;
        return true;
    }

    if ( Super.DoJump(bUpdating) )
    {
		if ( !bUpdating )
			PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);
        return true;
    }
    return false;
}

simulated function NotifyTeamChanged()
{
	// my PRI now has a new team
	PostNetReceive();
}

simulated event PostNetReceive()
{
	if ( ForceDefaultCharacter() )
	{
		Setup(class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter()));
        bNetNotify = false;
	}
	else if ( PlayerReplicationInfo != None )
    {
		Setup(class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName));
        bNetNotify = false;
    }
    else if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
    {
		Setup(class'xUtil'.static.FindPlayerRecord(DrivenVehicle.PlayerReplicationInfo.CharacterName));
        bNetNotify = false;
    }
}

simulated function ClientRestart()
{
	Super.ClientRestart();
	if ( Controller != None )
		OldController = Controller;
}

simulated function bool CheckValidFemaleDefault()
{
	return ( (PlacedFemaleCharacterName ~= "Tamika")
			|| (PlacedFemaleCharacterName ~= "Sapphire")
			|| (PlacedFemaleCharacterName ~= "Enigma")
			|| (PlacedFemaleCharacterName ~= "Cathode")
			|| (PlacedFemaleCharacterName ~= "Rylisa")
			|| (PlacedFemaleCharacterName ~= "Ophelia")
			|| (PlacedFemaleCharacterName ~= "Zarina") );
}

simulated function bool CheckValidMaleDefault()
{
	return ( (PlacedCharacterName ~= "Jakob")
			|| (PlacedCharacterName ~= "Gorge")
			|| (PlacedCharacterName ~= "Malcolm")
			|| (PlacedCharacterName ~= "Xan")
			|| (PlacedCharacterName ~= "Brock")
			|| (PlacedCharacterName ~= "Gaargod")
			|| (PlacedCharacterName ~= "Axon") );
}

simulated function bool ForceDefaultCharacter()
{
	local PlayerController P;

	if ( !class'DeathMatch'.default.bForceDefaultCharacter )
		return false;
		
	// validate and use player's model for enemies of same sex
	P = Level.GetLocalPlayerController();
	if ( (P != None) && (P.PlayerReplicationInfo != None) )
	{
		if ( P.PlayerReplicationInfo.bIsFemale )
		{
			PlacedFemaleCharacterName = P.PlayerReplicationInfo.CharacterName;
			if ( !CheckValidFemaleDefault() )
			{
				PlacedFemaleCharacterName = "Tamika";
				return false;
			}
		}
		else
		{
			PlacedCharacterName = P.PlayerReplicationInfo.CharacterName;
			if ( !CheckValidMaleDefault() )
			{
				PlacedCharacterName = "Jakob";
				return false;
			}
		}
	}
	return true;
}

simulated function string GetDefaultCharacter()
{
	if ( Level.IsDemoBuild() )
	{
		PlacedFemaleCharacterName = "Tamika";
		PlacedCharacterName = "Jakob";
	}
	else
	{
		// make sure picking from valid default characters
		if ( !CheckValidFemaleDefault() )
			PlacedFemaleCharacterName = "Tamika";
			
		if ( !CheckValidMaleDefault() )
			PlacedCharacterName = "Jakob";
	}
	// return appropriate character based on this pawn's sex
	if ( (PlayerReplicationInfo != None) && PlayerReplicationInfo.bIsFemale )
		return PlacedFemaleCharacterName;
	else
		return PlacedCharacterName;
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	if ( (rec.Species == None) || ForceDefaultCharacter() )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());

    Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if ( !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		if ( !Species.static.Setup(self,rec) )
			return;
	}
	ResetPhysicsBasedAnim();
}

simulated function ResetPhysicsBasedAnim()
{
    bIsIdle = false;
    bWaitForAnim = false;
}

function Sound GetSound(xPawnSoundGroup.ESoundType soundType)
{
    return SoundGroupClass.static.GetSound(soundType);
}

function class<Gib> GetGibClass(xPawnGibGroup.EGibType gibType)
{
    return GibGroupClass.static.GetGibClass(gibType);
}

simulated function DoDerezEffect()
{
    Spawn(TeleportFXClass);
}

State Dying
{
    simulated function AnimEnd( int Channel )
    {
        ReduceCylinder();
    }

	event FellOutOfWorld(eKillZType KillType)
	{
		local LavaDeath LD;

		// If we fall past a lava killz while dead- burn off skin.
		if( KillType == KILLZ_Lava )
		{
			if ( !bSkeletized )
			{
				if ( SkeletonMesh != None )
				{
					LinkMesh(SkeletonMesh, true);
					Skins.Length = 0;
				}
				bSkeletized = true;

				LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
				if ( LD != None )
					LD.SetBase(self);
				// This should destroy itself once its finished.

				PlaySound( sound'WeaponSounds.BExplosion5', SLOT_None, 1.5*TransientSoundVolume );
			}

			return;
		}

		Super.FellOutOfWorld(KillType);
	}

    function LandThump()
    {
        // animation notify - play sound if actually landed, and animation also shows it
        if ( Physics == PHYS_None)
        {
            bThumped = true;
            PlaySound(GetSound(EST_CorpseLanded));
        }
    }

    simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
    {
        local Vector SelfToHit, SelfToInstigator, CrossPlaneNormal;
        local float W;
        local float YawDir;

        local Vector HitNormal, shotDir;
        local Vector PushLinVel, PushAngVel;
        local Name HitBone;
        local float HitBoneDist;
        local int MaxCorpseYawRate;

		if ( bFrozenBody || bRubbery )
			return;

		if( Physics == PHYS_KarmaRagdoll )
		{
			// Can't shoot corpses during de-res
			if( bDeRes || bRubbery )
				return;

			// Throw the body if its a rocket explosion or shock combo
			if( damageType.Default.bThrowRagdoll )
			{
				shotDir = Normal(Momentum);
                PushLinVel = (RagDeathVel * shotDir) +  vect(0, 0, 250);
				PushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * -18000;
				KSetSkelVel( PushLinVel, PushAngVel );
			}
			else if( damageType.Default.bRagdollBullet )
			{
				if ( Momentum == vect(0,0,0) )
					Momentum = HitLocation - InstigatedBy.Location;
				if ( FRand() < 0.65 )
				{
					if ( Velocity.Z <= 0 )
						PushLinVel = vect(0,0,40);
					PushAngVel = Normal(Normal(Momentum) Cross vect(0, 0, 1)) * -8000 ;
					PushAngVel.X *= 0.5;
					PushAngVel.Y *= 0.5;
					PushAngVel.Z *= 4;
					KSetSkelVel( PushLinVel, PushAngVel );
				}
                PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
				if ( (LifeSpan > 0) && (LifeSpan < DeResTime + 2) )
					LifeSpan += 0.2;
			}
			else
			{
                PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
			}
			if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
				SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
			return;
		}

        if ( DamageType.default.bFastInstantHit && GetAnimSequence() == 'Death_Spasm' && RepeaterDeathCount < 6)
        {
            PlayAnim('Death_Spasm',, 0.2);
            RepeaterDeathCount++;
        }
        else if (Damage > 0)
        {
			if ( InstigatedBy != None )
			{
				if ( InstigatedBy.IsA('xPawn') && xPawn(InstigatedBy).bBerserk )
					Damage *= 2;

				// Figure out which direction to spin:

				if( InstigatedBy.Location != Location )
				{
					SelfToInstigator = InstigatedBy.Location - Location;
					SelfToHit = HitLocation - Location;

					CrossPlaneNormal = Normal( SelfToInstigator cross Vect(0,0,1) );
					W = CrossPlaneNormal dot Location;

					if( HitLocation dot CrossPlaneNormal < W )
						YawDir = -1.0;
					else
						YawDir = 1.0;
				}
			}
            if( VSize(Momentum) < 10 )
            {
                Momentum = - Normal(SelfToInstigator) * Damage * 1000.0;
                Momentum.Z = Abs( Momentum.Z );
            }

            SetPhysics(PHYS_Falling);
            Momentum = Momentum / Mass;
            AddVelocity( Momentum );
            bBounce = true;

            RotationRate.Pitch = 0;
            RotationRate.Yaw += VSize(Momentum) * YawDir;

            MaxCorpseYawRate = 150000;
            RotationRate.Yaw = Clamp( RotationRate.Yaw, -MaxCorpseYawRate, MaxCorpseYawRate );
            RotationRate.Roll = 0;

            bFixedRotationDir = true;
            bRotateToDesired = false;

            Health -= Damage;
            CalcHitLoc( HitLocation, vect(0,0,0), HitBone, HitBoneDist );

            if( InstigatedBy != None )
                HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
            else
                HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

            DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
        }
    }

    simulated function BeginState()
	{
		Super.BeginState();
		AmbientSound = None;
 	}

    simulated function Timer()
	{
		local KarmaParamsSkel skelParams;

		if ( !PlayerCanSeeMe() )
        {
			Destroy();
        }
        // If we are running out of life, bute we still haven't come to rest, force the de-res.
        // unless pawn is the viewtarget of a player who used to own it
        else if ( LifeSpan <= DeResTime && bDeRes == false )
        {
			skelParams = KarmaParamsSkel(KParams);

			// check not viewtarget
			if ( (PlayerController(OldController) != None) && (PlayerController(OldController).ViewTarget == self)
				&& (Viewport(PlayerController(OldController).Player) != None) )
			{
				skelParams.bKImportantRagdoll = true;
				LifeSpan = FMax(LifeSpan,DeResTime + 2.0);
				SetTimer(1.0, false);
				return;
			}
			else
			{
				skelParams.bKImportantRagdoll = false;
			}
            // spawn derez
            StartDeRes();
        }
		else
        {
			SetTimer(1.0, false);
        }
	}

	// We shorten the lifetime when the guys comes to rest.
	event KVelDropBelow()
	{
		local float NewLifeSpan;

		if(bDeRes == false)
		{
			//Log("Low Vel - Reducing LifeSpan!");
			NewLifeSpan = DeResTime + 3.5;
			if(NewLifeSpan < LifeSpan)
				LifeSpan = NewLifeSpan;
		}
	}
}

defaultproperties
{
     bCanDodgeDoubleJump=True
     UDamageWeaponMaterial=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
     UDamageSound=Sound'GameSounds.UDamageFire'
     InvisMaterial=FinalBlend'XEffectMat.Combos.InvisOverlayFB'
     ShieldStrengthMax=150.000000
     ShieldHitMat=Shader'XGameShaders.PlayerShaders.PlayerShieldSh'
     ShieldHitMatTime=1.000000
     Species=Class'XGame.SPECIES_Merc'
     GruntVolume=0.180000
     FootstepVolume=0.150000
     GibGroupClass=Class'XEffects.xPawnGibGroup'
     GibCountCalf=4
     GibCountForearm=2
     GibCountHead=2
     GibCountTorso=2
     GibCountUpperArm=2
     MinTimeBetweenPainSounds=0.350000
     SoundFootsteps(0)=SoundGroup'PlayerSounds.Final.FootstepDefault'
     SoundFootsteps(1)=SoundGroup'PlayerSounds.Final.FootstepRock'
     SoundFootsteps(2)=SoundGroup'PlayerSounds.Final.FootstepDirt'
     SoundFootsteps(3)=SoundGroup'PlayerSounds.Final.FootstepMetal'
     SoundFootsteps(4)=SoundGroup'PlayerSounds.Final.FootstepWood'
     SoundFootsteps(5)=SoundGroup'PlayerSounds.Final.FootstepPlant'
     SoundFootsteps(6)=SoundGroup'PlayerSounds.Final.FootstepFlesh'
     SoundFootsteps(7)=SoundGroup'PlayerSounds.Final.FootstepIce'
     SoundFootsteps(8)=SoundGroup'PlayerSounds.Final.FootstepSnow'
     SoundFootsteps(9)=SoundGroup'PlayerSounds.Final.FootstepWater'
     SoundFootsteps(10)=SoundGroup'PlayerSounds.Final.FootstepGlass'
     SoundGroupClass=Class'XGame.xMercMaleSoundGroup'
     TeleportFXClass=Class'XEffects.TransEffect'
     TransEffects(0)=Class'XEffects.NewTransEffect'
     TransEffects(1)=Class'XEffects.NewTransEffectBlue'
     MultiJumpRemaining=1
     MaxMultiJump=1
     MultiJumpBoost=25
     WallDodgeAnims(0)="WallDodgeF"
     WallDodgeAnims(1)="WallDodgeB"
     WallDodgeAnims(2)="WallDodgeL"
     WallDodgeAnims(3)="WallDodgeR"
     IdleHeavyAnim="Idle_Biggun"
     IdleRifleAnim="Idle_Rifle"
     FireHeavyRapidAnim="Biggun_Burst"
     FireHeavyBurstAnim="Biggun_Aimed"
     FireRifleRapidAnim="Rifle_Burst"
     FireRifleBurstAnim="Rifle_Aimed"
     FireRootBone="bip01 Spine"
     DeResTime=6.000000
     DeResMat0=FinalBlend'DeRez.Shaders.DeRezFinalBody'
     DeResMat1=FinalBlend'DeRez.Shaders.DeRezFinalHead'
     DeResLiftVel=(Points=(,(InVal=2.500000,OutVal=32.000000),(InVal=100.000000,OutVal=32.000000)))
     DeResLiftSoftness=(Points=((OutVal=0.300000),(InVal=2.500000,OutVal=0.050000),(InVal=100.000000,OutVal=0.050000)))
     DeResLateralFriction=0.300000
     RagdollLifeSpan=13.000000
     RagInvInertia=4.000000
     RagDeathVel=200.000000
     RagShootStrength=8000.000000
     RagSpinScale=2.500000
     RagDeathUpKick=150.000000
     RagGravScale=1.000000
     RagImpactSounds(0)=Sound'GeneralImpacts.Wet.Breakbone_01'
     RagImpactSounds(1)=Sound'GeneralImpacts.Wet.Breakbone_02'
     RagImpactSounds(2)=Sound'GeneralImpacts.Wet.Breakbone_03'
     RagImpactSoundInterval=0.500000
     RagImpactVolume=2.500000
     TransOutEffect(0)=Class'XEffects.NewTransDeresRed'
     TransOutEffect(1)=Class'XEffects.NewTransDeresBlue'
     PlacedCharacterName="Gorge"
     PlacedFemaleCharacterName="Rylisa"
     RequiredEquipment(0)="XWeapons.AssaultRifle"
     RequiredEquipment(1)="XWeapons.ShieldGun"
     VoiceType="xGame.MercMaleVoice"
     bCanWallDodge=True
     GroundSpeed=440.000000
     WaterSpeed=220.000000
     AirSpeed=440.000000
     JumpZ=340.000000
     WalkingPct=0.400000
     CrouchedPct=0.400000
     BaseEyeHeight=38.000000
     EyeHeight=38.000000
     CrouchHeight=29.000000
     CrouchRadius=25.000000
     ControllerClass=Class'XGame.xBot'
     bPhysicsAnimUpdate=True
     bDoTorsoTwist=True
     MovementAnims(0)="RunF"
     MovementAnims(1)="RunB"
     MovementAnims(2)="RunL"
     MovementAnims(3)="RunR"
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     DodgeSpeedFactor=1.500000
     DodgeSpeedZ=210.000000
     SwimAnims(0)="SwimF"
     SwimAnims(1)="SwimB"
     SwimAnims(2)="SwimL"
     SwimAnims(3)="SwimR"
     CrouchAnims(0)="CrouchF"
     CrouchAnims(1)="CrouchB"
     CrouchAnims(2)="CrouchL"
     CrouchAnims(3)="CrouchR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     AirAnims(0)="JumpF_Mid"
     AirAnims(1)="JumpB_Mid"
     AirAnims(2)="JumpL_Mid"
     AirAnims(3)="JumpR_Mid"
     TakeoffAnims(0)="JumpF_Takeoff"
     TakeoffAnims(1)="JumpB_Takeoff"
     TakeoffAnims(2)="JumpL_Takeoff"
     TakeoffAnims(3)="JumpR_Takeoff"
     LandAnims(0)="JumpF_Land"
     LandAnims(1)="JumpB_Land"
     LandAnims(2)="JumpL_Land"
     LandAnims(3)="JumpR_Land"
     DoubleJumpAnims(0)="DoubleJumpF"
     DoubleJumpAnims(1)="DoubleJumpB"
     DoubleJumpAnims(2)="DoubleJumpL"
     DoubleJumpAnims(3)="DoubleJumpR"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Jump_Mid"
     TakeoffStillAnim="Jump_Takeoff"
     CrouchTurnRightAnim="Crouch_TurnR"
     CrouchTurnLeftAnim="Crouch_TurnL"
     IdleCrouchAnim="Crouch"
     IdleSwimAnim="Swim_Tread"
     IdleWeaponAnim="Idle_Rifle"
     IdleRestAnim="Idle_Rest"
     IdleChatAnim="idle_chat"
     RootBone="Bip01"
     HeadBone="Bip01 Head"
     SpineBone1="Bip01 Spine1"
     SpineBone2="bip01 Spine2"
     LightHue=204
     LightSaturation=0
     LightBrightness=255.000000
     LightRadius=3.000000
     bActorShadows=True
     bDramaticLighting=True
     Mesh=SkeletalMesh'ThunderCrash.JakobM'
     LODBias=1.800000
     Texture=Texture'XEffects.RedMarker_t'
     PrePivot=(Z=-5.000000)
     Skins(0)=Texture'DemoPlayerSkins.Jakob_Body'
     Skins(1)=Texture'DemoPlayerSkins.Jakob_NewHead'
     MaxLights=8
     CollisionRadius=25.000000
     CollisionHeight=44.000000
     bNetNotify=True
     RotationRate=(Pitch=3072)
     Begin Object Class=KarmaParamsSkel Name=PawnKParams
         KConvulseSpacing=(Max=2.200000)
         KLinearDamping=0.150000
         KAngularDamping=0.050000
         KBuoyancy=1.000000
         KStartEnabled=True
         KVelDropBelowThreshold=50.000000
         bHighDetailOnly=False
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsSkel'XGame.xPawn.PawnKParams'

}
