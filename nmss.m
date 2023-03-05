function [valid] = nmss(bboxes, confidences)
[confidences, ind] = sort(confidences, 'descend');
bboxes = bboxes(ind,:);
is_valid = ones(1,size(bboxes,1));
for i = 1:size(bboxes,1)
    bb1 = bboxes(i,:);
    for j=find(is_valid)
        if i<j
            bb2 = bboxes(j,:);
            %iou가 0.3이상이면 기각
            if(getIOU(bb1,bb2)>0.3)
                is_valid(1,j) = 0;
            end
        end       
    end  
end
rev(ind) = 1:size(bboxes,1);
valid = logical(is_valid(rev));
end

function f = getIOU(bb1, bb2)
bi=[max(bb1(1),bb2(1)); max(bb1(2),bb2(2)); min(bb1(3),bb2(3)); min(bb1(4),bb2(4))];
iw=bi(3)-bi(1)+1;
ih=bi(4)-bi(2)+1;
if(iw>0 && ih>0)
    a = (bb1(3)-bb1(1)+1)*(bb1(4)-bb1(2)+1)+(bb2(3)-bb2(1)+1)*(bb2(4)-bb2(2)+1);
    f = iw*ih/(a-iw*ih);
else
    f = 0;
end
end