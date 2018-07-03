function varargout=gui_select(varargin)
% % Graphical User Interface Selector for indexed names v 1.1 (Nov 2008)
% %
% % panel_handle=gui_select(panel_handle,names,indices,codes)  
% %  creates a new gui_select interface filled with names, indices, codes returning a
% %  handle to gui_select panel ; if panel_handle is empty figure including
% %  new panel is created
% %  any data can be than accesed with getappdata and setappdata (list of
% %  fields below)
% %
% % panel_handle=gui_select(panel_handle,names,indices,codes,'param1','param1_value', 'param2','param2_value')
% %  create and sets the gui_select params (see list below)
% %
% % gui_select(panel_handle,'refresh') 
% %  refresh existing GUI according to data included with setappdata
% %
% % gui_select(panel_handle,'refresh',names,indices,codes)  
% %  refresh existing GUI with data given as parameters
% %
% % gui_select(panel_handle,'call_func',call_func)
% %  sets the callback of gui_select (called after each change) 
% %   accept handle to one argument function : call_func(h) where h 
% %    is a handle to gui_select caller gui  
% % 
% % gui_select(panel_handle,'state',state)  
% %  set state of existing GUI (see APPDATA below)
% %
% %
% % ---------APPDATA-----------------------
% % -------- input data ------------------- 
% % names       cell array of strings
% % indices     cell array of strings
% % codes       cell array of numbers 
% % --------- output data------------------
% % sel_full_names    cell array full name of selected
% % sel_names         cell array
% % sel_indices       cell array
% % sel_codes         vector
% % --------- state -----------------------
% % state            state of GUI : cell array with value of listboxes
% %                  (name and indices) and string of filter : 
% %                  defines the state of GUI with other params 
% %
% % ------PARAMATERS (with default values)-----
% % n_indices=5;                  number of indices fields
% % single_sel=0;                 if choice is restricted to singleval
% % call_func=[];                 handle to function called after each
% %                               change of gui : arguments call_func(panel_handle)
% % 
% % name_field_width=200;         width of fields with names
% % index_field_width=75;         width of fields with indices
% % field_heigth=185;             heigth of fields
% % button_heigth=20;             height of buttons
% % marginx=10;                   extra x-margin in interface
% % marginy=10;                   extra y-margin in interface
% % 
% % name_field_color=[0.95 0.95 0.98];   color of name list
% % index_field_color=[0.98 0.98 1];     color of inidces list
% %
% % v 1.1
% % corrected version with working not-indexed field in further than first indices 
% % 
% % -----------------W.M.Saj 2008--------------
VERSION =1.1;

%% checking input

% refesh existing GUI
if nargin==2 && strcmp(varargin{2},'refresh')
    panel_handle=varargin{1};
    refresh(panel_handle,[],panel_handle,0);return;
end

%% set user defined 'callback' for existing GUI
if nargin==3 && strcmp(varargin{2},'call_func')
    panel_handle=varargin{1};
    obj_gui_select=getappdata(panel_handle,'obj_gui_select');
    obj_gui_select.call_func=varargin{3};
    setappdata(panel_handle,'obj_gui_select',obj_gui_select);
    return;
end

%% set state of existing GUI
if nargin==3 && strcmp(varargin{2},'state')
    panel_handle=varargin{1};
    
    % setting state
    obj_gui_select=getappdata(panel_handle,'obj_gui_select');
        warning('Off',MATLAB:hg:uicontrol:ParameterValuesMustBeValid); % to avoid temporary problems like values outside range
        set(obj_gui_select.filter_handle,'String',varargin{3}{1});
        set(obj_gui_select.names_name_handle,'Value',varargin{3}{2});
        set(obj_gui_select.names_listbox_handle,'Value',[varargin{3}{3}])
        for idx=1:obj_gui_select.n_indices
            set(obj_gui_select.indices_listbox_handles(idx),'Value',[varargin{3}{3+idx}]);
        end
    warning('On',MATLAB:hg:uicontrol:ParameterValuesMustBeValid);
    refresh(panel_handle,[],panel_handle,0);return;
end

%% refresh existing GUI with data
if nargin==5 && strcmp(varargin{2},'refresh')
    % names_cl are handle to existing file : refresh
    panel_handle=varargin{1};
    obj_gui_select=getappdata(panel_handle,'obj_gui_select');
    
    names_cl=varargin{3};indices_cl=varargin{4};codes_cl=varargin{5};
    if isempty(indices_cl)
        for indx=1:length(names_cl)
            indices_cl{indx}={};
        end
    end
    
    [tmp,obj_gui_select.sorted_names_vec]=sort(names_cl);
    
    setappdata(panel_handle,'names',names_cl);
    setappdata(panel_handle,'indices',indices_cl);
    setappdata(panel_handle,'codes',codes_cl);
    
    setappdata(panel_handle,'obj_gui_select',obj_gui_select);

    % start position
    set(obj_gui_select.names_listbox_handle,'Value',1,'Max',1)
    set(obj_gui_select.indices_listbox_handles,'Value',1,'Max',1);    
    
    refresh(panel_handle,[],panel_handle,0);return;
