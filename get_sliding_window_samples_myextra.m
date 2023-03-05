function [samples_H,samples_L,bboxes_H, bboxes_L] = get_sliding_window_samples_myextra(test_img, stride, window_size, n_scale, reduce_ratio)
%test_img is graysclae
% if ftype is 1 -> hog 
% if ftype is 2 -> lbf 
%initializing
img_ho = size(test_img,1);
img_wo = size(test_img,2);
win_h = window_size(1);
win_w = window_size(2);
img_hi = img_ho;
img_wi = img_wo;
r = 1; %total reduce_ratio
samples_H = [];
bboxes_H = [];
samples_L = [];
bboxes_L = [];
%window의 스케일을 키워가며 반복
for i = 1:n_scale
    %window의 크기가 이미지보다 크면 종료
    if(img_hi < win_h || img_wi < win_w)
        break
    end
    test_img_i = imresize(test_img,[img_hi img_wi]);
    rend = img_hi - win_h + 1;
    cend = img_wi - win_w + 1;
    sizeofsamples_i = ceil(rend/stride)*ceil(cend/stride);
    samples_i_H = zeros(sizeofsamples_i,3780);
    samples_i_L = zeros(sizeofsamples_i,6195);
    bboxes_i_H = zeros(sizeofsamples_i,4);
    bboxes_i_L = zeros(sizeofsamples_i,4);
    n = 1;
    for ri = 1:stride:rend
        for ci = 1:stride:cend
            sample = test_img_i(ri:ri+win_h-1, ci:ci+win_w-1);
            sr = round(ri/r);
            sc = round(ci/r);
            bbox = [sc sr sc+round(win_w/r)-1 sr+round(win_h/r)-1];
            sample_H = extractHOGFeatures(sample);  
            samples_i_H(n,:) = sample_H;
            sample_L = extractLBPFeatures(sample,'CellSize',[6 12]);  
            samples_i_L(n,:) = sample_L;
            bboxes_i_L(n,:) = bbox;
            bboxes_i_H(n,:) = bbox;
            n = n + 1;
        end
    end

    samples_H = [samples_H; samples_i_H];
    samples_L = [samples_L; samples_i_L];
    bboxes_H = [bboxes_H; bboxes_i_H];
    bboxes_L = [bboxes_L; bboxes_i_L];
    r = r*reduce_ratio;
    img_hi = floor(img_hi*reduce_ratio);
    img_wi = floor(img_wi*reduce_ratio);
end
