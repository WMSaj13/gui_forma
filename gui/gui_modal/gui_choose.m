function [sel_full_names,sel_codes]=gui_choose(panel_handle,names,indices,codes,nme_str,single)
% % gui_choose v 1.0 (Aug 2008)
% % modal interface that returns selected by user names and codes of variables from
% % the list 
% %
% % [sel_full_names,sel_codes]=gui_choose(panel_handle,names,indices,codes,nme_str,single)
% %  panel_handle - handle to panel where interface or [] - new figure
% %  names, indices, codes - list of short names, indices and codes of
% %  variables
% %  nme_str - if panel_handle is [] this is new figure name
% %  single -  if 0, multiple variables could be selected if 1 only one
% %  sel_full_names, sel_codes - selected variables names and codes 
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

if nargin<6
    single=0;
end

if nargin<5
    nme_str=['gui_choose v. ' num2str(VERSION)];
end

if isempty(panel_handle)
    h=dialog('NumberTitle','Off','Name',nme_str,'Resize','On','MenuBar','None','Visible','Off','Color',[0.925 0.914 0.847],'CloseRequestFcn',@(src,event) close_h(src,event));
else
    set(panel_handle,'Units','pixels');
end


select_vars=gui_select(uipanel('Parent',h),names,indices,codes,'n_indices',5,'field_heigth',100);

if single==0
    set_vars=gui_set(uipanel('Parent',h),{},{},[],'n_fields_x',0,'n_fields_y',4,...
    'name_field_width',550,'name_string','selection','not_editable_color',[1 0.8 0.5]);
    add_var=gui_button_connect_sel_set(select_vars,set_vars,'add');
end

ok_button=uicontrol('Style','pushbutton','String','OK','FontWeight','Bold','Position',[0 0 100 25],'Callback',@(hObject,eventdata) ok_callback(hObject,eventdata));

cancel_button=uicontrol('Style','pushbutton','String','Cancel','FontWeight','Bold','Position',[0 0 100 25]);

if single==0
    set(cancel_button,'Callback',@(hObject,eventdata) cancel_callback_0(hObject,eventdata,set_vars));
else
    set(cancel_button,'Callback',@(hObject,eventdata) cancel_callback_1(hObject,eventdata,select_vars));
end

if single==0
    gui_layout(h,{set_vars {add_var ok_button cancel_button} select_vars},'margin_x',2,'margin_y',2);
else
    gui_layout(h,{{ok_button cancel_button} select_vars},'margin_x',2,'margin_y',2);
end

gui_screen_position(h);
set(h,'Visible','On');

uiwait;

if single==0
    sel_full_names=getappdata(set_vars,'names');
    sel_codes=getappdata(set_vars,'codes');
else
    sel_full_names=getappdata(select_vars,'sel_full_names');
    sel_codes=getappdata(select_vars,'sel_codes'); 
end

delete(h);

function close_h(hObject,eventdata)
uiresume;

function ok_callback(hObject,eventdata)
uiresume;

function cancel_callback_0(hObject,eventdata,set_vars)
setappdata(set_vars,'names',{});
setappdata(set_vars,'codes',[]);
uiresume;

function cancel_callback_1(hObject,eventdata,select_vars)
setappdata(select_vars,'sel_full_names',{});
setappdata(select_vars,'sel_codes',[]); 
uiresume;