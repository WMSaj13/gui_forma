function gui_screen_position(panel_handle,alig_x,alig_y)
% % gui_screen_position v 1.0 (Aug 2008)
% %
% % gui_screen_position(panel_handle,alig_x,alig_y)
% %
% %  allign figure on the screen (assuming the size of figure is smaller
% %  than a screen)
% %  panel_handle - alligned figure handle
% %  alig_x - x axis alligment 'left','middle' or 'right', default 'middle'
% %  alig_y - y axis alligment 'bottom','middle' or 'top', default 'middle'
% %
% % ------------W.M.Saj 2008--------------------------

if nargin==1
    alig_x='middle';
    alig_y='middle';
end

screen_size = get(0,'ScreenSize');
sx=screen_size(3);sy=screen_size(4);

panel_size = getpixelposition(panel_handle);
px=panel_size(3);py=panel_size(4);

switch alig_x 
    case 'middle'
        ppx=(sx-px)/2;
    case 'left'
        ppx=1;
    case 'right'
        ppx=sx-px-1;
end

switch alig_y 
    case 'middle'
        ppy=(sy-py)/2;
    case 'bottom'
        ppy=1;
    case 'top'
        ppy=sy-py-1;
end

setpixelposition(panel_handle,[ppx ppy px py]);