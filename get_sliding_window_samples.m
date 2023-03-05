function [samples, bboxes] = get_sliding_window_samples(test_img, stride, window_size, n_scale, reduce_ratio, ftype)
%test_img is graysclae
% if ftype is 1 -> hog 
% if ftype is 2 -> lbf 
% if ftype is 3 -> jsut img
%initializing
img_ho = size(test_img,1);
img_wo = size(test_img,2);
win_h = window_size(1);
win_w = window_size(2);
img_hi = img_ho;
img_wi = img_wo;
r = 1; %total reduce_ratio
samples = [];
if ftype ==3
    samples = {};
end
bboxes = [];
test_img_i = test_img;
%window의 스케일을 키워가며 반복
for i = 1:n_scale
    %window의 크기가 이미지보다 크면 종료
    img_hi = size(test_img_i,1);
    img_wi = size(test_img_i,2);
    if(img_hi < win_h || img_wi < win_w)
        break
    end   
    
    rend = img_hi - win_h +1;
    cend = img_wi - win_w + 1;
    sizeofsamples_i = ceil(rend/stride)*ceil(cend/stride);
    if ftype==1
    samples_i = zeros(sizeofsamples_i,3780);
    end
    if ftype==2
    samples_i = zeros(sizeofsamples_i,6195);
    end
    if ftype==3
    samples_i = cell(sizeofsamples_i,1);
    end
    bboxes_i = zeros(sizeofsamples_i,4);
    n = 1;
    for ri = 1:stride:rend
        for ci = 1:stride:cend
            sample = test_img_i(ri:ri+win_h-1, ci:ci+win_w-1);
            bbox = [round((ci)/r) round((ri)/r) round((ci+win_w-2)/r) round((ri+win_h-2)/r)];
            if ftype == 1
            sample = extractHOGFeatures(sample);  
            samples_i(n,:) = sample;
            end
            if ftype == 2
            sample = extractLBPFeatures(sample,'CellSize',[6 12]);  
            samples_i(n,:) = sample;
            end
            if ftype == 3
            samples_i{n} = sample;
            end
            bboxes_i(n,:) = bbox;
            n = n + 1;
        end
    end

    samples = [samples; samples_i];
    bboxes = [bboxes; bboxes_i];
    r = r*reduce_ratio;
    test_img_i = imresize(test_img_i,reduce_ratio);
end
end