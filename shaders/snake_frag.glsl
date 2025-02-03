#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
varying vec2 vTexCoord;
varying vec3 vNormal;
varying float vTime;

void main() {
    // Obtener el color base de la textura
    vec4 texColor = texture2D(texture, vTexCoord);
    
    // Crear un efecto pulsante verde
    float pulse = (sin(vTime * 2.0) + 1.0) * 0.5;
    vec3 glowColor = vec3(0.0, 1.0, 0.2); // Verde brillante
    
    // Intensificar el efecto
    float glowIntensity = pulse * 2.0; // Duplicar la intensidad
    
    // Mezclar el color de la textura con el brillo verde
    vec3 finalColor = mix(texColor.rgb, glowColor, glowIntensity * 0.6);
    
    // Añadir un brillo adicional en los bordes
    float edgeGlow = pow(1.0 - abs(dot(vNormal, vec3(0.0, 0.0, 1.0))), 2.0);
    finalColor += glowColor * edgeGlow * pulse * 0.5;
    
    // Asegurar que el color final tenga un mínimo de brillo
    finalColor = max(finalColor, texColor.rgb);
    
    gl_FragColor = vec4(finalColor, texColor.a);
}