// ====================================================================
//  Class:  XAdmin.DBTestCommandlet
//  Parent: Core.Commandlet
//
//  <Enter a description here>
// ====================================================================

class xAdminCommandlet extends Commandlet;

var AccessControlIni	m;

event int Main( string Parms )
{
	m = new(None) class'AccessControlIni';
	
//	m.Groups.Add(m.Groups.CreateGroup("Kickers", "K", 10));
//	m.AConfig.Save(m.Users, m.Groups);
	return 0;
}

defaultproperties
{
}
