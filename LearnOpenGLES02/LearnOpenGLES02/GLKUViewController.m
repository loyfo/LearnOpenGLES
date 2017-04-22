/*
    基本流程：
1. 准备三角形顶点数据数组
2. 设置GLKView的上下文为当前的上下文
3. 设置着色器属性
4. 申请、绑定、缓存顶点数据
5. 在代理方法中，准备绘图
    着色器准备
    清理
6. 启用缓存顶点数据、设置指针、绘图
7. dealloc方法中删除缓存数据
 
 */

#import "GLKUViewController.h"
#import <GLKit/GLKit.h>
//#include <OpenGLES/ES2/gl.h>
//#include <OpenGLES/ES2/glext.h>

/** 保存每个顶点的数据 */
typedef struct vector {
    GLKVector3 positionCoords;
}SceneVertex;

/** 保存三角形3个顶点的数据 */
static const SceneVertex vertices[] = {
    {{-0.5, -0.5, 0}},
    {{ 0.5, -0.5, 0}},
    {{-0.5,  0.5, 0}}
};

@interface GLKUViewController ()
{
    GLKBaseEffect *_basicEffect;
    GLuint vertexBufferID;
}

@end

@implementation GLKUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupVertex];
 
    GLKView *view = (GLKView *)self.view;
    
    view.delegate = self;
    
    NSAssert([view isMemberOfClass:[GLKView class]], @"ViewController's view is not a GLKView");
    
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:view.context];
    [self setupRenderBuffer];
    [self setupRender];
 
}

-(void)setupRender {
    _basicEffect = [[GLKBaseEffect alloc]init];
    _basicEffect.useConstantColor = GL_TRUE;
    _basicEffect.constantColor = GLKVector4Make(200,   /** 红 */
                                                0.0,   /** 绿 */
                                                0.0,   /** 蓝 */
                                                1.f);  /** alpha */
    glClearColor(1.0, 1.0, 1.0, 1.0);
}

-(void)setupRenderBuffer {
    glGenBuffers(1,                 //指定要生成的缓存标识符数量
                 &vertexBufferID);  //指针：缓存标识符的地址
    
    glBindBuffer(GL_ARRAY_BUFFER,   //绑定什么类型的缓存：顶点属性数组
                 vertexBufferID);   //需要绑定的缓存标识符（标识符为0表示没有缓存，就不会绑定数据）
    
    glBufferData(GL_ARRAY_BUFFER,   //初始化缓存信息
                 sizeof(vertices),  //缓存需要拷贝的大小
                 vertices,          //需要拷贝的数据：拷贝数据的地址
                 GL_STATIC_DRAW);   //提示：告诉上下文缓存适合放到GPU内存中，因为数据很少修改，可以帮助OpenGL ES优化内存
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_basicEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    /** ④启用顶点数据 */
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    /** ⑥设置指针：目的在于告诉OpenGL ES顶点数据在哪里以及解释每个顶点保存的数据 */
    glVertexAttribPointer(GLKVertexAttribPosition, /** 顶点数据 */
                          3,                       /** 每个顶点包含3个数据 */
                          GL_FLOAT,                /** 顶点数据类型 */
                          GL_FALSE,                /** 固定点数据是否归一化或直接转固定值：不转换，直接使用float类型数据，可以帮助OpenGL ES优化内存 */
                          sizeof(SceneVertex),     /** 步幅：从一个顶点到另一个需要跨过多少字节，取单个顶点大小 */
                          NULL);                   /** 告诉OpenGL ES可以从当前绑定的顶点缓存的开始位置访问顶点数据 */
    
    glDrawArrays(GL_TRIANGLES,  /** 告诉GPU怎样渲染缓存内的顶点数据：渲染三角形 */
                 0,             /** 第一个需要渲染的顶点位置 */
                 3);            /** 渲染的顶点数量 */
}


-(void)dealloc {
    /** 如果有缓存的情况下 */
    if (vertexBufferID != 0) {
        
        /** ⑦删除缓冲区数据 */
        glDeleteBuffers(1, &vertexBufferID);
        
        /** 将标识符设置为0 */
        vertexBufferID = 0;
    }
    
    /** 将当前上下文设置nil */
    [EAGLContext setCurrentContext:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
