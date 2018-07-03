function VisualAIM
% calibration tool for FORMA models
% v 2.02 Nov 2008

h=figure('MenuBar','None','Name','VisualAIM 2.01','HandleVisibility','Off','Color',[0.925 0.914 0.847],'Resize','Off','Visible','Off');

% panels used
forma_panel=gui_FORMA_panel(uipanel('Parent',h),'infobox_height',30,'margin',1,'is_reload',0);

params_list=gui_set(uipanel('Parent',h),{},{},{},'n_fields_y',5,'n_fields_x',4,'name_field_width',150,'name_string','parameter',...
    'value_string',{'assumed','initial','optimized','discr'},'is_func_rows',1,'is_sortable',0,...
    'func_rows_string',repmat({'set'},5,1),'not_editable',1:4,'call_func_rows',@params_set,'func_button_width',35,'value_field_widths',[290 75 75 65]);

vars_list=gui_set(uipanel('Parent',h),{},{},{},'n_fields_y',5,'n_fields_x',4,'name_field_width',150,'name_string','optimized variable',...
    'value_string',{'assumed','initial','optimized','discr'},'is_func_rows',1,'is_sortable',0,...
    'func_rows_string',repmat({'set'},5,1),'not_editable',1:4,'not_editable_color',[1 1 0.8],'call_func_rows',@vars_set,'func_button_width',35,...
    'call_remove_func',@remove_vars,'call_clear_func',@clear_vars,'value_field_widths',[290 75 75 65]);


add_param=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Add parameter','Position',[0 0 300 30]);
add_var=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Add variable','Position',[0 0 300 30],'Callback',@(hObject,eventdata) add_var_callback(hObject,eventdata,forma_panel,vars_list));
add_moment=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Add moment of variable','Position',[0 0 300 30],'Callback',@(hObject,eventdata) add_moment_callback(hObject,eventdata,forma_panel,vars_list));
set_optim2init=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Set optimized values as initial','Position',[0 0 300 30],'Callback',@(hObject,eventdata) optim2init(hObject,eventdata,forma_panel,vars_list,params_list));
export_opt=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Export optimized','Position',[0 0 300 30],'Callback',@(hObject,eventdata) call_export_opt(hObject,eventdata,forma_panel,vars_list,params_list));


load_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Load state','Position',[0 0 125 21],'Callback',@(hObject,eventdata) load_state_call(hObject,params_list,vars_list,h));
save_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Save state','Position',[0 0 125 21],'Callback',@(hObject,eventdata) save_state_call(hObject,params_list,vars_list,h));


optimalization_panel=gui_optimize_simplex(uipanel('Parent',h));

analysis_panel=gui_visualize(uipanel('Parent',h),...
    'get_impact_func',@(imp_per,is_percents) VisAIM_get_impact_func(imp_per,forma_panel,params_list,vars_list,is_percents),...
    'get_map_func',@(param_name,param_code,i,perc_vec,is_percents) VisAIM_get_map_func(i,perc_vec,forma_panel,params_list,vars_list,is_percents));

tabs=gui_tabs(uipanel('Parent',h),{optimalization_panel analysis_panel},'tabs_names_widths',[180 100],'tabs_names_strings',{'Optimalization','Analysis'});

gui_optimize_simplex(optimalization_panel,'set',...
    'equations',{'feval(getappdata(VisAIM,''full_optimized_func''),params_values,forma_panel,params_list,vars_list)'},...
    'x_labels',{'params_values'},...
    'p_labels',{'VisAIM','forma_panel','params_list','vars_list'},...
    'p_values',{h,forma_panel,params_list,vars_list},...
    'func_pre_opt',@(optimalization_panel)  pre_optimize(h,params_list,vars_list,optimalization_panel),...
    'func_post_opt',@(optimalization_panel) post_optimize(h,params_list,vars_list,optimalization_panel,forma_panel),...
    'f_values',[],'f_sigma',[]);

gui_optimize_simplex(optimalization_panel,'Disable');

gui_FORMA_panel(forma_panel,'change_pert_callback',@(hObject) changed_perturb(hObject,vars_list,params_list,optimalization_panel));

gui_set(params_list,'call_remove_func',@(panel_handle,pos) remove_params(panel_handle,pos));
gui_set(params_list,'call_clear_func',@(panel_handle) clear_params(panel_handle));

set(add_param,'Callback',@(hObject,eventdata) add_param_callback(hObject,eventdata,forma_panel,params_list));
set(export_opt,'Callback',@(hObject,eventdata) export_opt_callback(hObject,eventdata,forma_panel,params_list,vars_list));

gui_layout(h,{{{export_opt set_optim2init tabs {load_state save_state} forma_panel} {{add_var add_moment} vars_list add_param params_list}}});
gui_screen_position(h);
set(h,'Visible','On');

setappdata(h,'full_optimized_func',@full_optimized_func);

%
setappdata(params_list,'analysis_panel',analysis_panel);

setappdata(params_list,'val_type',[]);
setappdata(params_list,'val1',[]);setappdata(params_list,'val2',[]);
setappdata(params_list,'dist_type',[]);setappdata(params_list,'dist_params',[]);
setappdata(params_list,'init_val',[]);setappdata(params_list,'opt_val',[]);

setappdata(vars_list,'var_val_type',[]);

setappdata(vars_list,'val_type',[]);
setappdata(vars_list,'val1',[]);setappdata(vars_list,'val2',[]);
setappdata(vars_list,'dist_type',[]);setappdata(vars_list,'dist_params',[]);
setappdata(vars_list,'init_val',[]);setappdata(vars_list,'opt_val',[]);

setappdata(vars_list,'mom_type',[]);
setappdata(vars_list,'base_var',[]);
setappdata(vars_list,'lag',[]);

% elements to block
setappdata(h,'el2block',[get(vars_list,'Children'); get(params_list,'Children'); get(forma_panel,'Children');...
    add_param; add_var ; add_moment ; set_optim2init ; export_opt]);

setappdata(h,'recent_dir',evalc('pwd'));


function add_param_callback(hObject,eventdata,forma_panel,params_list)

[sel_full_names,sel_codes]=gui_choose([],getappdata(forma_panel,'params_names'),getappdata(forma_panel,'params_indices'),getappdata(forma_panel,'params_codes'),'add params:');

if isempty(sel_codes)
    return
end

val_type=getappdata(params_list,'val_type');
val1=getappdata(params_list,'val1');val2=getappdata(params_list,'val2');
dist_type=getappdata(params_list,'dist_type');dist_params=getappdata(params_list,'dist_params');
init_val=getappdata(params_list,'init_val');opt_val=getappdata(params_list,'opt_val');

val=get_param_val(forma_panel,sel_codes);

indices_added=[];
for indx=1:length(val)
    cell_val=[return_assumed_string(2,val(indx),val(indx),'norm',[val(indx) 0.1],1) {val(indx)} {val(indx)} {return_dis(2,val(indx),val(indx),(1+3*eps('single')*(sign(val(indx))))*val(indx),'norm',[val(indx) 0.1])}];
    if ~isempty(gui_set(params_list,'add',sel_full_names(indx),{cell_val},sel_codes(indx),'single'))
        indices_added=[indices_added indx];
    end
