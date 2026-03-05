%07/24/2025
%verify result

clc
clear
close all;

% high_reso_loc='C:\Users\youy\work\project\super-resolution\data_v2\gmi-val\';
% low_reso_loc='C:\Users\youy\work\project\super-resolution\data_v2\ssmis-val\';

data_loc='C:\Users\youy\work\project\super-resolution\data_v3_td_ts\mhs\matched-gmi-ssmis-with-number\';

high_reso_loc='C:\Users\youy\work\project\super-resolution\data_v3_td_ts\mhs\gmi-val\';
low_reso_loc='C:\Users\youy\work\project\super-resolution\data_v3_td_ts\mhs\ssmis-val\';

mat_loc='C:\Users\youy\work\project\super-resolution\mat-data-v3-td-ts\';

hist_adj_loc='C:\Users\youy\work\project\super-resolution\mat-data-v3-td-ts\';
load([hist_adj_loc,'hist_adj_gmi_ssmis-data-v3-mhs.mat']);
%***************************************************
file_list=dir([high_reso_loc,'*.mat']);

load([mat_loc,'trainedVDSR-v3-epoch50-ND15-patchesPerImage200-mhs.mat']);

ref=[];
sim1=[];
sim2=[];
sate=[];

for k1=1:length(file_list)

    k1
    %******************************************************************
    tp1=file_list(k1).name;
    filelist_with_num=dir([data_loc,tp1(1:4),'-*.mat']);

    load([filelist_with_num.folder,'\',filelist_with_num.name]);
    %filelist_name=filelist.name;

    %rain_ref=matched.rain_ref;
     rain_ref_ori=matched.rain_ref_original;
    % ref_lon=matched.rain_ref_lon;
    % ref_lat=matched.rain_ref_lat;

    %rain_S2=matched.rain_S2;
    rain_S2_ori=matched.rain_S2_original;
    % S2_lon=matched.rain_S2_lon;
    % S2_lat=matched.rain_S2_lat;

    ix1_ori=(~isnan(rain_ref_ori))&(~isnan(rain_S2_ori));
    %***********************************************************************

    ssmis=load([low_reso_loc,file_list(k1).name]);
    gmi=load([high_reso_loc,file_list(k1).name]);

    gmi=gmi.rain_ref;
    ssmis=ssmis.rain_S2;

    Iresidual= predict(net,ssmis);
    Iresidual=double(Iresidual);

    ssmis_new=ssmis+Iresidual;
    %***************************************************
    ssmis_adj=interp1(hist_adj.src_xvalue, hist_adj.dst_xvalue, log(ssmis+0.01));
    ssmis_adj=exp(ssmis_adj);

    %********************************************
    gmi=gmi(ix1_ori);
    ssmis=ssmis(ix1_ori);
    ssmis_new=ssmis_new(ix1_ori);
    ssmis_adj=ssmis_adj(ix1_ori);
    
    
    %********************************************
    ref=[ref;gmi(:)];
    sate=[sate;ssmis(:)];
    sim1=[sim1;ssmis_new(:)];
    sim2=[sim2;ssmis_adj(:)];
end


%*******************************************************
cv=0.1;

%ix1=ref>cv&sim1>cv&sim2>cv&sate>cv;
%**********************************
%original
ix1=ref>cv&sate>cv;

ref_ori=ref(ix1);
sate_ori=sate(ix1);

rmse1=rmse(ref_ori,sate_ori);
cf1=corr(ref_ori,sate_ori);
bias1=(sum(sate_ori)-sum(ref_ori))/sum(ref_ori);
%**************************
%CNN
ix2=ref>cv&sim1>cv;

ref_cnn=ref(ix2);
sim_cnn=sim1(ix2);

rmse2=rmse(ref_cnn,sim_cnn);
cf2=corr(ref_cnn,sim_cnn);
bias2=(sum(sim_cnn)-sum(ref_cnn))/sum(ref_cnn);
%*****************************
%hist
ix3=ref>cv&sim2>cv;

ref_hist=ref(ix3);
sim_hist=sim2(ix3);

rmse3=rmse(ref_hist,sim_hist);
cf3=corr(ref_hist,sim_hist);
bias3=(sum(sim_hist)-sum(ref_hist))/sum(ref_hist);

stats.bias=[bias1,bias3,bias2];
stats.rmse=[rmse1,rmse3,rmse2];
stats.cf=[cf1,cf3,cf2];
stats

%*****************************************************
clim_max=600;

a=log(ref_ori);
b=log(sate_ori);

intv=0.1/1;
sp1=-4:intv:6;
sp2=-4:intv:6;

X=[a,b];

ctrs=cell(2,1);
ctrs{1}=-4:intv:6;
ctrs{2}=-4:intv:6;

% with "edges" or without "edegs" it is only matters if we care about the
% boundary, most of times, it is fine with or without
% the following example, the N1 and N2 is exactly the same

% without edeges, N1 and N2 is slightly different, due to edge effect.

N1=hist3(X,'edges',ctrs);
N1(N1==0)=NaN;

%transerfed is a must; otherwise, x and y axis is opposite
N1=N1';

density_mhs.N1_ori=N1;
%***********************************************
h=pcolor(N1);

axis equal tight
grid on
%set(h,'alphadata',~isnan(N1))
set(h, 'EdgeColor', 'none');

xtick1=1:1:length(sp1);
xtick2=exp(sp1);

Xs=[0.1,0.5,1,2,4,8,16,32,64,128,256];

yi=interp1(xtick2,xtick1,Xs);

set(gca,'xtick',yi);
set(gca,'xticklabel',Xs,'FontSize',10);

set(gca,'ytick',yi);
set(gca,'yticklabel',Xs,'FontSize',10);

xlim([yi(1),yi(end)]);
ylim([yi(1),yi(end)]);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
h=colorbar;
% xlabel('TRMM PR (mm/hr)','Fontsize',10);
% ylabel('GPROF (mm/hr)','Fontsize',10);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
colormap jet;

clim([0,clim_max])
%*****************************************************

a=log(ref_cnn);
b=log(sim_cnn);

intv=0.1/1;
sp1=-4:intv:6;
sp2=-4:intv:6;

X=[a,b];

ctrs=cell(2,1);
ctrs{1}=-4:intv:6;
ctrs{2}=-4:intv:6;

% with "edges" or without "edegs" it is only matters if we care about the
% boundary, most of times, it is fine with or without
% the following example, the N1 and N2 is exactly the same

% without edeges, N1 and N2 is slightly different, due to edge effect.

N1=hist3(X,'edges',ctrs);
N1(N1==0)=NaN;

%transerfed is a must; otherwise, x and y axis is opposite
N1=N1';


density_mhs.N1_cnn=N1;
%***********************************************
figure
h=pcolor(N1);

axis equal tight
grid on
%set(h,'alphadata',~isnan(N1))
set(h, 'EdgeColor', 'none');

xtick1=1:1:length(sp1);
xtick2=exp(sp1);

Xs=[0.1,0.5,1,2,4,8,16,32,64,128,256];

yi=interp1(xtick2,xtick1,Xs);

set(gca,'xtick',yi);
set(gca,'xticklabel',Xs,'FontSize',10);

set(gca,'ytick',yi);
set(gca,'yticklabel',Xs,'FontSize',10);

xlim([yi(1),yi(end)]);
ylim([yi(1),yi(end)]);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
h=colorbar;
% xlabel('TRMM PR (mm/hr)','Fontsize',10);
% ylabel('GPROF (mm/hr)','Fontsize',10);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
colormap jet;

clim([0,clim_max])

%********************************
a=log(ref_hist);
b=log(sim_hist);

intv=0.1/1;
sp1=-4:intv:6;
sp2=-4:intv:6;

X=[a,b];

ctrs=cell(2,1);
ctrs{1}=-4:intv:6;
ctrs{2}=-4:intv:6;

% with "edges" or without "edegs" it is only matters if we care about the
% boundary, most of times, it is fine with or without
% the following example, the N1 and N2 is exactly the same

% without edeges, N1 and N2 is slightly different, due to edge effect.

N1=hist3(X,'edges',ctrs);
N1(N1==0)=NaN;

%transerfed is a must; otherwise, x and y axis is opposite
N1=N1';



%***********************************************
figure
h=pcolor(N1);

axis equal tight
grid on
%set(h,'alphadata',~isnan(N1))
set(h, 'EdgeColor', 'none');

xtick1=1:1:length(sp1);
xtick2=exp(sp1);

Xs=[0.1,0.5,1,2,4,8,16,32,64,128,256];

yi=interp1(xtick2,xtick1,Xs);

set(gca,'xtick',yi);
set(gca,'xticklabel',Xs,'FontSize',10);

set(gca,'ytick',yi);
set(gca,'yticklabel',Xs,'FontSize',10);

xlim([yi(1),yi(end)]);
ylim([yi(1),yi(end)]);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
h=colorbar;
% xlabel('TRMM PR (mm/hr)','Fontsize',10);
% ylabel('GPROF (mm/hr)','Fontsize',10);

hold on
plot([yi(1),yi(end)],[yi(1),yi(end)],'r');
colormap jet;

clim([0,clim_max])

density_mhs.N1_hist=N1;
%*************************************
density_mhs.stats=stats;

save('density_mhs.mat','density_mhs');









