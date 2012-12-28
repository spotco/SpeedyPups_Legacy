#import "BatchDraw.h"

@interface BatchJob : NSObject {
    GLuint tex;
    CGPoint *pvtx,*ptex;
    ccColor4B *pclr;
    int batch_ct,ord,cursize;
}
+(BatchJob*)cons_tex:(GLuint)tex;
-(void)add_obj:(gl_render_obj)gl;
-(void)clear;
-(void)draw;
@end

@implementation BatchJob
#define WHITE ccc4(255, 255, 255, 255)

+(BatchJob*)cons_tex:(GLuint)tex {
    BatchJob *b = [[BatchJob alloc] init];
    [b cons_tex:tex];
    return b;
}

-(void)cons_tex:(GLuint)ttex{
    tex = ttex;
    cursize = 36;
    [self alloc_arrs:cursize];

}

-(void)alloc_arrs:(int)size {
    pvtx = calloc(size, sizeof(CGPoint));
    ptex = calloc(size, sizeof(CGPoint));
    pclr = calloc(size, sizeof(ccColor4B));
}

-(void)incr_arrs_to:(int)sizef {
    CGPoint *o_pvtx,*o_ptex;
    ccColor4B *o_pclr;
    
    o_pvtx = pvtx;
    o_ptex = ptex;
    o_pclr = pclr;
    
    [self alloc_arrs:sizef];
    
    memcpy(pvtx, o_pvtx, sizeof(CGPoint)*cursize);
    memcpy(ptex, o_ptex, sizeof(CGPoint)*cursize);
    memcpy(pclr, o_pclr, sizeof(ccColor4B)*cursize);
    
    cursize = sizef;
    
    free(o_pvtx);
    free(o_ptex);
    free(o_pclr);
}

-(void)add_obj:(gl_render_obj)gl {
    int lim = gl.pts==4?6:3;
    
    while (cursize < batch_ct+lim) {
        [self incr_arrs_to:cursize*cursize];
    }
    
    for(int i = 0; i < lim; i++) {
        int t = i%3 + i/3;
        pvtx[batch_ct+i] = gl.tri_pts[t];
        ptex[batch_ct+i] = gl.tex_pts[t];
        pclr[batch_ct+i] = WHITE;
    }
    batch_ct+=lim;
}

-(void)clear {
    batch_ct = 0;
}

-(void)draw {
    glBindTexture(GL_TEXTURE_2D, tex);
	glVertexPointer(2, GL_FLOAT, 0, pvtx); 
	glTexCoordPointer(2, GL_FLOAT, 0, ptex);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, pclr);
    glDrawArrays(GL_TRIANGLES, 0, batch_ct);
}

-(void)dealloc {
    free(pvtx);
    free(ptex);
    free(pclr);
    [super dealloc];
}
@end


@implementation BatchDraw

#define KEY_TEX @"tex"
#define KEY_ZIND @"zind"
#define KEY_DORD @"dord"
static NSMutableDictionary* jobs;
static NSMutableDictionary* z_bucket;

+(void)init {
    if (!jobs) {
        jobs = [[NSMutableDictionary alloc] init];
        z_bucket = [[NSMutableDictionary alloc] init];
    }
}

+(void)add:(gl_render_obj)gl key:(NSString *)tex z_ord:(int)zord draw_ord:(int)dord {
    NSDictionary *tkey = [NSDictionary dictionaryWithObjectsAndKeys:
                          tex,KEY_TEX,
                          [NSNumber numberWithInt:zord],KEY_ZIND,
                          [NSNumber numberWithInt:dord],KEY_DORD, 
    nil];
    
    if (![jobs objectForKey:tkey]) {
        [jobs setObject:[BatchJob cons_tex:gl.texture.name] forKey:tkey];
    }
    BatchJob *b = [jobs objectForKey:tkey];
    [b add_obj:gl];
}

+(void)sort_jobs {
    [z_bucket removeAllObjects];
    for (NSDictionary* key in jobs) {
        if (![z_bucket objectForKey:[key objectForKey:KEY_ZIND]]) {
            [z_bucket setObject:[NSMutableArray array] forKey:[key objectForKey:KEY_ZIND]];
        }
        NSMutableArray *b = [z_bucket objectForKey:[key objectForKey:KEY_ZIND]];
        [b addObject:key];
    }
    
    for(NSNumber* key in z_bucket) { //sort everything in every bucket by draword
        NSMutableArray* a = [z_bucket objectForKey:key];
        [a sortUsingComparator:^NSComparisonResult(NSDictionary* a, NSDictionary* b) {
            NSNumber *v_a = [a objectForKey:KEY_DORD];
            NSNumber *v_b = [b objectForKey:KEY_DORD];
            return [v_a compare:v_b];
        }];
    }
}

-(void)draw {
    [super draw];
    NSArray* jobkeys = [z_bucket objectForKey:[NSNumber numberWithInt:zOrder_]];
    if (jobkeys) {
        for (NSDictionary *key in jobkeys) {
            BatchJob *b = [jobs objectForKey:key];
            [b draw];
        }
    }
}

+(void)clear {
    for (NSDictionary* key in jobs) {
        BatchJob *b = [jobs objectForKey:key];
        [b clear];
    }
}



@end
