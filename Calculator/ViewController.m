//
//  ViewController.m
//  Calculator
//
//  Created by Daniel Sup on 23/12/2018.
//  Copyright © 2018 Daniel Sup. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController ()
    @property (nonatomic) BOOL enteredNonZero;
@property (nonatomic, strong) CalculatorBrain *model;
@property (nonatomic) NSMutableArray *resultHistory;
@end

@implementation ViewController
@synthesize enteredNonZero;
@synthesize model = _model;
@synthesize memoryLabel;
@synthesize resultHistory = _resultHistory;

-(NSMutableArray *) resultHistory{
    if(!_resultHistory){
        _resultHistory = [[NSMutableArray alloc] init];
    }
    return _resultHistory;
}

- (CalculatorBrain *) model{
    if(!_model){
        _model = [[CalculatorBrain alloc] init];
    }
    return _model;
}

- (IBAction)undoPressed:(UIButton *)sender {
    [self.model undoOperationsAndOperands];
    if(enteredNonZero){
        enteredNonZero = NO;
        self.display.text = @"0";
    } else {
        id object = [self.resultHistory lastObject];
        if(object){
            [self.resultHistory removeLastObject];
            id secondObject = [self.resultHistory lastObject];
            if(secondObject) {
                self.display.text = (NSString *)[self.resultHistory lastObject];
            } else {
                self.display.text = @"0";
            }
        } else {
            self.display.text = @"0";
            
        }
    }
    self.memoryLabel.text = [CalculatorBrain descriptionOfProgram:self.model.secondProgram];
    NSString *variableString = @"";
    NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.model.program];
    for(NSString *variable in variables){
        NSString *equals = @" = ";
        double value = [self.model variableValue:variable];
        NSNumber *number = [NSNumber numberWithDouble:value];
        NSString *numberString = [number stringValue];
        NSString *variableWithValue = [variable stringByAppendingString:[equals stringByAppendingString:numberString]];
        if([variableString isEqualToString:@""]){
            variableString = variableWithValue;
        } else {
            variableString = [variableString stringByAppendingString:[@" " stringByAppendingString:variableWithValue]];
        }
    }
    self.variableLabel.text = variableString;
}

- (IBAction)cancelPressed:(UIButton *)sender {
    [[self model] cancel];
    self.memoryLabel.text = @"";
    self.display.text = @"0";
    self.variableLabel.text = @"";
}
- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variableName = [sender currentTitle];
    if([self.model isVariableDefined:variableName]){
        double variableValue = [self.model performOperation:[sender currentTitle]];
        self.display.text = [[NSNumber numberWithDouble:variableValue] stringValue];
        self.memoryLabel.text = [CalculatorBrain descriptionOfProgram:self.model.secondProgram];
        [self.resultHistory addObject:self.display.text];
        self.memoryLabel.text = [CalculatorBrain descriptionOfProgram:self.model.secondProgram];
        NSString *variableString = @"";
        NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.model.program];
        for(NSString *variable in variables){
            NSString *equals = @" = ";
            double value = [self.model variableValue:variable];
            NSNumber *number = [NSNumber numberWithDouble:value];
            NSString *numberString = [number stringValue];
            NSString *variableWithValue = [variable stringByAppendingString:[equals stringByAppendingString:numberString]];
            if([variableString isEqualToString:@""]){
                variableString = variableWithValue;
            } else {
                variableString = [variableString stringByAppendingString:[@" " stringByAppendingString:variableWithValue]];
            }
        }
        self.variableLabel.text = variableString;
    } else {
        [self.model addVariable:variableName withValue:[self.display.text doubleValue]];
    }
    enteredNonZero = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *variableString = @"";
    NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.model.program];
    for(NSString *variable in variables){
        NSString *equals = @" = ";
        double value = [self.model variableValue:variable];
        NSNumber *number = [NSNumber numberWithDouble:value];
        NSString *numberString = [number stringValue];
        NSString *variableWithValue = [variable stringByAppendingString:[equals stringByAppendingString:numberString]];
        if([variableString isEqualToString:@""]){
            variableString = variableWithValue;
        } else {
            variableString = [variableString stringByAppendingString:[@" " stringByAppendingString:variableWithValue]];
        }
    }
    self.variableLabel.text = variableString;
    
    if(![self.display.text containsString:@"You can not divide by zero"] && ![self.display.text containsString:@"You can not get a square root of negative number"]){
         
         if(enteredNonZero){
        [self enterPressed:sender];
    }
    if([self.model getLastElement] == 0 && [[sender currentTitle] isEqualToString:@"/"]){
        self.display.text = @"You can not divide by zero";
    } else if ([self.model getLastElement] < 0 && [[sender currentTitle] isEqualToString:@"sqrt"]) {
        self.display.text = @"You can not get a square root of negative number";
    } else {
        double result = [self.model performOperation:[sender currentTitle]];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        [self.resultHistory addObject:self.display.text];
        self.memoryLabel.text = [CalculatorBrain descriptionOfProgram:self.model.secondProgram];
     }
     }
    
}
- (IBAction)enterPressed:(UIButton *)sender {
    if(![self.display.text containsString:@"You can not divide by zero"] && ![self.display.text containsString:@"You can not get a square root of negative number"]){
        [self.resultHistory addObject:self.display.text];
        [self.model pushOperand:[self.display.text doubleValue]];
    enteredNonZero = NO;
    self.memoryLabel.text = [CalculatorBrain descriptionOfProgram:self.model.secondProgram];
        
    }
}
- (IBAction)test1Pressed:(UIButton *)sender {
    NSNumber *numb = nil;
    double a = [numb doubleValue];
    [self.model addVariable:@"x" withValue:a];
    [self.model addVariable:@"a" withValue:a];
    [self.model addVariable:@"b" withValue:a];
    
}
- (IBAction)test2Pressed:(id)sender {
    [self.model addVariable:@"x" withValue:22];
    [self.model addVariable:@"a" withValue:3];
    [self.model addVariable:@"b" withValue:16];
    
}
- (IBAction)test3Pressed:(id)sender {
    [self.model addVariable:@"x" withValue:1];
    [self.model addVariable:@"a" withValue:7];
    [self.model addVariable:@"b" withValue:11];
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if(![self.display.text containsString:@"You can not divide by zero"] && ![self.display.text containsString:@"You can not get a square root of negative number"]){
        
        if(enteredNonZero){
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        if(![digit isEqualToString:@"0"]){
            enteredNonZero = YES;
        }
    }
    }
}
@synthesize display;
@synthesize variableLabel;
 - (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