end

%% default
panel_handle=varargin{1};names_cl=varargin{2};indices_cl=varargin{3};codes_cl=varargin{4};

% case of empty parameters
if isempty(indices_cl)
    for indx=1:length(names_cl)
        indices_cl{indx}={};
    end
end
% empty codes are handled in code :)

%% component default parameters
obj_gui_select.n_indices=5;
obj_gui_select.single_sel=0;
obj_gui_select.call_func=[];

obj_gui_select.name_field_width=200;
obj_gui_select.index_field_width=75;
obj_gui_select.field_heigth=185;
obj_gui_select.button_heigth=20;
obj_gui_select.marginx=10;
obj_gui_select.marginy=10;

obj_gui_select.name_field_color=[0.95 0.95 0.98];
obj_gui_select.index_field_color=[0.98 0.98 1];

%% setting values
for idx=5:2:nargin
    eval(['obj_gui_select.' varargin{idx} '= varargin{idx+1};'])
end

%% definition of main handles
% figure handle
if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['obj_gui_select v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [400 400 2.5*obj_gui_select.marginx+obj_gui_select.name_field_width+(obj_gui_select.marginx+obj_gui_select.index_field_width)*obj_gui_select.n_indices  2.5*obj_gui_select.marginy+obj_gui_select.field_heigth+obj_gui_select.button_heigth]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');
    pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',...
    [pos_tmp(1) pos_tmp(2) 2.5*obj_gui_select.marginx+obj_gui_select.name_field_width+(obj_gui_select.marginx+obj_gui_select.index_field_width)*obj_gui_select.n_indices  2.5*obj_gui_select.marginy+obj_gui_select.field_heigth+obj_gui_select.button_heigth])
end

varargout{1}=panel_handle;

%% creating elements specific for components
% listbox with names
obj_gui_select.names_listbox_handle= uicontrol(panel_handle,'Style','listbox','FontWeight','Bold',...
                'String',{''},'BackgroundColor',obj_gui_select.name_field_color,'Value',1,'Position',...
                [obj_gui_select.marginx obj_gui_select.marginy obj_gui_select.name_field_width obj_gui_select.field_heigth]);
            
% listbox with indices
obj_gui_select.indices_listbox_handles=zeros(obj_gui_select.n_indices,1);
for indx=1:obj_gui_select.n_indices
    obj_gui_select.indices_listbox_handles(indx)=uicontrol(panel_handle,'Style','listbox','String',{''},'FontWeight','Bold','Value',1,'BackgroundColor',obj_gui_select.index_field_color,'Position',....
                [2*obj_gui_select.marginx+obj_gui_select.name_field_width+(obj_gui_select.marginx+obj_gui_select.index_field_width)*(indx-1) obj_gui_select.marginy obj_gui_select.index_field_width obj_gui_select.field_heigth]);
end

% special case
set(obj_gui_select.indices_listbox_handles(obj_gui_select.n_indices),'Max',2-obj_gui_select.single_sel);

% placing edit 
obj_gui_select.filter_handle=uicontrol(panel_handle,'Style','edit','Tag','edit1','String','*','BackgroundColor','white','Position',...
    [obj_gui_select.marginx+(obj_gui_select.name_field_width+obj_gui_select.marginx)/2 obj_gui_select.marginy+obj_gui_select.field_heigth+obj_gui_select.marginy/2 (obj_gui_select.name_field_width-obj_gui_select.marginx)/2 obj_gui_select.button_heigth]);

% text fields

obj_gui_select.names_name_handle= uicontrol(panel_handle,'Style','togglebutton','String','Names','Tag','Names','FontWeight','Bold',...
                'Position',[obj_gui_select.marginx obj_gui_select.marginy+obj_gui_select.field_heigth+obj_gui_select.marginy/2 (obj_gui_select.name_field_width-obj_gui_select.marginx)/2 obj_gui_select.button_heigth]);
            
obj_gui_select.indices_name_handle=[];
            