end

sel_codes=sel_codes(indices_added);
val=val(indices_added);

val_type=[val_type 2*ones(size(sel_codes))];
dist_type=[dist_type repmat({'norm'},size(sel_codes))];
for indx=1:length(sel_codes)
    dist_params=[dist_params {[val(indx) 0.1]}];
    init_val=[init_val;val(indx)];opt_val=[opt_val;val(indx)];
    val1=[val1;val(indx)];val2=[val2;(1+3*eps('single')*(sign(val(indx))))*val(indx)];
end

setappdata(params_list,'val_type',val_type);
setappdata(params_list,'val1',val1);setappdata(params_list,'val2',val2);
setappdata(params_list,'dist_type',dist_type);setappdata(params_list,'dist_params',dist_params);
setappdata(params_list,'init_val',init_val);setappdata(params_list,'opt_val',opt_val);

gui_visualize(getappdata(params_list,'analysis_panel'),'refresh params',getappdata(params_list,'names'),getappdata(params_list,'codes'));

function add_var_callback(hObject,eventdata,forma_panel,vars_list)

[sel_full_names,sel_codes]=gui_choose([],getappdata(forma_panel,'vars_names'),getappdata(forma_panel,'vars_indices'),getappdata(forma_panel,'vars_codes'),'add vars:');

if isempty(sel_codes)
    return
end

var_val_type=getappdata(vars_list,'var_val_type');
val_type=getappdata(vars_list,'val_type');

val1=getappdata(vars_list,'val1');val2=getappdata(vars_list,'val2');
dist_type=getappdata(vars_list,'dist_type');dist_params=getappdata(vars_list,'dist_params');
init_val=getappdata(vars_list,'init_val');opt_val=getappdata(vars_list,'opt_val');

mom_type=getappdata(vars_list,'mom_type');
base_var=getappdata(vars_list,'base_var');
lag=getappdata(vars_list,'lag');

val=get_var_ss_val(forma_panel,sel_codes);

index_added=[];
for indx=1:length(val)
    cell_val=[return_assumed_string(1,val(indx),(1+3*eps('single')*(sign(val(indx))))*val(indx),'norm',[val(indx) 0.1],0) {val(indx)} {val(indx)} {num2str(return_dis(1,val(indx),val(indx),(1+3*eps('single')*(sign(val(indx))))*val(indx),'norm',[val(indx) 0.1]),'%1.1g')}];
    if ~isempty(gui_set(vars_list,'add',sel_full_names(indx),{cell_val},sel_codes(indx),'single'))
        index_added=[index_added indx];
    end
end

sel_codes=sel_codes(index_added);
val=val(index_added);

var_val_type=[var_val_type ones(size(sel_codes))];
val_type=[val_type ones(size(sel_codes))];
dist_type=[dist_type repmat({'norm'},size(sel_codes))];
for indx=1:length(sel_codes)
    dist_params=[dist_params {[val(indx) 0.1]}];
end
init_val=[init_val;val];opt_val=[opt_val;val];
val1=[val1;val];val2=[val2;(1+3*eps('single')*(sign(val(indx))))*val];

mom_type=[mom_type repmat({''},size(sel_codes))];
base_var=[base_var repmat({''},size(sel_codes))];
lag=[lag repmat({[]},size(sel_codes))];

setappdata(vars_list,'var_val_type',var_val_type);
setappdata(vars_list,'val_type',val_type);
setappdata(vars_list,'val1',val1);setappdata(vars_list,'val2',val2);
setappdata(vars_list,'dist_type',dist_type);setappdata(vars_list,'dist_params',dist_params);
setappdata(vars_list,'init_val',init_val);setappdata(vars_list,'opt_val',opt_val);

setappdata(vars_list,'mom_type',mom_type);
setappdata(vars_list,'base_var',base_var);
setappdata(vars_list,'lag',lag);

function add_moment_callback(hObject,eventdata,forma_panel,vars_list)

[sel_full_names,sel_codes,sel_values]=gui_choose_mom([],getappdata(forma_panel,'vars_names'),getappdata(forma_panel,'vars_indices'),getappdata(forma_panel,'vars_codes'),'add moments of variables:');

if isempty(sel_codes)
    return
end

var_val_type=getappdata(vars_list,'var_val_type');

val_type=getappdata(vars_list,'val_type');
val1=getappdata(vars_list,'val1');val2=getappdata(vars_list,'val2');
dist_type=getappdata(vars_list,'dist_type');dist_params=getappdata(vars_list,'dist_params');
init_val=getappdata(vars_list,'init_val');opt_val=getappdata(vars_list,'opt_val');

mom_type=getappdata(vars_list,'mom_type');
base_var=getappdata(vars_list,'base_var');
lag=getappdata(vars_list,'lag');

for indx=1:length(sel_values)
        
    mom_type_i=sel_values{indx}{1};
    base_var_i=sel_values{indx}{2};
    lag_i=sel_values{indx}{3};

    var_val_type=[var_val_type 2*ones(1,max(length(lag_i),1))];
    val_type=[val_type ones(1,max(length(lag_i),1))];
    dist_type=[dist_type repmat({'norm'},1,max(length(lag_i),1))];
    
    
    for indx2=1:max(length(lag_i),1)
      
           if ~isequal(base_var_i,'')
                base_var_str=[' [' cell2mat(base_var_i) '] '];
           else
                base_var_str='';
           end
        
            if ~isempty(lag_i)
                lag_ij=lag_i(indx2);
                lag_str=[', lag :' num2str(lag_ij)];
            else
                lag_ij=[];
                lag_str=[];
            end
        
            val=get_var_moment_val(forma_panel,sel_codes(indx),mom_type_i,base_var_i,lag_ij);

            
            cell_val=[return_assumed_string(1,val,(1+3*eps('single')*(sign(val)))*val,'norm',[val 0.1],0) {val} {val} {num2str(return_dis(1,val,val,(1+3*eps('single')*(sign(val)))*val,'norm',[val 0.1]),'%1.1g')}];
            if ~isempty(gui_set(vars_list,'add',{[mom_type_i ' : ' sel_full_names{indx} base_var_str lag_str]},{cell_val},sel_codes(indx),'single'))
            
                dist_params=[dist_params {[val 0.1]}];

                init_val=[init_val;val];opt_val=[opt_val;val];
                val1=[val1;(1-1e-1)*val];val2=[val2;(1+3*eps('single')*(sign(val)))*val];

                mom_type=[mom_type {mom_type_i}];
                base_var=[base_var {base_var_i}];            
                lag=[lag {lag_ij}];     
           
            end
            
    end
end

setappdata(vars_list,'var_val_type',var_val_type);

