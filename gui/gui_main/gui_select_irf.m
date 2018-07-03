function varargout=gui_select_irf(panel_handle,varargin)
% % gui_select_irf v 1.0 (Aug 2008)
% %
% % component for selecting irf
% %
% % panel_handle=gui_select_irf(panel_handle,shock_names_list,shocks_codes_list,'param1_name',param1_value,'param2_name',param2_value...)
% %  creates a new component with given cell array of shocks_names and vector of shock codes parameters
% %
% % panel_handle=gui_select_irf(panel_handle,'refresh')
% % panel_handle=gui_select_irf(panel_handle,'refresh',shock_names_list,shocks_codes_list)
% %  refresh existing component according to its appdata or new given lists
% %  of shocks
% %
% % ---------parameters--------------
% % max_value=1000;            maximum length of IRF
% % callback=[];               function with handle to panel as argument
% %                            called when the irf is changed  
% % ---------------app data----------------
% % callback                   handle to function with panel handle as
% %                            argument
% % shocks_names_list          list of shocks names
% % shocks_codes_list          list of shocks codes 
% % 
% % irf_length                 length of IRF
% % shock_name                 choosen shock name
% % shock_code                 choosen shock code
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.0;

max_value=1000;
callback=[];

if (nargin==2 || nargin==4) & isequal(varargin{1},'refresh')
    
    if nargin==2
        shocks_names_list=getappdata(panel_handle,'shocks_names_list');
        shocks_codes_list=getappdata(panel_handle,'shocks_codes_list');
    else
        shocks_names_list=varargin{2};
        shocks_codes_list=varargin{3};
        setappdata(panel_handle,'shocks_names_list',shocks_names_list);
        setappdata(panel_handle,'shocks_codes_list',shocks_codes_list);
    end
    
    shock_code=getappdata(panel_handle,'shock_code');
    irf_length=getappdata(panel_handle,'irf_length');
    
    shocks_nme=getappdata(panel_handle,'shocks_nme');
    irf_len=getappdata(panel_handle,'irf_len');
    
    if ~isempty(shocks_names_list)
        set(shocks_nme,'String',shocks_names_list);
        
        is_shock_on_list=0;
        for indx=1:length(shocks_codes_list)
            if shocks_codes_list(indx)==shock_code
                set(shocks_nme,'Value',indx);
                is_shock_on_list=1;
                break;
            end
        end
        
        if is_shock_on_list==0
            set(shocks_nme,'Value',1);
            setappdata(panel_handle,'shock_name',shocks_names_list{1});
            setappdata(panel_handle,'shock_code',shocks_codes_list(1));
        end

        set(shocks_nme,'Enable','On');
        
    else
        set(shocks_nme,'String',' ','Enable','Inactive');
    end
    
    gui_value(irf_len,'refresh','value',irf_length);
    
    return;
end

shocks_names_list=varargin{1};
shocks_codes_list=varargin{2};

for idx=3:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

if isempty(panel_handle)
    h=dialog('NumberTitle','Off','Name',['gui_select_irf v. ' num2str(VERSION)],'Resize','Off','MenuBar','None');
    panel_handle=uipanel('Parent',h);
end

irf_len=gui_value(uipanel('Parent',panel_handle),'value',100,'max_value',max_value,'callback',@(hObject,val) change_irf_len(panel_handle,val) );

shocks_nme=uicontrol('Style','popupmenu','Units','Pixels',...
    'BackgroundColor','white','FontWeight','Bold','Position',[0 0 180 30],'Parent',panel_handle,...
    'Callback',@(hObject,eventdata) change_shock(hObject,eventdata,panel_handle));

if ~isempty(shocks_names_list)
    set(shocks_nme,'String',shocks_names_list);
else
    set(shocks_nme,'String',' ','Enable','Inactive');
end

panel_handle=gui_layout(panel_handle,{{shocks_nme irf_len}});

setappdata(panel_handle,'shocks_names_list',shocks_names_list);
setappdata(panel_handle,'shocks_codes_list',shocks_codes_list);

if ~isempty(shocks_names_list)
    setappdata(panel_handle,'shock_name',shocks_names_list{1});
    setappdata(panel_handle,'shock_code',shocks_codes_list(1));
else
    setappdata(panel_handle,'shock_name',' ');
    setappdata(panel_handle,'shock_code',[]);
end
setappdata(panel_handle,'irf_length',100);

setappdata(panel_handle,'shocks_nme',shocks_nme)
setappdata(panel_handle,'irf_len',irf_len)

setappdata(panel_handle,'callback',callback);

varargout{1}=panel_handle;

function change_shock(hObject,eventdata,panel_handle)

shocks_names_list=getappdata(panel_handle,'shocks_names_list');
shocks_codes_list=getappdata(panel_handle,'shocks_codes_list');

n=get(hObject,'Value');

setappdata(panel_handle,'shock_name',shocks_names_list{n});
setappdata(panel_handle,'shock_code',shocks_codes_list(n));

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
    feval(callback,panel_handle);
end

function change_irf_len(panel_handle,val)

setappdata(panel_handle,'irf_length',val);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)
    feval(callback,panel_handle);
end