//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSHUDOnslaught extends HudCTeamDeathMatch
    config(user);

var config float RadarScale, RadarTrans, IconScale, RadarPosX, RadarPosY;
var float RadarMaxRange, RadarRange;
var ONSPowerCore FinalCore[2];
var ONSPowerCore Node;
var ONSPlayerReplicationInfo OwnerPRI;
var protected array<PowerLink> PowerLinks;

//var array<color> PowerLinks;
var bool bMapDisabled;
var bool bReceivedLinks;
var vector MapCenter;
var float ColorPercent;

var()   Material            HealthBarBackMat;
var()   Material            HealthBarMat;
var()   float               HealthBarWidth;
var()   float               HealthBarHeight, HealthBarPosition;
var()   float               HealthBarViewDist;
var()   Material            BorderMat;
var()   color               NeutralColor;
var()   color               AttackColorA;
var()   color               AttackColorB;
var()   color               SeveredColorA;
var()   color               SeveredColorB;
var()   color               LinkColor[3];

var()   SpriteWidget    SymbolGB[2];
var()   SpriteWidget    CoreWidgets[2];
var()   NumericWidget   CoreHealthWidgets[2];

var()   NumericWidget   NodeLabelWidget;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=ONSInterface-TX.utx

simulated event PostBeginPlay()
{
	local ONSPowerCore Core;
	local TerrainInfo T, PrimaryTerrain;
	local int i;

	Super.PostBeginPlay();

	foreach AllActors( class'ONSPowerCore', Core )
		if ( Core.bFinalCore )
			FinalCore[Core.DefenderTeamIndex] = Core;

	Node = FinalCore[0];

	// Setup links right away, even though these will be overwritten when the new link setup is received from the server
	if ( Level.NetMode == NM_Client )
		SetupLinks();

	// Assign PowerNode numbers
	Core = Node;
	do
	{
        if (ONSPowerNode(Core) != None)
        {
            Core.NodeNum = ++i;
            Core.UpdateLocationName();
        }

        Core = Core.NextCore;
	} until ( Core == None || Core == Node );

	// Determine primary terrain
    foreach AllActors(class'TerrainInfo', T)
    {
        PrimaryTerrain = T;
        if (T.Tag == 'PrimaryTerrain')
            Break;
    }

    // Set RadarMaxRange to size of primary terrain
    if (Level.bUseTerrainForRadarRange && PrimaryTerrain != None)
        RadarRange = abs(PrimaryTerrain.TerrainScale.X * PrimaryTerrain.TerrainMap.USize) / 2.0;
    else if (Level.CustomRadarRange > 0)
        RadarRange = Clamp(Level.CustomRadarRange, 500.0, default.RadarMaxRange);

    SetTimer(1.0, true);
    Timer();
}

simulated function SetupLinks()
{
	local ONSPowerCore Core;
	local int i;

	if ( Node == None )
		return;

//	log(Name@"SetupLinks");
	Core = Node;
	do
	{
		for ( i = 0; i < Core.PowerLinks.Length; i++ )
			AddLink(Core, Core.PowerLinks[i]);

		Core = Core.NextCore;
	} until ( Core == None || Core == Node );
}

simulated function ReceiveLink( ONSPowerCore A, ONSPowerCore B )
{
	bReceivedLinks = True;

//	log(Name@"ReceiveLink  A:"$A.Name@"B:"$B.Name);
	AddLink(A,B);
//	A.AddPowerLink(B);
}

simulated function AddLink( ONSPowerCore A, ONSPowerCore B )
{
	local PowerLink Link;

	if ( HasLink(A,B) )
		return;

	Link = Spawn(class'PowerLink');
	Link.SetNodes(A,B);

	PowerLinks[PowerLinks.Length] = Link;
}

