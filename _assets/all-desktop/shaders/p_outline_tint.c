extern vec2 c_size;  // canvas size
extern number c_ss;  // canvas supersampling
extern vec4 c_tint;  // tinting

#ifdef GL_ES
extern number thickness;
extern vec4 outline_color;
extern number samples;
extern number sharpness;
#else
// Linux Mesa Intel compiler optimizes the outline_color if not defined
extern number thickness = 1.5;
extern vec4 outline_color = vec4(1.0,1.0,0.0,0.5);
extern number samples = 4;
extern number sharpness = 2.0;
#endif

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // defaults
    float _thickness = 1.5; // pixels
    vec4 _outline_color = vec4(1.0,1.0,0.0,0.5);
    int _samples = 4;
    float _sharpness = 2.0;
    
    if (thickness != 0.0) { _thickness = float(thickness); }
    if (outline_color != vec4(0.0,0.0,0.0,0.0)) { _outline_color = outline_color; }    
    if (float(samples) != 0.0)     { _samples = int(samples); }
    if (sharpness != 0.0) { _sharpness = float(sharpness); }

    // compensation for rounded kernel shape giving thinner outline
    _thickness = float(1.2 * _thickness);
    
    vec4 texcolor = Texel(texture,texture_coords);
    if (texcolor[3] < 1.0) {
        // find the nearest outline for pixels with alpha < 1
        // calculate the maximum alpha in a rectangle 
        float max_alpha = 0.0;
        int steps = int(ceil(_thickness * float(_samples) * c_ss));
        float step_dist_2 = float(steps * steps);
        for (int x=-steps; x<=steps; x++) {
            for (int y=-steps; y<=steps; y++) {
                if (float(x*x + y*y) <= step_dist_2) {
                    // rounded shape
                    vec2 tc = vec2(texture_coords.x + float(x)/(float(_samples) * c_size.x),
                                   texture_coords.y + float(y)/(float(_samples) * c_size.y));
                    vec4 c = Texel(texture,tc);
                    max_alpha = max(max_alpha, c[3]);
                }
            }
        }
        // alpha blend the texture color with the outline, using the texture alpha
        vec4 oc = texcolor[3] * texcolor + (1.0 - texcolor[3]) * _outline_color;
        // tint the colors (used for disabled buttons from kui.lua)
        if (c_tint[0] > 0.0)
            oc = oc * c_tint;
        // apply the max alpha and modulate with the outline alpha
        oc[3] = pow(max_alpha * _outline_color[3], _sharpness);
        return oc;
    } else {
        // solid color for pixels with alpha == 1
        return texcolor * color;
    }
}

