function [hAxHyp,cbSlope] = PlotColorbar(hAxIm,scale,shift,colorLim,MapofColor)

minColor = colorLim(1);
maxColor = colorLim(2);

hAxHyp = axes;
axis(hAxHyp,'off');
cbSlope = colorbar(hAxHyp,'Location','eastoutside');
hAxHyp.XLim = hAxIm.XLim;
hAxHyp.XTick = hAxIm.XTick;
hAxHyp.YLim = hAxIm.YLim;
hAxHyp.YTick = hAxIm.YTick;
hAxHyp.Position = hAxIm.Position;
hAxHyp.OuterPosition = hAxIm.OuterPosition;
colormap(hAxHyp,MapofColor);
% minColorSlope = round(minErr);
% maxColorSlope = round(maxErr);
caxis(hAxHyp,[minColor maxColor]);
uistack(hAxIm,'top');
% scale = 0.8;
cbSlope.Position(3) = cbSlope.Position(3)*scale;
% shift = 0.015;
cbSlope.Position(1) = cbSlope.Position(1) -shift;