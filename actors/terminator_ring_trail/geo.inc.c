#include "src/game/envfx_snow.h"

const GeoLayout terminator_ring_trail_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, terminator_ring_trail_Torus_mesh_layer_1),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, terminator_ring_trail_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
