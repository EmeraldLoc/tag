Note: This guide assumes you have knowledge of how to make a basic lua mod.

# Making a Stage Port for Tag

Porting stages to Tag isn't always the easiest at first, but gets easier once you gradually make more.
This guide will go over how to port an arena stage and a normal custom stage.

### Before Beginning

I recommend you check out the [romhack documentation](ROMHACKS.md) first. There is a lot of useful information there, and it's relatively similar to the process here. Some of the information here won't be explained, as it's explained there, so be sure to read that first!

### Adding a Custom Stage

Custom stages are seperate from the actual Tag mod. You create a mod that hooks into Tag's API to add a level. So, before moving on, be sure to create a folder mod that has a `main.lua` file, with your `levels` folder that has your level in it.

Now, open up the `main.lua` file. Custom levels are different than romhack levels. They need to be registered in the game's level database in order for the level to work. Here is some example code of what this would look like:

```
LEVEL_EXAMPLE = level_register('level_example_entry', COURSE_NONE, 'Name', 'example', 28000, 0x28, 0x28, 0x28)
```

I won't explain the arguments in-depth, however, the first argument is the name of the level entry (the file name for the .lvl file in the levels folder), the second argument is the course number, which will generally be set to none, the third argument is the level's name, with the fourth being the level id. The level id allows other mods to see if a level exists. For the last 4 arguments, generally just leave those at default unless you know what you're doing.

Now, we need to add the level to Tag's `levels` table. To do this, create a `joined_game` function, and hook that function to the `HOOK_JOINED_GAME` hook, like this:

```
local function joined_game()

end

hook_event(HOOK_JOINED_GAME, joined_game)
```

Now, we should add a failsafe that checks if Tag is loaded or not. Tag's API is a table, so you can simply check if that table exists or not by using the `not` keyword, then creating a popup from there. Here's an example of that:

```
if not _G.tag then
    djui_popup_create("The mod Tag is not loaded!", 2)
    return
end
```

The next step is adding the level to the Tag `levels` table. To do this, Tag has a function called `add_level`, we can access this function via `_G.tag.add_level`. The way you format using this function is entirely up to you, however I recommend treating the function like you're creating a table. Here's each argument for the `add_level` function:

| Field | Type | Notes |
| ----- | ---- | ----- |
| shortName | `string` | The level's shortname.
| level | `LevelNum\|integer` | The level id.
| painting | `TextureInfo\|nil` | The painting for the level.
| area | `integer` | The area the level takes place in.
| pipes | `table\|nil` | A list of pairs of pipes.
| spawnLocation | `Vec3f\|nil` | The position the player spawns in.
| spring | `table\|nil` | Where springs are placed.

Most of these you should know from the [romhack documentation](ROMHACKS.md). If you haven't read that yet, I'd recommend you give it a quick read.

Now, with that, here's an example of adding a level to Tag:

```
_G.tag.add_level(
    "example",
    LEVEL_EXAMPLE,
    get_texture_info("painting_example"),
    1,
    {
        {
            { x = 1000, y = 0, z = 0 },
            { x = -1000, y = 0, z = 0 },
        },
        {
            { x = 0, y = 0, z = 1000 },
            { x = 0, y = 150, z = -1000 },
        },
    },
    { x = 0, y = 0, z = 0 },
    {
        { x = 100, y = 0, z = 100, pitch = 0, yaw = 0, strength = 100 }
    }
)
```

With that done, you should have a level added to Tag! To test this, host a singleplayer lobby with the Tag mod, and your level mod active. Then, head into the Start menu in Options, and select your level. You should be able to see your pipes and springs!

If you have a good eye, you may have noticed that not all the entries that would exist when creating a romhack exist here. Tag expects the mod you're creating to handle most of the stuff related to your level. SO if you want a certain behavior to be removed, or the floor type to be changed, you need to do so in your mod, rather than depending on Tag's API for that stuff.

### Arena Stages

Arena stages already does a good amount of stuff for you. Pipes are added to the red and green flags in Capture the Flag, the spawn location is set to the spot where the Flag Tag flag spawns, and all springs are kept in the level. The only real changes you need to make to these stages is adding a painting, otherwise most of the work is done for you!

### Collision Fixes

If your level is experiencing weird collision jankiness, you can add a flag to fix most collision bugs to the top of the file:

```
gLevelValues.fixCollisionBugs = 1
```
