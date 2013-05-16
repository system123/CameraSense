
fid = fopen('frame1.txt');

frame = textscan(fid, '%s %u %*[^\n]',1);
% 
% C = textscan(fid, '%s%u %*[^\n]',3,'delimiter','\n', 'MultipleDelimsAsOne', 1);
sensors = textscan(fid, '%s X:%f Y:%f Z:%f',3,'delimiter',',','CollectOutput', true);
% C = textscan(fid, '%u8','delimiter','\n','CollectOutput', true);
A = fread(fid, [480 inf],'*uint8');
fclose(fid);
% 
% FRAME 1
% ACC0, X:-0.148773, Y:-0.770508, Z:-0.537430
% GYR0, X:-0.097894, Y:-0.230788, Z:-0.266778
% MAG0, X:-99.369354, Y:103.323486, Z:-35.193558