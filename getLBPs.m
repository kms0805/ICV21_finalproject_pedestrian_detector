function features = getLBPs(imglist)
n = size(imglist,1);
feature_size = size(extractLBPFeatures(imglist{1},'CellSize',[6 12]),2);
features = zeros(n,feature_size);
for i = 1:n
   features(i,:) = extractLBPFeatures(imglist{i},'CellSize',[6 12]);
end
end