setappdata(vars_list,'val_type',val_type);
setappdata(vars_list,'val1',val1);setappdata(vars_list,'val2',val2);
setappdata(vars_list,'dist_type',dist_type);setappdata(vars_list,'dist_params',dist_params);
setappdata(vars_list,'init_val',init_val);setappdata(vars_list,'opt_val',opt_val);

setappdata(vars_list,'mom_type',mom_type);
setappdata(vars_list,'base_var',base_var);
setappdata(vars_list,'lag',lag);


function val=get_var_ss_val(forma_panel,code)
FORMA_object=getappdata(forma_panel,'FORMA_object');
val=get_var_ss_val2(FORMA_object,code);

function val=get_var_ss_val2(p,code)
if p.state~=1
    val=nan(size(code));
else
    val=cell2mat(p.vars(code).val.get);
end

function val=get_var_moment_val(forma_panel,code,moment_type,base_var,lag)
FORMA_object=getappdata(forma_panel,'FORMA_object');
val=get_var_moment_val2(FORMA_object,code,moment_type,base_var,lag);

function val=get_var_moment_val2(p,code,moment_type,base_var,lag)

if p.state~=1
    val=nan(size(code));
else
    switch moment_type
    case 'STD'
        val=p.vars(code).moment(moment_type).get{1};
    case {'REL_STD', 'REG'}
        val=p.vars(code).moment(moment_type,base_var).get{1};
    case 'AUT'
        val=p.vars(code).moment(moment_type,lag).get{1};
        if iscell(val)
            val=cell2mat(val);
        end
    case 'CORR'
        val=p.vars(code).moment(moment_type,base_var,lag).get{1};
        if iscell(val)
            val=cell2mat(val);
        end
    end
end

function val=get_param_val(forma_panel,code)
FORMA_object=getappdata(forma_panel,'FORMA_object');
val=cell2mat(FORMA_object.params(code).val.get);

function remove_params2(panel_handle,pos)

val_type=getappdata(panel_handle,'val_type');

if length(val_type)==1
    clear_params(panel_handle);
    return;
end

val1=getappdata(panel_handle,'val1');val2=getappdata(panel_handle,'val2');
dist_type=getappdata(panel_handle,'dist_type');dist_params=getappdata(panel_handle,'dist_params');
init_val=getappdata(panel_handle,'init_val');opt_val=getappdata(panel_handle,'opt_val');

val_type=[val_type(1:pos-1) val_type(pos+1:length(val_type))];
val1=[val1(1:pos-1);val1(pos+1:length(val1))];
val2=[val1(1:pos-1);val2(pos+1:length(val2))];

dist_type=[dist_type(1:pos-1) dist_type(pos+1:length(dist_type))];
dist_params=[dist_params(1:pos-1) dist_params(pos+1:length(dist_params))];

init_val=[init_val(1:pos-1);init_val(pos+1:length(init_val))];
opt_val=[opt_val(1:pos-1);opt_val(pos+1:length(opt_val))];

setappdata(panel_handle,'val_type',val_type);
setappdata(panel_handle,'val1',val1);setappdata(panel_handle,'val2',val2);
setappdata(panel_handle,'dist_type',dist_type);setappdata(panel_handle,'dist_params',dist_params);
setappdata(panel_handle,'init_val',init_val);setappdata(panel_handle,'opt_val',opt_val);

function remove_params(panel_handle,pos)
remove_params2(panel_handle,pos)
gui_visualize(getappdata(panel_handle,'analysis_panel'),'refresh params',getappdata(panel_handle,'names'),getappdata(panel_handle,'codes'));

function clear_params2(panel_handle)

setappdata(panel_handle,'val_type',[]);
setappdata(panel_handle,'val1',[]);setappdata(panel_handle,'val2',[]);
setappdata(panel_handle,'dist_type',[]);setappdata(panel_handle,'dist_params',[]);
setappdata(panel_handle,'init_val',[]);setappdata(panel_handle,'opt_val',[]);

function clear_params(panel_handle)
clear_params2(panel_handle)
gui_visualize(getappdata(panel_handle,'analysis_panel'),'refresh params',getappdata(panel_handle,'names'),getappdata(panel_handle,'codes'));

function params_set(hObject,panel_handle,i)

set(hObject,'Enable','Off');

val_name=getappdata(panel_handle,'names');

val_type=getappdata(panel_handle,'val_type');
val1=getappdata(panel_handle,'val1');val2=getappdata(panel_handle,'val2');
dist_type=getappdata(panel_handle,'dist_type');dist_params=getappdata(panel_handle,'dist_params');

val_type_i=val_type(i);val1_i=val1(i);val2_i=val2(i);
dist_type_i=dist_type{i};dist_params_i=dist_params{i};

init_val=getappdata(panel_handle,'init_val');opt_val=getappdata(panel_handle,'opt_val');

init_val_i=init_val(i);opt_val_i=opt_val(i);


[val_type_i,val1_i,val2_i,dist_type_i,dist_params_i]=gui_set_var_type(val_type_i,val1_i,val2_i,dist_type_i,dist_params_i,init_val_i,opt_val_i,1,['set parameter ' val_name{i}  ' :']);

cell_val=[return_assumed_string(val_type_i,val1_i,val2_i,dist_type_i,dist_params_i,0) {init_val_i} {opt_val_i} {num2str(return_dis(val_type_i,opt_val_i,val1_i,val2_i,dist_type_i,dist_params_i),'%1.1g')}];
gui_set(panel_handle,'set row',i,cell_val);

val_type(i)=val_type_i;val1(i)=val1_i;val2(i)=val2_i;
dist_type{i}=dist_type_i;dist_params{i}=dist_params_i;

setappdata(panel_handle,'val_type',val_type);
setappdata(panel_handle,'val1',val1);setappdata(panel_handle,'val2',val2);
setappdata(panel_handle,'dist_type',dist_type);setappdata(panel_handle,'dist_params',dist_params);

set(hObject,'Enable','On');


function refresh_params_vars(panel_handle,is_params)

val_type=getappdata(panel_handle,'val_type');
val1=getappdata(panel_handle,'val1');val2=getappdata(panel_handle,'val2');
dist_type=getappdata(panel_handle,'dist_type');dist_params=getappdata(panel_handle,'dist_params');
init_val=getappdata(panel_handle,'init_val');opt_val=getappdata(panel_handle,'opt_val');

for indx=1:length(val_type)
    cell_val=[return_assumed_string(val_type(indx),val1(indx),val2(indx),dist_type{indx},dist_params{indx},is_params) {init_val(indx)} {opt_val(indx)} {num2str(return_dis(val_type(indx),opt_val(indx),val1(indx),val2(indx),dist_type{indx},dist_params{indx}),'%1.1g')}];
    gui_set(panel_handle,'set row',indx,cell_val);
end

gui_set(panel_handle,'refresh');

function remove_vars(vars_list,pos)

var_val_type=getappdata(vars_list,'var_val_type');

if length(var_val_type)==1
    clear_vars(vars_list);
    return;
