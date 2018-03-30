# Block


### 案例 1

```
@interface House ()

@property (nonatomic, strong) Person *person;

@end

@implementation House

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // self 持有 person
        _person = [Person new];
        [_person setCallback:^(Person *person) {
            
//            _person.name = @"xxx"; // 这里会导致 block 持有 self，而 block 是 person 对象所持有的，这就导致了循环引用
            person.name = @"xxx";  // 但是这样就不会导致循环引用，因为这里是作为一个参数传进来的，不会捕获 self
        }];
        
    }
    return self;
}

@end
```

详见 demo 中的示例代码和 clang 重写后的 C++ 代码。

### Block 作为函数参数

```
typedef void(^BlockType)(void);

int main(int argc, const char * argv[]) {
    
    NSString *string = @"This is a string!";
    void (^myBlock)(void) = ^ {
        
        NSLog(@"myBlock: %@", string);
    };
    
    void(^anotherBlock)(BlockType aBlock) = ^(BlockType aBlock){
        NSLog(@"AnotherBlock");
        
        aBlock();
    };
    
    anotherBlock(myBlock);

    return 0;
}
```

    
可以把这里传进去的 myBlock 看成是一个对象，调用 anotherBlock 时，就相当于调用一个函数，在这个函数中，myBlock 跟 anotherBlock 没有什么引用关系，myBlock 纯粹是一个参数，所以只需要考虑 myBlock 本身的情况。另外，myBlock 将外部的 string 对象捕获进去了，而且 myBlock 在堆上，所以 myBlock 对这个 string 对象进行了强引用。
