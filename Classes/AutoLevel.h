#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

@interface AutoLevel : GameObject {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;

@end
