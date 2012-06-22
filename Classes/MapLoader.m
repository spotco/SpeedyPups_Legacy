//
//  MapLoader.m
//  GOstrich
//
//  Created by Chengcheng Hao on 6/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MapLoader.h"

@implementation MapLoader

+(Map *) load_map:(NSString *)map_file_name oftype:(NSString *) map_file_type{
    
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:map_file_type];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:nil];
	
	NSData *islandData  =  [islandInputStr dataUsingEncoding : NSUTF8StringEncoding];
    
    NSDictionary *j_map_data = [[CJSONDeserializer deserializer] deserializeAsDictionary:islandData error:(nil)];
    
    NSArray *islandArray = [j_map_data objectForKey:(@"islands")];
    
	//NSArray *islandArray = [[CJSONDeserializer deserializer] deserializeAsArray : islandData error : nil ];
	
	int islandsCount = [islandArray count];
	
	//NSMutableArray *n_islands = [[NSMutableArray alloc] init];
    Map *map = [[Map alloc] init];
   
	
	for(int i = 0; i < islandsCount; i++){
		NSDictionary *currentIslandDict = (NSDictionary *)[islandArray objectAtIndex:i];
		CGPoint start = ccp( ((NSString *)[currentIslandDict objectForKey:@"x1"]).floatValue
							,((NSString *)[currentIslandDict objectForKey:@"y1"]).floatValue );
		CGPoint end = ccp( ((NSString *)[currentIslandDict objectForKey:@"x2"]).floatValue
						  ,((NSString *)[currentIslandDict objectForKey:@"y2"]).floatValue );
		NSLog(@"%f", start.x);
		Island *currentIsland;
		if (true) { //TODO: if statement here based on type of island read in json
			currentIsland = [LineIsland init_pt1:start pt2:end];
		}
		[map.n_islands addObject:currentIsland];
		
	}
    
    
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    //NSMutableArray *n_coins = [[NSMutableArray alloc] init];

    
    for(int i = 0; i < [coins_array count]; i++){
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        if([type compare:@"coins"]){
            Coin *c = [Coin init_x:((NSString *)[j_object  objectForKey:@"x"]).floatValue y:((NSString *)[j_object objectForKey:@"y"]).floatValue];
            [map.game_objects addObject:c];
        }
        
    }
     
    
    //map.n_islands = n_islands;
    
    
    return map;
}

@end