//shader编译
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ViewController ()
{
    UIView
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(GLuint)loadShaders:(NSString*)vert frag:(NSString *)frag {
    GLuint verShader,fragShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_VERTEX_SHADER file:frag];
    
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不必要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString*)file {
    //读取字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

@end
