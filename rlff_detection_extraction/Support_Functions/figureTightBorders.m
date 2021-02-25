function [ax] = figureTightBorders(ax)
% grab current axes and make tight borders, in preparation for figure
% publication:
% input - nothing, assuming gca works in function?
% output: ax
% ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax_height = ax_height * 0.98;
ax_width = ax_width * 0.98;  % was .98 (21/02/25) % 99
ax.Position = [left bottom ax_width ax_height];