//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Daniel Sup on 23/12/2018.
//  Copyright © 2018 Daniel Sup. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableArray *secondProgramStack;
@property (nonatomic, strong) NSMutableDictionary *variableDictionary;
@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;
@synthesize secondProgramStack = _secondProgramStack;
@synthesize variableDictionary = _variableDictionary;

- (NSMutableDictionary *) variableDictionary{
    if(!_variableDictionary){
        _variableDictionary = [[NSMutableDictionary alloc] init];
    }
    return _variableDictionary;
}

- (NSMutableArray *) secondProgramStack {
    if(!_secondProgramStack){
        _secondProgramStack = [[NSMutableArray alloc] init];
    }
    return _secondProgramStack;
}
- (NSMutableArray *) programStack {
    if(!_programStack){
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void) pushOperand:(double)operand{
    NSNumber *object = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:object];
    [self.secondProgramStack addObject:object];
}

- (void) cancel{
    [self.secondProgramStack removeAllObjects];
    [self.programStack removeAllObjects];
}

- (double) getLastElement{
    return [[self.programStack lastObject] doubleValue];
}

- (double) performOperation:(NSString *)operation{
    [self.programStack addObject:operation];
    [self.secondProgramStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:self.variableDictionary];
}

- (void) addVariable:(NSString *)variableName withValue:(double)value{
    NSNumber *object = [NSNumber numberWithDouble:value];
    [self.variableDictionary setValue:object forKey:variableName];
}

- (BOOL) isVariableDefined:(NSString *)variableName{
    id object = [self.variableDictionary objectForKey:variableName];
    if(!object){
        return false;
    }
    return true;
}

- (double) variableValue:(NSString *)variableName{
    NSNumber *object = [self.variableDictionary objectForKey:variableName];
    return [object doubleValue];
}

- (NSMutableDictionary *) allVariables{
    return self.variableDictionary;
}

- (void) undoOperationsAndOperands{
    [self.secondProgramStack removeLastObject];
    [self.programStack removeLastObject];
}

- (id) program{
    return [self.programStack copy];
}

- (id) secondProgram {
    return [self.secondProgramStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program{
    NSMutableArray *stack;
    NSString *description = @"";
    NSUInteger i = 0;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
        NSMutableArray *secondStack = [[NSMutableArray alloc] init];
        while([stack count] > 0 && i < [stack count]){
            id object = [stack objectAtIndex:i];
            if([object isKindOfClass:[NSNumber class]]){
                NSNumber *numberObject = (NSNumber *)object;
                NSString *stringVar = [numberObject stringValue];
                [secondStack addObject:stringVar];
                i++;
            } else if([object isKindOfClass:[NSString class]]){
                NSString *operation = (NSString *)object;
                if([operation isEqualToString:@"+"] || [operation isEqualToString:@"-"] || [operation isEqualToString:@"*"] || [operation isEqualToString:@"/"]){
                    NSString *firstArgument = @"0";
                    NSString *secondArgument = @"0";
                    bool firstBrackets = false;
                    bool secondBrackets = false;
                    if(i == 0){
                        NSString *result = [firstArgument stringByAppendingString:[@" " stringByAppendingString:[operation stringByAppendingString:[@" " stringByAppendingString:secondArgument]]]];
                        [secondStack insertObject:result atIndex:0];
                        [stack replaceObjectAtIndex:0 withObject:result];
                        i++;
                    } else if(i == 1){
                        secondArgument = [secondStack objectAtIndex:0];
                        id secondObject = [stack objectAtIndex: (i - 1)];
                        secondBrackets = [secondObject isKindOfClass:[NSString class]];
                        if(secondBrackets){
                            secondArgument = [@"( " stringByAppendingString:[firstArgument stringByAppendingString:@" )"]];
                        }
                        NSString *result = [firstArgument stringByAppendingString:[@" " stringByAppendingString:[operation stringByAppendingString:[@" " stringByAppendingString:secondArgument]]]];
                        [stack replaceObjectAtIndex:0 withObject:result];
                         [secondStack replaceObjectAtIndex:0 withObject:result];
                        [stack removeObjectAtIndex:1];
                    } else {
                        firstArgument = [secondStack objectAtIndex:(i - 2)];
                        secondArgument = [secondStack objectAtIndex:(i - 1)];
                        id firstObject = [stack objectAtIndex: (i - 2)];
                        id secondObject = [stack objectAtIndex: (i - 1)];
                        firstBrackets = [firstObject isKindOfClass:[NSString class]];
                        secondBrackets = [secondObject isKindOfClass:[NSString class]];
                        if(firstBrackets){
                            firstArgument = [@"( " stringByAppendingString:[firstArgument stringByAppendingString:@" )"]];
                        }
                        if(secondBrackets){
                            secondArgument = [@"( " stringByAppendingString:[secondArgument stringByAppendingString:@" )"]];
                        }
                        NSString *result = [firstArgument stringByAppendingString:[@" " stringByAppendingString:[operation stringByAppendingString:[@" " stringByAppendingString:secondArgument]]]];
                        [stack replaceObjectAtIndex:(i-2) withObject:result];
                        [secondStack replaceObjectAtIndex:(i-2) withObject:result];
                        [secondStack removeObjectAtIndex:(i - 1)];
                        [stack removeObjectAtIndex:(i-1)];
                        [stack removeObjectAtIndex:(i-1)];
                        i--;
                    }
                } else if ([operation isEqualToString:@"sin"] || [operation isEqualToString:@"cos"]
                           || [operation isEqualToString:@"sqrt"]){
                    NSString *unaryOperation = (NSString *)object;
                    NSString *string;
                    if(i == 0){
                        string = [unaryOperation stringByAppendingString:@"(0)"];
                        [secondStack insertObject:string atIndex:0];
                        int a = 1;
                        NSNumber *act = [NSNumber numberWithInt:a];
                        [stack insertObject:act atIndex:0];
                        i++;
                    } else {
                        NSString *lastObject = [secondStack objectAtIndex:(i - 1)];
                        NSString *actualOperation = [unaryOperation stringByAppendingString:@"("];
                        [secondStack removeObjectAtIndex:(i - 1)];
                        [stack removeObjectAtIndex:i];
                        string = [actualOperation stringByAppendingString:[lastObject stringByAppendingString:@")"]];
                        [secondStack insertObject:string atIndex:(i - 1)];
                        int a = 1;
                        NSNumber *act = [NSNumber numberWithInt:a];
                        [stack replaceObjectAtIndex:(i - 1) withObject:act];
                        [secondStack replaceObjectAtIndex:(i - 1) withObject:string];
                        
                    }
                } else {
                    int a = 1;
                    NSNumber *act = [NSNumber numberWithInt:a];
                    [stack replaceObjectAtIndex:i withObject:act];
                    [secondStack addObject:operation];
                    i++;
                }
            }
        }
        int objects = 0;
        for (NSString *str in secondStack){
            if(objects == 0){
                description = [description stringByAppendingString:str];
            } else {
                description = [[description stringByAppendingString: @", "] stringByAppendingString:str];
            }
            objects++;
        }
    }
    return description;
}

+ (double) popOperandOffStack:(NSMutableArray *)stack{
    double result = 0;
    id topOfStack = [stack lastObject];
    if(topOfStack){
        [stack removeLastObject];
    }
    if([topOfStack isKindOfClass:[NSNumber class]]){
         result = [topOfStack doubleValue];
    } else if([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]){
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if([operation isEqualToString:@"-"]){
            double subtract = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtract;
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if([operation isEqualToString:@"/"]){
            double divisor = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]){
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"Pi"]){
            result = M_PI;
        }
    }
    return result;
}

