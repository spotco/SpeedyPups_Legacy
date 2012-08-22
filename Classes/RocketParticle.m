#import "RocketParticle.h"
#import "GameRenderImplementation.h"

@implementation RocketParticle

+(RocketParticle*)init_x:(float)x y:(float)y {
    RocketParticle* p = [RocketParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p initialize];
    p.position = ccp(x,y);
    
    return p;
}

-(void)initialize {
    [super initialize];
    vx = float_random(-2, -4);
    vy = float_random(-2, 2);
    [self setColor:ccc3(255, 0, 0)];
}

-(void)update {
    [super update];
    int pct_y = (int)(((float)ct/STREAMPARTICLE_CT_DEFAULT)*200);
    //NSLog(@"pct:%i",pct_y);
    [self setColor:ccc3(255,pct_y,0)];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end