for indx=1:obj_gui_select.n_indices
    obj_gui_select.indices_name_handle(indx)=uicontrol(panel_handle,'Style','pushbutton','Enable','Inactive',...
                'String',{[num2str(indx) 'th index']},'FontWeight','Bold',...
                'Position',[2*obj_gui_select.marginx+obj_gui_select.name_field_width+(obj_gui_select.marginx+obj_gui_select.index_field_width)*(indx-1) obj_gui_select.marginy+obj_gui_select.field_heigth+obj_gui_select.marginy/2 obj_gui_select.index_field_width obj_gui_select.button_heigth]);
end

%% setting callbacks to elements
set(obj_gui_select.names_name_handle,'Callback',@(hObject,eventdata) refresh(hObject,eventdata,panel_handle));
set(obj_gui_select.filter_handle,'Callback',@(hObject,eventdata) refresh(hObject,eventdata,panel_handle));
set(obj_gui_select.indices_listbox_handles,'Callback',@(hObject,eventdata) refresh(hObject,eventdata,panel_handle));
set(obj_gui_select.names_listbox_handle,'Callback',@(hObject,eventdata) refresh(hObject,eventdata,panel_handle));

%% setting data fields
%input
setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'indices',indices_cl);
setappdata(panel_handle,'codes',codes_cl);

% auxillary & handles data 
[tmp,obj_gui_select.sorted_names_vec]=sort(names_cl);
setappdata(panel_handle,'obj_gui_select',obj_gui_select);

% refresh screen
refresh(panel_handle,[],panel_handle,0)


