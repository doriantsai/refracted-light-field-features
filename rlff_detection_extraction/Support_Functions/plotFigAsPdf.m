function plotFigAsPdf(h,saveFilename)

h.Units = 'Inches';
pos = h.Position;
h.PaperPositionMode='Auto';
h.PaperUnits = 'Inches';
h.PaperSize = [pos(3), pos(4)];
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,saveFilename,'-dpdf','-r0')