+ (double) popOperandOffStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues{
    double result = 0;
    id topOfStack = [stack lastObject];
    if(topOfStack){
        [stack removeLastObject];
    }
    if([topOfStack isKindOfClass:[NSNumber class]]){
        result = [topOfStack doubleValue];
    } else if([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]){
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] + [self popOperandOffStack:stack usingVariableValues:variableValues];
        } else if([operation isEqualToString:@"-"]){
            double subtract = [self popOperandOffStack:stack usingVariableValues:variableValues];
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] - subtract;
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] * [self popOperandOffStack:stack usingVariableValues:variableValues];
        } else if([operation isEqualToString:@"/"]){
            double divisor = [self popOperandOffStack:stack usingVariableValues:variableValues];
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] / divisor;
        } else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"sqrt"]){
            result = sqrt([self popOperandOffStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"Pi"]){
            result = M_PI;
        } else {
            result = [[variableValues objectForKey:operation] doubleValue];
        }
    }
    return result;
}

+ (double) runProgram:(id)program{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack usingVariableValues:variableValues];
}

+ (NSSet *) variablesUsedInProgram:(id)program{
    NSMutableArray *stack;
    NSMutableSet *variableSet = [[NSMutableSet alloc] init];
    int variables = 0;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
        for(NSObject *object in stack){
            if([object isKindOfClass:[NSString class]]){
                NSString *stringObject = (NSString *)object;
                if(![stringObject isEqualToString:@"+"] &&
                   ![stringObject isEqualToString:@"-"] &&
                   ![stringObject isEqualToString:@"*"] &&
                   ![stringObject isEqualToString:@"/"] &&
                   ![stringObject isEqualToString:@"sin"] &&
                   ![stringObject isEqualToString:@"cos"] &&
                   ![stringObject isEqualToString:@"sqrt"] &&
                   ![stringObject isEqualToString:@"Pi"]){
                    [variableSet addObject:stringObject];
                    variables++;
                }
            }
        }
    }
    if(variables == 0){
        return nil;
    } else {
        return variableSet;
    }
}
@end
