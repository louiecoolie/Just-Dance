local gameRules = {}


local BaseVehicleCaps = {
	LandLightArmor = 10; -- jeeps
	LandArtillery = 4; --  rocket artillery
	LandHeavyArmor = 8; -- tanks, apc
	AirHelicopterTransport = 6; -- light and transport helis
	AirHelicopterCombat = 3; -- attack helis
	AirJet = 2; -- jets
	AirFighter = 2;
};

local BaseWorldSettings = {
	Gravity = 1;
--	SeaLevel = 1;
--	WalkSpeed = 1;
	Trees = true;

}

local VehiclePointCostMultipliers = {
	LandLightArmor = 1; -- jeeps
	LandArtillery = 1; --  rocket artillery
	LandHeavyArmor = 1; -- tanks, apc
	AirHelicopterTransport = 1; -- light and transport helis
	AirHelicopterCombat = 1; -- attack helis
	AirJet = 1; -- jets
	AirFighter = 1; -- figher
};

gameRules["gamemode_bnb"] = {
    RuleSet =  {
        Map = "Procedural Hills";
		UsesTimer = true;
		RoundTime = 3600;
		StartingPoints = 100;
		MaxTeams = 2;
		Teams = {
			{
				Preset = "TEAM_BLUE";
				Reinforcements = 1750;
			},
			{
				Preset = "TEAM_RED";
				Reinforcements = 1750;
			}
		};
		-- Have an Enable Cheat rules option

		ClockTime = 14;

		Godmode = false;
		NBZ = false;

		WorldSettings = BaseWorldSettings;
        BaseVehicleCaps = BaseVehicleCaps;
        VehiclePointCostMultipliers = VehiclePointCostMultipliers;
     };
     ServerInfo = {
        ServerDescription = "Enter a description here!",
        ServerIcon = "rbxassetid://924320031",
        ServerInfo = "Build and Battle! Custom!",
     }
}

gameRules["gamemode_b"] = {
    RuleSet = {
        Map = "Procedural Hills";
		UsesTimer = false;
		RoundTime = 3600;
		StartingPoints = 1000;
		MaxTeams = 2;
		Teams = {
			{
				Preset = "TEAM_BLUE";
				Reinforcements = 1750;
			},
			{
				Preset = "TEAM_RED";
				Reinforcements = 1750;
			}
		};
		-- Have an Enable Cheat rules option
		
		ClockTime = 14;

		Godmode = true;
		NBZ = true;

		WorldSettings = {
			Gravity = 2;
			--SeaLevel = 1; -- to be implemented later
			--WalkSpeed = 1;
			Trees = true;
		
		};
        BaseVehicleCaps = BaseVehicleCaps;
        VehiclePointCostMultipliers = VehiclePointCostMultipliers;
     };
     ServerInfo = {
        ServerDescription = "Enter a description here!",
        ServerIcon = "rbxassetid://924320031",
        ServerInfo = "Building Sandbox! Custom!",
     }
}


return gameRules