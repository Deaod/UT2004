// ====================================================================
//  Class:  XGame.Intro_Brock
//  Parent: XGame.xIntroPawn
//
//  <Enter a description here>
// ====================================================================

class Intro_Brock extends xIntroPawn;

simulated function UpdatePrecacheMaterials()
{
	// Hacky McHack.
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CubeMaps.GdFace1", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CubeMaps.BRFace1", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CubeMaps.ChFace1", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CubeMaps.SkinFace1", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.brock.brock_head", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.brock.brock_body", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.malcom.malcom_head", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.malcom.malcom_body", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.lauren.lauren_head", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("Engine.GRADIENT_Fade", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a11", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a12", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a13", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a14", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a15", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a16", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a10", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a11", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a12", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a13", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a14", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a15", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale5Sprite.CrowdMale5_a16", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale1Sprite.CrowdMale1_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a11", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.NoiseLines_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.NoiseLines_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a12", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a13", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.ShotAsbestos", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a14", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a15", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a16", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a00", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a01", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a02", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a10", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a03", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale3Sprite.CrowdMale3_a10", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a10", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a11", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a04", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a11", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a12", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a05", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a12", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a13", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a06", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a13", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a14", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a07", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a14", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a15", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a08", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a15", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a16", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale2Sprite.CrowdMale2_a09", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale4Sprite.CrowdMale4_a16", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.ShotFace3", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.CrowdMale6Sprite.CrowdMale6_a17", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.shotPhobos2", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.ShotInferno", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.ShotSunTemple", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("MapThumbnails.shotscorchedearth", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.SC_BrockScreen_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.SC_LaurenScreen_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.SpotLights.SC_SpotlightGrad", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.SpotLights.SC_SpotlightNoise", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.SpotLights.SC_SpotlightOn_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.SpotLights.SC_SpotlightOnMsk_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.JM_AmbrosiaScreen_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.JM_NikolaiScreen_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.fans.fan_chick", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.gorge.gorge_head", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.gorge.gorge_body", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.jug_chick.Jug_chick_body", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.jug_chick.jug_chick_head", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.nikoli.nikoli_body", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.nikoli.nikoli", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.SC_ConcreteInside_T", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("intro_characters.fans.super_fan", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.KalendraIce", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("Engine.DefaultFont.Texture0", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.Kalendra5", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.Kalendra4", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.Kalendra3", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.Kalendra2", class'Material',true)));
	Level.AddPrecacheMaterial(Material(DynamicLoadObject("SC_Intro.Screens.Kalendra1", class'Material',true)));

	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();

	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.SpotLightCone", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipL", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipJ", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipK", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipI", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipH", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipG", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipM", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipD", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipE", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipF", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipC", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipB", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipA", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipN", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Column.ColumnBreakChipO", class'StaticMesh',true)));
	Level.AddPrecacheStaticMesh(StaticMesh(DynamicLoadObject("SC-Intro_Meshes.Lift", class'StaticMesh',true)));
}

defaultproperties
{
     MeshNameString="intro_brock.Brock"
}
