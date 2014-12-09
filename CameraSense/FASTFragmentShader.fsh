//
//  FASTFragmentShader.fsh
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/05/23.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

precision highp float;

//Variables for the FAST detector
uniform mediump float threshold;
uniform mediump float N;

uniform sampler2D inputImageTexture;

varying vec2 textureCoordinate;
varying vec2 FASTr1;
varying vec2 FASTr2;
uniform vec2 FASTr3;
varying vec2 FASTr4;
varying vec2 FASTr5;
varying vec2 FASTr6;
uniform vec2 FASTr7;
varying vec2 FASTr8;
varying vec2 FASTr9;
varying vec2 FASTr10;
uniform vec2 FASTr11;
varying vec2 FASTr12;
varying vec2 FASTr13;
varying vec2 FASTr14;
uniform vec2 FASTr15;
varying vec2 FASTr16;

mediump float radius[16];
//
//mediump float FASTPoints[16];

mediump vec4 thresh = vec4(threshold);
mediump vec4 nthresh = vec4(-threshold);

bool checkCorner(int i); 
lowp float allGTEThresh(mediump vec4 a);

//Array of indexes for checking all possible groiups of 12
uniform int ccIDX[19];

void main()
{
       
    mediump vec4 p = texture2D(inputImageTexture, textureCoordinate);
        
    mediump vec4 testVec = vec4( texture2D(inputImageTexture, FASTr1).r,
                                texture2D(inputImageTexture, FASTr5).r,
                                texture2D(inputImageTexture, FASTr9).r,
                                texture2D(inputImageTexture, FASTr13).r );

    testVec = abs( testVec - vec4(p.r) );
    
    bvec4 tmp = greaterThanEqual(testVec, vec4(threshold));
    
    bvec3 a = bvec3(tmp[0], tmp[1], tmp[2]);
    bvec3 b = bvec3(tmp[0], tmp[1], tmp[3]);
    bvec3 c = bvec3(tmp[0], tmp[2], tmp[3]);
    bvec3 d = bvec3(tmp[1], tmp[2], tmp[3]);

    if ( any( bvec4(all(a), all(b), all(c), all(d)) ) ) {
        
        radius[0] = texture2D(inputImageTexture, FASTr1).r - p.r;
        radius[1] = texture2D(inputImageTexture, FASTr2).r - p.r;
        radius[2] = texture2D(inputImageTexture, textureCoordinate + FASTr3).r - p.r;
        radius[3] = texture2D(inputImageTexture, FASTr4).r - p.r;
        radius[4] = texture2D(inputImageTexture, FASTr5).r - p.r;
        radius[5] = texture2D(inputImageTexture, FASTr6).r - p.r;
        radius[6] = texture2D(inputImageTexture, textureCoordinate + FASTr7).r - p.r;
        radius[7] = texture2D(inputImageTexture, FASTr8).r - p.r;
        radius[8] = texture2D(inputImageTexture, FASTr9).r - p.r;
        radius[9] = texture2D(inputImageTexture, FASTr10).r - p.r;
        radius[10] = texture2D(inputImageTexture, textureCoordinate + FASTr11).r - p.r;
        radius[11] = texture2D(inputImageTexture, FASTr12).r - p.r;
        radius[12] = texture2D(inputImageTexture, FASTr13).r - p.r;
        radius[13] = texture2D(inputImageTexture, FASTr14).r - p.r;
        radius[14] = texture2D(inputImageTexture, textureCoordinate + FASTr15).r - p.r;
        radius[15] = texture2D(inputImageTexture, FASTr16).r - p.r;
    
        if ( checkCorner(0) ) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, p.a);
            return;
        }
        else if ( checkCorner(1) ) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, p.a);
            return;
        }
        else if ( checkCorner(2) ) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, p.a);
            return;
        }
        else if ( checkCorner(3) ) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, p.a);
            return;
        }
        else {
           gl_FragColor = vec4(0.0, 0.0, 0.0, p.a);
           return;
        }

    }

    gl_FragColor = vec4(0.0, 0.0, 0.0, p.a);

}

//Returns -1 if all components are less than -threshold and 1 if all components > threshold and 0 otherwise
lowp float allGTEThresh(mediump vec4 a) {
        
    if ( all( greaterThanEqual(a, thresh) ) ) {
        return 1.0;
    }
    else if ( all( lessThanEqual(a, nthresh) ) ) {
        return -1.0;
    }
    else {
        return 0.0;
    }
    
}

bool checkCorner(int i){
    
    lowp vec4 check;
 
    check = vec4(
    
    allGTEThresh( vec4( radius[ccIDX[i     ]],
                        radius[ccIDX[i + 1 ]],
                        radius[ccIDX[i + 2 ]],
                        radius[ccIDX[i + 3 ]])),
    
    allGTEThresh( vec4( radius[ccIDX[i + 4 ]],
                        radius[ccIDX[i + 5 ]],
                        radius[ccIDX[i + 6 ]],
                        radius[ccIDX[i + 7 ]])),

    allGTEThresh( vec4( radius[ccIDX[i + 8 ]],
                        radius[ccIDX[i + 9 ]],
                        radius[ccIDX[i + 10]],
                        radius[ccIDX[i + 11]])),

    allGTEThresh( vec4( radius[ccIDX[i + 12]],
                        radius[ccIDX[i + 13]],
                        radius[ccIDX[i + 14]],
                        radius[ccIDX[i + 15]]))
    
    );

    lowp vec4 ones;
    ones = vec4(1.0, 1.0, 1.0, 1.0);
    lowp float sum = dot(check, ones);
    
    if (sum == 3.0 || sum == -3.0)
        return true;
    
    return false;
    
}
