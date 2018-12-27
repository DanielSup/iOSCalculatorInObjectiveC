//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Daniel Sup on 23/12/2018.
//  Copyright © 2018 Daniel Sup. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//edited and comment added
@interface CalculatorBrain : NSObject
- (void) pushOperand:(double) operand;
- (void) cancel;
- (double) getLastElement;
- (double) performOperation:(NSString *)operation;
- (void) addVariable:(NSString *)variableName withValue:(double)value;
- (BOOL) isVariableDefined:(NSString *)variableName;
- (double) variableValue:(NSString *)variableName;
- (NSMutableDictionary *) allVariables;
- (void) undoOperationsAndOperands;

@property (readonly) id program;
@property (readonly) id secondProgram;

+ (double) runProgram:(id)program;
+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *) variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end

NS_ASSUME_NONNULL_END
