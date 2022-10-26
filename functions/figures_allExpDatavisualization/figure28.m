figure
im = image(coeffsLM(find(baseSelect),:,4));
% imshow(coeffsLM(find(baseSelect),:,4), [])
% colorMap = [linspace(0,1,256)', zeros(256,2)];
% colorMap = [linspace(1,0,10)', zeros(10,2)];

colorMap = flipud(hot);
colorMap(14:end,:,:) = repmat(colorMap(end,:,:), [size(colorMap,1)-14+1,1]);
colormap(colorMap)
im.CDataMapping = 'scaled';
colorbar