simulated function RemoveLink( ONSPowerCore A, ONSPowerCore B )
{
	local int i;

//	log(Name@"Remove link from A:"$A.Name@"to"@B.Name);

	for ( i = PowerLinks.Length - 1; i >= 0; i-- )
	{
		if ( PowerLinks[i] == None )
		{
			PowerLinks.Remove(i,1);
			continue;
		}

		if ( PowerLinks[i].HasNodes(A,B) )
		{
//			log(Name@"found powerlink containing those nodes:"$PowerLinks[i].Name);
			PowerLinks[i].Destroy();
			PowerLinks.Remove(i,1);
		}
	}
}

simulated function ResetLinks()
{
//	log(Name@"ResetLinks");
	ClearLinks();
	RequestPowerLinks();

/*
	if ( Level.NetMode == NM_Client )
	{
		Core = Node;
		do
		{
			Core.PowerCoreReset();
			Core = Core.NextCore;
		} until ( Core == None || Core == Node );
	}
*/
}

simulated function bool HasLink( ONSPowerCore A, ONSPowerCore B )
{
	local int i;

	for ( i = PowerLinks.Length - 1; i >= 0; i-- )
	{
		if ( PowerLinks[i] == None )
		{
			PowerLinks.Remove(i,1);
			continue;
		}

		if ( PowerLinks[i].HasNodes(A,B) )
			return True;
	}

	return False;
}

simulated function ClearLinks()
{
	local int i;
	bReceivedLinks = False;

//	log(Name@"ClearLinks"@PowerLinks.Length);
	for ( i = 0; i < PowerLinks.Length; i++ )
		if ( PowerLinks[i] != None )
			PowerLinks[i].Destroy();

	PowerLinks.Remove(0, PowerLinks.Length);
}

// Finds a PowerCore within 2500 units of PosX/PosY on the RadarMap (assumes a map centered at 0,0,0)
simulated function ONSPowerCore LocatePowerCore(float PosX, float PosY, float RadarWidth)
{
    local float WorldToMapScaleFactor, Distance, LowestDistance;
    local vector WorldLocation, DistanceVector;
    local ONSPowerCore BestCore, Core;

	if (Node == None)
		return None;

    WorldToMapScaleFactor = RadarRange/RadarWidth;

    WorldLocation.X = PosX * WorldToMapScaleFactor;
    WorldLocation.Y = PosY * WorldToMapScaleFactor;

    LowestDistance = 2500.0;

	Core = Node;
	do
	{
        DistanceVector = Core.Location - WorldLocation;
        DistanceVector.Z = 0;
		Distance = VSize(DistanceVector);
        if (Distance < LowestDistance)
        {
            BestCore = Core;
            LowestDistance = Distance;
        }

		Core = Core.NextCore;
    } until ( Core == None || Core == Node );

    return BestCore;
}

