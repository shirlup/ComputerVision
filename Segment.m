function [lbls] = Segment(str)
I = imread(str);
lbls = ourSegment(I,false,1);
end
function [labels] = ourSegment(I,noise,count)
    

[Gmag,Gdir] = imgradient(I);
figure(count);
imshow(I);
count = count+1;
figure(count);
[m,n] = size(I);

%------------------------initialization of p_0-------------------

iter = 1;
m_1 = ones(24,m*n);
dir = mod(Gdir,360);
dir = dir./15;
p_0 = ones(24,m*n);
dir = floor(dir);
p_0 = p_0./46;

%-----------------------------------------------------------------
for i =1:m
    for j = 1:n
        p_0( dir(i,j)+1 ,(((i-1)*n)+j)) = 0.5;
    end
end

p_k = p_0;
s_k = update_support(p_0);

%------------------------initialize s_kplus1---------------------
numerator = (p_k.*s_k);
s_numerator = sum(numerator);
denominator = m_1;
for i = 1:n*m
    denominator(:,i) = s_numerator(i)*m_1(:,i);
end
p_kplus1 = numerator./denominator;
%----------------------------------------------------------------
while((norm(p_k-p_kplus1)) > (0.1*10^(-5)) && iter < 1000)
    p_k = p_kplus1;
    numerator= (p_k.*s_k);
    s_numerator = sum(numerator);
    denominator = m_1;
    for i = 1:m*n
        denominator(:,i) = s_numerator(i)*m_1(:,i);
    end
    p_kplus1 = numerator./denominator;
    s_k = update_support(p_kplus1);
    iter = iter + 1;
end


[~,labels] = max(p_k);
labels = reshape(labels,128,128);
labels = labels';
imshow(labels./24);
    if noise==false
    In = imnoise(I,'salt & pepper',0.2);
    ourSegment(In,true,count+1);
    In2 = imnoise(I,'gaussian',0.1,1);
    ourSegment(In2,true,count+3);
    end
%-------------------support--------------------------------------

    function [sMat] = update_support(p_k)
        %convMat = ones(7); %creating kernel
        convMat = fspecial('gaussian', 7,3);
        sMat = zeros(24,m*n);
        for k = 1:24
            v = p_k(k,:);
            matrix = reshape(v,m,n);
            support = conv2(matrix,convMat,'same');
            sMat(k,:) = support(:);
        end
    end
end