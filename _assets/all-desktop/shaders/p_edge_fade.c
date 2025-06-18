extern vec2 c_size;      // canvas size
extern number c_ss;      // canvas supersampling

extern vec2 min_max; 
extern number gradient; 

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // default values
    vec4 texcolor = Texel(texture,texture_coords);
    if(screen_coords.x<min_max.x){
        texcolor.a *= (screen_coords.x-min_max.x+gradient)/gradient;
    }
    if(screen_coords.x>min_max.y){
        texcolor.a *= 1.0-(screen_coords.x-min_max.y)/gradient;
    }
    return texcolor * color;
}
