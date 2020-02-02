class Admin extends AdminBase;

// Execute an administrative console command on the server.
function DoLogin( string Username, string Password )
{
	if (Level.Game.AccessControl.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
		Level.Game.AccessControl.AdminEntered(Outer, "");
	}
}

function DoLogout()
{
	if (Level.Game.AccessControl.AdminLogout(Outer))
	{
		bAdmin = false;
		Level.Game.AccessControl.AdminExited(Outer);
	}
}

defaultproperties
{
}
