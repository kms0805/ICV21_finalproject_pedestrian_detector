function [test_bboxes, test_confidences, test_image_ids] = detect(w,b,test_dir, stride, window_size, ...
    n_scale, reduce_ratio, ftype)
%initialize
test_bboxes = [];
test_confidences = [];
test_image_ids = cell(0,1);


testfiles = dir(test_dir);
testfiles = testfiles(3:end);
n = size(testfiles,1);
for i = 1:n
    if rem(i,20) == 0
        i/n
    end
    test_img = rgb2gray(imread([test_dir,testfiles(i).name]));
    [samples, bboxes] = get_sliding_window_samples(test_img,  stride, window_size,n_scale, reduce_ratio, ftype);
    all_confidences = samples*w+b;
     
    cur_test_bboxes = [];
    cur_test_confidences = [];
    cur_test_image_ids = cell(0,1);
    
    for j = 1:size(all_confidences,1)
        if(all_confidences(j) > 0)
            cur_test_confidences = [cur_test_confidences; all_confidences(j)];
            cur_test_bboxes = [cur_test_bboxes; bboxes(j,:)];
            cur_test_image_ids = [cur_test_image_ids; [testfiles(i).name]];
        end
    end
    if (~isempty(cur_test_confidences))
        is_maximum = nmss(cur_test_bboxes, cur_test_confidences);
        cur_test_confidences = cur_test_confidences(is_maximum,:);
        cur_test_bboxes = cur_test_bboxes(is_maximum,:);
        cur_test_image_ids = cur_test_image_ids(is_maximum,:);
    
        test_bboxes = [test_bboxes; cur_test_bboxes];
        test_confidences = [test_confidences; cur_test_confidences];
        test_image_ids = [test_image_ids; cur_test_image_ids];
    end
end
end

