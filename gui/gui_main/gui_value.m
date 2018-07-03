function panel_handle=gui_value(panel_handle,varargin)
% % gui_value v 1.0 (Aug 2008)
% %  simple seting the integer value in range with edit field and slider
% %
% % panel_handle=gui_value(panel_handle,'param1_name','param1_val,'param2_name',param2_val...)
% %  creates a new component with given parameters
% %
% % panel_handle=gui_value(panel_handle,'refresh')
% %  refresh component according to its app data
% %
% % panel_handle=gui_value(panel_handle,'refresh','app_data_name',app_data_value)
% %  refresh component according to a input (valid app data name and value) and its app data
% %
% % ---------- app data----------------------
% % value                   value of component
% % min_value               min value of component
% % max_value               max value of componen
% % callback                component callback handle
% %
% % ---------parameters----------------
% % value=5;               initial value
% % min_value=1;           min value
% % max_value=10;          max value
% % 
% % callback=[];           function called after each change with arguments
% %                        handle to gui_set object and gui_set value
% % 
% % val_width=35;          width of edit field
% % val_height=15;         height of edit field
% % slider_height=10;      height of slider 
% % margin=2;              extra margin in interface
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

value=5;
min_value=1;
max_value=10;

callback=[];

val_width=35; 
val_height=15;
slider_height=10;
margin=2;


if nargin==2 && isequal(varargin{1},'refresh')
     
    value=getappdata(panel_handle,'value');
    min_value=getappdata(panel_handle,'min_value');
    max_value=getappdata(panel_handle,'max_value');
    
    slider_handle=getappdata(panel_handle,'slider_handle');
    val_handle=getappdata(panel_handle,'val_handle');
    set(slider_handle,'Min',min_value,'Max',max_value,'Value',value);
    set(val_handle,'String',num2str(value));
    return;
end

if nargin==3 && isequal(varargin{1},'callback')
    setappdata(panel_handle,'callback',varargin{2});
    return;
end

if nargin==4 && isequal(varargin{1},'refresh')
    
    isappdata(panel_handle,varargin{2});
    setappdata(panel_handle,varargin{2},varargin{3});
 
    value=getappdata(panel_handle,'value');
    min_value=getappdata(panel_handle,'min_value');
    max_value=getappdata(panel_handle,'max_value');
    
    slider_handle=getappdata(panel_handle,'slider_handle');
    val_handle=getappdata(panel_handle,'val_handle');
    set(slider_handle,'Min',min_value,'Max',max_value,'Value',value);
    set(val_handle,'String',num2str(value));
    return;
end


for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_value v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [0 0 2*margin+2*val_height+val_width+1 2*margin+val_height+slider_height+1]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');
    pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',...
        [pos_tmp(1) pos_tmp(2)  2*margin+2*val_height+val_width+1 2*margin+val_height+slider_height+1]);
end

val_handle=uicontrol('Style','Edit','Parent',panel_handle,'FontWeight','Bold','BackgroundColor','white','String',num2str(value),'Position',[margin+val_height margin+slider_height+1 val_width val_height]);

minus_handle=uicontrol('Style','Pushbutton','Parent',panel_handle,'String','-','FontWeight','Bold','Position',[margin margin+slider_height+1 val_height val_height],'FontWeight','Bold');
plus_handle=uicontrol('Style','Pushbutton','Parent',panel_handle,'String','+','FontWeight','Bold','Position',[margin+val_height+val_width margin+slider_height+1 val_height val_height],'FontWeight','Bold');
slider_handle=uicontrol('Style','Slider','Parent',panel_handle,'Position',[margin margin 2*val_height+val_width slider_height],'Min',min_value,'Max',max_value,'Value',value,'SliderStep',(1/(max_value-min_value))*[1 1]);


set(val_handle,'Callback',@(hObject,eventdata) set_val(hObject,eventdata,panel_handle,slider_handle))
set(plus_handle,'Callback',@(hObject,eventdata) plus_val(hObject,eventdata,panel_handle,val_handle,slider_handle))
set(minus_handle,'Callback',@(hObject,eventdata) minus_val(hObject,eventdata,panel_handle,val_handle,slider_handle))
set(slider_handle,'Callback',@(hObject,eventdata) slider_val(hObject,eventdata,panel_handle,val_handle))


setappdata(panel_handle,'value',value);
setappdata(panel_handle,'min_value',min_value);
setappdata(panel_handle,'max_value',max_value);
setappdata(panel_handle,'callback',callback);

setappdata(panel_handle,'slider_handle',slider_handle);
setappdata(panel_handle,'val_handle',val_handle);

function set_val(hObject,eventdata,panel_handle,slider_handle)

value=getappdata(panel_handle,'value');
min_value=getappdata(panel_handle,'min_value');
max_value=getappdata(panel_handle,'max_value');

new_value=str2double(get(hObject,'String'));
if isempty(new_value) 
    new_value=value;
end

value=max(min(new_value,max_value),min_value);

set(hObject,'String',num2str(value));
set(slider_handle,'Value',value);

setappdata(panel_handle,'value',value);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
       feval(callback,panel_handle,value);
end

function plus_val(hObject,eventdata,panel_handle,val_handle,slider_handle)

value=getappdata(panel_handle,'value');
max_value=getappdata(panel_handle,'max_value');

value=min(value+1,max_value);

set(val_handle,'String',num2str(value));
set(slider_handle,'Value',value);

setappdata(panel_handle,'value',value);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
       feval(callback,panel_handle,value);
end

function minus_val(hObject,eventdata,panel_handle,val_handle,slider_handle)

value=getappdata(panel_handle,'value');
min_value=getappdata(panel_handle,'min_value');

value=max(value-1,min_value);

set(val_handle,'String',num2str(value));
set(slider_handle,'Value',value);

setappdata(panel_handle,'value',value);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
       feval(callback,panel_handle,value);
end

function slider_val(hObject,eventdata,panel_handle,val_handle)

value=round(get(hObject,'Value'));
set(val_handle,'String',num2str(value));

setappdata(panel_handle,'value',value);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
       feval(callback,panel_handle,value);
end