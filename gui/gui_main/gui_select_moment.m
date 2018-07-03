function varargout=gui_select_moment(panel_handle,varargin)
% % gui_select_moment v 1.0 (Aug 2008)
% %
% % component for selecting moment of variable
% %
% % panel_handle=gui_select_moment(panel_handle,'param1_name',param1_value,'param2_name',param2_value...)
% %  creates a new component with given parameters
% %
% % ---------paramaters--------------
% % max_value=10;                  max value of lag
% % base_var_select=[];            callback to function returning base_var
% % 
% % base_var_name='';              start base_var_name
% % base_var_code=[];              start base_var code
% % 
% % k1=0;                          start min added lag in moment
% % k2=0;                          start max added lag in moment
% % 
% % callback=[];                   handle to function with panel handle as
% %                                argument
% %
% % ---------------app data----------------
% % as parameters above with the same meaning
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

max_value=10;
base_var_select=[];

base_var_name='';
base_var_code=[];

k1=0;
k2=0;


for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_select_moments v. ' num2str(VERSION)],'Resize','Off','MenuBar','None');
    pos=getpixelposition(h);
    setpixelposition(h,[pos(1:2) 510 45]);
    panel_handle=uipanel('Parent',h);
end

pos=getpixelposition(panel_handle);
setpixelposition(panel_handle,[pos(1:2) 510 45]);

moment_back_len=gui_value(uipanel('Parent',panel_handle),'value',0,'min_value',-max_value,'max_value',max_value,'callback',@(hObject,val) change_k('k1',val,panel_handle));
moment_forward_len=gui_value(uipanel('Parent',panel_handle),'value',0,'min_value',-max_value,'max_value',max_value,'callback',@(hObject,val) change_k('k2',val,panel_handle));
set([moment_back_len,moment_forward_len],'Visible','Off');

pos=get(moment_back_len,'Position');set(moment_back_len,'Position',[315 3 pos(3:4)]);
pos=get(moment_back_len,'Position');set(moment_forward_len,'Position',[410 3 pos(3:4)]);

base_var=uicontrol('Style','pushbutton','Parent',panel_handle,'Visible','Off','FontWeight','Bold','FontAngle','Italic',...
    'String','base var not selected','Position',[100 7 200 25],'Callback',@(hObject,eventdata) choose_base_var(hObject,eventdata,panel_handle));

uicontrol('Style','popupmenu','Units','Pixels','String',{'STD','REL_STD','AUT','CORR','REG'},...
    'BackgroundColor','white','FontWeight','Bold','Position',[10 0 80 30],'Parent',panel_handle,...
    'Callback',@(hObject,eventdata) change_moment_type(hObject,eventdata,panel_handle,[moment_back_len moment_forward_len base_var]));

setappdata(panel_handle,'moment','STD');

setappdata(panel_handle,'base_var_name',base_var_name);
setappdata(panel_handle,'base_var_code',base_var_code);

setappdata(panel_handle,'k1',k1);
setappdata(panel_handle,'k2',k2);

setappdata(panel_handle,'base_var_select',base_var_select);

varargout{1}=panel_handle;

function change_moment_type(hObject,eventdata,panel_handle,uicontrols_handles)

mom_names=get(hObject,'String');
mom_type=mom_names{get(hObject,'Value')};

switch mom_type
    case 'STD'
        set(uicontrols_handles,'Visible','Off');
    case {'REL_STD', 'REG'}
        set(uicontrols_handles(1:2),'Visible','Off');
        set(uicontrols_handles(3),'Visible','On');
    case 'AUT'
        set(uicontrols_handles(1:2),'Visible','On');
        set(uicontrols_handles(3),'Visible','Off');        
    case 'CORR'
        set(uicontrols_handles,'Visible','On');
end

setappdata(panel_handle,'moment',mom_type);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
    feval(callback,panel_handle);
end

function choose_base_var(hObject,eventdata,panel_handle)

base_var_select=getappdata(panel_handle,'base_var_select');

if isempty(base_var_select)
    return
end

[var_name,var_code]=feval(base_var_select);

if isempty(var_name)
    return
end

set(hObject,'String',var_name);

setappdata(panel_handle,'base_var_name',var_name);
setappdata(panel_handle,'base_var_code',var_code);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
    feval(callback,panel_handle);
end

function change_k(k_string,val,panel_handle)

setappdata(panel_handle,k_string,val);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
    feval(callback,panel_handle);
end