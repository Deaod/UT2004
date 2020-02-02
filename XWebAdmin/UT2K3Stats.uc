//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K3Stats extends WebSkin;

var int i;
var bool bMutQuery, bRuleQuery, bFull, bRegLine, bAltLine;

function bool HandleSpecialQuery(WebRequest Request, WebResponse Response)
{
	bMutQuery = Mid(Request.URI,1) == "current_mutators";
	bRuleQuery = Mid(Request.URI,1) == "defaults_rules";
	return false;
}

function string HandleWebInclude(WebResponse Response, string Page)
{
	if (!bMutQuery && !bRuleQuery)
	 return "";

	if (Left(Page,5) != "cell_" &&
		Page != "current_mutators_group" &&
		Page != "current_mutators_group_row" &&
		Page != "defaults_row")
		return "";

	if (Page == "current_mutators_group" || Page == "current_mutators_group_row"||
		Page == "defaults_row")
	{
		if (bFull)
		{
			bAltLine = False;
			bRegLine = False;
			Response.Subst("CellClass", "n");
		}
		else
		{
			bAltLine = True;
			bRegLine = True;
			Response.Subst("CellClass", "nabg");
		}
		bFull = !bFull;
		return "";
	}

	else
	{
		if (bRegLine)
		{
			Response.Subst("CellClass", "n");
			if (bAltLine)
				bAltLine = False;
			else
				bRegLine = False;
		}
		else
		{
			Response.Subst("CellClass", "nabg");
			if (bAltLine)
				bRegLine = True;
			else
				bAltLine = True;
		}
	}
	return "";
}

function bool HandleHTM(WebResponse Response, string Page)
{
	if (Page ~= "current_mutators")
	{
		bMutQuery = False;
		bRegLine = False;
		bAltLine = False;
	}
	else if (Page ~= "defaults_row")
		bRuleQuery = False;
	return false;
}

defaultproperties
{
     SubPath="UT2K3Stats"
     DisplayName="UT2K3 Stats"
     SkinCSS="ut2003stats.css"
     SpecialQuery(0)="current_mutators"
     SpecialQuery(1)="defaults_rules"
}
