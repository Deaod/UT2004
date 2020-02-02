// ====================================================================
//  Class:  xWebAdmin.xWebAdminCommandLet
//  Parent: Core.Commandlet
//
//  <Enter a description here>
// ====================================================================

class xWebAdminCommandLet extends Commandlet;

event int Main( string Parms )
{
//	local class<xWebQueryHandler> Tmp;
//	local int i;
//	for (i = 0; i < class'XWebAdmin.UTServerAdmin'.default.QueryHandlerClasses.Length;i++)
//	{
//		Tmp = class<xWebQueryhandler>(DynamicLoadObject(class'xWebAdmin.UTServerAdmin'.default.QueryHandlerClasses[i],class'Class'));
//		if (Tmp != None)
//			Tmp.static.StaticSaveConfig();
//	}
	return 0;
}

defaultproperties
{
}
