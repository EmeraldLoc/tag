# Adding Modifiers

Warning: You will need some background lua experience to add modifiers.

To start adding a modifier, first head into `main.lua`, and find where each modifier is initialized. It should look something like this:

```
MODIFIER_MIN                           = 0
MODIFIER_NONE                          = 0
MODIFIER_1                             = 1
MODIFIER_2                             = 2
MODIFIER_MAX                           = 2
```
Adding a modifier to this list is easy, simply add to the bottom of the list your modifier. Put `MODIFIER_` at the beginning, then your modifier name, i.e. `MODIFIER_3`. You then want to increment `MODIFIER_MAX` by 1. Here's an example:

Before:
```
MODIFIER_MIN                           = 0
MODIFIER_NONE                          = 0
MODIFIER_1                             = 1
MODIFIER_2                             = 2
MODIFIER_MAX                           = 2
```

After:
```
MODIFIER_MIN                           = 0
MODIFIER_NONE                          = 0
MODIFIER_1                             = 1
MODIFIER_2                             = 2
MODIFIER_3                             = 3
MODIFIER_MAX                           = 3
```

The next step is making the name with the hex color, you know, what everyone actually see's. Open up the `a-misc.lua` file, and head to the function `get_modifier_text`. Inside this function, you'll notice each modifier is given a name, we can add a name by adding a if statement before `MODIFIER_NONE` is checked, checking if the modifier is set to our new one, and returning our modifier name. Here's an example:

Before:
```
if m == MODIFIER_1 then
    text = "\\#FFFFFF\\1"
elseif m == MODIFIER_2 then
    text = "\\#DCDCDC\\2"
elseif m == MODIFIER_NONE and gGlobalSyncTable.randomModifiers then
    text = "\\#FFFFFF\\None"
elseif m == MODIFIER_NONE then
    text = "Disabled"
end
```

After:
```
if m == MODIFIER_1 then
    text = "\\#FFFFFF\\1"
elseif m == MODIFIER_2 then
    text = "\\#DCDCDC\\2"
elseif m == MODIFIER_3 then
    text = "\\#FF0000\\3"
elseif m == MODIFIER_NONE and gGlobalSyncTable.randomModifiers then
    text = "\\#FFFFFF\\None"
elseif m == MODIFIER_NONE then
    text = "Disabled"
end
```

Now, at this point, you need to understand what your modifier does, and if it adds, or modifies functionalities related to Tag. Lets say it makes mario only be able to wallkick, that would be considered addition, as Tag never touches code related to that in normal play. Now, let's say that it's a Doubled Lives modifier, this modifier would go in the modify section. This means you need to find where the lives var is set, check if the modifier is set to your new modifier (via `if gGlobalSyncTable.modifier == MODIFIER_3 then`), and change the variable accordingly. In the case your modifier adds functionality, create a lua file wit the name `x_modifier.lua`, with x being your modifier name all lowercased. Inside that lua file, do whatever you need to do to get your modifier working, just be sure to check if the modifier is set to your modifier. The easiest way to do this is at the top of the function you're running. Add `if gGlobalSyncTable.modifier ~= MODIFIER_3 then return end` to the top, this simply checks if the modifier is equal to your modifier, if it isn't, return.

That's the current state of the modifier documentation.