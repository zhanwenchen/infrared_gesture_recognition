function tabl = getTrainingData(V,frames,bedRect,floorRect,persRect)

nFrames = length(frames);

% floor area
fur = floorRect(1);
flr = floorRect(2);
flc = floorRect(3);
frc = floorRect(4);
fr = flr-fur+1;
fc = frc-flc+1;

% bed area
bur = bedRect(1);
blr = bedRect(2);
blc = bedRect(3);
brc = bedRect(4);
br = blr-bur+1;
bc = brc-blc+1;

% person area
pur = persRect(1);
plr = persRect(2);
plc = persRect(3);
prc = persRect(4);
pr = plr-pur+1;
pc = prc-plc+1;


floorData = zeros(nFrames,fr,fc,3);
bedData = zeros(nFrames,br,bc,3);
persData =  zeros(nFrames,pr,pc,3);

for n=1:nFrames    
    floorData(n,:,:,:) = V(frames(n),fur:flr,flc:frc,:);
    bedData(n,:,:,:) = V(frames(n),bur:blr,blc:brc,:);
    persData(n,:,:,:) = V(frames(n),pur:plr,plc:prc,:);
end

fD = reshape(floorData,[nFrames*fr*fc 3]);
fR = repmat((fur:flr)',[nFrames*fc 1]);
bD = reshape(bedData,[nFrames*br*bc 3]);
bR = repmat((bur:blr)',[nFrames*bc 1]);
pD = reshape(persData,[nFrames*pr*pc 3]);
pR = repmat((pur:plr)',[nFrames*pc 1]);

labs = [1*ones(size(fD,1),1);  2*ones(size(bD,1),1) ; 3*ones(size(pD,1),1)];

tabl = [[fD;bD;pD] [fR;bR;pR] labs];

end
