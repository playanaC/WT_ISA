function [BWSK,X,Y,BWW,cnt_islands] = new_skel(BW,Tboxg,w1,w2,rs)

    % Crop image
    Tboxg = Tboxg + [-2,-2,2,2];
    cropI = imcrop(BW>0, Tboxg);

    % Maximum width
    W1 = (w1*2); %Width1
    W2 = (w2*2); %Width2
    BWR0 = cropI;
    
    % Background transform
    fl=1;cnt=0;
    while(fl==1 && (cnt<3))
        BW_distp = bwdist(~BWR0);
        fl=0;
        BW_distN=zeros(size(BW_distp));
        for j=1:size(BW_distp,1)
            for i=1:size(BW_distp,2)
                if(BW_distp(j,i)>W1 && BW_distp(j,i)<W2)
                    BW_distN(j,i)=0;
                    fl=1;
                else
                    BW_distN(j,i)=BW_distp(j,i);
                end
            end
        end
        BWR0 = (BW_distN>0);
        cnt=cnt+1;
    end
      
    % Obtain skeleton
    BWW = BW_distN>0;
    BWSKN = bwmorph(BWW,'thin',1);
    BWSK = bwmorph(BWSKN,'thin',Inf);

    % Take to Tboxg position
    [yl,xl] = find(BWSK);
    X = xl + Tboxg(1,1);
    Y = yl + Tboxg(1,2);
    [BWSK] = build_skel(X,Y,BW);
    
    % Check skeleton
    % Check for small holes
    Ap = 2*rs;
    BW2 = imfill(BWSK,'holes');
    BWr = (BW2 -BWSK)>0;
    
    % Obtain areas in the middle of the skeleton 
    [LB, neB] = bwlabel(BWr, 4);
    blobM = regionprops(LB, BWr, 'Area');
    
    % Count number of islands
    BWR = logical(zeros(size(BWSK))); %image to save big holes (islands)
    cnt_islands = 0; %island counter
    for Lbp = 1:neB
        if( blobM(Lbp).Area < Ap)
            BWB = (ismember(LB, Lbp))>0; %
            BWR = BWR | BWB; % adding small holes
        else
            cnt_islands=cnt_islands+1;
        end
    end
    
    % Obtain skeleton corrected
    BWSK = BWSK | BWR;
    BWSK = bwmorph((BWSK>0),'thin',Inf);
    
end