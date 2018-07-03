function panel_handle=gui_tabs(panel_handle,tabs_handles,varargin)
% % tabs for matlab v 1.0 (Aug 2008)
% %
% % panel_handle=gui_tabs(panel_handle,tabs_handles,'param1_name',param1_value,'param2_name',param2_value...)
% % panel_handle - gui_tabs object handle
% % tabs_handles - array cell with each tab handle
% %
% % ---------parameters-------------
% % tabs_names_loc=1;                       location of names : 0 or 1 (top/bottom or left/right) 
% % tabs_names_pos=1;                       position of names : 0 or 1 (depends on location)
% % 
% % active_fgcolor='black';                 active tab name color
% % nonactive_fgcolor=[0.25 0.25 0.25];     non-active tab name color
% % active_bgcolor=[0.91 0.90 0.83];        active tab color
% % nonactive_bgcolor=[0.86 0.85 0.78];     non-active tab color
% % panel_color=[0.91 0.90 0.83];           panel color
% % 
% % margin_x=5;          extra x-margin of each tab
% % margin_y=5;          extra y-margin of each tab
% % margin_x_out=5;      extra x-margin of the whole gui
% % margin_y_out=5;      extra y-margin of the whole gui
% % tabs_names_sep=3;    separator between tabs names
% % 
% % tabs_names_heights   height of tabs names 
% % tabs_names_widths    widths of tabs names 
% % tabs_names_strings   names of tabs
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

%aux value
n_tabs=length(tabs_handles);


%params
tabs_names_loc=1;
tabs_names_pos=1;

active_fgcolor='black';
nonactive_fgcolor=[0.25 0.25 0.25];
active_bgcolor=[0.91 0.90 0.83];
nonactive_bgcolor=[0.86 0.85 0.78];
panel_color=[0.91 0.90 0.83];

margin_x=5;
margin_y=5;
margin_x_out=5;
margin_y_out=5;
tabs_names_sep=3;

tabs_names_heights(1:n_tabs)=22;
tabs_names_widths(1:n_tabs)=100;
tabs_names_strings(1:n_tabs)={''};

for idx=1:2:nargin-2
    eval([varargin{idx} '= varargin{idx+1};']);
end

if (isempty(panel_handle))
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_tabs v. ' num2str(VERSION)],'MenuBar','None');
    panel_handle=uipanel('Parent',h);
end

set(panel_handle,'Units','Pixels','BackgroundColor',panel_color,'BorderType','beveledin');

colors_cl={active_fgcolor,nonactive_fgcolor,active_bgcolor,nonactive_bgcolor};

new_tabs=[];w=zeros(1,n_tabs);h=zeros(1,n_tabs);
pos=zeros(n_tabs,4);

for indx=1:n_tabs
    if isempty(tabs_handles{indx})
        tabs_handles{indx}=uipanel('Parent',panel_handle,'Units','Pixels','Position',[0 0 1 1],'Visible','Off');
        new_tabs=[new_tabs indx];
    else
        set(tabs_handles{indx},'Units','pixels','Visible','Off');
    end
    pos(indx,:)=getpixelposition(tabs_handles{indx});
    w(indx)=pos(indx,3);h(indx)=pos(indx,4);
end
max_w=max(w)+2*margin_x;max_h=max(h)+2*margin_y;

pos_tmp=getpixelposition(panel_handle);
setpixelposition(panel_handle,[pos_tmp(1:2) max_w+2*margin_x_out+2*margin_x+(1-tabs_names_loc)*max(tabs_names_widths) max_h+2*margin_y_out+2*margin_y+tabs_names_loc*max(tabs_names_heights)]);

for indx=1:length(new_tabs)
    setpixelposition(tabs_handles{new_tabs(indx)},[0 0 max_w max_h]);
    pos(new_tabs(indx),:)=[0 0 max_w-2*margin_x max_h-2*margin_y];
end

