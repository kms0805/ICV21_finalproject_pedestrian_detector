function [test_bboxes, test_confidences, test_image_ids] = detect_cascade(cascade_classifier, test_dir, stride, window_size,n_scale, reduce_ratio)
%initialize
test_bboxes = [];
test_confidences = [];
test_image_ids = cell(0,1);


testfiles = dir(test_dir);
testfiles = testfiles(3:end);
n = size(testfiles,1);
n = 1;
for i = 1:n
    if rem(i,20) == 0
        i/n
    end
    test_img = rgb2gray(imread([test_dir,testfiles(i).name]));
    [samples, bboxes] = get_sliding_window_samples(test_img,  stride, window_size,n_scale, reduce_ratio, 3);
    [~, bboxes, confidences] = detect_cascade_samples(samples, bboxes, cascade_classifier);
    cur_test_bboxes = bboxes;
    is_maximum = nmss(cur_test_bboxes, confidences);
    cur_test_confidences = confidences(is_maximum,:);
    cur_test_bboxes = cur_test_bboxes(is_maximum,:);
    n_c = size(cur_test_bboxes,1);
    cur_test_image_ids = cell(n_c,1);
    for c = 1:n_c
    cur_test_image_ids{c} = [testfiles(i).name];
    end
    test_bboxes = [test_bboxes; cur_test_bboxes];
    test_confidences = [test_confidences; cur_test_confidences];
    test_image_ids = [test_image_ids; cur_test_image_ids];
  
end
end