simulated function DrawRadarMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes)
{
	local float PawnIconSize, PlayerIconSize, CoreIconSize, MapScale, MapRadarWidth;
	local vector HUDLocation;
	local FinalBlend PlayerIcon;
	local Actor A;
	local ONSPowerCore CurCore;
	local int i;
	local plane SavedModulation;

	SavedModulation = C.ColorModulate;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;

	// Make sure that the canvas style is alpha
	C.Style = ERenderStyle.STY_Alpha;

	MapRadarWidth = RadarWidth;
    if (PawnOwner != None)
    {
//    	MapCenter.X = FClamp(PawnOwner.Location.X, -RadarMaxRange + RadarRange, RadarMaxRange - RadarRange);
//    	MapCenter.Y = FClamp(PawnOwner.Location.Y, -RadarMaxRange + RadarRange, RadarMaxRange - RadarRange);
        MapCenter.X = 0.0;
        MapCenter.Y = 0.0;
    }
    else
        MapCenter = vect(0,0,0);

	HUDLocation.X = RadarWidth;
	HUDLocation.Y = RadarRange;
	HUDLocation.Z = RadarTrans;

	DrawMapImage( C, Level.RadarMapImage, CenterPosX, CenterPosY, MapCenter.X, MapCenter.Y, HUDLocation );

	if (Node == None)
		return;

	CurCore = Node;
	do
	{
		if ( CurCore.HasHealthBar() )
			DrawHealthBar(C, CurCore, CurCore.Health, CurCore.DamageCapacity, HealthBarPosition);

		CurCore = CurCore.NextCore;
	} until ( CurCore == None || CurCore == Node );

	CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
	PawnIconSize = CoreIconSize * 0.5;
	PlayerIconSize = CoreIconSize * 1.5;
    MapScale = MapRadarWidth/RadarRange;
    C.Font = GetConsoleFont(C);

	Node.UpdateHUDLocation( CenterPosX, CenterPosY, RadarWidth, RadarRange, MapCenter );
	for ( i = 0; i < PowerLinks.Length; i++ )
		PowerLinks[i].Render(C, ColorPercent, bShowDisabledNodes);

	CurCore = Node;
	do
	{
		if (!bShowDisabledNodes && (CurCore.CoreStage == 255 || CurCore.PowerLinks.Length == 0))	//hide unused powernodes
		{
			if (PlayerOwner==none || !PlayerOwner.bDemoOwner)
			{
				CurCore = CurCore.NextCore;
				continue;
			}
		}

		C.DrawColor = LinkColor[CurCore.DefenderTeamIndex];

		// Draw appropriate icon to represent the current state of this node
	    if (CurCore.bUnderAttack || (CurCore.CoreStage == 0 && CurCore.bSevered))
	    	DrawAttackIcon( C, CurCore, CurCore.HUDLocation, IconScale, HUDScale, ColorPercent );

		if (CurCore.bFinalCore)
			DrawCoreIcon( C, CurCore.HUDLocation, PowerCoreAttackable(CurCore), IconScale, HUDScale, ColorPercent );
		else
		{
			DrawNodeIcon( C, CurCore.HUDLocation, PowerCoreAttackable(CurCore), CurCore.CoreStage, IconScale, HUDScale, ColorPercent );
			DrawNodeLabel(C, CurCore.HUDLocation, IconScale, HUDScale, C.DrawColor, CurCore.NodeNum);
		}

		CurCore = CurCore.NextCore;

	} until ( CurCore == None || CurCore == Node );

    // Draw PlayerIcon
    if (PawnOwner != None)
    	A = PawnOwner;
    else if (PlayerOwner.IsInState('Spectating'))
        A = PlayerOwner;
    else if (PlayerOwner.Pawn != None)
    	A = PlayerOwner.Pawn;

    if (A != None)
    {
    	PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
    	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
        HUDLocation = A.Location - MapCenter;
        HUDLocation.Z = 0;
    	if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
    	{
        	C.SetPos( CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5,
                          CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 );

            C.DrawColor = C.MakeColor(40,255,40);
            C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
        }
    }

//    // VERY SLOW DEBUGGING CODE for showing all the dynamic actors that exist in the level in real-time
//    ForEach DynamicActors(class'Actor', A)
//    {
//        if (A.IsA('Projectile')) //(A.IsA('Projector') || A.IsA('Emitter') || A.IsA('xEmitter'))
//        {
//            HUDLocation = A.Location - MapCenter;
//            HUDLocation.Z = 0;
//        	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
//            C.DrawColor = C.MakeColor(255,255,0);
//            C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
//        }
//        if (A.IsA('Pawn'))
//        {
//            if (Pawn(A).PlayerReplicationInfo != None && Pawn(A).PlayerReplicationInfo.Team != None)
//            {
//                if (Pawn(A).PlayerReplicationInfo.Team.TeamIndex == 0)
//                    C.DrawColor = C.MakeColor(255,0,0);
//                else if (Pawn(A).PlayerReplicationInfo.Team.TeamIndex == 1)
//                    C.DrawColor = C.MakeColor(0,0,255);
//                else
//                    C.DrawColor = C.MakeColor(255,0,255);
//            }
//            else
//                C.DrawColor = C.MakeColor(255,255,255);
//
//            HUDLocation = A.Location - MapCenter;
//            HUDLocation.Z = 0;
//
//            if (A.IsA('Vehicle'))
//            {
//            	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.5);
//                C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.5, PlayerIconSize * 0.5, 0, 0, 32, 32);
//            }
//            else
//            {
//            	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
//                C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
//            }
//        }
//    }

    // Draw Border
    C.DrawColor = C.MakeColor(200,200,200);
	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
	C.DrawTile(BorderMat,
               RadarWidth * 2.0,
               RadarWidth * 2.0,
               0,
               0,
               256,
               256);

    C.ColorModulate = SavedModulation;
}

