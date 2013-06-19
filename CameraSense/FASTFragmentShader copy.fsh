//
//  FASTFragmentShader.fsh
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/05/23.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

varying highp vec2 textureCoordinate;

//Variables for the FAST detector
uniform mediump float threshold;
uniform mediump float N;
uniform highp float texelHeight;
uniform highp float texelWidth;

uniform sampler2D inputImageTexture;

highp vec2 radius[16];

mediump float FASTPoints[16];


bool checkCorner(int i);
lowp float allGTEThresh(mediump vec4 a);

//Array of indexes for checking all possible groiups of 12
uniform int ccIDX[19];

void main()
{
    highp vec2 scale = vec2(texelWidth, texelHeight);
    
    radius[0] = vec2(0.0, -3.0)*scale;
    radius[1] = vec2(1.0, -3.0)*scale;
    radius[2] = vec2(2.0, -2.0)*scale;
    radius[3] = vec2(3.0, -1.0)*scale;
    radius[4] = vec2(3.0, 0.0)*scale;
    radius[5] = vec2(3.0, 1.0)*scale;
    radius[6] = vec2(2.0, 2.0)*scale;
    radius[7] = vec2(1.0, 3.0)*scale;
    radius[8] = vec2(0.0, 3.0)*scale;
    radius[9] = vec2(-1.0, 3.0)*scale;
    radius[10] = vec2(-2.0, 2.0)*scale;
    radius[11] = vec2(-3.0, 1.0)*scale;
    radius[12] = vec2(-3.0, 0.0)*scale;
    radius[13] = vec2(-3.0, -1.0)*scale;
    radius[14] = vec2(-2.0, -2.0)*scale;
    radius[15] = vec2(-1.0, -3.0)*scale;
    
    //mediump float FASTPoints[16];
       
    mediump vec4 p = texture2D(inputImageTexture, textureCoordinate);
    
    int FASTCheck = 0;

    for (int i = 0; i < 4; i++){
        
        int j = i*4;
        
        FASTPoints[j    ] = texture2D(inputImageTexture, textureCoordinate + radius[j    ]).r - p.r;
        FASTPoints[j + 1] = texture2D(inputImageTexture, textureCoordinate + radius[j + 1]).r - p.r;
        FASTPoints[j + 2] = texture2D(inputImageTexture, textureCoordinate + radius[j + 2]).r - p.r;
        FASTPoints[j + 3] = texture2D(inputImageTexture, textureCoordinate + radius[j + 3]).r - p.r;

        
        if ( abs(FASTPoints[j + 1]) >= threshold ) {
            FASTCheck++;            
        }
        
    }
        
    if (FASTCheck == 3){
        
        if (checkCorner(0)){
            gl_FragColor = vec4(vec3(1.0), p.a);
            return;
        }
        else if (checkCorner(1)){
            gl_FragColor = vec4(vec3(1.0), p.a);
            return;
        }
        else if (checkCorner(2)){
            gl_FragColor = vec4(vec3(1.0), p.a);
            return;
        }
        else if (checkCorner(3)){
            gl_FragColor = vec4(vec3(1.0), p.a);
            return;
        }
            
    }

    gl_FragColor = vec4(0.0, 0.0, 0.0, p.a);

}

mediump vec4 thresh = vec4(threshold);
mediump vec4 nthresh = vec4(-threshold);

//Returns -1 if all components are less than -threshold and 1 if all components > threshold and 0 otherwise
lowp float allGTEThresh(mediump vec4 a) {
    
    a = a - p.r;
    
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

//NOT CHECKING ALL PERMUTATIONS OF 12 NEEDS REWRITE
bool checkCorner(int i){
    
    lowp vec4 check;
 
    check = vec4(
    
    allGTEThresh( vec4( texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j     ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 1 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 2 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 3 ]]).r ) - p.r);
    
    allGTEThresh( vec4( texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j   4 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 5 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 6 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 7 ]]).r ) - p.r);
    
    allGTEThresh( vec4( texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j   8 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 9 ]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 10]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 11]]).r ) - p.r);
    
    allGTEThresh( vec4( texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j   12]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 13]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 14]]).r,
                        texture2D(inputImageTexture, textureCoordinate + radius[ccIDX[j + 15]]).r ) - p.r);
    
        allGTEThresh(vec4(FASTPoints[ccIDX[i]], FASTPoints[ccIDX[i + 1]], FASTPoints[ccIDX[i + 2]], FASTPoints[ccIDX[i + 3]])),
        allGTEThresh(vec4(FASTPoints[ccIDX[i + 4]], FASTPoints[ccIDX[i + 5]], FASTPoints[ccIDX[i + 6]], FASTPoints[ccIDX[i + 7]])),
        allGTEThresh(vec4(FASTPoints[ccIDX[i + 8]], FASTPoints[ccIDX[i + 9]], FASTPoints[ccIDX[i + 10]], FASTPoints[ccIDX[i + 11]])),
        allGTEThresh(vec4(FASTPoints[ccIDX[i + 12]], FASTPoints[ccIDX[i + 13]], FASTPoints[ccIDX[i + 14]], FASTPoints[ccIDX[i + 15]]))
    );
    
    lowp float sum = dot(check, lowp vec4(1.0));
    
    if (sum == 3.0 || sum == -3.0)
        return true;
    
    return false;
    
}
