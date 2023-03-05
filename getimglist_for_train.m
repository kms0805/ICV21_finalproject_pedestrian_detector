function [imglist, n] = getimglist_for_train(file_dir,h,w,is_pos)
files = dir(file_dir);
files = files(3:end);
if(is_pos == 1)
    n = size(files,1);
    imglist = cell(n,1);
    for i = 1:n
      img = imread([file_dir,files(i).name]);
        img = rgb2gray(img);
        r = centerCropWindow2d(size(img),[h w]);
        img = imcrop(img,r);
        imglist{i} = img;
    end
else
    n = size(files,1)*10;
    ni = 1;
    imglist = cell(n,1);
    for j = 1:size(files,1)
        img = imread([file_dir,files(j).name]);
        img = rgb2gray(img);
        for i =1:10
           %random crop
           r = randomCropWindow2d(size(img),[h w]); 
           img = imcrop(img,r);
           imglist{ni} = img; 
           ni = ni + 1;
        end
    end   
end
end