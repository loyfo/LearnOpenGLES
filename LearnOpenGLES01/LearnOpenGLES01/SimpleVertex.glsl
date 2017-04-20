attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2
// Add right before the main
uniform mat4 Projection;
uniform mat4 Modelview;

varying vec4 DestinationColor; // 3

void main(void) { // 4
DestinationColor = SourceColor; // 5
gl_Position = Projection * Modelview * Position; // 6
}
