acc = [];
gyro = [];
mag = [];
R = [];
Q = [];
usrAcc = [];
gAcc = [];
timeStamps = [];

for i = 1:508
    
    fid = fopen(sprintf('frame%u.txt',i));

    frame = textscan(fid, '%s %u %*[^\n]',1);
    
    timeStamps = [timeStamps, frame{2}];
    
    sensors = textscan(fid, '%s X:%f Y:%f Z:%f',3,'delimiter',',','CollectOutput', true);
    frame = textscan(fid, '%s%*[^\n]',1);
    tmpR = textscan(fid, '%f %f %f',3,'delimiter',',','CollectOutput', true);
    frame = textscan(fid, '%s%*[^\n]',1);
    tmpQ = textscan(fid, '%f %f %f %f',1,'delimiter',',','CollectOutput', true);
    usrSens = textscan(fid, '%s X:%f Y:%f Z:%f',2,'delimiter',',','CollectOutput', true);
    
    R(:,:,i) = tmpR{1};
    Q = [Q, tmpQ{1}'];
    
    tmp = sensors{2};
    
    acc = [acc, tmp(1,:)'];
    gyro = [gyro, tmp(2,:)'];
    mag = [mag, tmp(3,:)'];
    
    tmp = usrSens{2};
    
    usrAcc = [usrAcc, tmp(1,:)'];
    gAcc = [gAcc, tmp(2,:)'];
    
    fclose(fid);
    
end

save sensorData.mat acc gyro mag R Q usrAcc gAcc timeStamps
