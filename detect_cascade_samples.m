function [samples, bboxes, confidences] = detect_cascade_samples(samples, bboxes, cascade_classifier)

if ~exist('bboxes','var'), bboxes = 0; end
num_levels = size(cascade_classifier,1);
num_samples = size(samples,1);
for i = 1:num_levels
    
    strong_classifier = cascade_classifier{i}.strong_cf;
    block_bboxes =  strong_classifier(1:4,:);
    w_list = strong_classifier(5:40,:);
    b_list = strong_classifier(41,:);
    weak_threshold = strong_classifier(42,:);
    alpha = cascade_classifier{i}.alpha;
    threshold = cascade_classifier{i}.strong_Th;
    confidences = 0;
    
    num_weak_cf = size(w_list,2);
    
    for j = 1:num_weak_cf
        w = w_list(:,j);
        b = b_list(:,j);
        weak_Th = weak_threshold(j);
        alpha_t = alpha(j);
        bbox = block_bboxes(:,j);
        cellsize = [(bbox(4)-bbox(2)+1)/2 (bbox(3)-bbox(1)+1)/2];
        cut_samples = cell(num_samples,1);
        for ns = 1:num_samples
            cut_samples{ns} = samples{ns}(bbox(2):bbox(4),bbox(1):bbox(3));
        end
        X = getHOGs(cut_samples,cellsize,[2 2]);
        weak_confidence = X * w + b;
        weak_predicted = (weak_confidence >=  weak_Th);
        confidences = confidences + weak_predicted * alpha_t;        
    end
    strong_predicted = (confidences >= threshold);
    samples = samples(strong_predicted);
    bboxes = bboxes(strong_predicted,:);
    confidences = confidences(strong_predicted);
    num_samples = size(samples,1);
end
    