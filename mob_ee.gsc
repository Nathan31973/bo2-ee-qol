#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

init()
{
	level thread mob_solo();
}

mob_solo()
{ 
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		level waittill_multiple( "nixie_final_" + 386, "nixie_final_" + 481, "nixie_final_" + 101, "nixie_final_" + 872 );
		if (getPlayers().size <= 1)
		{
			addtestclient();
		}
	}
}