uniform mat4 transform;
uniform mat4 projection;
uniform mat3 normalMatrix;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying float vTime;

uniform float time;

void main() {
    vTexCoord = texCoord;
    vNormal = normalize(normalMatrix * normal);
    vTime = time;
    gl_Position = projection * transform * position;
}