function refresh(hObject,eventdata,panel_handle,call_callback)

    if nargin<4
        call_callback=1;
    end
    
    obj_gui_select=getappdata(panel_handle,'obj_gui_select');

    names_cl=getappdata(panel_handle,'names');
    indices_cl=getappdata(panel_handle,'indices');
    
    if get(obj_gui_select.names_name_handle,'Value')==0
        filt_names_cl=names_cl;
    else
        filt_names_cl=names_cl(obj_gui_select.sorted_names_vec);
    end

    [filt_names_cl,filt_indices]=filter_names(filt_names_cl,get(obj_gui_select.filter_handle,'String'));

    if isempty(filt_indices)
    
        set(obj_gui_select.names_listbox_handle,'FontAngle','Italic','String','No names matched','Value',1);
        set(obj_gui_select.indices_listbox_handles,'String','','Enable','Off');
        full_name='';name_short='';indices={};codes=[];
        
    else
        set(obj_gui_select.names_listbox_handle,'FontAngle','Normal');
      
        if length(filt_names_cl)==1
            filt_names_cl=filt_names_cl{1};
            index0=1;
        else
            index0=min(get(obj_gui_select.names_listbox_handle,'Value'),length(filt_names_cl));
        end
        
        set(obj_gui_select.names_listbox_handle,'String',filt_names_cl,'Value',index0);
        set(obj_gui_select.names_listbox_handle,'Max',2-obj_gui_select.single_sel);
        
        index0=filt_indices(index0);
       

    if get(obj_gui_select.names_name_handle,'Value')~=0
        index0=obj_gui_select.sorted_names_vec(index0);
    end
    
    % setting indices from the name slcteded
    if length(index0)==1
        indices_set=indices_cl{index0};
        [indices_set,mindx]=match_var(indices_set,{},0);
        
    else
        
       for i=1:length(index0)  
            [indices_set,mindx]=match_var(indices_cl{index0(i)},{},0);
            if (length(mindx)~=1) || ~isequal(mindx{1},'not indexed') 
                if obj_gui_select.single_sel
                    set(obj_gui_select.names_listbox_handle,'Value',index0(i),'Max',1);
                else
                    mindx={'multiple'};
                end
                break;
            end
        end
    end
    %% 1st index - could be empty
    if isequal(mindx,{'multiple'}) && ~obj_gui_select.single_sel 
                
        set(obj_gui_select.indices_listbox_handles(1),'String','multiple','Enable','Off','Value',1);    
        set(obj_gui_select.indices_listbox_handles(2:obj_gui_select.n_indices),'String','','Enable','Off');
                
        name_short_t=names_cl(index0);
        indices_t=indices_cl(index0);
                
        name_short=[];indices=[];
        for indx=1:length(index0)
            name_short=[name_short repmat(name_short_t(indx),size(indices_t{indx}))];
            for indx2=1:length(indices_t{indx})
                indices=[indices {indices_t{indx}{indx2}}];
            end
        end
                
        [full_name,codes]=get_variable2(panel_handle,name_short,indices);
    else
                
        if (length(mindx)==1) && isequal(mindx{1},'not indexed') && ~obj_gui_select.single_sel 
            set(obj_gui_select.indices_listbox_handles(1),'String','not indexed','Enable','Off','Value',1);    
            set(obj_gui_select.indices_listbox_handles(2:obj_gui_select.n_indices),'String','','Enable','Off');
        else

            %set(obj_gui_select.names_listbox_handle,'Max',1);
            set(obj_gui_select.indices_listbox_handles(1),'Enable','On','String',mindx2string(mindx));%,'Value',unique(min(get(obj_gui_select.indices_listbox_handles(1),'Value'),length(mindx))));
        end
    
        for idx=1:obj_gui_select.n_indices-1 
            % next indices till the last one 
        
            vals=get(obj_gui_select.indices_listbox_handles(idx),'Value');
        
            if length(vals)==1
                slcted=mindx{vals};
                [indices_set,mindx]=match_var(indices_set,slcted,idx);
            else
                for i=1:length(vals)  
                    slcted=mindx{vals(i)};
                    [indices_set2,mindx2]=match_var(indices_set,slcted,idx);
                    if ~isempty(mindx2)
                        if obj_gui_select.single_sel
                            set(obj_gui_select.indices_listbox_handles(idx),'Value',vals(i),'Max',1);
                        end
                        break;
                    end
                end
             
                if obj_gui_select.single_sel
                    indices_set=indices_set2;mindx=mindx2;
                else
                    if isempty(mindx2)
                        mindx=[];
                    else
                        mindx={'multiple'};
                    end
                end
            end
        
            set(obj_gui_select.indices_listbox_handles(idx),'Max',2-obj_gui_select.single_sel);        

            if isempty(mindx)
                set(obj_gui_select.indices_listbox_handles((idx+1):obj_gui_select.n_indices),'String','','Enable','Off');
                [full_name,name_short,indices,codes]=get_variable(panel_handle); 
                break;
            else
                set(obj_gui_select.indices_listbox_handles(idx+1),'Enable','On','String',mindx2string(mindx),'Value',unique(min(get(obj_gui_select.indices_listbox_handles(idx+1),'Value'),length(mindx))));
           
                if isequal(mindx,{'multiple'})
                
                    set(obj_gui_select.indices_listbox_handles((idx+2):obj_gui_select.n_indices),'String','','Enable','Off');           
            
                    vals=get(obj_gui_select.indices_listbox_handles(idx),'Value');
                    mindx_t=get(obj_gui_select.indices_listbox_handles(idx),'String');
                    indices=[];
            
                    for i=1:length(vals)  
                        slcted=mindx_t{vals(i)};
                        [indices_set_tmp,mindx_tmp]=match_var(indices_set,slcted,idx);
                        indices=[indices;indices_set_tmp];
                    end
            
                    name_short=repmat(names_cl(index0),size(indices));
           
                    [full_name,codes]=get_variable2(panel_handle,name_short,indices);
                    break;           
                end
            end
        end
    end
    end
    
     setappdata(panel_handle,'sel_full_names',full_name);
     setappdata(panel_handle,'sel_names',name_short);
     setappdata(panel_handle,'sel_indices',indices);
     setappdata(panel_handle,'sel_codes',codes);

    % saving the state data
    for idx=1:obj_gui_select.n_indices
        listbox_val{idx}=get(obj_gui_select.indices_listbox_handles(idx),'Value');
    end
    
    setappdata(panel_handle,'state',...
        {get(obj_gui_select.filter_handle,'String') get(obj_gui_select.names_name_handle,'Value')...
        get(obj_gui_select.names_listbox_handle,'Value') listbox_val{:} });    
    
    % calling the user set function
    if call_callback && ~isempty(obj_gui_select.call_func)
       feval(obj_gui_select.call_func,panel_handle);
    end
    
     setappdata(panel_handle,'sel_full_names',full_name);
     setappdata(panel_handle,'sel_names',name_short);
     setappdata(panel_handle,'sel_indices',indices);
     setappdata(panel_handle,'sel_codes',codes);
     
function output=mindx2string(mindx)
    for ind=1:length(mindx)
        
        if isempty(mindx{ind})
            output{ind}='not indexed';
        else
            output{ind}=mindx{ind};
        end
        
    end
    
function [mvar,mindx]=match_var(index_array,indx,pos)
% return matching variables from array of cells with index
% indx - value
% pos - position on which we search for value