function bool PowerCoreAttackable(ONSPowerCore PC)
{
    if  (PawnOwnerPRI != None && PawnOwnerPRI.Team != None)
    {
        if (PC.DefenderTeamIndex != PawnOwnerPRI.Team.TeamIndex)
            return (PC.PoweredBy(PawnOwnerPRI.Team.TeamIndex));
        else
        {
            if (PawnOwnerPRI.Team.TeamIndex == 0)
                return (PC.PoweredBy(1));
            else
                return (PC.PoweredBy(0));
        }
    }

    return False;
}

simulated function ShowTeamScorePassA(Canvas C)
{
	local int x;

	Super.ShowTeamScorePassA(C);

	if (bShowPoints)
		for (x = 0; x < 2; x++)
		{
			DrawSpriteWidget (C, SymbolGB[x]);

			if (FinalCore[x] != None && FinalCore[x].CoreStage == 0)
			{
				DrawSpriteWidget (C, CoreWidgets[x]);

				if (FinalCore[x].bUnderAttack)
				{
					CoreHealthWidgets[x].Tints[TeamIndex].G = 255 * ColorPercent;
					CoreHealthWidgets[x].Tints[TeamIndex].B = 255 * ColorPercent;
				}
				else
					CoreHealthWidgets[x].Tints[TeamIndex] = WhiteColor;

				CoreHealthWidgets[x].Value = round((float(FinalCore[x].Health) / FinalCore[x].DamageCapacity) * 100);
				DrawNumericWidget(C, CoreHealthWidgets[x], DigitsBig);

				//C.DrawColor = HudColorHighLight;
				//Draw2DLocationDot(C, FinalCore[x].Location,0.5 + tmpPosX[x]*HUDScale, tmpPosY*HUDScale, tmpScaleX*HUDScale, tmpScaleY*HUDScale);
			}
		}
}

simulated function ShowTeamScorePassC(Canvas C)
{
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;

    if (Level.bShowRadarMap && !bMapDisabled)
    {
        RadarWidth = 0.5 * RadarScale * HUDScale * C.ClipX;
        CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
        CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;
        DrawRadarMap(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, false);
    }
}

