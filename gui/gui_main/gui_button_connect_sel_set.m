function handle=gui_button_connect_sel_set(sel_handle,set_handle,operation,varargin)
% % gui_button_connect_sel_set v 1.0 (Aug 2008)
% % componets providing simple interaction between component gui_select
% % and gui_set
% %
% % handle=gui_button_connect_sel_set(sel_handle,set_handle,operation,'param1_name',param1_val,'param2_name',param2_val...)
% %  create a new button with the same paramaters as uicontrol pushbutton
% %  and extra parameters as above joining gui_select and gui_set components
% %  given by handle, operation  argument sets the interaction 'add' add selected 
% %  values with values given by val_func, 'add
% %  single' add only if name is not included in gui_set before, 'remove'
% %  removes element with selected names from gui_set
% %
% % -----parameter and app data---------------
% % 
% % val_func     handle to function values=val_func(val_func(sel_names,sel_codes)
% %              that with given selected names and codes from the
% %              gui_select creates value cell array that fits the gui_set component
% %              object
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

val_func=[];

arg_narg=[];arg_varg=[];
for idx=1:2:nargin-3
    if isequal(varargin{idx},'val_func')
        val_func=varargin{idx+1};
    else
        arg_narg=[arg_narg varargin(idx)];
        arg_varg=[arg_varg varargin(idx+1)];
    end
end

if ~isempty(arg_narg)
    handle=uicontrol('Style','pushbutton','FontWeight','Bold','Position',[0 0 200 25],'String',operation,arg_narg,arg_varg);
else
    handle=uicontrol('Style','pushbutton','FontWeight','Bold','Position',[0 0 200 25],'String',operation);
end

if isequal(operation,'add')
    set(handle,'Callback',@(hObject,eventdata) hcallback_add(hObject,eventdata,sel_handle,set_handle));
end

if isequal(operation,'add single')
    set(handle,'Callback',@(hObject,eventdata) hcallback_add_single(hObject,eventdata,sel_handle,set_handle));
end

if isequal(operation,'remove')
    set(handle,'Callback',@(hObject,eventdata) hcallback_remove(hObject,eventdata,sel_handle,set_handle));
end

setappdata(handle,'val_func',val_func);

function hcallback_add(hObject,eventdata,sel_handle,set_handle)

sel_names=getappdata(sel_handle,'sel_full_names');
sel_codes=getappdata(sel_handle,'sel_codes');

if isempty(sel_names)
    return
end

val_func=getappdata(hObject,'val_func');

val_cl={};
if ~isempty(val_func)
    val_cl=val_func(sel_names,sel_codes);
    if isempty(val_cl)
        return
    end
end

gui_set(set_handle,'add',sel_names,val_cl,sel_codes);

function hcallback_add_single(hObject,eventdata,sel_handle,set_handle)

sel_names=getappdata(sel_handle,'sel_full_names');
sel_codes=getappdata(sel_handle,'sel_codes');

if isempty(sel_names)
    return
end

val_func=getappdata(hObject,'val_func');

val_cl={};
if ~isempty(val_func)
    val_cl=val_func(sel_names,sel_codes);
    if isempty(val_cl)
        return
    end
end

gui_set(set_handle,'add',sel_names,val_cl,sel_codes,'single');

function hcallback_remove(hObject,eventdata,sel_handle,set_handle)

sel_names=getappdata(sel_handle,'sel_full_names');

if isempty(sel_names)
    return
end

gui_set(set_handle,'remove',sel_names);