acc = [];
gyro = [];
mag = [];

for i = 1:934
    
    fid = fopen(sprintf('frame%u.txt',i));

    frame = textscan(fid, '%s %u %*[^\n]',1);
    sensors = textscan(fid, '%s X:%f Y:%f Z:%f',3,'delimiter',',','CollectOutput', true);

    tmp = sensors{2};
    
    acc = [acc, tmp(1,:)'];
    gyro = [gyro, tmp(2,:)'];
    mag = [mag, tmp(3,:)'];
    
    fclose(fid);
    
end

save sensorData.mat acc gyro mag
