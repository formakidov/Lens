//
//  CVWrapper.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject

- (UIImage*) processImageWithOpenCV:(UIImage*) sourceImage points: (CGPoint[]) points;
- (NSArray *)detectEdges:(UIImage*) sourceImage size: (CGSize) targetSize;

@end

