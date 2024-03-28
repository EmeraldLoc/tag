# Creating a Official Romhack

Before beginning, this guide assumes you have some lua experience, experience with photo editors, and experience with git/github.

### Some Recommended Mods

[Noclip](https://mods.sm64coopdx.com/mods/noclip.30/)
[Position Display](https://github.com/Agent-11/agent-ex-coop-mods/blob/main/mods/pos-display.lua)

### Actually Beggining

First, head to `romhacks.lua`. There should be a table called `romhacks` in that file.

The table `romhacks` is a table containing:

| Field | Type | Notes |
| ----- | ---- | ----- |
| `name`|`string`|Name of the romhack.
| `shortName`|`string`|The short name/abbreviated name of the romhack.
| `levels`|`table`|The table of levels in the romhack.

The first 2 fields are rather simple, the 3rd one is where the fun begins.

A `levels` table contains the following fields:

| Field | Type | Notes |
| ----- | ---- | ----- |
| `name`|`string`|Abbreviated level name.
| `level`|`integer`|The level id.
| `painting` |`texture/nil`|A painting for the level.
| `area`|`integer`|The area for a level.
| `pipes`|`table/nil`|A table of pairs of 2 pipes.
| `spawnLocation`|`Vec3/nilf`|A spawn location.
| `overrideName`|`string/nil`|A override name, typically used for subareas.

Anything with /nil in it means it's optional, and you don't have to include it. Pipes and paintings should be set to nil, whereas spawnLoaction and overrideName can just not be included in the table. Begin constructing the table, keep painting and pipes as nil for now.

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
            { x = 0, y = 0, z = 0}
        },
        {
            { x = 0, y = 0, z = 0},
            { x = 0, y = 0, z = 0}
        }
    }
}
```

Except do that on one line. Now get a mod that renders mario's position (I recommend Pos Display), and go to the place you want your first pipe to go. Now plug in the position values into the first pipe, and do the same for the second, and that's it! You can have as many pairs of pipes as you want.

### Contributing

Once you do all this, fork the tag repo, put your changes into that repo, and make a pull request. Put in the name you would like to be credited with and I will make sure to credit you.

That's it!
