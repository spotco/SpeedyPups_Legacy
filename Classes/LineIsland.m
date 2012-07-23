
#import "LineIsland.h"
#import "GameEngineLayer.h"

@implementation LineIsland

#define HEI 56
#define OFFSET -40
static float INF = INFINITY;


+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LineIsland *new_island = [LineIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island init_tex];
	[new_island init_top];
    [new_island calculate_normal];
	return new_island;
	
}

-(void)calculate_normal {
    Vec3D *line_vec = [Vec3D init_x:endX-startX y:endY-startY z:0];
    normal_vec = [[Vec3D Z_VEC] crossWith:line_vec];
    [normal_vec normalize];
    [line_vec dealloc];
    [normal_vec scale:ndir];
}

-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end {
	startX = start.x;
	startY = start.y;
	endX = end.x;
	endY = end.y;
}

-(void)calc_init {
    t_min = 0;
    t_max = sqrtf(powf(endX - startX, 2) + powf(endY - startY, 2));
}

-(Vec3D*)get_tangent_vec {
    Vec3D *v = [Vec3D init_x:endX-startX y:endY-startY z:0];
    [v normalize];
    return v;
}

-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x {
    return [Common cons_line_seg_a:ccp(startX,startY) b:ccp(endX,endY)];
}

-(float)get_t_given_position:(CGPoint)position {
    float dx = powf(position.x - startX, 2);
    float dy = powf(position.y - startY, 2);
    float f = sqrtf( dx+dy );
    return f;
}

-(CGPoint)get_position_given_t:(float)t {
    if (t > t_max || t < t_min) {
         return ccp([Island NO_VALUE],[Island NO_VALUE]);
    } else {
        float frac = t/t_max;
        Vec3D *dir_vec = [Vec3D init_x:endX-startX y:endY-startY z:0];
        [dir_vec scale:frac];
        CGPoint pos = ccp(startX+dir_vec.x,startY+dir_vec.y);
        [dir_vec dealloc];
        return pos;
    }
}

