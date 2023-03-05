function blocks = getblocks_bbox()
b=[];
for i = 12:2:64
    b=[b; i i;i 2*i];
end
for i = 12:2:32
    b=[b; 2*i i];
end
blocks=[];
n=size(b,1);
for i = 1:n
    if (mod(64-b(i,1), 4)== 0 && mod(128-b(i,2), 4)==0)
        sx = 1:4:64-b(i,1)+1;
        sy = 1:4:128-b(i,2)+1;
        [sp, n_sp] = getStratingPoint(sx,sy);
        for j=1:n_sp
            blocks = [blocks; sp(j,:) sp(j,:)+b(i,:)-[1 1]];
        end
    end
    if (mod(64-b(i,1), 6)==0 && mod(128-b(i,2), 6)==0)
        sx = 1:6:64-b(i,1)+1;
        sy = 1:6:128-b(i,2)+1;
        [sp, n_sp] = getStratingPoint(sx,sy);
        for j=1:n_sp
            blocks = [blocks; sp(j,:) sp(j,:)+b(i,:)-[1 1]];
        end
    end
end
blocks = unique(blocks,'rows');
end
function [sp, n] =getStratingPoint(sx,sy)
nx = size(sx,2);
ny = size(sy,2);
sx = repmat(sx,ny,1);
sx = reshape(sx,[],1);
sy = repmat(sy,1,nx);
sy = reshape(sy,[],1);
sp = [sx sy];
n=nx*ny;
end