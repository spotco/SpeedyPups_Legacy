#import "GameObject.h"
#import "FireworksParticleA.h"

@interface CheckPoint : GameObject {
    CCSprite *inactive_img,*active_img;
    BOOL activated;
}

+(CheckPoint*)cons_x:(float)x y:(float)y;
-(void)cons_img;

@end
