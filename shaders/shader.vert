#version 450
#extension GL_ARB_separate_shader_objects : enable

out gl_PerVertex {
    vec4 gl_Position;
};

layout(location = 0) out vec4 data;
layout(location = 1) out vec4 data2;


layout (binding = 0) uniform UniformBufferObject {
	vec2 resolution;
	float time;
	float reserved;
} ubo;

vec2 positions[5] = vec2[](
    vec2(-1, -1),
    vec2(+1, -1),
    vec2(+1, +1),
	vec2(-1, +1), 
	vec2(-1, -1)
); 

#define PI (355.0/113.0)

vec2 rotate(vec2 v, float a){
	float c=cos(a), s=sin(a);
	return vec2(v.x*c + v.y*s, -v.x*s + v.y*c);
}

vec4 pf1(int pid, float time, out vec4 color)
{
	float scale = 0.01;
	float blur = 0.2;
	vec3 pos = vec3(0); 
	pos.x += (pid%1000)*0.01 - 5;
	pos.y += (pid/1000)*0.01 - 5;
	pos+=vec3(cos(pid%743*16.0+time) , sin(pid%1235*0.31+time) , sin(pid%125*0.61+time))*0.01;
	pos+=sin(pos.yzx+time*0.5)*0.8;
	pos+=cos(pos.zxy*4+time*0.5)*0.1;
	pos+=cos(pos.yzx*16+time*0.5)*0.01;
	pos+=cos(pos.yzx*64+time*0.15)*0.005;
	pos.z+=2;
	color=vec4(vec3(0.2,0.5,0.9)*0.5, blur);
	return vec4(pos, scale);
}


float osin(float x){ return sin(x*PI/4.0); }
vec2 osin(vec2 x){ return sin(x*PI/4.0); }
vec3 osin(vec3 x){ return sin(x*PI/4.0); }
vec4 osin(vec4 x){ return sin(x*PI/4.0); }

vec4 pf2(int pid, float time, out vec4 color)
{
	float scale = 0.3+sin((pid%884)*311.172)*0.3;
	scale=scale*scale+0.001;
	float blur = min(1,scale*5);
	vec3 pos = vec3(0);
	//float ang = pid*3.14159/4 + time*2;
	//pos.xy = vec2(cos(ang), sin(ang));
	if (pid<80000)
	{
		
		int spiral = pid/4000;
		float obj=pid%4000;
		obj+=osin(time*0.2+pid)*64;
		obj+=time*64;
		float ang = (time/2+osin(time)/4+(obj/64.0+1));
		pos.xyz = vec3(
			cos(ang)+sin(spiral*227.13352)*2*spiral, 
			(obj/256.0)*8+spiral*2, 
			sin(ang) + spiral
			);
		pos.y=64-abs(pos.y-32);
		pos.y+=96;
		pos.xz*=osin(pos.y/16+3.14159/2)*osin(pos.y/13)*8 ;
		pos.z+=8;
		pos+=sin(pos*2+pid+0.01*time/scale)/16;
		scale+=abs(4+100/(1+time/2)+osin(time*0.25)*2-pos.z)*0.05;
		float amp=0.2+pow(osin(obj/64.0-time)*0.5+.5,2);
		amp/=scale*scale*20;
		blur=mix(blur,1,smoothstep(56,64,time));
		amp*=smoothstep(66,60,time);
		color=vec4((vec3(0.6+sin(spiral*34.12)*0.5, 0.7, 0.5))*1.9*amp, blur);
	}
	else 
	{
		pos=(fract(sin(vec3(pid)*vec3(0.63116,0.523,0.69312))*51.123)*2-1)*16;
		pos.y+=64+16+64+64*sin(pid);
		pos.y+=(time)*sin(pid%7451*214.125)-8*smoothstep(63,68,time)-64*pow(sin(pid%613476)*.5+.5,4);
		pos+=sin(pos);
		pos.z+=16;
		scale*=0.01;
		vec3 c = vec3(0.9, 0.6, 0.5)*0.03 ;
		scale+=abs(4+100/(1+time/2)+osin(time*0.25)*2-pos.z)*0.05;
		float fadein=smoothstep(64,72,time);
		float fadein2=smoothstep(72,80,time);
		float fadein3=smoothstep(88,96,time);
		c=mix(c,c.yxz, osin(time/2)*fadein);
		c=mix(c,c.zyx, osin(time/4)*fadein);
		pos+=sin(pos.yxz*.5)*fadein2*2;
		pos+=sin(pos.yxz*.25)*fadein3*4;
		color=vec4(mix(c,c.zyx,sin(pid*.125+.5))/pow(scale,1.9)*0.3*(0.01+fadein), blur);
	}
	pos.y-=time;
	return vec4(pos, scale);
}


float df(vec3 p, float time){
	vec3 pm1 = p; 	pm1.xz= mod(p.xz+2,4)-2;
	vec3 pm2 = p; 	pm2.xz= mod(rotate(p.xz,0.4)+1.4,2.8)-1.4;
	vec3 pm4 = p; 	pm4.xz= mod(rotate(p.xz,1.2),16)-8;
	float sphere = length(pm1)-1.2;
	sphere=min(sphere, length(pm2)-1);
	sphere=min(sphere, length(pm4)-5);
	vec3 pm3 = p; 	pm3.xz= mod(rotate(p.xz,0.7)+0.9,1.8)-0.9;
	sphere = max(sphere, length(pm3.xz)-0.5);
	float floor = 1-p.y;
	return min(sphere,floor);
}

