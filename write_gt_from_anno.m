function write_gt_from_anno(annodir)
delete('gt.txt');
files = dir(annodir);
files = files(3:end);
n = size(files,1);
fileID = fopen('gt.txt','w');
for i = 1:n
    record = info_from_anno([annodir,files(i).name]);
    nobj = length(record.objects);
    for j = 1:nobj
        name = record.imgname;
        bbox = record.objects(j).bbox;
        fprintf(fileID, '%s %d %d %d %d\n', name(10:end) , bbox);
    end
end
fclose(fileID);
end