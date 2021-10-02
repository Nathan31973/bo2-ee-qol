#include maps/mp/_utility;
#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_sidequests;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zm_buried_sq_tpo;
#include maps/mp/zm_buried_sq_ows;
#include maps/mp/zm_buried_sq_ip;

// This Script was created By StickGaming 
// Some code in the script have been use or remix from other people round the internet
// This script is allow to be shared around the interwebs
//
// Any contributors will be credited down below
// Nathan3197
// 
//
// Credit of use of other people code found on the internet
//  Teh-Bandit - for making the time bomb step to be done with any amount of player
// 
// Big thanks to the pluto team for all there hard efforts to allow us to play BO2 with mods and servers.

	// Buried all player EE


main()
{
	// replacing 3arc functions
	replaceFunc( ::_are_all_players_in_time_bomb_volume, ::new_are_all_players_in_time_bomb_volume );
	replaceFunc( ::ows_target_delete_timer, ::new_ows_target_delete_timer );
	replaceFunc( ::ows_targets_start, ::new_ows_targets_start);
	replaceFunc( ::sndhit, ::sndhitnew);
	replaceFunc( ::sq_ml_puzzle_logic, ::new_sq_ml_puzzle_logic);

	// setting up target to hit (it will be used later)
	level.targettohit = 19;
	level thread playertracker_onlast_step();
}
playertracker_onlast_step()
{
	// when the players are on the last step of rich EE we are going
	// to check how many players are in the lobby when this step is activated
	// and change the target require to be hit base on how many players are in
	// the session.
	level endon("game_end"); //kill this function on game end
	level endon("step_done"); //kill this function when the step is done (fail or sucess)
	for(;;)
	{
		wait 1;
		flag_wait("sq_ows_start");
		players = getPlayers();
		if(players.size == 1)
		{
			level.targettohit = 19; // Saloon has 19 target 
		}
		else if(players.size == 2)
		{
			level.targettohit = 39; // Saloon + outside the candy store (20)
		}
		else if(players.size == 3)
		{
			level.targettohit = 61; //Saloon + outside the candy store + Myster box area (big guy area 22)
		}
		else if(players.size >= 4) //All 4 areas of the map
		{
			level.targettohit = 84;
		}
		wait 45;
		// in game the players can miss some targets depending on what area they choose.
		if(level.targettohit >= 1) // resetting if the player hasn't hit all the target that is required
		{
			flag_set( "sq_ows_target_missed" );
			flag_clear("sq_ows_start");
		}
	}
}

//Teh-Bandit time bomb fix
new_are_all_players_in_time_bomb_volume( e_volume )
{
	n_required_players = 4;
	a_players = get_players();
	if ( getPlayers().size <= 8 ) //this allow server with 8 player limit to do the EE
	{
		n_required_players = a_players.size;
	}
	n_players_in_position = 0;
	_a239 = a_players;
	_k239 = getFirstArrayKey( _a239 );
	while ( isDefined( _k239 ) )
	{
		player = _a239[ _k239 ];
		if ( player istouching( e_volume ) )
		{
			n_players_in_position++;
		}
		_k239 = getNextArrayKey( _a239, _k239 );
	}
	b_all_in_valid_position = n_players_in_position == n_required_players;
	return b_all_in_valid_position;
}

//When a target spawn it has alive timer then it will despawn
new_ows_target_delete_timer()
{
	self endon( "death" );
	wait 5; // change this if you want the target to stay alive longer (3arc had this set to 4)
	self notify( "ows_target_timeout" );	
}

//when a target is hit play a sound
sndhitnew()
{
	self endon( "ows_target_timeout" );
	self waittill( "damage" );
	level.targettohit--; // target to hit does down
	//AllClientsPrint("target left to hit:" + level.targettohit); //debug
	self playsound( "zmb_sq_target_hit" );
}

//rip from 3arc but with some changes
new_ows_targets_start()
{
	n_cur_second = 0;
	flag_clear( "sq_ows_target_missed" );
	level thread sndsidequestowsmusic();
	a_sign_spots = getstructarray( "otw_target_spot", "script_noteworthy" );
	while ( n_cur_second < 40 )
	{
		a_spawn_spots = ows_targets_get_cur_spots( n_cur_second );
		if ( isDefined( a_spawn_spots ) && a_spawn_spots.size > 0 )
		{
			ows_targets_spawn( a_spawn_spots );
		}
		wait 1;
		n_cur_second++;
	}
	//AllClientsPrint("Waiting for target to stop spawning");
	if ( !flag( "sq_ows_target_missed" ) )
	{
		level notify("step_done"); // this allow us to close any function that have this on endon
		flag_set( "sq_ows_success" );
		playsoundatposition( "zmb_sq_target_success", ( 0, 0, 0 ) );
	}
	else
	{
		level notify("step_done"); // this allow us to close any function that have this on endon
		level thread playertracker_onlast_step();
		playsoundatposition( "zmb_sq_target_fail", ( 0, 0, 0 ) );
	}
	level notify( "sndEndOWSMusic" );
}

//Maze fix (rip from 3arc but with some changes)
new_sq_ml_puzzle_logic()
{
	a_levers = getentarray( "sq_ml_lever", "targetname" );
	level.sq_ml_curr_lever = 0;
	a_levers = array_randomize( a_levers );
	i = 0;
	while ( i < a_levers.size )
	{
		a_levers[ i ].n_lever_order = i;
		i++;
	}
	while ( 1 )
	{
		level.sq_ml_curr_lever = 0;
		sq_ml_puzzle_wait_for_levers();
		n_correct = 0;
		_a424 = a_levers;
		_k424 = getFirstArrayKey( _a424 );
		while ( isDefined( _k424 ) )
		{
			m_lever = _a424[ _k424 ];
			players = getPlayers();
			if ( m_lever.n_flip_number == m_lever.n_lever_order )
			{
				playfxontag( level._effect[ "sq_spark" ], m_lever, "tag_origin" );
				n_correct++;
				m_lever playsound( "zmb_sq_maze_correct_spark" );
				// this step is really hard to do when you don't have 4 people watching all 4 switches at the same time
				// with 3 or less players tell the player if a switch is in the correct order but don't tell what color
				if(players.size <= 3)
				{
					AllClientsPrint("^3Spark");
				}
			}
			else
			{
				// this step is really hard to do when you don't have 4 people watching all 4 switches at the same time
				// with 3 or less players tell the player if a switch is in the correct order but don't tell what color
				if(players.size <= 3)
				{
					AllClientsPrint("No Spark");
				}
			}
			_k424 = getNextArrayKey( _a424, _k424 );
		}
		if ( n_correct == a_levers.size )
		{
			flag_set( "sq_ip_puzzle_complete" );
		}
		level waittill( "zm_buried_maze_changed" );
		level notify( "sq_ml_reset_levers" );
		wait 1;
	}
}
