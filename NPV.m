function [ present ] = NPV(revenue_matrix)
%this function returns the net present value of a cost structure.
discount_rate=.08;
present=0;
for i=1:length(revenue_matrix)
    present=present+revenue_matrix(i)/(1+discount_rate)^(i-1);
end

end

