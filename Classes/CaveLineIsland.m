
#import "CaveLineIsland.h"

@implementation CaveLineIsland

+(CaveLineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	CaveLineIsland *new_island = [CaveLineIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island init_tex];
	[new_island init_top];
	return new_island;
}

-(CCTexture2D*)get_tex_corner {
    return [Resource get_tex:TEX_CAVE_CORNER_TEX];
}
-(CCTexture2D*)get_tex_top {
    return [Resource get_tex:TEX_CAVE_TOP_TEX];
}
-(ccColor4F)get_corner_fill_color {
    return ccc4f(TEX_ISLAND_CAVE_CORNERFILLCOLOR, 1.0);
}


-(void)draw {
    [super draw];
}

@end
