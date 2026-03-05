%use loop for the POS

clc
clear
close('all');
%****************************************
data_loc='C:\Users\youy\work\project\tropics-hurricane\mat-vdsr-paper\';

load([data_loc,'density_atms.mat']);
var1=density_atms.N1_ori;
var2=density_atms.N1_hist;
var3=density_atms.N1_cnn;

load([data_loc,'density_mhs.mat']);
var4=density_mhs.N1_ori;
var5=density_mhs.N1_hist;
var6=density_mhs.N1_cnn;

load([data_loc,'density_ssmis.mat']);
var7=density_ssmis.N1_ori;
var8=density_ssmis.N1_hist;
var9=density_ssmis.N1_cnn;

colormap jet;

%******************* *********************************
POS=[...
    0.05,0.70,0.25,0.25;...
    0.05,0.38,0.25,0.25;...
    0.05,0.06,0.25,0.25;...

    0.37,0.70,0.25,0.25;...
    0.37,0.38,0.25,0.25;...
    0.37,0.06,0.25,0.25;...

    0.69,0.70,0.25,0.25;...
    0.69,0.38,0.25,0.25;...
    0.69,0.06,0.25,0.25];
% pos(1)=0.24; %x0
% pos(3)=0.0075; %bar thickness
% pos(2)=0.795; % y1
% pos(4)=0.2; %height

Cbar_POS=[...
    0.28,0.70,0.01,0.25;...
    0.28,0.38,0.01,0.25;...
    0.28,0.06,0.01,0.25;...

    0.60,0.70,0.01,0.25;...
    0.60,0.38,0.01,0.25;...
    0.60,0.06,0.01,0.25;...

    0.92,0.70,0.01,0.25;...
    0.92,0.38,0.01,0.25;...
    0.92,0.06,0.01,0.25];

sate_name={'atms','mhs','ssmis'};

%************************************************
intv=0.1/1;
sp1=-4:intv:6;
xtick1=1:1:length(sp1);
xtick2=exp(sp1);

Xs=[0.1,0.2,0.5,1,2,4,8,16,32,64,128,256];

yi=interp1(xtick2,xtick1,Xs);

%************************************************
%colorbar max
cbar_max=[3000,600,400];

%*************************************************
Notes1={...
    '(a) ATMS ','(b) Hist adj. ATMS','(c) VDSR adj. ATMS',...
    '(d) MHS ','(e) Hist adj. MHS','(f) VDSR adj. MHS',...
    '(g) SSMIS ','(h) Hist adj. SSMIS','(i) VDSR adj. SSMIS'};

Xmarker={'Reference rain rate (mm/hr)'};
Ymarker={...
    'ATMS rain rate (mm/hr)',...
    'Hist adj. ATMS rain rate (mm/hr)',...
    'VDSR adj. ATMS rain rate (mm/hr)',...
    'MHS rain rate (mm/hr)',...
    'Hist adj. MHS rain rate (mm/hr)',...
    'VDSR adj. MHS rain rate (mm/hr)',...
    'SSMIS rain rate (mm/hr)',...
    'Hist adj. SSMIS rain rate (mm/hr)',...
    'VDSR adj. SSMIS rain rate (mm/hr)',...
    };
%************************************************

for i=1:9%

    eval(['N1=var',num2str(i),';']);
    %**********************************************
    figure(1)
    axes('position',POS(i,:));
    h=pcolor(N1);
    hold on
    axis equal tight
    grid on
    %set(h,'alphadata',~isnan(N1))
    set(h, 'EdgeColor', 'none');

    set(gca,'LineWidth',0.2);


    %     %***********************
    h1=colorbar;
    set(h1,'position',Cbar_POS(i,:));
    set(h1,'FontSize',5);

    if i>=1&i<=3
        set(gca, 'CLim', [0,cbar_max(1)])
        set(h1,'ytick',0:500:3000)
        set(h1,'yticklabel',{'1','500','1000','1500','2000','2500','3000'})
    end

    if i>=4&i<=6
        set(gca, 'CLim', [0,cbar_max(2)])
        set(h1,'ytick',0:100:6000)
        set(h1,'yticklabel',{'1','100','200','300','400','500','600'})
    end

    if i>=7&i<=9
        set(gca, 'CLim', [0,cbar_max(3)])
        set(h1,'ytick',0:100:4000)
        set(h1,'yticklabel',{'1','100','200','300','400'})
    end

    set(h1,'LineWidth',0.1);
    %******************************************************
    plot([14,220],[14,220],'-k','LineWidth',0.1);
    %*****************************************************
    set(gca,'xtick',yi);
    set(gca,'xticklabel',Xs,'FontSize',5);

    set(gca,'ytick',yi);
    set(gca,'yticklabel',Xs,'FontSize',5);

    xlim([yi(1),yi(end)]);
    ylim([yi(1),yi(end)]);


    xlabel(Xmarker{1},'FontSize',5);
    ylabel(Ymarker{i},'FontSize',5);


    text(0.05,0.92,Notes1{i},'FontSize',6,'units','normalized','FontSize',5);%,'BackGroundColor',[1,1,1]);

end

%******************************************
set(gcf,'renderer','painter');

print -r600 -dpng C:\Users\youy\work\project\tropics-hurricane\figure-vdsr-paper\density-plot.png











