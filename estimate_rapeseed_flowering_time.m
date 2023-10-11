%% Loading data
load('trainingData.mat');
% normalization
if 0
    [input_data,rule1]=mapminmax(data(:,2:end)',0,1); input_data=input_data';
    % [output_data,rule2]=mapminmax(data(:,1)',0,1); output_data=output_data';
    % input_data=[input_data output_data];
    input_data=[input_data data(:,1)];
    data=input_data;
end
%% random forest regression
%%Number of Leaves and Trees Optimization
if 1
Input=[data(:,1:end-1)]; 
% Input=data(:,2:end-3); 
Output=data(:,end);
if 1
for RFOptimizationNum=1:5
    
RFLeaf=[5,10,20,50,100,200,500];
col='rgbcmyk';
figure('Name','RF Leaves and Trees');
for i=1:length(RFLeaf)
    RFModel=TreeBagger(200,Input,Output,'Method','R','OOBPrediction','On','MinLeafSize',RFLeaf(i));
    plot(oobError(RFModel),col(i));
    hold on
end
xlabel('Number of Grown Trees');
ylabel('Mean Squared Error') ;
LeafTreelgd=legend({'5' '10' '20' '50' '100' '200' '500'},'Location','NorthEast');
title(LeafTreelgd,'Number of Leaves');
hold off;

disp(RFOptimizationNum);
end
end
%% Cycle Preparation
RFScheduleBar=waitbar(0,'Random Forest is Solving...');
RFRMSEMatrix=[];
RFrAllMatrix=[];
RFRunNumSet=10;
for RFCycleRun=1:RFRunNumSet
%% Training Set and Test Set Division
if 1
RandomNumber=(randperm(length(Output),floor(length(Output)*0.3)))';
TrainYield=Output;
TestYield=zeros(length(RandomNumber),1);
TrainVARI=Input;
TestVARI=zeros(length(RandomNumber),size(TrainVARI,2));

for i=1:length(RandomNumber)
    m=RandomNumber(i,1);
    TestYield(i,1)=TrainYield(m,1);
    TestVARI(i,:)=TrainVARI(m,:);
    TrainYield(m,1)=-100;
    TrainVARI(m,:)=-100;
end
TrainYield(all(TrainYield==-100,2),:)=[];
TrainVARI(all(TrainVARI==-100,2),:)=[];
end
%% RF
nTree=200;
nLeaf=5;
RFModel=TreeBagger(nTree,TrainVARI,TrainYield,...
    'Method','regression','OOBPredictorImportance','on', 'MinLeafSize',nLeaf);
[RFPredictYield,RFPredictConfidenceInterval]=predict(RFModel,TestVARI);

%% Accuracy of RF
RFRMSE=sqrt(sum(sum((RFPredictYield-TestYield).^2))/size(TestYield,1));
RFrMatrix=corrcoef(RFPredictYield,TestYield);
RFr=RFrMatrix(1,2); R2=RFr*RFr;
disp(R2);
RFRMSEMatrix=[RFRMSEMatrix,RFRMSE];
RFrAllMatrix=[RFrAllMatrix,RFr];
if RFRMSE<10
    disp(RFRMSE);
    break;
end
disp(RFCycleRun);
str=['Random Forest is Solving...',num2str(100*RFCycleRun/RFRunNumSet),'%'];
waitbar(RFCycleRun/RFRunNumSet,RFScheduleBar,str);
end
close(RFScheduleBar);

%% Ranking of importance of features
if 1
    PredictorDeltaError = RFModel.OOBPermutedPredictorDeltaError;
    figure
    bar(PredictorDeltaError);grid on;
    xlabel 'Feature';
    ylabel 'Magnitude';
    title('Feature magnitude');
end
% 
if 1
    PredictorDeltaError2 = PredictorDeltaError;
    a1=mean(PredictorDeltaError2(1:18));
    a2=mean(PredictorDeltaError2(19:36));
    a3=mean(PredictorDeltaError2(37:54));
    a4=mean(PredictorDeltaError2(55:72));
    a5=mean(PredictorDeltaError2(73:90));
    a6=mean(PredictorDeltaError2(91:108));
    a7=mean(PredictorDeltaError2(109:126));
    a8=mean(PredictorDeltaError2(127:144));
    a9=mean(PredictorDeltaError2(145:162));
    a10=mean(PredictorDeltaError2(163:180));
    PredictorDeltaError3=[a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,PredictorDeltaError2(181),PredictorDeltaError2(182),PredictorDeltaError2(183)];
    figure,bar(PredictorDeltaError3);grid on;
    xlabel 'Feature';
    ylabel 'Magnitude';
    title('Feature magnitude');
end

%% RF Model Storage
RFModelSavePath='.\';
save(sprintf('%sRFR_model_20220725.mat',RFModelSavePath),'nLeaf','nTree',...
    'RandomNumber','RFModel','RFPredictConfidenceInterval','RFPredictYield','RFr','RFRMSE',...
    'TestVARI','TestYield','TrainVARI','TrainYield');
end
%% Estimate rapeseed peak flowering date
if 1
clear
%load saved model
load('RF_model_20220725.mat');
[~, R]=geotiffread('.\input features\China_dem_25km.tif');  % 读取原tif影像的投影信息
info=geotiffinfo('.\input features\China_dem_25km.tif');
lo=imread('.\input features\China_longitude_25km.tif');
la=imread('.\input features\China_latitude_25km.tif');
dem=imread('.\input features\China_dem_25km.tif');
[m,n]=size(dem);
lo=reshape(lo,m*n,1);
la=reshape(la,m*n,1);
dem=reshape(dem,m*n,1);
doy_mean=[];

a=2000:2021;
u=2;
b=ceil(min(la)):u:ceil(max(la));
doyM=zeros(length(a),length(b)-1);
stdM=zeros(length(a),length(b)-1);
x=1; 
for i=2001:2022
    fname=strcat('.\input features\',num2str(i),'_mete_data.tif');
    img=imread(fname);
    [m,n,z]=size(img);
    img=reshape(img,m*n,z);
    img=[img lo la dem];

    %air tem
    data4=img(:,18*2+1:18*3);
    data5=data4-273.15;
    data5(data5<3)=0;
    data5=data5.*10;
    a=1;
    for j=18*2+1:18*3
        x=data5(:,1:a);
        if a==1
            img(:,j)=x;
        else
            img(:,j)=sum(x')';
        end
        a=a+1;
    end

    %soil tem
    data4=img(:,18*6+1:18*8);
    data5=data4-273.15;
    data5(data5<0)=0;
    data5=data5.*10;
    a=1;
    for k=18*6+1:18*8
        x=data5(:,1:a);
        if a==1
            img(:,k)=x;
        else
            img(:,k)=sum(x')';
        end
        a=a+1;
    end
    %

    result=predict(RFModel,img);
    result(isnan(dem))=-1;  %0
    result(isnan(img(:,1)))=-1;  %0

    result=reshape(result,m,n);
    
    s2 = num2str(i);
    f_name = strcat('.\results\',s2,'_floweringDOY','.tif');
    f_name2 = strcat('.\results\',s2,'_floweringDOY_month','.tif');
    geotiffwrite(f_name,result, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
    
    result2=int8(result);
    result2(result<=240)=8; result2(result<=210)=7; result2(result<=180)=6; result2(result<=150)=5;result2(result<=120)=4; result2(result<=90)=3; result2(result<=60)=2; result2(result<=30)=1; 
    result2(isnan(img(:,1)))=-1;  %0
    geotiffwrite(f_name2,result2, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end
end
%%%%%%%%%%
% doy_mean2=mean(doy_mean')';
% result=reshape(doy_mean2,m,n);
% f_name = strcat('2001-2020','_floweringDOY','.tif');
% geotiffwrite(f_name,result, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
