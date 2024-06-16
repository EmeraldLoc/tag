# Creating a Official Romhack

Before beginning, this guide assumes you have some lua experience, experience with photo editors, and experience with git/github.

### Some Recommended Mods

[Noclip](https://mods.sm64coopdx.com/mods/noclip.30/)
[Position Display](https://github.com/Agent-11/agent-ex-coop-mods/blob/main/mods/pos-display.lua)

### Romhack Table Configuration

First, head to `romhacks.lua`. There should be a table called `romhacks` in that file.

The table `romhacks` is a table containing multiple romhack entries. A romhack entries looks like:

| Field | Type | Notes |
| ----- | ---- | ----- |
| `name`|`string`|Name of the romhack.
| `shortName`|`string`|The short name/abbreviated name of the romhack.
| `water`|`boolean`|The default value for the water variable.
| `levels`|`table`|The table of levels in the romhack.

The first 3 fields are rather simple, the 4th one is where the fun begins.

A `levels` table contains the following fields:

| Field | Type | Notes |
| ----- | ---- | ----- |
| `name`|`string`|Abbreviated level name.
| `level`|`integer`|The level id.
| `painting` |`texture/nil`|A painting for the level.
| `area`|`integer`|The area for a level.
| `pipes`|`table/nil`|A table of pairs of 2 pipes.
| `springs`|`table/nil`|A table of springs. Each entry containing an x, y, and z coordinate, the pitch, yaw, and strength.
| `spawnLocation`|`Vec3f/nil`|A spawn location.
| `overrideName`|`string/nil`|A override name, typically used for subareas.
| `room`|`integer/nil`|A specific room to be forced. You have 5 seconds to re-enter a room if you leave it, shown with buzzing.
| `unwantedBhvs`|`table/nil`|A table of unwanted behavior id's.
| `disabledBhvs`|`table/nil`|A table of disabled behavior id's, disabled meaning disabling interaction's for that behavior.
| `levelLoop`|`function`|A function that runs every frame when the level is in play.

Anything with /nil in it means it's optional, and you don't have to include it. Pipes and paintings should be set to nil, whereas anything after pipes doesn't have to be included in the table (for no good reason, this needs to be update, here's a TODO for me). Begin constructing the table, keep painting and pipes as nil for now.

### Paintings

![painting_template](https://github.com/EmeraldLoc/tag-dev/assets/86802223/771dd2a2-6bc7-4d07-9799-02b4dd0166b9)

Paintings typically contain a main attraction. Think of sl's snowman head, the wiggler, or the eyerock as gold examples of paintings. You can use that painting template to easily create a painting, so long as you have a little bit of knowledge on how to use a photo editor. Also, if the romhack already has painting for levels, go grab those instead. They will probably have to be stiched together from multiple files, but that would be ideal. Also I'd recommend the Noclip mod for getting the shot.

Once you finish getting all your paintings, name them with this naming scheme:

x = short name for romhack

y = level name

`painting_x_y`

Example:

`painting_vanilla_cg`

Once you've done all that, drag your paintings into Tag's `texture` directory.

Once you do that, add your textures to the painting entry via `get_texture_info(painting_x_y)`

### Pipes

Creating pipes is easy. Here's how the pipe's table is constructed:

```
pipes = {
    -- list of pairs of pipes
    {
        -- pair of pipes
        {
            -- pipe
            { x = 0, y = 0, z = 0},
            -- pipe
            { x = 0, y = 0, z = 0}
        },
        -- pair of pipes
        {
            -- pipe
            { x = 0, y = 0, z = 0},
            -- pipe
            { x = 0, y = 0, z = 0}
        }
    }
}
```

Now get a mod that renders mario's position (I recommend Pos Display), and go to the place you want your first pipe to go. Now plug in the position values into the first pipe, and do the same for the second, and that's it! You can have as many pairs of pipes as you want.

### Contributing

Once you do all this, fork the tag repo, put your changes into that repo, and make a pull request. Put in the name you would like to be credited with and I will make sure to credit you.

That's it!