-(void) draw {
	if (endX < [GameEngineLayer get_cur_pos_x]-800 ||
		startY > [GameEngineLayer get_cur_pos_y]+800) { //TODO -- FIXME
		return;
	} 
	[super draw];
    
	glBindTexture(GL_TEXTURE_2D, main_fill.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, main_fill.tri_pts); //coord per vertex, type, stride, pointer to array
	glTexCoordPointer(2, GL_FLOAT, 0, main_fill.tex_pts);
	glDrawArrays(GL_TRIANGLES, 0, 3); //drawtype,offset,pts
	glDrawArrays(GL_TRIANGLES, 1, 3);
    
    glBindTexture(GL_TEXTURE_2D, top_fill.texture.name);
    glVertexPointer(2,GL_FLOAT,0,top_fill.tri_pts);
    glTexCoordPointer(2,GL_FLOAT,0,top_fill.tex_pts);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawArrays(GL_TRIANGLES, 1, 3);
    
    
    
    glColor4ub(109,110,112,255);
    glLineWidth(5.0f);
    
    if (has_prev == NO) {
        //ccDrawLine(tl, bl1);
        
        glBindTexture(GL_TEXTURE_2D, left_line_fill.texture.name);
        glVertexPointer(2, GL_FLOAT, 0, left_line_fill.tri_pts);
        glTexCoordPointer(2, GL_FLOAT, 0, left_line_fill.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawArrays(GL_TRIANGLES, 1, 3);
         
        ccDrawQuadBezier(bl1, bl, bl2, 3);
    }
    if (next == NULL) {
        //ccDrawLine(tr, br1);
        
        glBindTexture(GL_TEXTURE_2D, right_line_fill.texture.name);
        glVertexPointer(2, GL_FLOAT, 0, right_line_fill.tri_pts);
        glTexCoordPointer(2, GL_FLOAT, 0, right_line_fill.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawArrays(GL_TRIANGLES, 1, 3);
        
        ccDrawQuadBezier(br1, br, br2, 3);
    }
    
    //ccDrawLine(bl2, br2);
    
    glBindTexture(GL_TEXTURE_2D, bottom_line_fill.texture.name);
    glVertexPointer(2, GL_FLOAT, 0, bottom_line_fill.tri_pts);
    glTexCoordPointer(2, GL_FLOAT, 0, bottom_line_fill.tex_pts);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawArrays(GL_TRIANGLES, 1, 3);
    
    if (has_prev == NO) {
        glBindTexture(GL_TEXTURE_2D, tl_top_corner.texture.name);
        glVertexPointer(2, GL_FLOAT, 0, tl_top_corner.tri_pts);
        glTexCoordPointer(2, GL_FLOAT, 0, tl_top_corner.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawArrays(GL_TRIANGLES, 1, 3);
    }
    if (next == NULL) {
        glBindTexture(GL_TEXTURE_2D, tr_top_corner.texture.name);
        glVertexPointer(2, GL_FLOAT, 0, tr_top_corner.tri_pts);
        glTexCoordPointer(2, GL_FLOAT, 0, tr_top_corner.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawArrays(GL_TRIANGLES, 1, 3);
    }
    
    
    if (next != NULL) {
        glBindTexture(GL_TEXTURE_2D, corner_fill.texture.name);
        glVertexPointer(2,GL_FLOAT,0,corner_fill.tri_pts);
        glTexCoordPointer(2,GL_FLOAT,0,corner_fill.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glColor4f(0.29, 0.69, 0.03, 1.0);
        ccDrawSolidPoly(toppts, 3, YES);
        
        glBindTexture(GL_TEXTURE_2D, corner_line_fill.texture.name);
        glVertexPointer(2, GL_FLOAT, 0, corner_line_fill.tri_pts);
        glTexCoordPointer(2, GL_FLOAT, 0, corner_line_fill.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawArrays(GL_TRIANGLES, 1, 3);
    }
    
}

-(void)scale_ndir:(Vec3D*)v {
    [v scale:ndir];
}

-(void)init_tex {	
    main_fill.texture = [Resource get_tex:TEX_GROUND_TEX_1];
    
	main_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	main_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = main_fill.tri_pts;
	CGPoint* tex_pts = main_fill.tex_pts;
	CCTexture2D* texture = main_fill.texture;
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    float taille = fill_hei;
    
    tri_pts[3] = ccp(0,0);
    tri_pts[2] = ccp(endX-startX,endY-startY);
    tri_pts[1] = ccp(0+v3t1.x * taille,0+v3t1.y * taille);
    tri_pts[0] = ccp(endX-startX +v3t1.x * taille ,endY-startY +v3t1.y * taille);
	
	tex_pts[2] = ccp(tri_pts[2].x/texture.pixelsWide, tri_pts[2].y/texture.pixelsHigh);
	tex_pts[3] = ccp(tri_pts[3].x/texture.pixelsWide, tri_pts[3].y/texture.pixelsWide);
	tex_pts[0] = ccp(tri_pts[0].x/texture.pixelsWide, tri_pts[0].y/texture.pixelsWide);
	tex_pts[1] = ccp(tri_pts[1].x/texture.pixelsWide, tri_pts[1].y/texture.pixelsWide);
    
    /**
     TL                  TR
     
     BL1                 BR1
     BL  BL2       BR2   BR
     
     **/
    
    
    bl = main_fill.tri_pts[1];
    br = main_fill.tri_pts[0];
    tl = main_fill.tri_pts[3];
    tr = main_fill.tri_pts[2];
    
    float R = 7.5;
    [v3t1 negate];
    [v3t1 scale:R];
    
    bl1 = ccp(bl.x + v3t1.x,bl.y + v3t1.y);
    
    [v3t2 normalize];
    [v3t2 scale:R];
    bl2 = ccp(bl.x + v3t2.x,bl.y+v3t2.y);
    
    br1 = ccp(br.x + v3t1.x,br.y + v3t1.y);
    [v3t2 negate];
    br2 = ccp(br.x + v3t2.x,br.y+v3t2.y);
    
    
    float L = 20;
    [v3t1 negate];
    [v3t1 normalize];
    [v3t1 scale:L];
    tl = ccp(tl.x + v3t1.x, tl.y + v3t1.y);
    tr = ccp(tr.x + v3t1.x, tr.y + v3t1.y);
    
    [self init_left_line_fill];
    [self init_right_line_fill];
    
    [v3t2 dealloc];
    [v3t1 dealloc];
}

-(void)init_top {
    top_fill.texture = [Resource get_tex:TEX_GROUND_TOP_1];
    
	top_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	top_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = top_fill.tri_pts;
	CGPoint* tex_pts = top_fill.tex_pts;
	CCTexture2D* texture = top_fill.texture;
	
	float dist = sqrt(pow(endX-startX, 2)+pow(endY-startY, 2));
    
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    
    float hei = HEI;
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    
    tri_pts[2] = ccp(endX-startX + d_o_x              ,endY-startY + d_o_y);
    tri_pts[3] = ccp(0 + d_o_x                        ,0  + d_o_y);
    tri_pts[0] = ccp(endX-startX+v3t1.x*hei  + d_o_x  ,endY-startY+v3t1.y*hei + d_o_y);
    tri_pts[1] = ccp(v3t1.x*hei + d_o_x               ,v3t1.y*hei + d_o_y);
    
    tex_pts[0] = ccp(dist/texture.pixelsWide,0);
    tex_pts[1] = ccp(0,0);
    tex_pts[2] = ccp(dist/texture.pixelsWide,1);
    tex_pts[3] = ccp(0,1);
    
    toppts[0] = ccp(endX-startX,endY-startY);
    toppts[1] = ccp(tri_pts[2].x,tri_pts[2].y);
    
    [v3t2 negate];
    [v3t2 normalize];
    [self init_tl_top:tri_pts[1] bot:tri_pts[3] vec:v3t2];
    [v3t2 negate];
    [self init_tr_top:tri_pts[2] bot:tri_pts[0] vec:v3t2];
    
    [self init_bottom_line_fill];
    
    [v3t1 dealloc];
    [v3t2 dealloc];
}

-(void)init_tl_top:(CGPoint)top bot:(CGPoint)bot vec:(Vec3D*)vec {
    Vec3D *mvr = [Vec3D init_x:-vec.x y:-vec.y z:0];
    [mvr scale:8];
    
    top = [mvr transform_pt:top];
    bot = [mvr transform_pt:bot];
    [mvr dealloc];
    
    
    tl_top_corner.texture = [Resource get_tex:TEX_TOP_EDGE];
	tl_top_corner.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	tl_top_corner.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = tl_top_corner.tri_pts;
	CGPoint* tex_pts = tl_top_corner.tex_pts;
    
    [vec scale:20];
    
    /**
     2  3
     
     0  1
     **/
    tri_pts[0] = ccp(top.x+vec.x,top.y+vec.y);
    tri_pts[1] = top;
    tri_pts[2] = ccp(bot.x+vec.x,bot.y+vec.y);
    tri_pts[3] = bot;
    [vec normalize];
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[3] = ccp(1,1);
    tex_pts[2] = ccp(0,1);
}

-(void)init_tr_top:(CGPoint)top bot:(CGPoint)bot vec:(Vec3D*)vec {
    Vec3D *mvr = [Vec3D init_x:-vec.x y:-vec.y z:0];
    [mvr scale:8];
    
    top = [mvr transform_pt:top];
    bot = [mvr transform_pt:bot];
    [mvr dealloc];
    
    
    tr_top_corner.texture = [Resource get_tex:TEX_TOP_EDGE];
	tr_top_corner.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	tr_top_corner.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = tr_top_corner.tri_pts;
	CGPoint* tex_pts = tr_top_corner.tex_pts;
    
    [vec scale:20];
    
    tri_pts[0] = ccp(top.x+vec.x,top.y+vec.y);
    tri_pts[1] = top;
    tri_pts[2] = ccp(bot.x+vec.x,bot.y+vec.y);
    tri_pts[3] = bot;
    [vec normalize];
    
    tex_pts[2] = ccp(0,0);
    tex_pts[3] = ccp(1,0);
    tex_pts[1] = ccp(1,1);
    tex_pts[0] = ccp(0,1);
}

-(void)init_bottom_line_fill {
    bottom_line_fill.texture = [Resource get_tex:TEX_ISLAND_BORDER];
	bottom_line_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	bottom_line_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = bottom_line_fill.tri_pts;
	CGPoint* tex_pts = bottom_line_fill.tex_pts;
    
    Vec3D *v = [Vec3D init_x:br2.x-bl2.x y:br2.y-bl2.y z:0];
    Vec3D *dirv;
    
    if (ndir == -1) {
        dirv = [[Vec3D Z_VEC] crossWith:v];
    } else {
        dirv = [v crossWith:[Vec3D Z_VEC]];
    }
    
    [dirv normalize];
    [dirv scale:5];
    
    //bl2,br2
    tri_pts[0] = bl2;
    tri_pts[1] = br2;
    tri_pts[2] = ccp(bl2.x+dirv.x,bl2.y+dirv.y);
    tri_pts[3] = ccp(br2.x+dirv.x,br2.y+dirv.y);
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[2] = ccp(0,1);
    tex_pts[3] = ccp(1,1);
    
    [v dealloc];
    [dirv dealloc];
}

-(void)init_corner_line_fill {
    if (next == NULL) {
        return;
    }
    CGPoint a = br2;
    CGPoint b = ccp(next.bl2.x-startX+next.startX,next.bl2.y-startY+next.startY);
    
    corner_line_fill.texture = [Resource get_tex:TEX_ISLAND_BORDER];
	corner_line_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	corner_line_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
    
    CGPoint* tri_pts = corner_line_fill.tri_pts;
	CGPoint* tex_pts = corner_line_fill.tex_pts;
    
    Vec3D *v = [Vec3D init_x:b.x-a.x y:b.y-a.y z:0];
    Vec3D *dirv;
    
    if (ndir == -1) {
        dirv = [[Vec3D Z_VEC] crossWith:v];
    } else {
        dirv = [v crossWith:[Vec3D Z_VEC]];
    }
    

    [dirv normalize];
    [dirv scale:5];
    
    
    tri_pts[0] = a;
    tri_pts[1] = b;
    tri_pts[2] = ccp(a.x+dirv.x,a.y+dirv.y);
    tri_pts[3] = ccp(b.x+dirv.x,b.y+dirv.y);

    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[2] = ccp(0,1);
    tex_pts[3] = ccp(1,1);
    
    [v dealloc];
    [dirv dealloc];
}

-(void)init_left_line_fill {
    //tl,bl1
    CGPoint a = tl;
    CGPoint b = bl1;
    
    
    left_line_fill.texture = [Resource get_tex:TEX_ISLAND_BORDER];
	left_line_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	left_line_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
    
    CGPoint* tri_pts = left_line_fill.tri_pts;
	CGPoint* tex_pts = left_line_fill.tex_pts;
    
    Vec3D *v = [Vec3D init_x:b.x-a.x y:b.y-a.y z:0];
    Vec3D *dirv;
    
    if (ndir == -1) {
        dirv = [[Vec3D Z_VEC] crossWith:v];
    } else {
        dirv = [v crossWith:[Vec3D Z_VEC]];
    }
    
    
    [dirv normalize];
    [dirv scale:5];
    
    
    tri_pts[0] = a;
    tri_pts[1] = b;
    tri_pts[2] = ccp(a.x+dirv.x,a.y+dirv.y);
    tri_pts[3] = ccp(b.x+dirv.x,b.y+dirv.y);
    
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[2] = ccp(0,1);
    tex_pts[3] = ccp(1,1);
    
    [v dealloc];
    [dirv dealloc];
}

-(void)init_right_line_fill {
    //tr,br1
    CGPoint a = tr;
    CGPoint b = br1;
    
    right_line_fill.texture = [Resource get_tex:TEX_ISLAND_BORDER];
	right_line_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	right_line_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
    
    CGPoint* tri_pts = right_line_fill.tri_pts;
	CGPoint* tex_pts = right_line_fill.tex_pts;
    
    Vec3D *v = [Vec3D init_x:b.x-a.x y:b.y-a.y z:0];
    Vec3D *dirv;
    
    if (ndir == -1) {
        dirv = [[Vec3D Z_VEC] crossWith:v];
    } else {
        dirv = [v crossWith:[Vec3D Z_VEC]];
    }
    
    [dirv normalize];
    [dirv scale:-5];
    
    
    tri_pts[0] = a;
    tri_pts[1] = b;
    tri_pts[2] = ccp(a.x+dirv.x,a.y+dirv.y);
    tri_pts[3] = ccp(b.x+dirv.x,b.y+dirv.y);
    
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[2] = ccp(0,1);
    tex_pts[3] = ccp(1,1);
    
    [v dealloc];
    [dirv dealloc];
}

-(void)link_finish {
    if (next != NULL) {
        [self init_corner_tex];
        [self init_corner_top];
        [self init_corner_line_fill];
    }
}

-(void)init_corner_top {
    Vec3D *v3t2 = [Vec3D init_x:(next.endX - next.startX) y:(next.endY - next.startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    toppts[2] = ccp( d_o_x+next.startX-startX ,d_o_y+next.startY-startY );

    
    float corner_top_scale = 0.65;
    
    Vec3D *reduce_left = [Vec3D init_x:toppts[1].x-toppts[0].x y:toppts[1].y-toppts[0].y z:0];
    float leftlen = [reduce_left length];
    [reduce_left normalize];
    leftlen = leftlen * corner_top_scale;
    toppts[1] = ccp( toppts[0].x + reduce_left.x * leftlen, toppts[0].y + reduce_left.y * leftlen);
    
    
    Vec3D *reduce_right = [Vec3D init_x:toppts[2].x-toppts[0].x y:toppts[2].y-toppts[0].y z:0];
    float rightlen = [reduce_right length];
    [reduce_right normalize];
    rightlen = rightlen * corner_top_scale;
    toppts[2] = ccp( toppts[0].x + reduce_right.x * rightlen, toppts[0].y + reduce_right.y * rightlen);
    
    
    [v3t2 dealloc];
    [v3t1 dealloc];
    [reduce_left dealloc];
    [reduce_right dealloc];
    
    
}

-(void)init_corner_tex {
    corner_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*3);
    corner_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*3);
    corner_fill.texture = [Resource get_tex:TEX_GROUND_TEX_1];
    
    CGPoint* tri_pts = corner_fill.tri_pts;
    CGPoint* tex_pts = corner_fill.tex_pts;
    CCTexture2D* texture = corner_fill.texture;
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    tri_pts[0] = ccp(endX-startX,endY-startY);
    tri_pts[1] = ccp(endX+v3t1.x*fill_hei-startX,endY+v3t1.y*fill_hei-startY);
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    v3t2 = [Vec3D init_x:(next.endX - next.startX) y:(next.endY - next.startY) z:0];
    v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    tri_pts[2] = ccp(next.startX+v3t1.x*next.fill_hei-startX, next.startY+v3t1.y*next.fill_hei-startY);
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    tex_pts[0] = ccp(tri_pts[0].x/texture.pixelsWide, tri_pts[0].y/texture.pixelsHigh);
    tex_pts[1] = ccp(tri_pts[1].x/texture.pixelsWide, tri_pts[1].y/texture.pixelsHigh);
    tex_pts[2] = ccp(tri_pts[2].x/texture.pixelsWide, tri_pts[2].y/texture.pixelsHigh);  
}


@end
