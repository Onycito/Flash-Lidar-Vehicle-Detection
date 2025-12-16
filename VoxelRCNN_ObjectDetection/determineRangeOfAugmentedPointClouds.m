
XLIM = cellfun(@(x) x.XLimits, a(:,1), UniformOutput=false);
XLIMM = cell2mat(XLIM);
XLim = [min(XLIMM(:,1)), max(XLIMM(:,2))]

XLIM = cellfun(@(x) x.YLimits, a(:,1), UniformOutput=false);
XLIMM = cell2mat(XLIM);
YLim = [min(XLIMM(:,1)), max(XLIMM(:,2))]

XLIM = cellfun(@(x) x.ZLimits, a(:,1), UniformOutput=false);
XLIMM = cell2mat(XLIM);
ZLim = [min(XLIMM(:,1)), max(XLIMM(:,2))]

%%

xbox = cellfun(@(x) [x(:,1), x(:,1)+x(:,4)], a(:,2), UniformOutput=false);
xboxM = cell2mat(xbox);
XboxLim = [min(xboxM(:,1)), max(xboxM(:,2))]

xbox = cellfun(@(x) [x(:,2), x(:,2)+x(:,5)], a(:,2), UniformOutput=false);
xboxM = cell2mat(xbox);
YboxLim = [min(xboxM(:,1)), max(xboxM(:,2))]

xbox = cellfun(@(x) [x(:,3), x(:,3)+x(:,6)], a(:,2), UniformOutput=false);
xboxM = cell2mat(xbox);
ZboxLim = [min(xboxM(:,1)), max(xboxM(:,2))]