simulated function DrawNodeLabel(Canvas C, vector HUDLocation, float IconScaling, float HUDScaling, Color LabelColor, int Num)
{
	local float LabelIconSize;
	local int TensPlace,row,col;
	local float x,y;

	if ( C == None || Num >= 100)
		return;

	LabelIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    C.DrawColor = WhiteColor;

	if (Num > 9)
    {
        TensPlace = Num / 10;
        Num = Num - (TensPlace * 10);

		X = HUDLocation.X - (1.5 * LabelIconSize * 1.5);
		Y = HUDLocation.Y - LabelIconSize * 1.5;
		C.SetDrawColor(0,0,0,255);
		for (Row=-1;Row<2;Row++)
		{
			for (Col=-1;Col<2;Col++)
			{
		        C.SetPos(X+Col,Y+Row );
		        C.DrawTile(DigitsBig.DigitTexture, LabelIconSize, LabelIconSize, DigitsBig.TextureCoords[TensPlace].X1, DigitsBig.TextureCoords[TensPlace].Y1, DigitsBig.TextureCoords[0].X2, DigitsBig.TextureCoords[0].Y2);
		    }
		}

		C.SetDrawColor(255,255,0,255);
        C.SetPos(X,Y);
        C.DrawTile(DigitsBig.DigitTexture, LabelIconSize, LabelIconSize, DigitsBig.TextureCoords[TensPlace].X1, DigitsBig.TextureCoords[TensPlace].Y1, DigitsBig.TextureCoords[0].X2, DigitsBig.TextureCoords[0].Y2);
    }

	X = HUDLocation.X - LabelIconSize * 1.5;
	Y = HUDLocation.Y - LabelIconSize * 1.5;

	C.SetDrawColor(0,0,0,255);
	for (Row=-1;Row<2;Row++)
	{
		for (Col=-1;Col<2;Col++)
		{
		    C.SetPos(x+Col,y+Row);
		    C.DrawTile(DigitsBig.DigitTexture, LabelIconSize, LabelIconSize, DigitsBig.TextureCoords[Num].X1, DigitsBig.TextureCoords[Num].Y1, DigitsBig.TextureCoords[0].X2, DigitsBig.TextureCoords[0].Y2);
		}
	}
	C.SetDrawColor(255,255,0,255);
    C.SetPos(x,y);
    C.DrawTile(DigitsBig.DigitTexture, LabelIconSize, LabelIconSize, DigitsBig.TextureCoords[Num].X1, DigitsBig.TextureCoords[Num].Y1, DigitsBig.TextureCoords[0].X2, DigitsBig.TextureCoords[0].Y2);

}

simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height)
{
	local vector		CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator		CameraRotation;
	local float			Dist, HealthPct;
	local color         OldDrawColor;

	// rjp --  don't draw the health bar if menus are open
	if ( PlayerOwner.Player.GUIController.bActive )
		return;

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation( CameraLocation, CameraRotation );
	TargetLocation = A.Location + vect(0,0,1) * Height;
	Dist = VSize(TargetLocation - CameraLocation);

	// Check Distance Threshold
	if (Dist > HealthBarViewDist)
		return;

	CamDir	= vector(CameraRotation);

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);
	if ((TargetLocation - CameraLocation) dot CamDir < 0 || HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		TargetLocation = A.Location + vect(0,0,1) * A.CollisionHeight;
		if ((TargetLocation - CameraLocation) dot CamDir < 0)
			return;
		HBScreenPos = C.WorldToScreen(TargetLocation);
		if (HBScreenPos.X <= 0 || HBScreenPos.X >= C.ClipX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.ClipY)
			return;
	}

	if (FastTrace(TargetLocation, CameraLocation))
	{
	    	C.DrawColor = WhiteColor;

	    	C.SetPos(HBScreenPos.X - HealthBarWidth * 0.5, HBScreenPos.Y);
	    	C.DrawTileStretched(HealthBarBackMat, HealthBarWidth, HealthBarHeight);

	    	HealthPct = 1.0f * Health / MaxHealth;

	    	if (HealthPct < 0.35)
	    	   C.DrawColor = RedColor;
	    	else if (HealthPct < 0.70)
	    	   C.DrawColor = GoldColor;
	    	else
	    	   C.DrawColor = GreenColor;

	    	C.SetPos(HBScreenPos.X - HealthBarWidth * 0.5, HBScreenPos.Y);
	    	C.DrawTileStretched(HealthBarMat, HealthBarWidth * HealthPct, HealthBarHeight);
	}

	C.DrawColor = OldDrawColor;
}

simulated function Timer()
{
	local ONSPowerCore C;

	if (PlayerOwner.Pawn != None && OwnerPRI != None && OwnerPRI.Team != None)
	{
		C = OwnerPRI.GetCurrentNode();
		if (C != None)
			PlayerOwner.ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 22);
	}
}

