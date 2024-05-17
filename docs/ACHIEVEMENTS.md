# Making Achievements

Here are each of the entries of an achievement:

| Field | Type | Notes |
| ----- | ---- | ----- |
| name | string | The name of the achievement. This is what shows up when you get the achievement.
| description | string | The description/guide for how to get the achievement.
| reward | Reward | The rewards for getting achivements. The reward class is talked about later.
| initFunc | function or nil | A function that is ran at the start of the game,
| loopFunc | function or nil | A function that is ran each frame.

Now, for rewards...

| Field | Type | Notes |
| ----- | ---- | ----- |
| title | string or nil | A title a player can use.
| trail | Trail or nil | A boost trail a player can use.

The trail class is:

| Field | Type | Notes |
| ----- | ---- | ----- |
| name | string | The name of the trail.
| model | ModelExtendedId or Integer | The model for the trail.

Types that are also nil means it's optional.

Some useful entries for making achievements is the stats variable. This gets the players stats, you can get global stats via "stats.globalStats.x", and gamemode stats via "stats[GAMEMODE_HERE].x". If you need a variable to say, start a timer, do so below the class definitions and above the achievements list.