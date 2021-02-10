clear all; clc;
Minimum_length = 20;
Maximum_length = 40;
worm_color = 35;

%% Sequence segmentation
pathl1 = 'D:\Demo_imgs\';
name_file = (strcat(pathl1,'matlab.mat'));
load(strcat(name_file));
path = pathl1;

% [name,tt] = get_files(path,30); %array of images's name
% disp('Processing region of interest...');
% [IC,noise] = interest_region(name,path,tt,worm_color); %Petri dish background(white)
% disp('Processing all tracks...');
% Cgs = worm_color:-1:26; %expected worm colors
% [BWM,BWM_label] = find_tracks(IC,path,name,Cgs,tt,2); %worm movement segmentation
% figure(3);imagesc(BWM_label);colorbar;colorbar('YTickLabel',{'BK','35','34','33','32','31','30','29','28','27','26'});% Add colour bar
% title('Threshold integrations');pause(0.1);
% disp('Analyzing all the tracks...');
% [MaskRGB,Noise_RGB,mat_result] = analyse_tracks(BWM,IC,80,path,name,tt,worm_color,noise,Minimum_length); %segmentation filtering
% MaskB = logical(MaskRGB(:,:,1)); %worm movement segmentation
% TRuido = logical(Noise_RGB(:,:,1)); %noise tracks

%% Show results
[LB, totalF] = bwlabel(MaskB, 8); %count and separate worm tracks
blobMeasurements = regionprops(LB, MaskB, 'Centroid','BoundingBox'); %rectangle around the binary image
tlt = sprintf('Total tracks c. elegans = %d',totalF); %title image
show_worms(LB,totalF,blobMeasurements,2,1,tlt,14); pause(0.1);%show final worms's tracks 
clear tlt noise Cgs noise BWM; %delete variables without using

%% Process tracks
disp('Processing c. elegans tracks...');
rs = 3; %resolution increase
for x = 10:totalF
    tb_box = round(blobMeasurements(x).BoundingBox) + [-6, -6, 6, 6]; %rectangle around the binary image
    MaskBMP = ismember(LB, x)>0; %extract track x
   
    try
        disp('Counting worms in tracks...');
        [Tworms,start_tracking] = find_worms(path,name,MaskBMP,worm_color,mat_result,x,TRuido); % Count how many worms are on the track
        [PXIG,skl,bds,Tworms,lenght,widths,colors] = find_state1(path,name,start_tracking,MaskBMP,worm_color,Tworms,tb_box,rs,Maximum_length); %get worm model
    catch
        Tworms=0;
    end
    
    if(Tworms>0)
        er=(zeros(tt,Tworms));% fault log

        %% Color and marker symbols from worms in plot
        [colorF,markerF,marker_form] = color_form(Tworms,1,99); %RGB colors are obtained randomly from 1 to 99
        argsC = {colorF,markerF,marker_form}; %it is stored in a cell to be used later

        %% Get all predictions of worms
        args1 = {path,name,Tworms,tb_box,worm_color,start_tracking,MaskBMP,TRuido,tt,x,totalF};%arguments for processing
        args2 = {lenght,widths,colors,bds,PXIG,skl,rs,er}; %arguments for processing
        graph = 1; %if graph = 1 then show plot result, if graph = 0, the plot result is hidden
        auto = 1; %if auto = 1, then use new_skel, if auto = 0, then use bwmorph
        [lgi,lenght,widths,colors,skl,bds,PXIG,er,colns] = predict1(args1,args2,argsC,graph,auto,x);%worm skeleton prediction
        clear args1; clear args2;

        %% Check and fix all lengths
        disp('Check length and segmentation...');
        color_C =35:1:42;
        args3 = {path,name,Tworms,tb_box,MaskBMP,TRuido,tt,x,totalF};%arguments for processing
        args4 = {color_C,lgi,lenght,widths,colors,bds,PXIG,skl,rs};%arguments for processing
        [lgi,skl,lenght,widths,colors] = check_worms(args3,args4,argsC); %Check and fix all lengths
        clear args3; clear args4;

        %% Obtain track models
        [LG,WG,CG] = get_model(lenght,skl,widths,colors,er);

        %% Reduce skeleton size
        disp('Reducing scale to normal size...');
        [SSKL, lgi2] = resize_skels(skl,tb_box,rs,MaskB,path,name);

        %% Analizar trayectorias
        disp('Analyzing tracks...');
        [skl1,skl_status,Behavior,status] = analyse_worms(SSKL);

        %% Save track in XML
        [~,xdt] = find(MaskBMP);
        [~,xidt] = find(MaskBMP&TRuido);
        pdt = (size(xidt,1)*100)/size(xdt,1);% Noise percentage in track
        model_Number = 8; %Model name. (Only numbers)
        save_XML_dot(path,x,skl1,skl_status,Behavior,status,lgi2,pdt,rs,WG,CG,colns,auto,model_Number); %Create xml file
    end
end