simulated function Tick(float deltaTime)
{
    local ONSPowerCore Core;

	Super.Tick(deltaTime);

	if ( OwnerPRI == None && PawnOwnerPRI != None )
		OwnerPRI = ONSPlayerReplicationInfo(PawnOwnerPRI);

	if (FinalCore[0].DefenderTeamIndex != 0)
	{
    	foreach AllActors( class'ONSPowerCore', Core )
    		if ( Core.bFinalCore && (Core.DefenderTeamIndex < 2) )
    			FinalCore[Core.DefenderTeamIndex] = Core;
    }

	if ( !bReceivedLinks && OwnerPRI != None )
	{
		ClearLinks();
		RequestPowerLinks();
	}

	ColorPercent = 0.5f + Cos((Level.TimeSeconds * 4.0) * 3.14159 * 0.5f) * 0.5f;
}

simulated function RequestPowerLinks()
{
	if ( OwnerPRI != None )
	{
		OwnerPRI.OnReceiveLink = ReceiveLink;
		OwnerPRI.OnRemoveLink = RemoveLink;
		OwnerPRI.ResetLinks = ResetLinks;
		OwnerPRI.ServerSendPowerLinks();
		bReceivedLinks = true;
	}
}

exec function ToggleRadarMap()
{
	bMapDisabled = !bMapDisabled;
}

//exec function ZoomInRadarMap()
//{
//    RadarRange = Max(RadarRange - (RadarMaxRange * 0.1), 3000.0);
//}
//
//exec function ZoomOutRadarMap()
//{
//    RadarRange = Min(RadarRange + (RadarMaxRange * 0.1), RadarMaxRange);
//}

exec function LinkDesigner()
{
    if (OwnerPRI != None)
		OwnerPRI.RequestLinkDesigner();
}

exec function CopyLinkSetup()
{
	local ONSPowerLinkOfficialSetup S;
	local ONSOnslaughtGame.PowerLinkSetup BlankSetup;
	local ONSPowerCore O;
	local int x, y;

	S = spawn(class'ONSPowerLinkOfficialSetup');
	foreach DynamicActors(class'ONSPowerCore', O)
	{
		S.LinkSetups[x] = BlankSetup;
		S.LinkSetups[x].BaseNode = O.Name;
		for (y = 0; y < O.PowerLinks.length; y++)
			S.LinkSetups[x].LinkedNodes[y] = O.PowerLinks[y].Name;
		x++;
	}

	CopyObjectToClipboard(S);
	S.Destroy();

	PlayerOwner.ClientMessage("Link setup copied to clipboard");
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'HudContent.Generic.NoEntry');
    Level.AddPrecacheMaterial(Material'HudContent.Generic.HUD');
    Level.AddPrecacheMaterial(Material'InterfaceContent.BorderBoxD');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.HealthBar');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.MapBorderTex');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.NewHUDicons');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.CurrentPlayerIcon');

	Super.UpdatePrecacheMaterials();
}

simulated static function bool CoreWorldToScreen( ONSPowerCore Core, out vector ScreenPos, float ScreenX, float ScreenY, float RadarWidth, float Range, vector Center, optional bool bIgnoreRange )
{
	local vector ScreenLocation;
	local float Dist;

	if ( Core == None )
		return false;

    ScreenLocation = Core.Location - Center;
    ScreenLocation.Z = 0;
	Dist = VSize(ScreenLocation);
	if ( bIgnoreRange || (Dist < (Range * 0.95)) )
	{
        ScreenPos.X = ScreenX + ScreenLocation.X * (RadarWidth/Range);
        ScreenPos.Y = ScreenY + ScreenLocation.Y * (RadarWidth/Range);
        ScreenPos.Z = 0;
        return true;
    }

    return false;
}

simulated static function DrawMapImage( Canvas C, Material Image, float MapX, float MapY, float PlayerX, float PlayerY, vector Dimensions )
{
	local float MapScale, MapSize;
	local byte  SavedAlpha;

	/*
	Dimensions.X = Width
	Dimensions.Y = Range
	Dimensions.Z = Alpha

	*/

	if ( Image == None || C == None )
		return;

	MapSize = Image.MaterialUSize();
	MapScale = MapSize / (Dimensions.Y * 2);

	SavedAlpha = C.DrawColor.A;

	C.DrawColor = default.WhiteColor;
	C.DrawColor.A = Dimensions.Z;

	C.SetPos( MapX - Dimensions.X, MapY - Dimensions.X );
	C.DrawTile( Image, Dimensions.X * 2.0, Dimensions.X * 2.0,
	           (PlayerX - Dimensions.Y) * MapScale + MapSize / 2.0,
			   (PlayerY - Dimensions.Y) * MapScale + MapSize / 2.0,
			   Dimensions.Y * 2 * MapScale, Dimensions.Y * 2 * MapScale );

	C.DrawColor.A = SavedAlpha;
}

