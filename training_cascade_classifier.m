function cascade_classifier =training_cascade_classifier(pos_list, neg_list, blocks,F_target, f_max, d_min)

%initialize
cascade_classifier = {};
D_i = 1;
F_i = 1;
i = 0;

while(F_i>F_target)
    i = i+1;
    fprintf('Level %d: \n',i);    
    f_i = 1;
    
    %adaboost
    npos = size(pos_list,1);
    nneg = size(neg_list,1);
    nall = npos + nneg;
    w_t = [ones(npos,1)./(2*npos); ones(nneg,1)./(2*nneg)];
    
    strong_classifier = [];
    alpha_list = [];
    strong_confiednce = zeros(nall,1);
    img_list = [pos_list; neg_list];
    
    while (f_i > f_max)
        w_t = w_t ./ sum(w_t);
        now_blocks = datasample(blocks,250,1,'Replace',false);
        lowest_error = inf;
        % 250 개의 random으로 고른 block 에 의한 svm
        for j = 1:250
            bbox = now_blocks(j,:);
            cellsize = [(bbox(4)-bbox(2)+1)/2 (bbox(3)-bbox(1)+1)/2];
            windowsample_list = cell(nall,1);
            
            for ni = 1:nall
                windowsample_list{ni} = img_list{ni}(bbox(2):bbox(4),bbox(1):bbox(3));  
            end
            X = getHOGs(windowsample_list,cellsize,[2 2]);
            y = zeros(nall,1);
            y(1:npos) = 1;
            svm_model = fitcsvm(X,y);
            w = svm_model.Beta;
            b = svm_model.Bias;
            cur_confidence = X * w + b;
            
            % 모든 가능한 weak_threshold별로 최적의 weak_threshold 검색 후 error 측정
            error_list_temp = zeros(npos,1);
            for nw = 1:npos
                weak_threshold = cur_confidence(nw);
                predicted = (cur_confidence >= weak_threshold); 
                error_list_temp(nw,1) = sum(w_t.*abs(predicted-y));             
            end
            [error, idx] = min(error_list_temp);
            best_weak_threshold = cur_confidence(idx);
            if error < lowest_error
                lowest_error = error;
                weak_classifier =  [bbox'; w; b; best_weak_threshold];
                predicted_now = predicted;        
            end             
        end
        beta_t = lowest_error / (1 - lowest_error);
        ei = abs(predicted_now-y);
        w_t = w_t .* (beta_t .^ (1 - ei));
        alpha_t = log(1/beta_t);
        strong_confiednce = strong_confiednce + alpha_t * predicted_now;
        
        min_detect_pos = round(d_min * npos);
        temp = maxk(strong_confiednce(1:npos), min_detect_pos);
        threshold = temp(end);
        
        strong_predicted = (strong_confiednce >= threshold);
        
        d_i = sum(strong_predicted(1:npos))/npos;
        f_i = sum(strong_predicted(npos+1:end)) / nneg;
        
        strong_classifier = [strong_classifier weak_classifier];
        alpha_list = [alpha_list alpha_t]; 
        fprintf('now f_i -> %f\n', f_i);
    end
    
    D_i = D_i * d_i;
    F_i = F_i * f_i;
    
    fprintf('now F-i ->  %f\n', F_i);   
    cascade_classifier{i} = struct('strong_cf',strong_classifier,'alpha',alpha_list,'strong_Th',threshold);

    % set neg 을 비우고 다시 채운다.
    neg_list = {};
    if F_i > F_target
        neg_list = getimglist_for_train('INRIAPerson/Train/neg/',128,64,0);
        [neg_list, ~, ~] = detect_cascade_samples(samples, bboxes, cascade_classifier);
    end

end