end

mom_type=getappdata(vars_list,'mom_type');
base_var=getappdata(vars_list,'base_var');
lag=getappdata(vars_list,'lag');

var_val_type=[var_val_type(1:pos-1) var_val_type(pos+1:length(var_val_type))];
mom_type=[mom_type(1:pos-1) mom_type(pos+1:length(mom_type))];
base_var=[base_var(1:pos-1) base_var(pos+1:length(base_var))];
lag=[lag(1:pos-1) lag(pos+1:length(lag))];

setappdata(vars_list,'var_val_type',var_val_type);
setappdata(vars_list,'mom_type',mom_type);
setappdata(vars_list,'base_var',base_var);
setappdata(vars_list,'lag',lag);

remove_params2(vars_list,pos);

function clear_vars(vars_list)

setappdata(vars_list,'var_val_type',[]);
setappdata(vars_list,'mom_type',[]);
setappdata(vars_list,'base_var',[]);
setappdata(vars_list,'lag',[]);

clear_params2(vars_list);


function vars_set(hObject,panel_handle,i)

set(hObject,'Enable','Off');

var_name=getappdata(panel_handle,'names');

val_type=getappdata(panel_handle,'val_type');
val1=getappdata(panel_handle,'val1');val2=getappdata(panel_handle,'val2');
dist_type=getappdata(panel_handle,'dist_type');dist_params=getappdata(panel_handle,'dist_params');

mom_type=getappdata(panel_handle,'mom_type');
base_var=getappdata(panel_handle,'base_var');
lag=getappdata(panel_handle,'lag');

val_type_i=val_type(i);
val1_i=val1(i);val2_i=val2(i);
dist_type_i=dist_type{i};dist_params_i=dist_params{i};

init_val=getappdata(panel_handle,'init_val');opt_val=getappdata(panel_handle,'opt_val');

init_val_i=init_val(i);opt_val_i=opt_val(i);

mom_type_i=mom_type{i};
base_var_i=base_var{i};lag_i=lag{i};

[val_type_i,val1_i,val2_i,dist_type_i,dist_params_i]=gui_set_var_type(val_type_i,val1_i,val2_i,dist_type_i,dist_params_i,init_val_i,opt_val_i,0,['set variable ' var_name{i} ' :']);

cell_val=[return_assumed_string(val_type_i,val1_i,val2_i,dist_type_i,dist_params_i,0) {init_val_i} {opt_val_i} {num2str(return_dis(val_type_i,opt_val_i,val1_i,val2_i,dist_type_i,dist_params_i),'%1.1g')}];

gui_set(panel_handle,'set row',i,cell_val);

val_type(i)=val_type_i;val1(i)=val1_i;val2(i)=val2_i;
dist_type{i}=dist_type_i;dist_params{i}=dist_params_i;

setappdata(panel_handle,'val_type',val_type);
setappdata(panel_handle,'val1',val1);setappdata(panel_handle,'val2',val2);
setappdata(panel_handle,'dist_type',dist_type);setappdata(panel_handle,'dist_params',dist_params);

set(hObject,'Enable','On');


function changed_perturb(forma_panel,vars_list,params_list,optimalization_panel)

gui_optimize_simplex(optimalization_panel,'Disable');
gui_set(vars_list,'clear');gui_set(params_list,'clear');
gui_optimize_simplex(optimalization_panel,'Enable');

function optim2init(hObject,eventdata,forma_panel,vars_list,params_list)

setappdata(params_list,'init_val',getappdata(params_list,'opt_val'));
refresh_params_vars(params_list,1);
setappdata(vars_list,'init_val',getappdata(vars_list,'opt_val'));
refresh_params_vars(vars_list,0);

function call_export_opt(hObject,eventdata,forma_panel,vars_list,params_list)

function assumed=return_assumed_string(val_type,val1,val2,dist_type,dist_params,params_set)

params_types={'set value','range','distribution in range'};
vars_types={'free value','target','range','distribution in range'};

if val_type<4
    if params_set==1
        assumed=params_types{val_type-1};
    else
        assumed=vars_types{val_type};
    end

    if val_type==2
        assumed=[assumed ' = ' num2str(val1)];
    end

    if val_type==3
        assumed=[assumed ' : ' num2str(val1) ' - ' num2str(val2)];
    end

else
    
    param_str=[];
    for indx=1:length(dist_params)
        param_str=[param_str num2str(dist_params(indx)) ','];
    end
    assumed=[dist_type ':' param_str  ' in range : ' num2str(val1) ' - ' num2str(val2)];

end

assumed={assumed};

function dis=return_dis(val_type,val,val1,val2,dist_type,dist_params)

switch val_type
    
    case 1
    dis=NaN;
    
    case 2
    dis=abs(val-val1);
    
    case 3
        if val>val2 | val<val1
            dis=Inf;
        else
            dis=0;
        end

    case 4
        if val>val2 | val<val1
            dis=Inf;
        else
            dis=1./abs(val_pdf(dist_type,val,dist_params));
        end
end

function val=val_pdf(pdf_name,x,params)

if length(params)==1
    val=pdf(pdf_name,x,params(1));
end
if length(params)==2
    val=pdf(pdf_name,x,params(1),params(2));
end
if length(params)==3
    val=pdf(pdf_name,x,params(1),params(2),params(3));
end

function control_edit(hObject,eventdata,forma_panel)

val=str2num(get(hObject,'String'));

if isempty(val) || val<0
    set(hObject,'String',num2str(getappdata(hObject,'DefaultVal')));
end

function pre_optimize(h,params_list,vars_list,optimalization_panel)
block_gui(h);
init_val=getappdata(params_list,'init_val');setappdata(optimalization_panel,'x0',{init_val});
setappdata(optimalization_panel,'x_lb',{-inf(size(init_val))});
setappdata(optimalization_panel,'x_ub',{inf(size(init_val))});

function post_optimize(h,params_list,vars_list,optimalization_panel,forma_panel)

% get optimized values
p_opt_val=cell2mat(getappdata(optimalization_panel,'x'));

% get codes
p_codes=getappdata(params_list,'codes');
v_codes=getappdata(vars_list,'codes');

v_var_val_type=getappdata(vars_list,'var_val_type');
v_mom_type=getappdata(vars_list,'mom_type');
v_base_var=getappdata(vars_list,'base_var');
v_lag=getappdata(vars_list,'lag');

% getting object
p=getappdata(forma_panel,'FORMA_object');

% set params
p.params(p_codes)=p_opt_val;

try
    evalc('p.solve_all=[];');
catch
    warndlg('Solving Forma model failed!','Error','modal');
    return;
end

% get vars
v_opt_val=[];
for indx=1:length(v_var_val_type)
    if v_var_val_type(indx)==1
        v_opt_val(indx)=get_var_ss_val2(p,v_codes(indx));
    else
        v_opt_val(indx)=get_var_moment_val2(p,v_codes(indx),v_mom_type{indx},v_base_var{indx},v_lag{indx});
    end
