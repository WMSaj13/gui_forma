function varargout=gui_FORMA_panel(panel_handle,varargin)
% % gui_FORMA_panel v 1.2 (Nov 2008)
% %  gui panel for FORMA object reading
% %
% %  panel_handle=gui_FORMA_panel(panel_handle,'param1_name',param1_val,'param2_name',param2_val...)
% %    creates a new component with given paramaters
% %
% %  gui_FORMA_panel(panel_handle,'refresh')
% %    refresh existing component according to values in app data
% %
% %  gui_FORMA_panel(panel_handle,'change_pert_callback',change_pert_callback)
% %   set the callback of component
% %
% % ----------------app data field--------------------------
% %
% % FORMA_object FORMA_object_name                FORMA perturbation object and name of variable it 
% %                                               was copied from
% % params_names params_indices params_codes      parameters names and indices and codes in model 
% %                                               (cell array structures)
% % params_full_names params_full_codes           paramaters full names and codes (cell array and vector)  
% % vars_names vars_indices vars_codes            variables names and indices and codes in model 
% %                                               (cell array structures)
% % vars_full_names vars_full_codes               variables full names and codes (cell array and vector)
% % shocks_names shocks_indices shocks_codes      shocks names and indices and codes in model 
% %                                               (cell array structures)
% % shocks_full_names shocks_full_codes           shocks full names and codes (cell array and vector)       
% %
% % exogs_names exogs_indices exogs_codes            exogenic vars names and indices and codes in model 
% %                                               (cell array structures)
% % exogs_full_names exogs_full_codes               exogenic vars full names and codes (cell array and vector)       
% %
% % change_pert_callback                          callback function executed when perturbation is changed                          
% % infobox_handle                                handle to infobox listbox
% %
% % ------------------parameters----------------
% % is_reload=1;                      button reload visible 
% % is_ask_before_reload=1;           confirmation is needed to reload
% % is_horizontal=0;                  layout is vertical, not horizontal 
% % infobox_width=300;                infobox width
% % infobox_height=110;               infobox height
% % button_height=25;                 button height
% % load_button_width=100;            load button width
% % reload_button_width=100;          reload button width
% %
% % load_button_string='Load perturbation from workspace' 
% % reload_button_string='Reload perturbation from workspace'
% %
% % margin=5;                         extra margin in gui layout 
% % change_pert_callback=[];          function called after each perturbation
% %                                   change
% %
% %
% % ------------W.M.Saj 2008--------------------------

VERSION=1.2;

if nargin<1
    panel_handle=[];
end

if nargin==3 && isequal(varargin{1},'change_pert_callback')
    setappdata(panel_handle,'change_pert_callback',varargin{2});
    return;
end

if nargin==2 && isequal(varargin{1},'refresh')
    refresh(panel_handle);
    return;
end

is_reload=1;
is_ask_before_reload=1;
is_horizontal=0;

change_pert_callback=[];

infobox_width=300;
infobox_height=110;
load_button_width=300;
reload_button_width=300;
button_height=25;

load_button_string='Load perturbation from workspace'; 
reload_button_string='Reload perturbation from workspace';

margin=5;

for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};']);
end

% aux params
panel_size_x=infobox_width+2*margin;
panel_size_y=infobox_height+4*margin+2*button_height;

if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['obj_FORMA_object v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [0 0 panel_size_x panel_size_y]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');
    pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',...
    [pos_tmp(1:2) panel_size_x panel_size_y]);
end

infobox_handle=uicontrol('Parent',panel_handle,'Style','listbox','Position',...
    [0 0 infobox_width infobox_height],...
    'FontWeight','Bold','FontAngle','Italic','String','','BackgroundColor','white','Enable','Inactive');

load_button_handle=uicontrol('Parent',panel_handle,'Style','pushbutton','Position',...
    [0 0 load_button_width button_height],...
    'FontWeight','Bold','String',load_button_string,'Callback',@(hObject,eventdata) load_button(hObject,eventdata,panel_handle));

if is_reload
    reload_button_handle=uicontrol('Parent',panel_handle,'Style','pushbutton','Position',...
        [0 0 reload_button_width button_height],'UserData',is_ask_before_reload,...
        'FontWeight','Bold','String',reload_button_string,'Callback',@(hObject,eventdata) reload_button(hObject,eventdata,panel_handle));
end

