function [pff_all,predict_all,ski_GS,cnt_SGS,save_BWSKLi,BW_all,RW_all,CW_all,e] = predict_skeletons(argsNS1,argsNS2,tb_box,lenght,TRuido,auto,t,kt)
    %% Input variables
    
    % Valores del modelo
    Igray = argsNS1{1,7};
    Colors = argsNS1{1,8};
    
    % Model values
    XY_all = argsNS2{1,5};
    TAMGS = argsNS1{1,4};
    Wg = argsNS1{1,6};
    rs = argsNS2{1,6};
    ccl = argsNS2{1,7};
    
    % Error matrix
    e=zeros(1,TAMGS); % fault log

    %% Find next segmentation
    [BW_GS,Tbbox_GS,PXI_GS,bdi_GS,ski_GS] = get_NextS(argsNS1,argsNS2,tb_box);
    
    %% Find repeating segmentations
    % Output variables
    SGS = {};
    cnt_SGS = [];
    
    % Find segmentations
    for bgs = 1:TAMGS
        sumGS = 0;
        temp = bgs;
        for gs=1:TAMGS
            BWAND = BW_GS{1,bgs}&BW_GS{1,gs};
            [~,Xand] = find(BWAND);
            if (~isempty(Xand))
                sumGS = sumGS + 1;
                if(bgs~=gs)
                    temp = [temp;gs];
                end
            end
        end
        cnt_SGS(1,bgs) = sumGS;
        SGS{1,bgs} = temp;
    end
    clear bgs sumGS temp gs BWAND Xand BWAND Xand;
    ccl = [ccl;cnt_SGS]; %save how many worms are in the segmentation
    
    %% Get better length
    lg=[];W={};f=0;
    for gs=1:TAMGS
        [ygs,~]=find(ccl(:,gs)==1); %find individual worms
        if(isempty(ygs))
            [ygs,~]=find(ccl(:,gs)>1);
        end
        lenghtGS = lenght(ygs,gs); %get lengths of 'individual' worms
        lm = round(mean(lenghtGS)); %get average length
        lg = [lg,lm]; %save average length

        [~,v] = min(abs(lenghtGS-lm)); %get width closer to average length
        W{1,gs} = Wg{v,gs}; %save width
    end
    clear cnt_l gs lenghtGS counts vc;
    
    %% Find possible skeletons in segmentation
    argsSKL = {BW_GS,Tbbox_GS,bdi_GS,ski_GS,cnt_SGS,W,rs}; %arguments for processing
    [save_SKL,save_BWSKL,save_BWSKLi,XYF_GS] = get_Skeletons(TAMGS,lg,argsSKL,f,10,auto);
    
    %% Optimization method
    CTRuido = logical(imcrop(TRuido,tb_box));
    RCTRuido = imresize(CTRuido,rs);
    
    for gn=1:TAMGS 
        bdi = BW_GS{1,gn};
        if(cnt_SGS(1,gn) == 1)
        try
            BWi_skls = save_BWSKL{1,gn}; %skeletons pixels
            skls = save_SKL{1,gn}; %skeletons points
            LG = lg(1,gn); %length model
            wn = W{1,gn}; %width model
            Cwn = Colors{1,gn}; %color model
            crop_BWi = bdi_GS{1,gn}; %previous segmentation
            Ski_BWi = ski_GS{1,gn}; %previous skeleton
            predictE = PXI_GS(:,gn); %previous centroid, speed, ...
            result = []; %array to save results
            
            % Advance window of the optimization process
            disp(sprintf('Solving %d combinations...', size(skls,1)));
            if(size(skls,1)>10)
                fbar = waitbar(0,sprintf('Solving %d combinations...', size(skls,1)));
                pause(.1);
            end
            for i=1:size(skls,1)
                XYi = skls{i,1}; %skeleton to analyze   
                [BWGi] = build_body(XYi(:,1),XYi(:,2),bdi,wn); %rebuild body
                
                %% Overlap parameter
                [KY,~] = find((abs(crop_BWi-BWGi))>0); 
                result(i,1) = size(KY,1); %save result of Overlap
                
                %% Completeness parameter
                BWcompd = bdi;
                BWcompd = abs((BWcompd - BWGi))>0; %restar pixeles solapados
                [~,Xcmd]=find(BWcompd);
                result(i,2) = size(Xcmd,1); %save result of completeness

                %% Noise parameter
                % Área del ruido en trayectoria
                [~,Xra] = find(logical(BWGi) & RCTRuido);
                result(i,3)= size(Xra,1); %save result of noise

                %% Color parameter
                cc = color_compare(Igray,XYi,Cwn,wn,2);
                result(i,4) = cc;% Noise
                
%                 %% Length parameter
%                 result(i,5)= abs((LG - size(XYi,1))*(mean(wn)^2)); %save result of length