end

% save values
setappdata(params_list,'opt_val',p_opt_val);
setappdata(vars_list,'opt_val',v_opt_val);

%
unblock_gui(h);

% refresh panels
refresh_params_vars(params_list,1);
refresh_params_vars(vars_list,0);



function cost=full_optimized_func(params_val,forma_panel,params_list,vars_list)

v_calc_val=calc_forma_ss(params_val,forma_panel,params_list,vars_list);

if any(isnan(v_calc_val))
    cost=NaN;return;
end

p_val_type=getappdata(params_list,'val_type');
p_val1=getappdata(params_list,'val1');p_val2=getappdata(params_list,'val2');
p_dist_type=getappdata(params_list,'dist_type');p_dist_params=getappdata(params_list,'dist_params');

v_val_type=getappdata(vars_list,'val_type');
v_val1=getappdata(vars_list,'val1');v_val2=getappdata(vars_list,'val2');
v_dist_type=getappdata(vars_list,'dist_type');v_dist_params=getappdata(vars_list,'dist_params');

% calculating discrepancy
p_dis=[];
for indx=1:length(p_val_type)
        p_dis(indx)=return_dis(p_val_type(indx),params_val(indx),p_val1(indx),p_val2(indx),p_dist_type{indx},p_dist_params{indx});
end

v_dis=[];
for indx=1:length(v_val_type)
        v_dis(indx)=return_dis(v_val_type(indx),v_calc_val(indx),v_val1(indx),v_val2(indx),v_dist_type{indx},v_dist_params{indx});
end

% cost function
cost=log(sum(abs(p_dis))+sum(abs(v_dis)));


function [v_calc_val,varargout]=calc_forma_ss(params_val,forma_panel,params_list,vars_list)

v_calc_val=[];

p_codes=getappdata(params_list,'codes');

v_var_val_type=getappdata(vars_list,'var_val_type');
v_codes=getappdata(vars_list,'codes');

v_mom_type=getappdata(vars_list,'mom_type');
v_base_var=getappdata(vars_list,'base_var');
v_lag=getappdata(vars_list,'lag');

% getting object
p=getappdata(forma_panel,'FORMA_object');

% set params
p.params(p_codes)=params_val;

% solve model
try
    ev_string=evalc('p.solve_all=[];');
catch
    v_calc_val=nan(size(v_codes));return;
end

% check if solved
if p.state==0 || ~isempty(strfind(ev_string, 'error')) || ~isempty(strfind(ev_string, 'warning'))
    v_calc_val=nan(size(v_codes));return;
end

% get values
for indx=1:length(v_var_val_type)
    if v_var_val_type(indx)==1
        v_calc_val(indx)=get_var_ss_val2(p,v_codes(indx));
    else
        v_calc_val(indx)=get_var_moment_val2(p,v_codes(indx),v_mom_type{indx},v_base_var{indx},v_lag{indx});
    end
end

if nargout==2
    varargout{1}=p;
end

function [var_tab_plus, var_tab_minus,params_names,vars_names]=VisAIM_get_impact_func(imp_per,forma_panel,params_list,vars_list,is_percents)

params_val_init=getappdata(params_list,'init_val');
var_tab_plus=[];var_tab_minus=[];

params_names=getappdata(params_list,'names');
vars_names=getappdata(vars_list,'names');

if isempty(vars_names) | isempty(params_names)
    return;
end

info_hand=gui_progress_bar([],'calculations progress...');

if is_percents
    var_tab_unchanged=calc_forma_ss(params_val_init,forma_panel,params_list,vars_list);
end

gui_progress_bar(info_hand,100/(length(params_val_init)+1));

for indx=1:length(params_val_init)

    % set single parameter change
    params_val=params_val_init;params_val(indx)=(1+imp_per/100)*params_val(indx);
    % calc new forma solution
    var_tab_plus(indx,:)=calc_forma_ss(params_val,forma_panel,params_list,vars_list);
    
    % set single parameter change
    params_val=params_val_init;params_val(indx)=(1-imp_per/100)*params_val(indx);
    % calc new forma solution
    var_tab_minus(indx,:)=calc_forma_ss(params_val,forma_panel,params_list,vars_list);

    gui_progress_bar(info_hand,indx*100/(length(params_val_init)+1)-1);

end

if is_percents
    for indx=1:length(params_val_init)
        var_tab_plus(indx,:)=100*(var_tab_plus(indx,:)./var_tab_unchanged-1);
        var_tab_minus(indx,:)=100*(var_tab_minus(indx,:)./var_tab_unchanged-1);
    end
end

try
    close(info_hand)
catch
end

function [var_tab,vars_names]=VisAIM_get_map_func(p_indx,perc_vec,forma_panel,params_list,vars_list,is_percents)

params_val_init=getappdata(params_list,'init_val');

var_tab=[];
vars_names=getappdata(vars_list,'names');

if isempty(vars_names)
    return;
end

info_hand=gui_progress_bar([],'calculations progress...');

if is_percents
    var_tab_unchanged=calc_forma_ss(params_val_init,forma_panel,params_list,vars_list);
end

gui_progress_bar(info_hand,100/(length(perc_vec)+1));

for indx=1:length(perc_vec)
    % set paramater new value
    params_val=params_val_init;params_val(p_indx)=(perc_vec(indx)/100)*params_val_init(p_indx);
    % calc new forma solution
    var_tab(indx,:)=calc_forma_ss(params_val,forma_panel,params_list,vars_list);

    gui_progress_bar(info_hand,(indx+1)*100/(length(perc_vec)+1));
    
end

if is_percents
   for indx=1:length(perc_vec)
    var_tab(indx,:)=100*(var_tab(indx,:)./var_tab_unchanged-1);
   end
end

try
    close(info_hand);
catch
end
    

function export_opt_callback(export_opt,eventdata,forma_panel,params_list,vars_list)

if isempty(getappdata(forma_panel,'FORMA_object'))
    return;
end

params_val=getappdata(params_list,'init_val');
[v_calc_val,optimized_pert]=calc_forma_ss(params_val,forma_panel,params_list,vars_list);
evalc('model_name=optimized_pert.model.name');