mvar=[];mindx=[];
for idx=1:length(index_array)
    tmp=index_array{idx};
    if iscell(tmp) && isempty(tmp)   
        tmp={'not indexed'};
    end
    if pos>length(tmp)
        continue
    end
    if  (pos==0) || (isequal(tmp{pos},indx))
        
        mvar=[mvar;{tmp}];

        if length(tmp)>pos 
            mindx=[mindx; {tmp{pos+1}}];
        else
            if length(tmp)==pos
                mindx=[mindx;{''}];
            end
        end
    end
    
    % removing repeating values in mindx
    mindx=unique(mindx);
    
    if length(mindx)==1 && isequal(mindx{1},'')
        mindx=[];
    end
    
end

function [filtered,ind]=filter_names(str_cells,pattern)

% simpler interface for regexp

filtered=[];ind=[];

if isempty(pattern)
    pattern='*';
end

indx=findstr(pattern,'*');

if ~isempty(indx)
    pattern = regexprep(pattern, '*', '\\w*');
end
pattern=['\<' pattern '\>'];

for indx=1:length(str_cells)
    if ~isempty(regexpi(str_cells{indx},pattern, 'once' ))
        filtered=[filtered {str_cells{indx}}];
        ind=[ind indx];
    end
end

function [full_name,short_name,variab_indices,variab_code]=get_variable(panel_handle)

obj_gui_select=getappdata(panel_handle,'obj_gui_select');

index0=get(obj_gui_select.names_listbox_handle,'Value');
name=get(obj_gui_select.names_listbox_handle,'String'); 

if isempty(name) | strcmp(name,'No names matched')
    full_name={};
    short_name={};
    variab_indices={};
    return;
end

if iscell(name)
    short_name={name{index0}};
else
    short_name={name};
end

if length(index0)>1 | isequal(get(obj_gui_select.indices_listbox_handles(1),'Enable'),'off')
    for i=1:length(index0)
            full_name(i)={[]};
            variab_indices(i)={{}};
    end
else
    index=get(obj_gui_select.indices_listbox_handles(1),'Value');
    nme=get(obj_gui_select.indices_listbox_handles(1),'String');if ~iscell(nme) nme={nme}; end;
    
    short_name_old=short_name;
    
    for i=1:length(index)
        short_name{i}=short_name_old{1};
        full_name(i)={nme{index(i)}};
        variab_indices(i)={{nme{index(i)}}};
    end
end
    

for idx=2:length(obj_gui_select.indices_listbox_handles)
    
    if isequal(get(obj_gui_select.indices_listbox_handles(idx),'Enable'),'off')
        break;
    end
    
    index=get(obj_gui_select.indices_listbox_handles(idx),'Value');
    nme=get(obj_gui_select.indices_listbox_handles(idx),'String');if ~iscell(nme) nme={nme}; end;
    
    full_name_old=full_name;variab_indices_old=variab_indices;short_name_old=short_name;
    
    if length(nme)==1 && isequal(nme{1},'not indexed')
       break;
    end
    
    for i=1:length(index)
        short_name{i}=short_name_old{1};
        if isequal(nme{index(i)},'not indexed')
            full_name(i)={[full_name_old{1}]};
            variab_indices(i)={[variab_indices_old{1}]};
        else
            full_name(i)={[full_name_old{1} ',' nme{index(i)}]};
            variab_indices(i)={[variab_indices_old{1} {nme{index(i)}}]};
        end
    end
end

[full_name,variab_code]=get_variable3(panel_handle,short_name,variab_indices,full_name);

function [full_name,variab_code]=get_variable2(panel_handle,name_short,indices)

variab_code=[];

for i=1:length(name_short)
    tmp_index=indices{i};
    full_name{i}=tmp_index{1};
    for indx=2:length(tmp_index)
        if ~isequal(tmp_index{indx},'not indexed')
            full_name(i)={[full_name{i} ',' tmp_index{indx}]};
        end
    end
end

[full_name,variab_code]=get_variable3(panel_handle,name_short,indices,full_name);

function [full_name,variab_code]=get_variable3(panel_handle,name_short,indices,full_name)

for i=1:length(full_name)
    full_name(i)={[name_short{i} '<' full_name{i} '>']};
end

for i=1:length(full_name)
        variab_code(i)=find_code_val(panel_handle,name_short{i},indices(i));
end

function code=find_code_val(panel_handle,nme,ind)

code=[];

names_cl=getappdata(panel_handle,'names');
indices_cl=getappdata(panel_handle,'indices');
codes_cl=getappdata(panel_handle,'codes');

if isempty(codes_cl)
    code=0;
    return;
end

for indx=1:length(names_cl)
    if strcmp(nme,names_cl{indx})
        for indx2=1:length(indices_cl{indx})
            if isequal(ind,indices_cl{indx}(indx2))
                code=codes_cl{indx}(indx2);
                return;
            end
        end
    end
end