simulated static function DrawAttackIcon( Canvas C, ONSPowerCore CurCore, vector HUDLocation, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float AttackIconSize, CoreIconSize;
	local color HoldColor;

	if ( C == None )
		return;

    if (CurCore.bFinalCore)
	   CoreIconSize = 2.0 * IconScaling * 16 * C.ClipX * HUDScaling/1600;
	else
	   CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;

    AttackIconSize = CoreIconSize * (2.5 + 1.5 * ColorPercentage);

    HoldColor = C.DrawColor;

    if (CurCore.bSevered && CurCore.CoreStage == 0)
        C.DrawColor = default.SeveredColorA * ColorPercentage + default.SeveredColorB * (1.0 - ColorPercentage);
    else
        C.DrawColor = default.AttackColorA * ColorPercentage + default.AttackColorB * (1.0 - ColorPercentage);

    C.SetPos(HUDLocation.X - AttackIconSize * 0.5, HUDLocation.Y - AttackIconSize * 0.5);
    C.DrawTile(Material'NewHUDIcons', AttackIconSize, AttackIconSize, 0, 64, 64, 64);
    C.DrawColor = HoldColor;
}

simulated static function DrawCoreIcon( Canvas C, vector HUDLocation, bool bAttackable, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float CoreIconSize;
//	local color HoldColor;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    C.SetPos(HUDLocation.X - CoreIconSize * 3.0 * 0.5, HUDLocation.Y - CoreIconSize * 3.0 * 0.5);

//    HoldColor = C.DrawColor;

    if (bAttackable)
        C.DrawColor = C.DrawColor * ColorPercentage + (C.DrawColor * 0.5) * (1.0 - ColorPercentage);

    C.DrawTile(Material'NewHUDIcons', CoreIconSize * 3.0, CoreIconSize * 3.0, 64, 0, 64, 64);
//    C.DrawColor = HoldColor;
}

simulated static function DrawNodeIcon( Canvas C, vector HUDLocation, bool bAttackable, byte Stage, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float CoreIconSize;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    if (Stage == 4 || Stage == 1)
    {
        if (bAttackable)
        {
            C.SetPos(HUDLocation.X - CoreIconSize * 0.75 * 0.5, HUDLocation.Y - CoreIconSize * 0.75 * 0.5);
            C.DrawTile(Material'NewHUDIcons', CoreIconSize * 0.75, CoreIconSize * 0.75, 0, 0, 32, 32);
        }
        else
        {
            C.SetPos(HUDLocation.X - CoreIconSize * 1.75 * 0.5, HUDLocation.Y - CoreIconSize * 1.75 * 0.5);
            C.DrawTile(Material'NewHUDIcons', CoreIconSize * 1.75, CoreIconSize * 1.75, 0, 32, 32, 32);
        }
    }
    else
	{
		if ( Stage != 0 )
			C.DrawColor = C.DrawColor * ColorPercentage + default.LinkColor[2] * (1.0 - ColorPercentage);

		if (bAttackable)
	    {
	        C.SetPos(HUDLocation.X - CoreIconSize * 2.0 * 0.5, HUDLocation.Y - CoreIconSize * 2.0 * 0.5);
	        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 2.0, CoreIconSize * 2.0, 32, 0, 32, 32);
	    }
	    else
	    {
	        C.SetPos(HUDLocation.X - CoreIconSize * 1.75 * 0.5, HUDLocation.Y - CoreIconSize * 1.75 * 0.5);
	        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 1.75, CoreIconSize * 1.75, 0, 32, 32, 32);
	    }
	}
}

