function classFrames = ClassifyFBP(V,f)

[nFrames,R,C,B] = size(V);
classFrames = zeros(nFrames,R,C);

for i = 1:nFrames
    I = squeeze(V(i,:,:,:));
    J = reshape(I,[R*C B]);
    r = repmat((1:R)',[C 1]);
    T = [J r];
    fbpClasses = f.predictFcn(T);
    classFrames(i,:,:) = reshape(fbpClasses,[R C]);
end

end