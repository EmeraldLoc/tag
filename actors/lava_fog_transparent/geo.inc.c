#include "src/game/envfx_snow.h"

const GeoLayout lava_fog_transparent_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ASM(0, geo_update_layer_transparency),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, lava_fog_transparent_Cylinder_mesh_layer_5),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, lava_fog_transparent_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