button = questdlg('Choose export destiny:','Choose export destiny:','File','Workspace','Cancel','Cancel'); 
switch button
    case 'File'
        [FileName,PathName] = uiputfile('.mat','Save optimized object as *.mat',[model_name '_opt.mat']);
        if ~isequal(FileName,0) & ~isequal(PathName,0)
            save([PathName '\' FileName],'optimized_pert');
        end
    case 'Workspace'
        try
            answer = inputdlg('Export to (output name):','',1,{'optimized_pert'});
            assignin('base', answer{1}, optimized_pert);
        catch
            % do nothing
        end
end


function block_gui(h)
set(getappdata(h,'el2block'),'Enable','Off')

function unblock_gui(h)
set(getappdata(h,'el2block'),'Enable','On')

function panel_handle=gui_set_type(panel_handle,varargin)
% panel_handle=gui_set_type(panel_handle,varargin)
% aux gui tool for VisualAIM

VERSION=1.0;

params_types={'set value','range','distribution in range'};
vars_types={'free value','target','range','distribution in range'};
dist_types={'norm','beta','bino','chi2','logn','exp','poiss','rayl','unif','ev','gam','gev','gp','geo','hyge','nbin','ncf','nct','ncx2','unid','wbl'};max_n_params=3;

params_set=1;

init_val=0;
val1=0;val2=0; 
val_type=2;
dist_type='norm'; dist_params=[1,1];

callback=[];

field1_width=175;field2_width=50;
field_height=25;margin_size=5;

for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

dist_index=0;
for indx=1:length(dist_types)
    if isequal(dist_types{indx},dist_type)
        dist_index=indx;
        break;
    end
end

if params_set==1
    sel_types=params_types;
else
    sel_types=vars_types;
end

if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_set_type v. ' num2str(VERSION)],'Resize','On','MenuBar','None');
    panel_handle=uipanel('Parent',h);
end

set(panel_handle,'Units','Pixels','Position',[100 100 max(field1_width+2*margin_size+max_n_params*(field2_width+margin_size),field1_width+2*field2_width+4*margin_size) 2*field_height+3*margin_size]);

val1_edit=uicontrol('Style','Edit','BackgroundColor','White','Units','Pixels','Position',[field1_width+2*margin_size field_height+2*margin_size field2_width field_height],'String',num2str(val1),...
   'Parent',panel_handle,'Callback',@(hObject,eventdata) change_val1(hObject,eventdata,panel_handle,1));

val2_edit=uicontrol('Style','Edit','BackgroundColor','White','Units','Pixels','Position',[field1_width+field2_width+3*margin_size field_height+2*margin_size field2_width field_height],'String',num2str(val2),'Visible','Off',...
    'Parent',panel_handle,'Callback',@(hObject,eventdata) change_val2(hObject,eventdata,panel_handle,1));

for indx=1:max_n_params
    param_edit(indx)=uicontrol('Style','Edit','BackgroundColor','White','Units','Pixels',...
        'Position',[(field1_width+2*margin_size)+((indx-1)*(field2_width+margin_size)) margin_size field2_width field_height],'UserData',indx,'Visible','Off',...
        'Parent',panel_handle,'Callback',@(hObject,eventdata) change_param(hObject,eventdata,panel_handle,1));
end

for indx=1:length(dist_params)
    set(param_edit(indx),'String',num2str(dist_params(indx)));
end

dist_handle=uicontrol('Style','popupmenu','Units','Pixels','String',dist_types,...
    'BackgroundColor','white','Visible','Off','FontWeight','Bold','FontAngle','Italic','Position',[margin_size margin_size-2 field1_width field_height],...
    'Value',dist_index,'Parent',panel_handle,'Callback',@(hObject,eventdata) change_dist(hObject,eventdata,panel_handle,param_edit,1));

var_type=uicontrol('Style','popupmenu','Units','Pixels','String',sel_types,'Value',val_type-params_set,...
    'BackgroundColor','white','FontWeight','Bold','Position',[margin_size field_height+2*margin_size-2 field1_width field_height],'Parent',panel_handle,...
    'Callback',@(hObject,eventdata) change_type(hObject,eventdata,panel_handle,val1_edit,val2_edit,dist_handle,param_edit,params_set,1));

setappdata(panel_handle,'params_set',params_set);
setappdata(panel_handle,'max_n_params',max_n_params);

setappdata(panel_handle,'init_val',init_val);
setappdata(panel_handle,'val1',val1);setappdata(panel_handle,'val2',val2);
setappdata(panel_handle,'val_type',val_type);
setappdata(panel_handle,'dist_type',dist_type);
setappdata(panel_handle,'dist_params',dist_params);
setappdata(panel_handle,'callback',callback);

change_type(var_type,[],panel_handle,val1_edit,val2_edit,dist_handle,param_edit,params_set,0)

function change_type(hObject,eventdata,panel_handle,val1_edit,val2_edit,dist_handle,param_edit,params_set,is_call)

val_type=get(hObject,'Value')+params_set;
setappdata(panel_handle,'val_type',val_type);

switch val_type
    case 1
        val=getappdata(panel_handle,'init_val');
        setappdata(panel_handle,'val1',val);
        set(val1_edit,'Visible','On','Enable','Inactive','String',num2str(val));
        set([val2_edit,dist_handle,param_edit],'Visible','Off');
    case 2
        if is_call
            val=getappdata(panel_handle,'init_val');
            setappdata(panel_handle,'val1',val);
        else
            val=getappdata(panel_handle,'val1');
        end
        set(val1_edit,'Visible','On','Enable','On','String',num2str(val));
        set([val2_edit,dist_handle,param_edit],'Visible','Off');
        change_val1(val1_edit,eventdata,panel_handle,0);
    case 3
        set([val1_edit,val2_edit],'Visible','On','Enable','On');
        set([dist_handle,param_edit],'Visible','Off');
        change_val1(val1_edit,eventdata,panel_handle,0);change_val2(val2_edit,eventdata,panel_handle,0);
    case 4
        set([val1_edit,val2_edit,dist_handle],'Visible','On','Enable','on');
        change_val1(val1_edit,eventdata,panel_handle,0);change_val2(val2_edit,eventdata,panel_handle,0);
        change_dist(dist_handle,eventdata,panel_handle,param_edit,0);
end

callback=getappdata(panel_handle,'callback');
if ~isempty(callback) && is_call
       feval(callback,panel_handle);
end


function change_val1(hObject,eventdata,panel_handle,is_call)

val_type=getappdata(panel_handle,'val_type');
new_val=str2double(get(hObject,'String'));

if ~isfinite(new_val)
    set(hObject,'String',num2str(getappdata(panel_handle,'val1')));
    return;
end

if val_type>2
   new_val=min(new_val,getappdata(panel_handle,'val2'));
end

set(hObject,'String',num2str(new_val));
setappdata(panel_handle,'val1',new_val);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback)&& is_call
       feval(callback,panel_handle);
end


function change_val2(hObject,eventdata,panel_handle,is_call)

new_val=str2double(get(hObject,'String'));

if ~isfinite(new_val)
    set(hObject,'String',num2str(getappdata(panel_handle,'val2')));
    return;
end

new_val=max(new_val,getappdata(panel_handle,'val1'));
set(hObject,'String',num2str(new_val));
setappdata(panel_handle,'val2',new_val);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback) && is_call
       feval(callback,panel_handle);
end


function change_param(hObject,eventdata,panel_handle,is_call)

dist_params=getappdata(panel_handle,'dist_params');
new_val=str2double(get(hObject,'String'));

if ~isfinite(new_val)
    set(hObject,'String',num2str(dist_params(get(hObject,'UserData'))));
    return;
end

dist_params(get(hObject,'UserData'))=new_val;
setappdata(panel_handle,'dist_params',dist_params);

