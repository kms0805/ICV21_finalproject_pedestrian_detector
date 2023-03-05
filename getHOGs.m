function features = getHOGs(imglist,cellsize,blocksize)
n = size(imglist,1);
feature_size = size(extractHOGFeatures(imglist{1},'CellSize',cellsize, 'BlockSize', blocksize),2);
features = zeros(n,feature_size);
for i = 1:n
   features(i,:) = extractHOGFeatures(imglist{i},'CellSize',cellsize, 'BlockSize', blocksize);
end
end