function record = info_from_anno(filename)
fd = fopen(filename,'rt');

record.imgname = [];
record.objects.bbox = [];
namestr = 'Image filename : %q';
bboxstr = 'Bounding box for object %d "PASperson" (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)';
notEOF=1;
while(notEOF)
    line=fgetl(fd);
    notEOF=ischar(line);
    if(strncmp(line,namestr,14))
        name = strread(line,namestr);
        record.imgname = char(name);
    end
    if(strncmp(line,bboxstr,8))
        [obj,xmin,ymin,xmax,ymax] = strread(line,bboxstr);
        record.objects(obj).bbox = [xmin ymin xmax ymax];
    end
end
fclose(fd);    
end