tabs_buttons_handles=zeros(1,n_tabs);
for indx=1:n_tabs    
    tabs_buttons_handles(indx)=uicontrol('Parent',panel_handle,'Style','pushbutton','String',tabs_names_strings{indx},'Position',...
        [margin_x_out+tabs_names_loc*(indx*tabs_names_sep+sum(tabs_names_widths(1:indx-1)))+(1-tabs_names_loc)*((1-tabs_names_pos)*(margin_x+max_w)+tabs_names_pos*(max(tabs_names_widths)-tabs_names_widths(indx)))...
         margin_y_out+tabs_names_loc*(tabs_names_pos*(margin_y+max_h)-1*(1-tabs_names_pos))+(1-tabs_names_loc)*(max_h-tabs_names_heights(indx)-(indx*tabs_names_sep+sum(tabs_names_heights(1:indx-1))))...
         tabs_names_widths(indx) tabs_names_heights(indx)],'UserData',indx);
end

tabs_bg=uipanel('Parent',panel_handle,'Units','Pixels','Position',...
    [margin_x_out+(1-tabs_names_loc)*tabs_names_pos*max(tabs_names_widths) margin_y_out+tabs_names_loc*(1-tabs_names_pos)*max(tabs_names_heights) margin_x+max_w margin_y+max_h],'BorderType','beveledout','BackgroundColor',active_bgcolor);

text_mask_handles=zeros(1,n_tabs);
for indx=1:n_tabs 
    tmp_pos=getpixelposition(tabs_buttons_handles(indx));
    text_mask_handles(indx)=uicontrol('Parent',panel_handle,'Style','text','Position',...
        [tmp_pos(1)+(1-tabs_names_loc)*(tabs_names_pos*(tabs_names_widths(indx)-2)+(1-tabs_names_pos)*(-2)) ...
         tmp_pos(2)+(1-tabs_names_loc)*2+tabs_names_loc*(tabs_names_pos*(-2)+(1-tabs_names_pos)*(max(tabs_names_heights)-2)) ...
         tabs_names_loc*(tabs_names_widths(indx)-2)+(1-tabs_names_loc)*4 ...
         tabs_names_loc*4+(1-tabs_names_loc)*(tabs_names_heights(indx)-2)],...
        'BackgroundColor',panel_color,'Visible','Off');
end

tabed_panels_handles=zeros(1,n_tabs);
for indx=1:n_tabs
    tabed_panels_handles(indx)=tabs_handles{indx};
    set(tabed_panels_handles(indx),'Parent',tabs_bg,'Position',[(max_w-pos(indx,3))/2 (max_h-pos(indx,4))/2 pos(indx,3:4)])
end

set(tabs_buttons_handles,'BackgroundColor',nonactive_bgcolor,'SelectionHighlight','Off','ForegroundColor',nonactive_fgcolor,...
        'FontWeight','Bold','Callback',@(hObject,eventdata) switch_tabs(hObject,eventdata,panel_handle,tabed_panels_handles,...
        tabs_buttons_handles,text_mask_handles,colors_cl));

set(tabs_buttons_handles(1),'BackgroundColor',active_bgcolor,'ForegroundColor',active_fgcolor,'FontWeight','Bold');
set(tabed_panels_handles(1),'Visible','On');
set(text_mask_handles(1),'Visible','On');

setappdata(panel_handle,'tabed_panels_handles',tabed_panels_handles)
setappdata(panel_handle,'tabs_buttons_handles',tabs_buttons_handles)
setappdata(panel_handle,'text_mask_handles',text_mask_handles)


function switch_tabs(hObject,eventdata,panel_handle,tabed_panels_handles,tabs_buttons_handles,text_mask_handles,colors_cl)
    
    active_tab=get(hObject,'UserData');
    
    active_fgcolor=colors_cl{1};
    nonactive_fgcolor=colors_cl{2};
    active_bgcolor=colors_cl{3};
    nonactive_bgcolor=colors_cl{4};
    
    set(text_mask_handles,'Visible','Off');
    set(tabed_panels_handles,'Visible','Off');
    set(tabs_buttons_handles,'BackgroundColor',nonactive_bgcolor,'ForegroundColor',nonactive_fgcolor);
    
    set(text_mask_handles(active_tab),'Visible','On');
    set(tabed_panels_handles(active_tab),'Visible','On');
    set(tabs_buttons_handles(active_tab),'BackgroundColor',active_bgcolor,'ForegroundColor',active_fgcolor);