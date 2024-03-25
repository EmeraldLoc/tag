# Creating a Official Romhack

Before beginning, this guide assumes you have some lua experience, and experience with photo editors.

First, head to `romhacks.lua`, there is a table called `romhacks`.

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
| ``