if is_horizontal
    if is_reload
        gui_pos={{load_button_handle infobox_handle reload_button_handle}};
    else
        gui_pos={{load_button_handle infobox_handle}};
    end
else
    if is_reload
        gui_pos={reload_button_handle infobox_handle load_button_handle};
    else
        gui_pos={infobox_handle load_button_handle};
    end
end


gui_layout(panel_handle,gui_pos,'margin_x',margin,'margin_y',margin);

setappdata(panel_handle,'infobox_handle',infobox_handle);

setappdata(panel_handle,'FORMA_object',[]);
setappdata(panel_handle,'FORMA_object_name','');

setappdata(panel_handle,'params_names',{});
setappdata(panel_handle,'params_indices',{});
setappdata(panel_handle,'params_codes',{});

setappdata(panel_handle,'params_full_names',{});
setappdata(panel_handle,'params_full_codes',[]);

setappdata(panel_handle,'vars_names',{});
setappdata(panel_handle,'vars_indices',{});
setappdata(panel_handle,'vars_codes',{});

setappdata(panel_handle,'vars_full_names',{});
setappdata(panel_handle,'vars_full_codes',[]);

setappdata(panel_handle,'shocks_names',{});
setappdata(panel_handle,'shocks_indices',{});
setappdata(panel_handle,'shocks_codes',{});

setappdata(panel_handle,'shocks_full_names',{});
setappdata(panel_handle,'shocks_full_codes',[]);


setappdata(panel_handle,'exogs_names',{});
setappdata(panel_handle,'exogs_indices',{});
setappdata(panel_handle,'exogs_codes',{});

setappdata(panel_handle,'exogs_full_names',{});
setappdata(panel_handle,'exogs_full_codes',[]);


setappdata(panel_handle,'change_pert_callback',change_pert_callback);

varargout{1}=panel_handle;

function load_button(hObject,eventdata,panel_handle)

variables = evalin('base','whos');nam={variables.name};

list_var=[];var_model=[];var_state=[];
for ind=1:length(nam)
    str = evalin('base',['class(' nam{ind} ')']);
    if  isequal(str,'perturbation')
        list_var=[list_var {nam{ind}}];
        var_model=[var_model {evalin('base',[nam{ind} '.model.name'])}];
        var_state=[var_state  {evalin('base',[nam{ind} '.state'])}];
    end
end

if isempty(list_var) msgbox('There are no perturbations in the workspace','Message','error','Modal');return; end

state_str={'not',''};
for ind=1:length(list_var)
    new_list_var{ind}=[list_var{ind} '  [ ' var_model{ind}   ' model , ' state_str{var_state{ind}+1} ' solved ]'];
end

[s,v] = listdlg('Name','Load perturbation from workspace','ListSize',[320,320],'PromptString','Select a model file:',...
                'SelectionMode','single','ListString',new_list_var);

if (v==0) return; end

FORMA_object_name=list_var{s};
load(panel_handle,FORMA_object_name);

refresh(panel_handle);

function reload_button(hObject,eventdata,panel_handle)

FORMA_object_name=getappdata(panel_handle,'FORMA_object_name');

if ~isempty(FORMA_object_name)

    if get(hObject,'UserData')
     if isequal(questdlg('Do you want to reload perturbation ?','Ask','Yes','Cancel','Cancel'),'Cancel')
         return;
     end
    end
    load(panel_handle,FORMA_object_name);
    refresh(panel_handle);
end

function load(panel_handle,FORMA_object_name)

h_wd=warndlg('Loading perturbation','Please wait...');

FORMA_object=evalin('base',FORMA_object_name);

setappdata(panel_handle,'FORMA_object',FORMA_object);
setappdata(panel_handle,'FORMA_object_name',FORMA_object_name);

[names_list,indices_list,codes_list,full_names_list,full_codes_list]=get_info(FORMA_object,'params');
setappdata(panel_handle,'params_names',names_list);
setappdata(panel_handle,'params_indices',indices_list);
setappdata(panel_handle,'params_codes',codes_list);
setappdata(panel_handle,'params_full_names',full_names_list);
setappdata(panel_handle,'params_full_codes',full_codes_list);

[names_list,indices_list,codes_list,full_names_list,full_codes_list]=get_info(FORMA_object,'vars');
setappdata(panel_handle,'vars_names',names_list);
setappdata(panel_handle,'vars_indices',indices_list);
setappdata(panel_handle,'vars_codes',codes_list);
setappdata(panel_handle,'vars_full_names',full_names_list);
setappdata(panel_handle,'vars_full_codes',full_codes_list);

