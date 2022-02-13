minetest mod floatland_realm
============================

Produce hard biome at the floatlands, you will need a diamond shovel.

Information
-----------

This mod is named `floatland_realm`, it produces a large floadlands, 
an with possible new spawn place (if you configured `floatland_spawn`), 
so a diamond shovel will be need.

![screenshot.png](screenshot.png)

Technical info
--------------

This is a fork for minenux project, from original work that fixed minor problems, 
cos original author do not respond to issues, it work with minetest 0.4.X and minetest4.

It make the floatlands of mgv7 interesting, by the adition of new hard blocks, 
it uses the setting from minetest config files of mapgen v7, specially the `mgv7_floatland_level` 
and try to redefined the floatland layer of biome fully, it put 4 new nodes 
and try to made all the floadland a complete continuos layer in sky.

Currently the portal is not working as spected. This mod is just a fix version of original one.

#### Depends

* mgv7 mapgen only
* default mod

#### Blocks

| Node/item        | tecnical names         | related/drop |  note                    |
| ---------------- | ---------------------- | ------------ | ------------------------ |
| Float Sand       | floatland_realm:sand   |              | top block, use diamond shovel |
| Float Grass      | floatland_realm:grass  | default:dirt | top block, use diamond shovel |
| Float Dirt       | floatland_realm:dirt   |              | |
| Float Stone      | floatland_realm:stone  | floatland_realm:dirt | |
| Float Key        | floatland_realm:key    |              | For use in Float land portals |
| Float portal smk | floatland_realm:portal | floatland_realm:key, default:mese | The smoke inside of the portal |

#### Biomes

| Name            | technical names  | nodes of biome |
| --------------- | ---------------- | ---------------------------------------------- |
| Floatland Beach | floatland_beach | floatland_realm:grass, floatland_realm:dirt, floatland_realm:stone |
| Floatland grass | floatland_grass | floatland_realm:sand, floatland_realm:stone |


# License

LGPL 2.1 check [license.txt](license.txt)

Code by Amaz an archived work of it are at https://github.com/Amaz1/floatland_realm

The noise code is based on the floatlands C++ noise code. 
See https://github.com/minetest/minetest/blob/28841961ba91b943b7478704181604fa3e24e81e/src/mapgen_v7.cpp#L415