%                 %% Smoothness parameter
%                 [m_theta] = get_SmssPX(XYi,5,30);
%                 result(i,6) = m_theta; %save result of smoothness

                if(size(skls,1)>10)
                    waitbar(i/size(result,1)); %update process bar
                end
            end
            if(size(skls,1)>10)
                close(fbar); %close process window
            end
            [~,v] = min(sum(result,2)); %get optimal skeleton
                       
            XYF_GS{1,gn} = skls{v,1}; %save skeleton
        catch
            XYF_GS{1,gn} = ski_GS{1,gn};
            e(1,gn)=1;
        end
        else
            if(isempty(XYF_GS{1,gn}))
                All = {};
                crash = SGS{1,gn};
                n = size(crash,1); %total worms in tracks
                for cn=1:n 
                    bdg = crash(cn,1);
                    All{1,cn} = 1:1:size(save_SKL{1,bdg},1); %get all combination vectors 
                end

                % Get matrix of combinations
                c = cell(1,numel(All));
                [c{:}] = ndgrid(All{:});
                result = cell2mat(cellfun(@(v)v(:), c, 'UniformOutput', false));
                if((size(result,1)>24000)) %update combination matrix if it is greater than 24000 combinations
                    result=result(1:24000,:);
                end
                
                % Advance window of the optimization process
                disp(sprintf('Solving %d combinations...', size(result,1)));
                if(size(result,1)>10)
                    gbar = waitbar(0,sprintf('Solving %d combinations...', size(result,1)));
                end
                
                resultC=[]; %array to save results
                for cr=1:size(result,1)  
                    %% Optimization process for aggregations between worms
                    sum_smt=0;
                    Sum_noise=0;
                    Sum_slp=0;
                    sum_LPX = 0;
                    sum_cc=0;
                    BWcomp = bdi;
                    
                    for gns=1:n
                        fg = result(cr,gns); %row where to look
                        bdg = crash(gns,1); %worm to analyze
                        LG = lg(1,bdg); %length model
                        wn = W{1,bdg}; %width model
                        Cwn = Colors{1,bdg}; %color model
                        BdW = save_SKL{1,bdg}; %skeletons points
                        XYi = BdW{fg,1}; %skeleton to analyze 
                        [BWGi] = build_body(XYi(:,1),XYi(:,2),bdi,wn);%rebuild body

                        %% Overlap parameter
                        crop_BWi = bdi_GS{1,bdg};
                        BWcompd = (abs(crop_BWi-BWGi))>0;
                        [KY,~] = find(BWcompd);
                        Sum_slp = Sum_slp + size(KY,1); %result of Overlap

                        %% Completeness parameter
                        BWcomp = (abs(BWcomp - BWGi))>0; %result of completeness
                        
                        %% Noise parameter
                        G_noise = (logical(RCTRuido) & logical(BWGi));
                        [~,Xrn]=find(G_noise);
                        Sum_noise = Sum_noise + size(Xrn,1); %result of noise

                        %% Color parameter
                        cc = color_compare(Igray,XYi,Cwn,wn,2);     
                        sum_cc = sum_cc + cc; %save result of color
                
%                         %% Length parameter
%                         sum_LPX = sum_LPX + abs((LG - size(XYi,1))*(mean(wn)^2)); %result of length

%                         %% Smoothness parameter
%                         [m_theta] = get_SmssPX(XYi,5,30);
%                         sum_smt = sum_smt + m_theta; %result of smoothness
                    end
                    
                    %% Save result of Overlap
                    resultC(cr,1)= Sum_slp;

                    %% Save result of completeness
                    [~,Xcmd]=find(BWcomp);
                    resultC(cr,2)= size(Xcmd,1);    
                    
                    %% Save result of noise
                    resultC(cr,3)= Sum_noise;

                    %% Save result of color
                    resultC(cr,4)= sum_cc;

%                     %% Save result of length
%                     resultC(cr,5)= sum_LPX;

%                     %% Save result of smoothness
%                     resultC(cr,6)= sum_smt;

                    if(size(result,1)>10)
                        waitbar(cr/size(result,1)); %update process bar
                    end
                end

                %% Close windows bar
                if(size(result,1)>10)
                    close(gbar); %close process window
                end
                
                %% Get optimal skeletons
                [~, vg] = min(sum(resultC,2));
                
                %% Save results
                for gns=1:n
                    fg = result(vg,gns); %row where to look
                    bdg = crash(gns,1); %worm to save
                    BdW = save_SKL{1,bdg}; %skeletons points
                    BWGi = BdW{fg,1}; %skeleton to save
                    XYF_GS{1,bdg} = BWGi; %save skeletons
                end 
            end
        end
    end   
    %% Save output values
    [BW_all,RW_all,CW_all,pff_all,predict_all] = save_predict(Igray,TAMGS,ski_GS,XYF_GS,PXI_GS,BW_GS);
end