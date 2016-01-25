#version 450
// Reference: https://www.shadertoy.com/view/4ds3zs
#ifdef GL_ES
precision mediump float;
#endif

uniform float iGlobalTime;
uniform vec3 iResolution;
in vec2 fragCoord;

float iSphere(vec3 ro, vec3 rd, vec4 sph) {
    // a sphere centered at the origin has equation |xyz| = r
    // meaning, |xyz|^2 = r^2, meaning <xyz, xyz> = r^2
    // now, xyz = ro + t*rd, therefore |ro|^2+|t*rd|^2 + 2<ro, rd> t - r^2 = 0
    // |rd| = 1 (normalized) so equation reduce to |ro|^2+ t^2 + 2<ro, rd> t - r^2 = 0
    // which is a quadratic equation, so
    vec3 oc = ro - sph.xyz;
    float b = 2.0 *dot(oc, rd);
    float c = dot(oc,oc) - sph.w*sph.w;
    float h = b*b - 4.0 *c;
    if(h <0.0) return -1.0; //no intersection

    //pick smaller one(i.e, close one)
    //not (-b+sqrt(h)) /2
    float t = (-b - sqrt(h))/ 2.0;
    return t;
}

vec3 nSphere(vec3 pos, vec4 sph) {
    //sphere center at (l, m, n) radius r
    //normal at intersect point N= ( (x-l)/r, (y-m)/r, (z-n)/r )
    return (pos - sph.xyz)/sph.w;
}

float iPlane(vec3 ro, vec3 rd) {
    //equation of a plane, y=0 = ro.y+t*rd.y
    // t = -ro.y/rd.y
    return -ro.y/rd.y;
}

vec3 nPlane(vec3 pos) {// normal of plane
    return vec3(0.0, 1.0, 0.0);
}

vec4 sph1 = vec4(0.0, 1.0, 0.0, 1.0);//sphere center
float intersect(vec3 ro, vec3 rd, out float resT) {
    resT = 1000.0;
    float id = -1.0;
    float tsph = iSphere(ro, rd, sph1);// intersect with a sphere
    float tpla = iPlane(ro, rd);//intersect with a plane
    if(tsph >0.0)//if intersect with sphere
    {
        id  = 1.0;
        resT = tsph;
    }
    if(tpla > 0.0 && tpla < resT)
    {//if intersect with plane and nearer than sphere or -1
        id = 2.0;
        resT = tpla;
    }
    return id;
}

void main() {
    //light direction
    vec3 lightDir = normalize(vec3(0.57, 0.57, 0.57));
    
    //uv are the pixel coordinates, from 0 to 1
    float aspect_ratio = iResolution.x / iResolution.y;
    vec2 uv = fragCoord.xy;

    //let's move that sphere...
    sph1.x = 0.5 * cos(iGlobalTime) * 2.0;
    sph1.y = 1.0 + (cos(iGlobalTime * 5.0) + 1.0) / 3.0;
    sph1.z = 0.5 * sin(iGlobalTime);

    //we generate a ray with origin "ro" and direction "rd"
    vec3 ro = vec3(0.0, 0.5, 3.0);
    //vec2(1.78, 1.0) adjust ratio of length and width
    vec3 rd = normalize(vec3( (-1.0 +2.0*uv) *vec2(aspect_ratio, 1.0), -1.0));
    //we intersect the ray with the 3d scene
    float t;
    float id = intersect(ro, rd, t);

    //we need to do some lighting
    //and for that we need normals
    //we draw black, by default
    vec3 col = vec3(0.7);
    if (id > 0.5 && id < 1.5) {//if we hit the sphere
        //intersect position
        vec3 pos = ro + t*rd;
        //normal at intersect position
        vec3 nor = nSphere(pos, sph1);
        //diffuse light cos(theta) = dot(surface normal, direction to light)
        float dif = clamp(dot(nor, lightDir), 0.0, 1.0);//use clamp restrict cos to[0, 1]
        //ambient occlusion
        float ao = 0.5 + 0.5*nor.y;
        col = vec3(0.9 / 3.0, 0.8 / 3.0, 0.9 / 1.0)*dif*ao + vec3(0.1, 0.2, 0.4)*ao;
    }
    else if (id > 1.5) {//we hit the plane
        vec3 pos = ro + t*rd;
        vec3 nor = nPlane( pos );
        //ambient occlusion
        float amb = smoothstep(0.0, 2.0 * (sph1.w - sph1.y + 1.0), length(pos.xz-sph1.xz));
        col = vec3(amb* 0.7);
    }

    col = sqrt(col);
    gl_FragColor = vec4(col, 1.0);
}
