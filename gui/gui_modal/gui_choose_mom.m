function [sel_full_names,sel_codes,sel_values]=gui_choose_mom(panel_handle,names,indices,codes,nme_str)
% % gui_choose v 1.0 (Aug 2008)
% % modal interface that returns selected by user names and codes and description of variables 
% % moments from the list 
% %
% % [sel_full_names,sel_codes,sel_values]=gui_choose_mom(panel_handle,names,indices,codes,nme_str)
% %
% % panel_handle - handle to panel where interface or [] - new figure
% % names, indices, codes - list of short names, indices and codes of
% % variables
% % nme_str - if panel_handle is [] this is new figure name 
% % sel_full_names, sel_codes - selected variables names and codes
% % sel_values - cell array with description of selected moment
% %  sel_values{1} - string with type of moment 
% %  sel_values{2} - base_var name or '' if N/A
% %  sel_values{3} - vectors with lags or [] if N/A
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

if nargin<5
    nme_str=['gui_choose_mom v. ' num2str(VERSION)];
end

if isempty(panel_handle)
    h=dialog('NumberTitle','Off','Name',nme_str,'Resize','On','MenuBar','None','Visible','Off','Color',[0.925 0.914 0.847],'CloseRequestFcn',@(src,event) close_h(src,event));
else
    set(panel_handle,'Units','pixels');
end

select_vars=gui_select(uipanel('Parent',h),names,indices,codes,'n_indices',5,'field_heigth',100);

set_vars=gui_set(uipanel('Parent',h),{},{},[],'n_fields_x',3,'n_fields_y',4,...
    'name_field_width',100,'name_string','variable','value_string',{'moment','base var','lag'},'not_editable',1:3,'not_editable_color',[1 0.8 0.5]);

sel_mom=gui_select_moment(uipanel('Parent',h),'base_var_select',@() gui_choose([],names,indices,codes,'select base variable:',1));

add_var=gui_button_connect_sel_set(select_vars,set_vars,'add','val_func',@(sel_names,sel_codes) add_mom(sel_names,sel_codes,sel_mom));

ok_button=uicontrol('Style','pushbutton','String','OK','FontWeight','Bold','Position',[0 0 100 25],'Callback',@(hObject,eventdata) ok_callback(hObject,eventdata));
cancel_button=uicontrol('Style','pushbutton','String','Cancel','FontWeight','Bold','Position',[0 0 100 25],'Callback',@(hObject,eventdata) cancel_callback(hObject,eventdata,set_vars));

gui_layout(h,{set_vars { add_var ok_button cancel_button} sel_mom select_vars},'margin_x',2,'margin_y',2);
gui_screen_position(h);
set(h,'Visible','On');

uiwait;

sel_full_names=getappdata(set_vars,'names');
sel_values=getappdata(set_vars,'values');
sel_codes=getappdata(set_vars,'codes');

delete(h);

function close_h(hObject,eventdata)
uiresume;

function ok_callback(hObject,eventdata)
uiresume;

function cancel_callback(hObject,eventdata,set_vars)
setappdata(set_vars,'names',{});
setappdata(set_vars,'codes',[]);
uiresume;

function output=add_mom(sel_names,sel_codes,sel_mom)

moment_type=getappdata(sel_mom,'moment');

k1=getappdata(sel_mom,'k1');
k2=getappdata(sel_mom,'k2');

base_var_name=getappdata(sel_mom,'base_var_name');
base_var_code=getappdata(sel_mom,'base_var_code');

if  (isequal(moment_type,'REL_STD') || isequal(moment_type,'REG') || isequal(moment_type,'CORR')) && isequal(base_var_name,'')  
        output=[];return;
end

for indx=1:length(sel_codes)
    output{indx}{1}=moment_type;
    if (isequal(moment_type,'REL_STD') || isequal(moment_type,'REG') || isequal(moment_type,'CORR'))
        output{indx}{2}=base_var_name;
        output{indx}{4}=base_var_code;
    else
        output{indx}{2}='';
        output{indx}{4}=0;
    end

    if (isequal(moment_type,'AUT') || isequal(moment_type,'CORR'))
        output{indx}{3}=[k1:k2];
    else
        output{indx}{3}=[];
    end

end