callback=getappdata(panel_handle,'callback');
if ~isempty(callback) && is_call
       feval(callback,panel_handle);
end

function change_dist(hObject,eventdata,panel_handle,param_edit,is_call)

nme=get(hObject,'String');
dist_nme=nme{get(hObject,'Value')};
setappdata(panel_handle,'dist_type',dist_nme);

dist_n_params=nargin([dist_nme 'pdf'])-1;

dist_params=getappdata(panel_handle,'dist_params');

if dist_n_params>length(dist_params)
    dist_params=[dist_params ones(1,dist_n_params-length(dist_params))];
    setappdata(panel_handle,'dist_params',dist_params);
end

for indx=1:dist_n_params;
    change_param(param_edit(indx),[],panel_handle,0)
end

set(param_edit(1:dist_n_params),'Visible','On');
set(param_edit(dist_n_params+1:getappdata(panel_handle,'max_n_params')),'Visible','Off');

callback=getappdata(panel_handle,'callback');
if ~isempty(callback) && is_call
       feval(callback,panel_handle);
end

function [val_type,val1,val2,dist_type,dist_params]=gui_set_var_type(val_type,val1,val2,dist_type,dist_params,init_val,opt_val,params_set,nme_str)

% modal interface for setting state of variable or parameter
VERSION=1.1;

if nargin<9
    nme_str=['gui_set_var_type v. ' num2str(VERSION)];
end

h=dialog('Position',[400 400 5 5],'Visible','Off','NumberTitle','Off','Name',nme_str,'Resize','Off','MenuBar','None','Color',[0.925 0.914 0.847],'CloseRequestFcn',@close_figure_callback);
setappdata(h,'accept_changes',0);

plot_handle=gui_plot_val_dist(uipanel('Parent',h),'val_type',val_type,'val1',val1,'val2',val2,'dist_type',dist_type,'dist_params',dist_params,'init_val',init_val,'opt_val',opt_val);
setappdata(plot_handle,'init_val',init_val);setappdata(plot_handle,'opt_val',opt_val);

set_handle=gui_set_type(uipanel('Parent',h),'val_type',val_type,'init_val',init_val,'val1',val1,'val2',val2,'dist_type',dist_type,'dist_params',dist_params,'params_set',params_set,'callback',@(hObject) show_on_plot(hObject,plot_handle));

ok_handle=uicontrol('Style','Pushbutton','String','Ok','FontWeight','Bold','Position',[0 0 100 30],...
    'Callback',@(hObject,eventdata) ok_callback(hObject,eventdata,h));

cancel_handle=uicontrol('Style','Pushbutton','String','Cancel','FontWeight','Bold','Position',[0 0 100 30],...
    'Callback',@(hObject,eventdata) cancel_callback(hObject,eventdata,h));

gui_layout(h,{{set_handle {cancel_handle ok_handle}} plot_handle},'margin_x',2,'margin_y',2);
gui_screen_position(h);
set(h,'Visible','On');

uiwait;

% on exit
if getappdata(h,'accept_changes')==1
    val1=getappdata(set_handle,'val1');val2=getappdata(set_handle,'val2');
    dist_type=getappdata(set_handle,'dist_type');dist_params=getappdata(set_handle,'dist_params');
    val_type=getappdata(set_handle,'val_type');
end
delete(h);

function show_on_plot(hObject,plot_handle)

params_set=getappdata(hObject,'params_set');

val_type=getappdata(hObject,'val_type');
val1=getappdata(hObject,'val1');val2=getappdata(hObject,'val2');
dist_type=getappdata(hObject,'dist_type');dist_params=getappdata(hObject,'dist_params');
init_val=getappdata(plot_handle,'init_val');opt_val=getappdata(plot_handle,'opt_val');

setappdata(plot_handle,'init_val',init_val);setappdata(plot_handle,'opt_val',opt_val);
setappdata(plot_handle,'val_type',val_type);
setappdata(plot_handle,'val1',val1);setappdata(plot_handle,'val2',val2);
setappdata(plot_handle,'dist_type',dist_type);setappdata(plot_handle,'dist_params',dist_params);

gui_plot_val_dist(plot_handle,'refresh');

function cancel_callback(hObject,eventdata,h)
uiresume;

function ok_callback(hObject,eventdata,h)
setappdata(h,'accept_changes',1);uiresume;

function close_figure_callback(hObject,eventdata)
uiresume;

function panel_handle=gui_plot_val_dist(panel_handle,varargin)

if nargin==2 && isequal(varargin{1},'refresh')
    refresh(panel_handle,getappdata(panel_handle,'plot_axes'));
    return;
end

size_x=400;size_y=200;
margin_x=30;margin_y=30;

params_set=0;

init_val=0;
opt_val=1;

val1=-2;
val2=2;

dist_type='norm';
dist_params=[0,1];
val_type=4;

for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end


if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_plot_val_dist v. ' num2str(VERSION)],'Resize','On','MenuBar','None');
    panel_handle=uipanel('Parent',h,'Units','Pixels');
else
    set(panel_handle,'Units','pixels');
end
set(panel_handle,'Position',[0 0 size_x+2*margin_x size_y+2*margin_y])

plot_axes=axes('Parent',panel_handle,'Units','Pixels','Position',[margin_x margin_y size_x size_y]);

setappdata(panel_handle,'init_val',init_val);setappdata(panel_handle,'opt_val',opt_val);
setappdata(panel_handle,'val1',val1);setappdata(panel_handle,'val2',val2);
setappdata(panel_handle,'dist_type',dist_type);setappdata(panel_handle,'dist_params',dist_params);
setappdata(panel_handle,'val_type',val_type);setappdata(panel_handle,'params_set',params_set);
setappdata(panel_handle,'plot_axes',plot_axes);

refresh(panel_handle,plot_axes)



function refresh(panel_handle,plot_axes)

init_val=getappdata(panel_handle,'init_val');opt_val=getappdata(panel_handle,'opt_val');
val1=getappdata(panel_handle,'val1');val2=getappdata(panel_handle,'val2');
dist_type=getappdata(panel_handle,'dist_type');dist_params=getappdata(panel_handle,'dist_params');
val_type=getappdata(panel_handle,'val_type');
params_set=getappdata(panel_handle,'params_set');

if val_type>2
    if val2>val1
        domain=[(val1-0.25*(val2-val1)):((val2-val1)/100):(val2+0.25*(val2-val1))];
    else
        domain=[(val1-0.1):0.01:(val1+0.1)];
    end
end

axes(plot_axes);cla(plot_axes);