[names_list,indices_list,codes_list,full_names_list,full_codes_list]=get_info(FORMA_object,'shocks');
setappdata(panel_handle,'shocks_names',names_list);
setappdata(panel_handle,'shocks_indices',indices_list);
setappdata(panel_handle,'shocks_codes',codes_list);
setappdata(panel_handle,'shocks_full_names',full_names_list);
setappdata(panel_handle,'shocks_full_codes',full_codes_list);


[names_list,indices_list,codes_list,full_names_list,full_codes_list]=get_info(FORMA_object,'exogs');
setappdata(panel_handle,'exogs_names',names_list);
setappdata(panel_handle,'exogs_indices',indices_list);
setappdata(panel_handle,'exogs_codes',codes_list);
setappdata(panel_handle,'exogs_full_names',full_names_list);
setappdata(panel_handle,'exogs_full_codes',full_codes_list);


try
    close(h_wd)
catch
end

function refresh(panel_handle)

FORMA_object=getappdata(panel_handle,'FORMA_object');
FORMA_object_name=getappdata(panel_handle,'FORMA_object_name');
change_pert_callback=getappdata(panel_handle,'change_pert_callback');
infobox_handle=getappdata(panel_handle,'infobox_handle');

info_string=evalc('FORMA_object');
out_string=string2cell(info_string);
out_string(1)={['source name: ' FORMA_object_name]};
set(infobox_handle,'String',out_string);
if FORMA_object.state==1
    set(infobox_handle,'ForegroundColor',[0.0 0.3 0.0]);
else
    set(infobox_handle,'ForegroundColor',[0.6 0.0 0.0]);
end

if ~isempty(change_pert_callback)
       feval(change_pert_callback,panel_handle);
end

function out_string=string2cell(input_string)

remain=input_string;
for indx=1:length(findstr(input_string,char(10))) 
    [inp_str,remain] = strtok(remain,char(10));
    out_string(indx)={inp_str};
end

function [names_list,indices_list,codes_list,full_names_list,full_codes_list]=get_info(p_object,vtype)

if isequal(vtype,'vars')
    maxindx=p_object.model.n_vars;
end

if isequal(vtype,'params')
    maxindx=p_object.model.n_params;
end

if isequal(vtype,'shocks')
    maxindx=p_object.model.n_shocks;
    shock_codes=get_codes(p_object.model.shocks);
end

if isequal(vtype,'exogs')
    maxindx=p_object.model.n_exog;
    exog_codes=get_codes(p_object.model.exog);
end


indx_var=1;

codes_list={[]};

names_list={};        
indices_list={};

full_names_list={};
full_codes_list=[];

for indx=1:maxindx
    
    if isequal(vtype,'vars')
       var_info=p_object.model.get_info_var(indx);
    end
    
    if isequal(vtype,'params') 
       var_info=p_object.model.get_info_param(indx);
    end

    if isequal(vtype,'shocks')
        var_info=p_object.model.get_info_var(shock_codes(indx));
    end
    
    if isequal(vtype,'exogs')
        var_info=p_object.model.get_info_var(exog_codes(indx));
    end
    
    
    var_name=var_info{1}{1};
    var_indx=var_info{1}{2};
    
    index_string=[];
    if ~isempty(var_indx)
        index_string=[index_string var_indx{1}];
        for id=2:length(var_indx)
            index_string=[index_string ',' var_indx{id}];
        end
    end
    index_string=['<' index_string '>'];
   
    full_names_list{indx}=[var_name index_string];
    
    if isequal(vtype,'shocks') 
        indx_t=shock_codes(indx);
    else
        if isequal(vtype,'exogs') 
            indx_t=exog_codes(indx);
        else
            indx_t=indx;            
        end
    end
    
    full_codes_list(indx)=indx_t;
    
    is_indx=0;
    for indx2=1:(indx_var-1)
        if isequal(names_list{indx2},var_name)
            indices_list{indx2}={indices_list{indx2}{:} var_indx};
            codes_list{indx2}=[codes_list{indx2} indx_t];
            is_indx=1;
            break;
        end
    end
    
    if is_indx==0
        names_list{indx_var}=var_name;
        indices_list{indx_var}={var_indx};
        codes_list{indx_var}=indx_t;
        indx_var=indx_var+1;
    end
  
end