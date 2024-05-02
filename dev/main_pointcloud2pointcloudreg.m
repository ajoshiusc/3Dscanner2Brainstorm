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

sketch_pts = [86,254;266,112;446,254;266,396];% [254,426;254,67;112,246;396,246];
cap_pts = [122,253;258,66;466,250;260,436];%[253,390;250,46;66,254;436,252];

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
imagesc(cap_img); colormap gray;hold on;%title('cap with warped sketch pts');
plot(centerscap(:,1),centerscap(:,2),'ro');
plot(xsR,ysR,'y+');axis off;
axis equal;
exportgraphics(gca,"cap_markers.gif","Append",true)
close all;

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
    imagesc(cap_img); colormap gray;hold on;%title(sprintf('cap with warped sketch pts: iter %d',kk));
    plot(centerscap(:,1),centerscap(:,2),'ro');
    plot(xsR,ysR,'y+');axis off;
    axis equal;
    exportgraphics(gca,"cap_markers.gif","Append",true)
    close all;
end


%% Map contact locations to the 3d cap
load('head_surf.mat');


NPTS = length(cap_img);
ll=linspace(-1,1,NPTS);
[X1,Y1]=meshgrid(ll,ll);

u_sketch = interp2(X1,xsR,ysR);
v_sketch = interp2(Y1,xsR,ysR);

(2*xsR)/NPTS -1
(2*ysR)/NPTS -1

% map from flat space to 3d cap

centerscapuv = 2*centerscap/NPTS - 1;

u_cap=head_surf.u;
v_cap=head_surf.v;


figure;hold on;title('pts identified on cap flat map');
patch('faces',head_surf.faces,'vertices',[u_cap,v_cap],'facevertexcdata',head_surf.vcolor,'facecolor','interp','edgecolor','none');
plot3(centerscapuv(:,1),centerscapuv(:,2),0*centerscapuv(:,2),'yo');
viscircles(centerscapuv, 0.05*ones(length(centerscap),1),'EdgeColor','b');
axis equal; axis off; camlight; material dull;view(70,30);axis tight;view(0,90);


cap_points(:,1)=griddata(u_cap,v_cap,head_surf.vertices(:,1),centerscapuv(:,1),centerscapuv(:,2));
cap_points(:,2)=griddata(u_cap,v_cap,head_surf.vertices(:,2),centerscapuv(:,1),centerscapuv(:,2));
cap_points(:,3)=griddata(u_cap,v_cap,head_surf.vertices(:,3),centerscapuv(:,1),centerscapuv(:,2));


figure;hold on;title('pts identified on cap');
patch('faces',head_surf.faces,'vertices',head_surf.vertices,'facevertexcdata',head_surf.vcolor,'facecolor','interp','edgecolor','none');
%plot3(cap_points(:,1),cap_points(:,2),cap_points(:,3),'yo');
mysphere(cap_points,3,'w',10);

axis equal; axis off; camlight; material dull;view(70,30);axis tight;


sketch_points(:,1)=griddata(u_cap,v_cap,head_surf.vertices(:,1),u_sketch,v_sketch);
sketch_points(:,2)=griddata(u_cap,v_cap,head_surf.vertices(:,2),u_sketch,v_sketch);
sketch_points(:,3)=griddata(u_cap,v_cap,head_surf.vertices(:,3),u_sketch,v_sketch);

figure;hold on;title('pts mapped from sketch to cap');
patch('faces',head_surf.faces,'vertices',head_surf.vertices,'facevertexcdata',head_surf.vcolor,'facecolor','interp','edgecolor','none');
%plot3(sketch_points(:,1),sketch_points(:,2),sketch_points(:,3),'yo');
%0.5*ones(size(head_surf.vertices))
mysphere(sketch_points,3,'y',10);

axis equal; axis off; camlight; material dull;view(70,30);axis tight;







