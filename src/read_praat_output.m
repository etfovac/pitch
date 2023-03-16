function [N, dt, F0] = read_praat_output(folder, file_name);
fileID = fopen([folder 'Sound ' file_name '.txt']);
C = textscan(fileID,'%f %f %f', 'TreatAsEmpty',{'NA','na','--undefined--'},'CommentStyle','//');
fclose(fileID);
%whos C
N = C{1};
dt = C{2};
F0 = C{3};
