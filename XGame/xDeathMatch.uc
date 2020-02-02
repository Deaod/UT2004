//=============================================================================
// xDeathMatch.
//=============================================================================
class xDeathMatch extends DeathMatch;

#exec OBJ LOAD FILE=WeaponSkins.utx
#exec OBJ LOAD FILE=UT2004Weapons.utx
#exec OBJ LOAD FILE=XEffectMat.utx
#exec OBJ LOAD FILE=WeaponStaticMesh.usx
#exec OBJ LOAD FILE=NewWeaponPickups.usx
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE=intro_characters.utx
#exec OBJ LOAD FILE=DemoPlayerSkins.utx
#exec OBJ LOAD FILE=PlayerSkins.utx
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=LastManStanding.utx
#exec OBJ LOAD FILE=HUDContent.utx

var globalconfig bool		bCustomPreload;		// if true, precache non-Epic characters as well

static function PrecacheGameTextures(LevelInfo myLevel)
{
	local int i;
	local array<xUtil.PlayerRecord> AllPlayerList, PlayerList;
	local bool bIsTeamGame;
	local class<GameInfo> GameClass;
	local Texture LoadedSkin, LoadedSkinBlue, LoadedFace, LoadedFaceBlue;
	
	myLevel.AddPrecacheMaterial(Material'UT2004Weapons.AssaultRifleTex0');
	myLevel.AddPrecacheMaterial(Material'XEffects.bulletpock');
	myLevel.AddPrecacheMaterial(Material'WeaponSkins.GrenadeTex');
	myLevel.AddPrecacheMaterial(Material'WeaponSkins.ShieldTex0');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.Minigun_burst');
	myLevel.AddPrecacheMaterial(Material'XEffects.pcl_Spark');
	myLevel.AddPrecacheMaterial(Material'XEffects.EmitSmoke_t');
	myLevel.AddPrecacheMaterial(Material'XEffects.SmokeTex');
	myLevel.AddPrecacheMaterial(Material'XEffects.rocketblastmark');
    myLevel.AddPrecacheMaterial(Texture'XEffects.FlakTrailTex');
	myLevel.AddPrecacheMaterial(Texture'ExplosionTex.we1_frames');
	myLevel.AddPrecacheMaterial(Texture'ExplosionTex.exp2_frames');
	myLevel.AddPrecacheMaterial(Texture'ExplosionTex.SmokeReOrdered');
	myLevel.AddPrecacheMaterial(Texture'ExplosionTex.exp1_frames');
	myLevel.AddPrecacheMaterial(Material'XEffects.Rexpt');
	myLevel.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.shock_ring_b');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.Shield.ShieldSpark');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.SlimeSkin');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.goop_green_a');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.PlayerShield');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.Shield3rdFB');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.ShieldRip3rdFB');
 	myLevel.AddPrecacheMaterial(Material'XGameShaders.LinkGunShell');
	myLevel.AddPrecacheMaterial(Material'Engine.BlobTexture');
 	myLevel.AddPrecacheMaterial(Material'XGameShaders.LEnergy');
	myLevel.AddPrecacheMaterial(class'NewTransDeresBlue'.Default.Texture);
	myLevel.AddPrecacheMaterial(Material'intro_characters.BRface1');
	myLevel.AddPrecacheMaterial(Material'AW-2004Particles.Fire.BlastMark');
	myLevel.AddPrecacheMaterial(Material'gradient_FADE');
	myLevel.AddPrecacheMaterial(Material'AW-2004Particles.plasmastar');
	myLevel.AddPrecacheMaterial(Material'XEffects.BotSpark');
	myLevel.AddPrecacheMaterial(Material'InterfaceContent.SquareBoxA');
	myLevel.AddPrecacheMaterial(Material'LastManStanding.LMSLogoSmall');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.redbolt');
	myLevel.AddPrecacheMaterial(Material'XEffects.SpeedTrailTex');
	myLevel.AddPrecacheMaterial(Material'XEffects.pcl_ball');
    myLevel.AddPrecacheMaterial(Texture'XGameShaders.MinigunFlash');

    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat1');
    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat2');
    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat3');
    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat1P');
    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat2P');
    myLevel.AddPrecacheMaterial(Texture'XEffects.BloodSplat3P');
    myLevel.AddPrecacheMaterial(Texture'XEffects.xBioSplat');
    myLevel.AddPrecacheMaterial(Texture'XEffects.xBioSplat2');
    myLevel.AddPrecacheMaterial(Texture'XGameShadersB.BloodJetc');
    myLevel.AddPrecacheMaterial(Texture'XGameShadersB.BloodPuffA');
    myLevel.AddPrecacheMaterial(Texture'XGameShadersB.AlienBloodJet');
    myLevel.AddPrecacheMaterial(Texture'XGameShadersB.BloodPuffGreen');
    myLevel.AddPrecacheMaterial(Texture'XGameShadersB.BloodPuffOil');

    myLevel.AddPrecacheMaterial(Texture'XEffects.GibOrganicGreen');
    myLevel.AddPrecacheMaterial(Texture'XEffects.GibOrganicRed');
    myLevel.AddPrecacheMaterial(Texture'XEffects.GibBot');
    
    myLevel.AddPrecacheMaterial(Texture'EpicParticles.FlickerFlare2');

	if ( myLevel.IsDemoBuild() )
		myLevel.AddPrecacheMaterial(Material'DemoPlayerSkins.DemoSkeleton');
	else
		myLevel.AddPrecacheMaterial(Texture(DynamicLoadObject("PlayerSkins.Human_Skeleton", class'Material')));

	if ( !Static.NeverAllowTransloc() )
	{
		myLevel.AddPrecacheMaterial(Material'XEffects.TransTrailT');
 		myLevel.AddPrecacheMaterial(Material'XGameShaders.TransPlayerCell');
 		myLevel.AddPrecacheMaterial(Material'XGameShaders.TransPlayerCellRed');
		myLevel.AddPrecacheMaterial(Material'WeaponSkins.NEWTranslocatorTEX');
		myLevel.AddPrecacheMaterial(Material'WeaponSkins.NEWTranslocatorBlue');
		myLevel.AddPrecacheMaterial(Material'WeaponSkins.NEWTranslocatorPUCK');
		myLevel.AddPrecacheMaterial(Material'WeaponSkins.NEWtranslocatorGlass');
	}

	if ( Default.bAllowVehicles )
	{
		myLevel.AddPrecacheMaterial(Material'HUDContent.NoEntry');
	}	
	myLevel.AddPrecacheMaterial(Material'EpicParticles.BurnFlare1');
	myLevel.AddPrecacheMaterial(Material'DeRez.DeRezSkin');
	myLevel.AddPrecacheMaterial(Material'DeRez.RezTest4');

	// water effects
	myLevel.AddPrecacheMaterial(Material'xGame.xCausticRing2');
	myLevel.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
	myLevel.AddPrecacheMaterial(Material'xGame.xSplashBase');
	myLevel.AddPrecacheMaterial(Material'xGame.xWaterdrops2');

	if ( ((myLevel.NetMode == NM_ListenServer) || (myLevel.NetMode == NM_Client))
		&& !myLevel.bSkinsPreloaded && 
		((myLevel.bShouldPreload && myLevel.bDesireSkinPreload && !Default.bForceDefaultCharacter) || myLevel.IsDemoBuild()) )
	{
		class'xUtil'.static.GetPlayerList(AllPlayerList);
		if ( !myLevel.IsDemoBuild() )
		{
			myLevel.ForceLoadTexture(Texture(DynamicLoadObject("UT2004PlayerSkins.XanMk3V2_abdomen", class'Material')));
			myLevel.ForceLoadTexture(Texture(DynamicLoadObject("UT2004PlayerSkins.Skaarj_Skeleton_Body", class'Material')));
		}
		// Filter out 'duplicate' characters - only used in single player
		// also filter out characters that aren't useable by bots (probably not meant for DM)
		for(i=0; i<AllPlayerList.Length; i++)
		{
			if ( (AllPlayerList[i].Menu != "DUP") && (AllPlayerList[i].BotUse > 0) )
			{
				// if no custom preloading, only preload Epic characters - PlayerSkins, UT2004PlayerSkins, MechaSkaarjSkins, NecrisSkins, MetalSkins
				if ( Default.bCustomPreload
					|| (Left(AllPlayerList[i].BodySkinName,12) ~= "PlayerSkins.")
					|| (Left(AllPlayerList[i].BodySkinName,18) ~= "UT2004PlayerSkins.")
					|| (Left(AllPlayerList[i].BodySkinName,21) ~= "UT2004ECEPlayerSkins.")
					|| (Left(AllPlayerList[i].BodySkinName,16) ~= "DemoPlayerSkins.") )
				{
					PlayerList[PlayerList.Length] = AllPlayerList[i];
				}
			}
		}
		GameClass = myLevel.GetGameClass();
		bIsTeamGame = (GameClass != None) && GameClass.Default.bTeamGame;
		for (i=0; i<PlayerList.Length; i++ )
		{
			DynamicLoadObject(PlayerList[i].MeshName,Class'Mesh');
			if ( !bIsTeamGame )
			{
				if ( (MyLevel.GRI != None) && MyLevel.GRI.bForceTeamSkins  )
				{
					if ( class'DMMutator'.Default.bBrightSkins && (Left(PlayerList[i].BodySkinName,12) ~= "PlayerSkins.") )
						LoadedSkin = Texture(DynamicLoadObject("Bright"$PlayerList[i].BodySkinName$"_0B", class'Material',true));
					else
						LoadedSkin = Texture(DynamicLoadObject(PlayerList[i].BodySkinName$"_0", class'Material'));
				}
				else
					LoadedSkin = Texture(DynamicLoadObject(PlayerList[i].BodySkinName,Class'Material'));
				myLevel.ForceLoadTexture(LoadedSkin);
			}
			else
			{
				// preload team skins
				if ( class'DMMutator'.Default.bBrightSkins && (Left(PlayerList[i].BodySkinName,12) ~= "PlayerSkins.") )
				{
					LoadedSkin = Texture(DynamicLoadObject("Bright"$PlayerList[i].BodySkinName$"_0B",Class'Material',true));
					LoadedSkinBlue = Texture(DynamicLoadObject("Bright"$PlayerList[i].BodySkinName$"_1B",Class'Material',true));
				}
				else
				{
					LoadedSkin = Texture(DynamicLoadObject(PlayerList[i].BodySkinName$"_0",Class'Material'));
					LoadedSkinBlue = Texture(DynamicLoadObject(PlayerList[i].BodySkinName$"_1",Class'Material'));
					if ( PlayerList[i].TeamFace )
					{
						LoadedFace = Texture(DynamicLoadObject(PlayerList[i].FaceSkinName$"_0", class'Material'));
						LoadedFaceBlue = Texture(DynamicLoadObject(PlayerList[i].FaceSkinName$"_1", class'Material'));
						myLevel.ForceLoadTexture(LoadedFace);
						myLevel.ForceLoadTexture(LoadedFaceBlue);
					}
				}
				myLevel.ForceLoadTexture(LoadedSkin);
				myLevel.ForceLoadTexture(LoadedSkinBlue);
			}
			if ( !PlayerList[i].TeamFace )
			{
				LoadedFace = Texture(DynamicLoadObject(PlayerList[i].FaceSkinName,Class'Material'));
				myLevel.ForceLoadTexture(LoadedFace);
			}
			if ( PlayerList[i].VoiceClassName != "" )
				DynamicLoadObject(PlayerList[i].VoiceClassName,Class'Class');
		}
	}
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotCalf');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotForearm');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotHand');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotHead');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotTorso');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibBotUpperarm');

	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicCalf');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicForearm');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicHand');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicHead');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicTorso');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XEffects.GibOrganicUpperarm');

	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.shield');
	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.grenademesh');
	myLevel.AddPrecacheStaticMesh(StaticMesh'NewWeaponPickups.AssaultPickupSM');
	if ( !Static.NeverAllowTransloc() )
		myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.NEWTranslocatorPUCK');
}

defaultproperties
{
     DefaultEnemyRosterClass="XGame.xDMRoster"
     DeathMessageClass=Class'XGame.xDeathMessage'
     GameName="DeathMatch"
     ScreenShotName="UT2004Thumbnails.DMShots"
     DecoTextName="XGame.Deathmatch"
     Acronym="DM"
}
