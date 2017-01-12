//
//  Consts.h
//  SpeedMeasure
//
//  Created by Bryan Yuan on 1/12/17.
//  Copyright © 2017 Bryan Yuan. All rights reserved.
//

#ifndef Consts_h
#define Consts_h

#define COLOR_WITH_HEX(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]
#define XY_TILT_COLOR  COLOR_WITH_HEX(0x005ead)
#define XY_VIEW_BG_COLOR  COLOR_WITH_HEX(0xf4f4f4)

#endif /* Consts_h */