vec4 pf3(int pid, float time, out vec4 color)
{
	float scale = 0.1;
	float blur = 0.1;
	vec3 pos = vec3(sin(time/4)*4,-4,cos(time/4)-2); 
	
	vec3 dir = fract(sin(vec3(pid%115347*0.5321,pid%82345*0.12345,pid%5123*0.14123))*412.5317)-.5;
	dir=normalize(dir);
	pos+=dir;
	
	for (int i=0; i<50; i++){
		vec3 p = pos;
		p.yz=rotate(p.yz,0.5);
		p.z+=time;
		p.y-=4;
		float dist=df(p, time);
		if (dist<0.001) break;
		pos+=dir*dist;
	}
	pos.z+=4;
	//scale+=abs(8-pos.z)*0.05;
	color=vec4(vec3(0.5,0.4,0.3)*0.4, blur);
	return vec4(pos, scale);
}

vec3 path(float time){
	return vec3((sin(time/4.2)+sin(time/4))*2+4+time,-6+sin(time/7),sin(time/4.1)+cos(time/4)-4+time*0.25);
}

vec4 pf4(int pid, float time, out vec4 color)
{
	float scale = 0.1;
	float blur = 0.1;
	vec3 pos=vec3(0);

	if (pid<500000)
	{		
		pos = path(time);
		vec3 c=vec3(0.5,0.4,0.3);
		if(pid<250000) {
			pos.x+=9;
			pos.y-=5;
			c=vec3(0.3,0.3,0.5);
		}
		vec3 dir = fract(sin(vec3(pid%115347*0.5321,pid%82345*0.12345,pid%5123*0.14123))*412.5317)-.5;
		dir.y+=0.7;
		//dir.xz = rotate(dir.xz, time/4);
		dir=normalize(dir);
		pos+=dir;
		for (int i=0; i<50; i++){
			vec3 p = pos;
			float dist=df(p, time);
			if (dist<0.001) break;
			pos+=dir*dist;
		}
		color=vec4(c*0.1, blur);
	}
	else if(pid<501000) {
		pid-=500000;
		scale=0.02+pow(abs(sin(pid*42.7123)),8.0);
		float ts=3+scale;
		pos=path(time-sin(pid+time/ts)*8-8);
		float amp=cos(pid+time/ts+1)*32;
		blur=smoothstep(0,1,scale*2);
		
		
		pos+=sin(pos.yzx+vec3(pid*12.3,pid*9.512,pid*3.4))*.05;
		
		//scale*=abs(sin(pid*6123.123));
		//pos=vec3(0);
		color=vec4(vec3(0.5,0.4,0.9)*0.01/pow(scale,1.1)*amp, blur);
	} else {
		pos.z=-44;
		scale=0;
	}
	// camera
	pos-=path(time);
	pos.y+=4;
	pos.x+=sin(time/4);
	pos.x-=2;
	pos.z+=4;
	pos.xz=rotate(pos.xz,0.4);
	pos.yz=rotate(pos.yz,-0.9);
	return vec4(pos, scale);
}

void main() {
	int vid = gl_VertexIndex;
	int tid = vid/3; // triangle id
	int pid = tid/2; // polygon id
	int issecondtris = tid%2;
	vec2 uv = positions[vid%3+issecondtris*2];
	
	//vec3 pos=pf1(pid, ubo.time);
	vec4 col_res1, col_res2;
	vec4 pos_res1 = pf4(pid, ubo.time, col_res1);
	vec4 pos_res2 = pf4(pid, ubo.time+0.1, col_res2);
	
	if(pos_res1.z<0||pos_res2.z<0) {
		gl_Position=vec4(0,0,-1,1);
		return;
	}
	
	float blur = col_res1.w;
	float scale = 0.02;
	
	float size1 = pos_res1.w/pos_res1.z;
	float size2 = pos_res2.w/pos_res2.z;
	
	// calculate shape
	// project to 2d
	vec2 pos_2d = pos_res1.xy/pos_res1.z;
	vec2 pos2_2d = pos_res2.xy/pos_res2.z;
	vec2 diff_2d = pos2_2d.xy-pos_2d.xy;
	float angle = atan(diff_2d.x, diff_2d.y) + 3.14159/2;
	float len = length(diff_2d);
	vec2 displace = rotate(uv, angle);
	float amp1 = size1/(size1+len);
	float amp2 = size2/(size2+len);
	col_res1.xyz*=amp1;
	col_res2.xyz*=amp2;
	//float size = pow(abs(cos(sin(pid*3.4125)*32.12)),2)*0.02;
	//if (pid>7) size=0; // discard
	

	vec2 aspectCorrection = vec2(ubo.resolution.y/ubo.resolution.x, 1.0f);
	// blur optimization
	float blur_optimization = (1+blur*blur)*0.5+1/ubo.resolution.y;
	displace*=blur_optimization;
	uv*=blur_optimization;
	
	float mixfac = -uv.x*.5+.5;
    gl_Position = vec4((mix(pos_2d+displace*size1, pos2_2d+displace*size2, mixfac))*aspectCorrection, 0.5, 1);
    data.xy = uv;
	data.z = pid;
	data.w = mix(size1, size2, mixfac); // undefined for now
	// color
	data2=mix(col_res1, col_res2, mixfac);
}