if val_type<4
    
    hold(plot_axes,'on');
    
    stem(plot_axes,init_val,1,'bx','LineWidth',1.5,'MarkerSize',10);
    
    if ~(params_set==1 & val_type==2) 
        stem(plot_axes,opt_val,1,'rx','LineWidth',1.5,'MarkerSize',10);
    end
    
    mv1=min([init_val,opt_val]);
    mv2=max([init_val,opt_val]); 
    
    if val_type==2          
        if ~isempty(val1)
            if params_set==1
                hl=legend(plot_axes,'value','Location','NE','Orientation','Vertical');set(hl,'FontSize',6);       
            else
                stem(plot_axes,val1,1,'kx','LineWidth',1.5,'MarkerSize',10);
                mv1=min([mv1,val1]);
                mv2=max([mv2,val1]);
                hl=legend(plot_axes,'init','optimized','target','Location','NE','Orientation','Vertical');set(hl,'FontSize',6);
            end
        else
                hl=legend(plot_axes,'init','optimized','Location','NE','Orientation','Vertical');set(hl,'FontSize',6);
        end
    end

    if val_type==3
        plot(plot_axes,domain,double(val1*(1-3*eps('single')*(sign(val1)))<=domain & domain<=val2*(1+3*eps('single')*(sign(val2)))),'k--','LineWidth',1.5)
        hl=legend(plot_axes,'init','optimized','range','Location','NE','Orientation','Vertical');set(hl,'FontSize',6);       
        mv1=min([mv1,val1]);mv2=max([mv2,val2]); 
    end
    
    hold(plot_axes,'off');
    if abs(mv2-mv1)<1e-4;
        mv1=min(mv1,mv2)*(1-3*eps('single')*sign(min(mv1,mv2)));
        mv2=max(mv1,mv2)*(1+3*eps('single')*sign(max(mv1,mv2)));
    end

    axis(plot_axes,[mv1-(mv2-mv1)/10  mv2+(mv2-mv1)/10 0 1.5]);
    
else
    hold(plot_axes,'on');
    stem(plot_axes,init_val,val_pdf(dist_type,init_val,dist_params),'bx','LineWidth',1.5,'MarkerSize',10);
    stem(plot_axes,opt_val,val_pdf(dist_type,opt_val,dist_params),'rx','LineWidth',1.5,'MarkerSize',10);
    dist_val=double(val1-eps('single')<=domain & domain<=val2+eps('single')).*val_pdf(dist_type,domain,dist_params);
    plot(plot_axes,domain,dist_val,'k--','LineWidth',1.5);
    
    mv1=min([init_val,opt_val,domain(1)]);mv2=max([init_val,opt_val,domain(length(domain))]); 

    if abs(mv2-mv1)<1e-4;
        mv1=min(mv1,mv2)-3*eps('single');
        mv2=max(mv1,mv2)+3*eps('single');
    end
    
    hold(plot_axes,'off');
    hl=legend(plot_axes,'init','optimized','distribution','Location','B','Orientation','Vertical');set(hl,'FontSize',6);
    if isfinite(max(dist_val))
        axis(plot_axes,[mv1-(mv2-mv1)/10  mv2+(mv2-mv1)/10 0 max(1.5*max(abs(dist_val)),eps('single'))]);
    end            
end

grid(plot_axes,'on');


function load_state_call(hObject,params_list,vars_list,h)

[FileName,PathName,FilterIndex] = uigetfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Select VisualAIM state to load *.mat',[getappdata(h,'recent_dir') '\visualaim_save.mat']);

if ~isequal(FileName,0) & ~isequal(PathName,0)

    try
        warning off;
        
        load([PathName '\' FileName],'state_obj_params','state_obj_vars','state_aux_obj_params','state_aux_obj_vars');    
        gui_set(params_list,'set state obj',state_obj_params);
        gui_set(vars_list,'set state obj',state_obj_vars);
        
        setappdata(params_list,'val_type',state_aux_obj_params.val_type);
        setappdata(params_list,'val1',state_aux_obj_params.val1);setappdata(params_list,'val2',state_aux_obj_params.val2);
        setappdata(params_list,'dist_type',state_aux_obj_params.dist_type);setappdata(params_list,'dist_params',state_aux_obj_params.dist_params);
        setappdata(params_list,'init_val',state_aux_obj_params.init_val);setappdata(params_list,'opt_val',state_aux_obj_params.opt_val);

        setappdata(vars_list,'var_val_type',state_aux_obj_vars.var_val_type);

        setappdata(vars_list,'val_type',state_aux_obj_vars.val_type);
        setappdata(vars_list,'val1',state_aux_obj_vars.val1);setappdata(vars_list,'val2',state_aux_obj_vars.val2);
        setappdata(vars_list,'dist_type',state_aux_obj_vars.dist_type);setappdata(vars_list,'dist_params',state_aux_obj_vars.dist_params);
        setappdata(vars_list,'init_val',state_aux_obj_vars.init_val);setappdata(vars_list,'opt_val',state_aux_obj_vars.opt_val);

        setappdata(vars_list,'mom_type',state_aux_obj_vars.mom_type);
        setappdata(vars_list,'base_var',state_aux_obj_vars.base_var);
        setappdata(vars_list,'lag',state_aux_obj_vars.lag);
         
        warning on;
        
        setappdata(h,'recent_dir',PathName);
        
    catch
       warndlg('Loading failed!','Loading GUI state failed','modal');
       return;
    end
end

function save_state_call(hObject,params_list,vars_list,h)

state_obj_params=gui_set(params_list,'get state obj');
state_obj_vars=gui_set(vars_list,'get state obj');

state_aux_obj_params.val_type=getappdata(params_list,'val_type');
state_aux_obj_params.val1=getappdata(params_list,'val1');
state_aux_obj_params.val2=getappdata(params_list,'val2');
state_aux_obj_params.dist_type=getappdata(params_list,'dist_type');
state_aux_obj_params.dist_params=getappdata(params_list,'dist_params');
state_aux_obj_params.init_val=getappdata(params_list,'init_val');
state_aux_obj_params.opt_val=getappdata(params_list,'opt_val');

state_aux_obj_vars.var_val_type=getappdata(vars_list,'var_val_type');

state_aux_obj_vars.val_type=getappdata(vars_list,'val_type');
state_aux_obj_vars.val1=getappdata(vars_list,'val1');
state_aux_obj_vars.val2=getappdata(vars_list,'val2');
state_aux_obj_vars.dist_type=getappdata(vars_list,'dist_type');
state_aux_obj_vars.dist_params=getappdata(vars_list,'dist_params');
state_aux_obj_vars.init_val=getappdata(vars_list,'init_val');
state_aux_obj_vars.opt_val=getappdata(vars_list,'opt_val');

state_aux_obj_vars.mom_type=getappdata(vars_list,'mom_type');
state_aux_obj_vars.base_var=getappdata(vars_list,'base_var');
state_aux_obj_vars.lag=getappdata(vars_list,'lag');


[FileName,PathName,FilterName] = uiputfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Save state of GUI',[getappdata(h,'recent_dir') '\visualaim_save.mat']);

if ~isequal(FileName,0) & ~isequal(PathName,0)
    save([PathName '\' FileName],'state_obj_params','state_obj_vars','state_aux_obj_params','state_aux_obj_vars');
    setappdata(h,'recent_dir',PathName);
end