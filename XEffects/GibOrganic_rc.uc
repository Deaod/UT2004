class GibOrganic_rc extends Resource;

#exec TEXTURE IMPORT FILE=Textures\Gibs\GibOrganicGreen.tga LODSET=2 DXT=5 
#exec TEXTURE IMPORT FILE=Textures\Gibs\GibOrganicRed.tga LODSET=2 DXT=5 

#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicCalf.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicForearm.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicHand.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicHead.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicTorso.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibOrganicUpperarm.lwo COLLISION=0


// bot gibs
#exec TEXTURE IMPORT FILE=Textures\Gibs\GibBot.tga LODSET=2 DXT=5 

#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotCalf.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotForearm.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotHand.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotHead.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotTorso.lwo COLLISION=0
#exec STATICMESH IMPORT FILE=Models\Gibs\GibBotUpperarm.lwo COLLISION=0

defaultproperties
{
}
