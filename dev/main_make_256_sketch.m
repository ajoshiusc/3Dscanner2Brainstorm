%||AUM||
%||Shree Ganeshaya Namaha||
clc;clear all;close all;
restoredefaultpath;
addpath(genpath('/home/ajoshi/Projects/brainstorm3'));
load('/home/ajoshi/Projects/brainstorm3/defaults/eeg/Colin27/channel_ANT_Waveguard_256.mat');
% uncomment for 64 channel ANT Waveguard
% load('defaults/eeg/Colin27/channel_ANT_Waveguard_64.mat');
X1 = [];
Y1 = [];
for i=1:length(Channel)
    [X,Y] = bst_project_2d(Channel(i).Loc(1,:), Channel(i).Loc(2,:), Channel(i).Loc(3,:), '2dcap');
    X1 = [X1 X];
    Y1 = [Y1 Y];
end
plot(X1,Y1, 'ok', 'MarkerSize',10);axis equal;axis off;

pts = [X1',Y1'];

save('256_pts.mat',"pts");
