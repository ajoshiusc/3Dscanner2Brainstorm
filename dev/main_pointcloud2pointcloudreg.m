%||AUM||
%||Shree Ganeshaya Namaha||
clear all;close all;clc;

load("centers_cap_sketch.mat")
NIT=20;

step_size=.05;
lap_reg=8;


figure;
imagesc(sketch_img); colormap gray;hold on;title('sketch');
plot(centerssketch(:,1),centerssketch(:,2),'r*');
axis equal;



figure;
imagesc(cap_img); colormap gray;hold on;title('cap');
plot(centerscap(:,1),centerscap(:,2),'b+');
axis equal;

% will warp sketch to cap

sketch_pts = [254,426;254,67;112,246;396,246];
cap_pts = [253,390;250,46;66,254;436,252];

[warp,L,LnInv,bendE] = tpsGetWarp(10, sketch_pts(:,1)', sketch_pts(:,2)', cap_pts(:,1)', cap_pts(:,2)' );
 
[xsR,ysR] = tpsInterpolate( warp, sketch_pts(:,1)', sketch_pts(:,2)', [1]);



figure;
imagesc(cap_img); colormap gray;hold on;title('cap with orig sketch pts');
plot(centerscap(:,1),centerscap(:,2),'ro');

plot(centerssketch(:,1),centerssketch(:,2),'y+');
axis equal;

[xsR,ysR] = tpsInterpolate( warp, centerssketch(:,1)', centerssketch(:,2)', [1]);
centerssketch(:,1) = xsR;
centerssketch(:,2) = ysR;

figure;
imagesc(cap_img); colormap gray;hold on;title('cap with warped sketch pts');
plot(centerscap(:,1),centerscap(:,2),'ro');
plot(xsR,ysR,'y+');
axis equal;


lambda = 100000;

for kk=1:NIT
    fprintf('.');
    %tic
    k=dsearchn(centerssketch,centerscap);

    %k is an index into sketch pts

    [vec_atlas_pts,ind]=unique(k);

    vec_atlas2sub=centerscap(ind,:)-centerssketch(vec_atlas_pts,:);
    dist = sqrt(vec_atlas2sub(:,1).^2+vec_atlas2sub(:,2).^2);

    [dist2,isoutlier]=rmoutliers(dist);
    ind(isoutlier) = [];
    vec_atlas_pts(isoutlier) = [];

    [warp,L,LnInv,bendE] = tpsGetWarp(lambda, centerssketch(vec_atlas_pts,1)', centerssketch(vec_atlas_pts,2)', centerscap(ind,1)', centerscap(ind,2)' );

    [xsR,ysR] = tpsInterpolate( warp, centerssketch(:,1)', centerssketch(:,2)', [0]);
    centerssketch(:,1) = xsR;
    centerssketch(:,2) = ysR;

    figure;
    imagesc(cap_img); colormap gray;hold on;title(sprintf('cap with warped sketch pts: iter %d',kk));
    plot(centerscap(:,1),centerscap(:,2),'ro');
    plot(xsR,ysR,'y+');
    axis equal;

end

