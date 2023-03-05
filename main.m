% Introduction to Computer Vision Assignment #4 (Final Project)
% < Sliding Window-based Object Detection >
% SNU ECE 2018-14643 김민성

%%
clear;
clc;
%% -----------------  dir setting ----------------------
%directories
images_train_pos_dir = 'INRIAPerson/train_64x128_H96/pos/';
images_train_neg_dir = 'INRIAPerson/Train/neg/';
images_test_pos_dir = 'INRIAPerson/Test/pos/';
annos_test_pos_dir = 'INRIAPerson/Test/annotations/';
%% ------------------------ training ------------------------

h = 128;
w = 64;
[pos_list, npos] = getimglist_for_train(images_train_pos_dir,h,w,1);
[neg_list, nneg] = getimglist_for_train(images_train_neg_dir,h,w,0);
%% positive sample's HOG feature 
pos_feature_list = getHOGs(pos_list,[8 8],[2 2]);
%% negative sample's HOG feature
neg_feature_list = getHOGs(neg_list,[8 8],[2 2]);
%% Train svm
%%dataset setting
X = [pos_feature_list; neg_feature_list];
y = zeros(npos+nneg,1);
y(1:npos) = 1;
%%fitting
svm_model = fitcsvm(X,y,'BoxConstraint',1);
%%
w = svm_model.Beta;
b = svm_model.Bias; 
%% ------------------- Testing ------------------------
%ground truth 정보를 담은 파일을 생성하였다.
write_gt_from_anno(annos_test_pos_dir);
%% detect
tic
[test_bboxes, test_confidences, test_image_ids] = detect(w,b,images_test_pos_dir, 8, [128 64], 10, 0.8, 1);
toc
%% evaluate
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = evaluate_detections(test_bboxes, test_confidences, test_image_ids, 'gt.txt',1);
%%
visualize_detections_by_image(test_bboxes, test_confidences, test_image_ids, tp, fp, images_test_pos_dir, 'gt.txt');












%% --------------------- cascade ---------------------------------------------
blocks = getblocks_bbox();
%% training cascade
cascade_classifier = training_cascade_classifier(pos_list, neg_list, blocks, 0.01, 0.7, 0.9975);
%% detect cascade
tic
[test_bboxes, test_confidences, test_image_ids] = detect_cascade(cascade_classifier,images_test_pos_dir, 8, [128 64], 10, 0.8);
toc
%% evaluate
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = evaluate_detections(test_bboxes, ...
    test_confidences, test_image_ids, 'gt.txt',1);
%%
visualize_detections_by_image(test_bboxes, test_confidences, test_image_ids, tp, fp, images_test_pos_dir, 'gt.txt');












%% ------------------------------------LBP------------------------------------------
pos_feature_list = getLBPs(pos_list);
neg_feature_list = getLBPs(neg_list);
%% Train svm
%%dataset setting
X = [pos_feature_list; neg_feature_list];
y = zeros(npos+nneg,1);
y(1:npos) = 1;

%%fitting
svm_model = fitcsvm(X,y,'BoxConstraint',1);
%%
w = svm_model.Beta;
b = svm_model.Bias; 

%% detect
tic
[test_bboxes, test_confidences, test_image_ids] = detect(w,b,images_test_pos_dir, 8, [128 64], 10, 0.8,2);
toc
%% evaluate
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = evaluate_detections(test_bboxes, ...
    test_confidences, test_image_ids, 'gt.txt',1);
%%
visualize_detections_by_image(test_bboxes, test_confidences, test_image_ids, tp, fp, images_test_pos_dir, 'gt.txt');










%% 추가 구현 ----------------------LBF + HOG--------------------------------
pos_feature_list_H = getHOGs(pos_list,[8 8],[2 2]);
neg_feature_list_H = getHOGs(neg_list,[8 8],[2 2]);
pos_feature_list_L = getLBPs(pos_list);
neg_feature_list_L = getLBPs(neg_list);

%% svm_H
%%dataset setting
X = [pos_feature_list_H; neg_feature_list_H];
y = zeros(npos+nneg,1);
y(1:npos) = 1;
svm_model_H = fitcsvm(X,y,'BoxConstraint',1);

%% svm_L
%%dataset setting
X = [pos_feature_list_L; neg_feature_list_L];
y = zeros(npos+nneg,1);
y(1:npos) = 1;
svm_model_L = fitcsvm(X,y,'BoxConstraint',1);

%%
w_H = svm_model_H.Beta;
b_H = svm_model_H.Bias; 
w_L = svm_model_L.Beta;
b_L = svm_model_L.Bias; 

%%
tic
[test_bboxes, test_confidences, test_image_ids] = detect_myextra(w_H,b_H,w_L,b_L,images_test_pos_dir, 8, [128 64], 10, 0.8);
toc
%% evaluate
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = evaluate_detections(test_bboxes, ...
    test_confidences, test_image_ids, 'gt.txt',1);
%%
visualize_detections_by_image(test_bboxes, test_confidences, test_image_ids, tp, fp, images_test_pos_dir, 'gt.txt');