simulated static function DrawSpawnIcon( Canvas C, vector HUDLocation, bool bFinalCore, float IconScaling, float HUDScaling )
{
	local float CoreIconSize;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    C.DrawColor.B = 0;
    C.DrawColor.G = 200;
    C.DrawColor.R = 0;
    C.DrawColor.A = 255;

    if (bFinalCore)
    {
        C.SetPos(HUDLocation.X - CoreIconSize * 5.5 * 0.5, HUDLocation.Y - CoreIconSize * 5.5 * 0.5);
        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 5.5, CoreIconSize * 5.5, 64, 64, 64, 64);
    }
    else
    {
        C.SetPos(HUDLocation.X - CoreIconSize * 4.5 * 0.5, HUDLocation.Y - CoreIconSize * 4.5 * 0.5);
        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 4.5, CoreIconSize * 4.5, 64, 64, 64, 64);
    }
}

simulated static function DrawSelectionIcon( Canvas C, vector HUDLocation, color IconColor, float IconScaling, float HUDScaling )
{
	local float CoreIconSize;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;

	C.DrawColor = IconColor;
	C.SetPos( HUDLocation.X - CoreIconSize * 1.5, HUDLocation.Y - CoreIconSize * 1.5);
	C.DrawTile( Material'NewHUDIcons', CoreIconSize * 3, CoreIconSize * 3, 32, 32, 32, 32 );
}

defaultproperties
{
     RadarScale=0.200000
     RadarTrans=255.000000
     IconScale=1.000000
     RadarPosX=1.000000
     RadarPosY=0.100000
     RadarMaxRange=500000.000000
     HealthBarBackMat=Texture'InterfaceContent.Menu.BorderBoxD'
     HealthBarMat=Texture'ONSInterface-TX.HealthBar'
     HealthBarWidth=75.000000
     HealthBarHeight=8.000000
     HealthBarPosition=485.000000
     HealthBarViewDist=4000.000000
     BorderMat=Texture'ONSInterface-TX.MapBorderTEX'
     AttackColorA=(G=189,R=244,A=255)
     AttackColorB=(B=11,G=162,R=234,A=255)
     SeveredColorA=(B=192,G=192,R=192,A=255)
     SeveredColorB=(B=128,G=128,R=128,A=255)
     LinkColor(0)=(R=255,A=255)
     LinkColor(1)=(B=255,A=255)
     LinkColor(2)=(B=255,G=255,R=255,A=255)
     SymbolGB(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.600000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-32,OffsetY=7,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SymbolGB(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.600000,PosX=0.500000,OffsetX=32,OffsetY=7,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CoreWidgets(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=365,Y1=233,X2=432,Y2=313),TextureScale=0.250000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-110,OffsetY=45,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=100,G=100,R=255,A=200),Tints[1]=(B=32,G=32,R=255,A=200))
     CoreWidgets(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=365,Y1=233,X2=432,Y2=313),TextureScale=0.250000,PosX=0.500000,OffsetX=110,OffsetY=45,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=128,A=200),Tints[1]=(B=255,G=210,R=32,A=200))
     CoreHealthWidgets(0)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.240000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-149,OffsetY=88,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CoreHealthWidgets(1)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.240000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=149,OffsetY=88,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     NodeLabelWidget=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.240000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreTeam(0)=(MinDigitCount=2,PosX=0.442000)
     ScoreTeam(1)=(MinDigitCount=2,PosX=0.558000)
     TeamScoreBackGround(0)=(PosX=0.442000)
     TeamScoreBackGround(1)=(PosX=0.558000)
     TeamScoreBackGroundDisc(0)=(PosX=0.442000)
     TeamScoreBackGroundDisc(1)=(PosX=0.558000)
     TeamSymbols(0)=(PosX=0.442000)
     TeamSymbols(1)=(PosX=0.558000)
}
