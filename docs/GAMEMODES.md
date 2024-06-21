# Adding Gamemodes

Warning: You will need some background lua experience to add gamemodes.

Adding gamemodes can be tedious, yet fun! To begin adding a gamemode, head to where all the gamemodes are initialized in `main.lua`. you should see a list of gamemodes with assigned integer values. You can simply increment the `MAX_GAMEMODES` variable, and on the line above the line where `MAX_GAMEMODES` is initialized, you can add the name of your gamemode, in all capital letters (i.e `GAMEMODE_3`), and set the variable to be set to the same number you set `MAX_GAMEMODES` to. Example:

Old:
```
-- gamemodes
MIN_GAMEMODE     = 1
GAMEMODE_1       = 1
GAMEMODE_2       = 2
MAX_GAMEMODE     = 2
```

New:
```
-- gamemodes
MIN_GAMEMODE     = 1
GAMEMODE_1       = 1
GAMEMODE_2       = 2
GAMEMODE_3       = 3
MAX_GAMEMODE     = 3
```

Next, you'll need to set the players required to start this gamemode. To do this, find where the `playersNeeded` variable is initialized. From there, add your gamemode to the list. Example:

Old:
```
playersNeeded = {
    [GAMEMODE_1] = 2,
    [GAMEMODE_2] = 3,
}
```

New:
```
playersNeeded = {
    [GAMEMODE_1] = 2,
    [GAMEMODE_2] = 3,
    [GAMEMODE_3] = 2,
}
```

Once you do that, head to the `get_gamemode` function in `a-misc.lua`. Scroll to the bottom of the function, and add your gamemode entry there. Example:

Old:
```
function get_gamemode(g)
	if g == GAMEMODE_1 then
		return "\\#316BE8\\Gamemde!!\\#DCDCDC\\"
	elseif g == GAMEMODE_2 then
        	return "\\#E82E2E\\Gamemde 2!!\\#DCDCDC\\"
	end

	return "Uhhhhhhhhhh"
end
```

New:
```
function get_gamemode(g)
	if g == GAMEMODE_1 then
		return "\\#316BE8\\Gamemde!!\\#DCDCDC\\"
	elseif g == GAMEMODE_2 then
        	return "\\#E82E2E\\Gamemde 2!!\\#DCDCDC\\"
	elseif g == GAMEMODE_3 then
		return "\\#F9F000\\Gamemode 3!\\#DCDCDC\\"
	end

	return "Uhhhhhhhhhh"
end
```

Optional: The default active timer for a gamemode is 120 seconds. If you want the default active timer to be different, in `main.lua`, head to where `gGlobalSyncTable.activeTimers` is initialized to a table. ("`{}`"). Below that is a loop where each gamemode has it's active timer set. You can add an exception for your gamemode, and make it use the default active timer you want. Example:

Old:
```
for i = MIN_GAMEMODE, MAX_GAMEMODE do
    gGlobalSyncTable.activeTimers[i] = 120 * 30
end
```

New:
```
for i = MIN_GAMEMODE, MAX_GAMEMODE do
    gGlobalSyncTable.activeTimers[i] = 120 * 30

    if i == GAMEMODE_3 then
        gGlobalSyncTable.activeTimers[i] = 240 * 30
    end
end
```

Optional: If you want override runner/tagger names (like in Infection, or Juggernaut), you can head to the `get_role_name` function in `a-misc.lua`. There, head to the role checked, and add an exception for your gamemode. Example:

Old:
```
if role == RUNNER then
    return "\\#316BE8\\Runner"
elseif role == TAGGER then
    return "\\#E82E2E\\Tagger"
end
```

New:
```
if role == RUNNER then
    if g == GAMEMODE_3 then
        return "\\#0000FF\\Blue Man"
    end

    return "\\#316BE8\\Runner"
elseif role == TAGGER then
    if g == GAMEMODE_3 then
        return "\\#FF0000\\Red Man"
    end

    return "\\#E82E2E\\Tagger"
end
```

Optional: If you changed the role name, you probably want to change the top text in the Leaderboard. This can be done in a very similar manner to the roles. In `hud_leaderboard.lua`, in the `hud_winner_group_render` function, there should be 2 if statements, one for runners winning, and one for taggers winning. Add your exceptions accordingly. Example:

Old:
```
local text = "What the heck is happening."

if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
    text = "Runners Win"
elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
    text = "Taggers Win"
end
...
```

New:
```
local text = "What the heck is happening."

if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
    text = "Runners Win"

    if gGlobalSyncTable.gamemode == GAMEMODE_3 then
        text = "Blue Men Win"
    end
elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
    text = "Taggers Win"

    if gGlobalSyncTable.gamemode == GAMEMODE_3 then
        text = "Red Men Win"
    end
end
...
```

Now, for the hard part, making the logic for the gamemode. Create a lua file for your gamemode (i.e `gamemode_3.lua`). Then, I'd recommend copying the `tag.lua` file into your lua file. From there, go through each and every function, and update/remove anything that doesn't need to exist. At the beginning of each function, be sure to have:
```
if gGlobalSyncTable.gamemode ~= GAMEMODE then return end
```

The `WILDCARD_ROLE` is a 3rd role you can use for a gamemode, and as the name suggest's, it can be a role for anything.

That's the current documentation, more in-depth documentation is planned.
