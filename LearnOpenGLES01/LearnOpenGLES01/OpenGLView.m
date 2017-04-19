//
//  OpenGLView.m
//  LearnOpenGLES01
//
//  Created by 黄维平 on 2017/4/19.
//  Copyright © 2017年 hwp. All rights reserved.
//

#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView () {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
}

@end

@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self render];
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;        //将默认layer转换为特殊layer
    _eaglLayer.opaque = YES;                       //将layer的透明度设为0
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;     //使用OpenGL ES 2.0版本
    _context = [[EAGLContext alloc] initWithAPI:api];      //创建上下文
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);                 //创建一个新的render buffer object，用于存放渲染过的图像。这里返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）。有时候你会发现这个唯一值被用来作为程序内的一个OpenGL 的名称。
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);    //告诉OpenGL：我在后面引用GL_RENDERBUFFER的地方，其实是想用_colorRenderBuffer。其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];   //为render buffer分配空间
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);   // 把前面创建的buffer render依附在frame buffer的GL_COLOR_ATTACHMENT0位置上。
}

- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);  //设置一个RGB颜色和透明度
    glClear(GL_COLOR_BUFFER_BIT);                   //“填色”动作，GL_COLOR_BUFFER_BIT声明要清理那个缓冲区
    [_context presentRenderbuffer:GL_RENDERBUFFER]; //将缓冲区（render buffer和color buffer）的颜色呈现到UIView上
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)compileShaders {
    
    // 1   调用你刚刚写的动态编译方法，分别编译了vertex shader 和 fragment shader
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2   调用了glCreateProgram glAttachShader  glLinkProgram 连接 vertex 和 fragment shader成一个完整的program。
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3   调用 glGetProgramiv  lglGetProgramInfoLog 来检查是否有error，并输出信息。
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4   调用 glUseProgram  让OpenGL真正执行你的program
    glUseProgram(programHandle);
    
    // 5  调用 glGetAttribLocation 来获取指向 vertex shader传入变量的指针。以后就可以通过这写指针来使用了。还有调用 glEnableVertexAttribArray来启用这些数据。（因为默认是 disabled的。）
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1  找到shader文件
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2    调用 glCreateShader来创建一个代表shader 的OpenGL对象。这时你必须告诉OpenGL，你想创建 fragment shader还是vertex shader。所以便有了这个参数：shaderType
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3    调用glShaderSource ，让OpenGL获取到这个shader的源代码。（就是我们写的那个）这里我们还把NSString转换成C-string
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length] ;
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4    调用glCompileShader 在运行时编译shader
    glCompileShader(shaderHandle);
    
    // 5    如果编译失败了，我们必须一些信息来找出问题原因。 glGetShaderiv 和 glGetShaderInfoLog  会把error信息输出到屏幕。
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)dealloc
{
    _context = nil;
}

@end
