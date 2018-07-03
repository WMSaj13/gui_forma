function Umbrella
% Umbrella : simple solution for forecast v 1.03 Nov 2008

h=figure('HandleVisibility','Off','MenuBar','None','Name','Umbrella 1.03','Color',[0.925 0.914 0.847],'Resize','Off','Visible','Off');

forma_panel=gui_FORMA_panel(uipanel('Parent',h),'is_horizontal',1,'infobox_height',30,'load_button_width',220,'margin',1,'is_reload',0);

banner_one=uicontrol('Parent',h,'Style','text','String','UMBRELLA','ForegroundColor',[0.1 0.1 0.5],'FontWeight','Bold','FontSize',16,'Position',[0 0 200 25]);
banner_two=uicontrol('Parent',h,'Style','text','String','simple solution for Forecast','ForegroundColor',[0.1 0.1 0.85],'FontWeight','Bold','FontSize',8,'Position',[0 0 200 15]);

info_list=gui_set(uipanel('Parent',h),{},{},{},'n_fields_y',4,'n_fields_x',6,'name_field_width',150,...
'name_string','information set variable','value_string',{'type','time serie','length','lag','std dev','data source'},'is_func_rows',1,'is_sortable',1,...
    'func_rows_string',repmat({'get data'},4,1),'not_editable',[2 3],'not_editable_color',[1 1 0.7],'call_func_rows',@(hObject,info_list,i) set_inf_source(hObject,info_list,i,h,forma_panel),...
    'func_button_width',70,'call_func',@(hObject) block_buttons(h),'edit_call_func',@edit_info_list,'value_field_widths',[49 200 60 50 60 80],'changed_color','w');

vars_list=gui_set(uipanel('Parent',h),{},{},{},'n_fields_y',8,'n_fields_x',0,'name_field_width',225,...
'name_string','forecasted variables','call_func',@(hObject) block_buttons(h),'not_editable_color',[0.75 0.75 0.98]);

forecast_option=gui_set(uipanel('Parent',h),{'first quarter','last quarter','forecast type','variance in first period',...
    'initial value','end value','default std dev of info ','zero approx'},...
    {{1} {11} {{'smooth','current','pred'}} {{0,'non zero'}} {{'first value','zero'}} {{'last value','zero'}} {1e-6} {1e-7}},{},'n_fields_y',8,'n_fields_x',1,'name_field_width',100,...
'name_field_width',150,'name_string','option','value_string',{'value'},'is_sortable',0,'is_removable',0,'is_clearable',0,...
'not_editable',[],'not_editable_color',[1 1 0.5],'call_func',@(hObject) block_buttons(h),'edit_call_func',@edit_forecast_option,'value_field_widths',[75],'changed_color','w');


set_type_add_info=uicontrol('Parent',h,'Style','popupmenu','FontWeight','Bold','String',{'Vars','Shocks','Exog'}','Position',[0 0 70 20]);
set_type_add_obsv=uicontrol('Parent',h,'Style','popupmenu','FontWeight','Bold','String',{'Vars','Shocks','Exog'}','Position',[0 0 70 20]);

add_info=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Add information to set','Position',[0 0 175 25],'Callback',@(hObject,eventdata) add_info_callback(hObject,eventdata,forma_panel,info_list,forecast_option,set_type_add_info,h));
add_obsv=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Add forecasted variables','Position',[0 0 175 25],'Callback',@(hObject,eventdata) add_obsv_callback(hObject,eventdata,forma_panel,vars_list,set_type_add_obsv,h));

is_model_recalculated=uicontrol('Parent',h,'Style','checkbox','FontWeight','Bold','String','set approx types and re-solve model','Value',1,'Position',[0 0 250 25]);

make_forecast=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Make forecast','Position',[0 0 250 25],'Callback',@(hObject,eventdata) make_forecast_callback(hObject,forma_panel,info_list,vars_list,forecast_option,is_model_recalculated,h));

are_plots_merged=uicontrol('Parent',h,'Style','checkbox','FontWeight','Bold','String','merge plots','Position',[0 0 100 25]);
are_devs_plotted=uicontrol('Parent',h,'Style','checkbox','FontWeight','Bold','String','show devs','Position',[0 0 80 25]);

plot_info=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Show information','Position',[0 0 125 25],'Callback',@(hObject,eventdata) plot_info_set_callback(hObject,forma_panel,info_list,vars_list,forecast_option,are_plots_merged,h));
plot_obsv=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Show forecasted','Position',[0 0 125 25],'Callback',@(hObject,eventdata) plot_obsv_set_callback(hObject,forma_panel,info_list,vars_list,forecast_option,are_plots_merged,are_devs_plotted,h));

test_forecast=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Test self-consistency of forecast','Position',[0 0 250 25],'Callback',@(hObject,eventdata) test_forecast_callback(hObject,forma_panel,info_list,vars_list,forecast_option,h));
export_forecast=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Export results','Position',[0 0 250 25],'Callback',@(hObject,eventdata) export_xls_callback(hObject,forma_panel,info_list,vars_list,forecast_option,is_model_recalculated,h));

load_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Load state','Position',[0 0 100 21],'Callback',@(hObject,eventdata) load_state_call(hObject,eventdata,forma_panel,info_list,vars_list,forecast_option,h));
save_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Save state','Position',[0 0 100 21],'Callback',@(hObject,eventdata) save_state_call(hObject,eventdata,forma_panel,info_list,vars_list,forecast_option,h));

gui_layout(h,{{{test_forecast export_forecast {are_plots_merged are_devs_plotted} {plot_info plot_obsv} is_model_recalculated make_forecast {add_obsv set_type_add_obsv} {add_info set_type_add_info}} {{vars_list forecast_option  }}} info_list {{banner_two banner_one } forma_panel {save_state load_state}}},'margin_x',1,'margin_y',1);
gui_screen_position(h);
set(h,'Visible','On');

setappdata(h,'f',[]);

setappdata(h,'info_ts',[]);
setappdata(h,'info_dev',[]);
setappdata(h,'info_type',[]);

setappdata(h,'val_level',[]);
setappdata(h,'val_dev',[]);

setappdata(h,'std_val_level',[]);
setappdata(h,'std_val_dev',[]);

setappdata(h,'recent_dir',evalc('pwd'));

% aux
setappdata(h,'buttons2block',[test_forecast export_forecast plot_info plot_obsv]);
set([test_forecast export_forecast plot_info plot_obsv],'Enable','Off')
gui_FORMA_panel(forma_panel,'change_pert_callback',@(hObject) verify_app_codes(hObject,forma_panel,info_list,vars_list,h))
setappdata(h,'equations_stack',{'ss'});
setappdata(h,'equations_len',12);

function clear_sets(h,info_list,vars_list)
block_buttons(h);
gui_set(info_list,'clear');
gui_set(vars_list,'clear');

function add_info_callback(hObject,eventdata,forma_panel,info_list,forecast_option,set_type_add_info,h)

block_buttons(h)

switch get(set_type_add_info,'Value')
    case 1
        names=getappdata(forma_panel,'vars_names');
        indices=getappdata(forma_panel,'vars_indices');
        codes=getappdata(forma_panel,'vars_codes');
    case 2
        names=getappdata(forma_panel,'shocks_names');
        indices=getappdata(forma_panel,'shocks_indices');
        codes=getappdata(forma_panel,'shocks_codes');
    case 3
        names=getappdata(forma_panel,'exogs_names');
        indices=getappdata(forma_panel,'exogs_indices');
        codes=getappdata(forma_panel,'exogs_codes') ;
end

p=getappdata(forma_panel,'FORMA_object');
std_dev=gui_set(forecast_option,'get element',[7 1]);

[sel_full_names,sel_codes]=gui_choose([],names,indices,codes,'add to information set:',0);

switch get(set_type_add_info,'Value')
    case 2
        sel_codes=get_codes(p.model.shocks(sel_codes));
    case 3
        sel_codes=get_codes(p.model.exog(sel_codes));
end

for indx=1:length(sel_codes)
    gui_set(info_list,'add',sel_full_names(indx),repmat({[{{'level','dev'}} {cell2mat(p.vars(sel_codes(indx)).val.get)} {1} {0} {std_dev} {{'constant','var','xls file','equation'}}]},1,length(sel_codes(indx))),sel_codes(indx),'single');
end

function edit_info_list(hObject,indx,val)

if indx(2)==4   
    if (ceil(val)~=val)
        val=ceil(val);
        gui_set(hObject,'set element',indx,val);
    end    
end

if indx(2)==5   
    if val<0
        val=1e-6;
        gui_set(hObject,'set element',indx,val);
    end    
end


function add_obsv_callback(hObject,eventdata,forma_panel,vars_list,set_type_add_obsv,h)

block_buttons(h)

switch get(set_type_add_obsv,'Value')
    case 1
        names=getappdata(forma_panel,'vars_names');
        indices=getappdata(forma_panel,'vars_indices');
        codes=getappdata(forma_panel,'vars_codes');
    case 2
        names=getappdata(forma_panel,'shocks_names');
        indices=getappdata(forma_panel,'shocks_indices');
        codes=getappdata(forma_panel,'shocks_codes');       
    case 3
        names=getappdata(forma_panel,'exogs_names');
        indices=getappdata(forma_panel,'exogs_indices');
        codes=getappdata(forma_panel,'exogs_codes'); 
end

[sel_full_names,sel_codes]=gui_choose([],names,indices,codes,'add to observables:',0);
for indx=1:length(sel_codes)
    gui_set(vars_list,'add',sel_full_names(indx),{},sel_codes(indx),'single');
end

function edit_forecast_option(hObject,indx,val)

if indx(1)<=2
    if (val<1)
        val=1;
    else
        if (ceil(val)~=val)
            val=ceil(val);
        end
    end  
end

switch indx(1)
    
    case 1  
        val_end=gui_set(hObject,'get element',[2 1]);   
        if val>val_end
            val=val_end;
        end
        gui_set(hObject,'set element',indx,val);   
    case 2
        val_beg=gui_set(hObject,'get element',[1 1]);   
        if val<val_beg
            val=val_beg;
        end
        gui_set(hObject,'set element',indx,val);        
    case {7,8}
        if (val<=0)
            [val_tmp,val]=gui_set(hObject,'get element',indx);
            gui_set(hObject,'set element',indx,val);
        end    
end

function make_forecast_callback(hObject,forma_panel,info_list,vars_list,forecast_option,is_model_recalculated,h)

% getting perturbation and model
p=getappdata(forma_panel,'FORMA_object');

if isempty(p)
    return
end

block_buttons(h);
set(hObject,'Enable','Off');

m_model=p.model;

% getting codes of information set and output (observables)
i_codes=getappdata(info_list,'codes');
o_codes=getappdata(vars_list,'codes');

if isempty(i_codes)
    warndlg('Empty information set!','Forecast failed','modal');
    set(hObject,'Enable','On');
    return;
end


% getting info set details
i_val=getappdata(info_list,'out_values');


if get(is_model_recalculated,'Value')==1
    % setting approx types
    p.vars(i_codes).approx_type=1;
    p.vars(o_codes).approx_type=1;
    try
        res_str=evalc('p.solve_all=[];');
    catch
        warndlg('Solving Forma model failed!','Forecast failed','modal');
        set(hObject,'Enable','On');
        return;
    end
end

max_quarter=1;
for indx=1:length(i_val)
    i_type{indx}=i_val{indx}{1};
    i_time_series{indx}=i_val{indx}{2};
    if isempty(i_time_series{indx})
       warndlg('Empty information in set','Forecast failed!','modal');
       return;
    end
    i_lag(indx)=i_val{indx}{4};
    i_std_dev(indx)=i_val{indx}{5};
    i_source{indx}=i_val{indx}{6};
    max_quarter=max(max_quarter,i_lag(indx)+length(i_time_series{indx}));
end

if max_quarter==1
    max_quarter=2;
end;

% info for user
info_hf=gui_progress_bar([],'Making forecast...');
progress_unit=100/(2*length(o_codes)+6);


options_val=getappdata(forecast_option,'out_values');

first_quarter_of_forecast=quarter2time(options_val{1}{1});
last_quarter_of_forecast=quarter2time(options_val{2}{1});

forecast_type=options_val{3}{1};

est_type=options_val{4}{1};
if ~isnumeric(est_type)
    est_type=1;
end

init_value_of_info=options_val{5}{1};
end_value_of_info=options_val{6}{1};

approx_zero=options_val{8}{1};

% solve model, set approx types, makes corrections etc
% time_series{indx} contains info about indx - th variable

for indx=1:length(i_codes);
    
    if isequal(init_value_of_info,'zero')
        init_val=0;
    else
        init_val=i_time_series{indx}(1);
    end
    
    if isequal(end_value_of_info,'zero')
        end_val=0;
    else
        end_val=i_time_series{indx}(length(i_time_series{indx}));
    end
    
    if i_lag(indx)<0
            time_series{indx}=i_time_series{indx}((1-i_lag(indx)):length(i_time_series{indx}));
            time_series{indx}=[time_series{indx}(:) ; end_val*ones(max_quarter-length(time_series{indx}),1)];         
    else
        beg_ts=init_val*ones(i_lag(indx),1); 
        if isequal(i_source{indx},'constant')
            time_series{indx}=[beg_ts ; i_time_series{indx}*ones(max_quarter-length(beg_ts),1)];
        else
            time_series{indx}=[beg_ts ; i_time_series{indx}(:)];
            time_series{indx}=[time_series{indx} ; end_val*ones(max_quarter-length(time_series{indx}),1)]; 
        end           
    end
    time_series{indx}=max(time_series{indx},approx_zero);
end

gui_progress_bar(info_hf,progress_unit);

% set time vector
tQ                      = time('0Q1');
t                       = tQ:tQ:time(quarter2time(max_quarter));

setappdata(h,'info_ts',time_series);
setappdata(h,'info_dev',i_std_dev);
setappdata(h,'info_type',i_type);

for indx=1:length(i_codes)
    in_infoset{indx}               = information;
    in_infoset{indx}(t)            = time_series{indx};
    in_infoset{indx}(t).std        = i_std_dev(indx);
    io_infoset{indx}               = inf_obj(inf_type('ts',i_type{indx}),in_infoset{indx});
end

%% setting info 
in_db_model                = inf_set(m_model);

for indx=1:length(i_codes)
    in_db_model.vars(i_codes(indx)).ts    = io_infoset{indx};
end

gui_progress_bar(info_hf,2*progress_unit);

% forecast preparation
f                       = forecast(p);
f.inf_set               = in_db_model;


f.period_first          = time(first_quarter_of_forecast);
f.period_current        = time(first_quarter_of_forecast);
f.period_last           = time(last_quarter_of_forecast);

gui_progress_bar(info_hf,3*progress_unit);

% making forecast
try
    f = f.make(est_type);
catch
    S=lasterror;
    warndlg(S.message,'Forecast failed!','modal');
    set(hObject,'Enable','On');
    try
        close(info_hf);
    catch
    end
    return;
end

val_level={};
val_dev={};
std_val_level={};
std_val_dev={};


gui_progress_bar(info_hf,6*progress_unit);

if ~isempty(o_codes)
    % getting forecasted values
    forecast_time=time(first_quarter_of_forecast):time('0Q1'):time(last_quarter_of_forecast);

    % forecasted value of variables
    forecast_out=f.vars(o_codes).forecast(forecast_type,forecast_time,inf_type('ts','level')).get;
    for indx=1:length(o_codes)
        val_level{indx}=cell2mat(forecast_out{1}{indx}.inf.mean);
        std_val_level{indx}=cell2mat(forecast_out{1}{indx}.inf.std);
        gui_progress_bar(info_hf,(indx+6)*progress_unit);
    end

    % standard deviation of variables
    forecast_out=f.vars(o_codes).forecast(forecast_type,forecast_time,inf_type('ts','dev')).get;
    for indx=1:length(o_codes)
        val_dev{indx}=cell2mat(forecast_out{1}{indx}.inf.mean);
        std_val_dev{indx}=cell2mat(forecast_out{1}{indx}.inf.std);
        gui_progress_bar(info_hf,(length(o_codes)+indx+6)*progress_unit);
    end
end

setappdata(h,'f',f);
setappdata(h,'val_level',val_level);
setappdata(h,'val_dev',val_dev);
setappdata(h,'std_val_level',std_val_level);
setappdata(h,'std_val_dev',std_val_dev);

try
    close(info_hf);
catch
end

set(hObject,'Enable','On');
unblock_buttons(h)

function set_inf_source(hObject,info_list,i,h,forma_panel)

set(hObject,'Enable','Off');
block_buttons(h);

[names,out_values,codes]=gui_set(info_list,'get row',i);

recent_dir=getappdata(h,'recent_dir');

info_set=out_values{2};

try 
    
    switch out_values{6}
        case 'constant'
            answer = [];
            while (isnan(str2double(answer)) & ~strcmp(answer,'ss')) 
                answer = inputdlg({'Enter value:'},'Constant value information',1,{num2str(info_set(1))});
            end
            if ~isempty(answer)
               if strcmp(answer,'ss')
                    p=getappdata(forma_panel,'FORMA_object');
                    info_set=cell2mat(p.vars(codes).val.get);
               else
                    info_set=str2double(answer);
               end
            else
                set(hObject,'Enable','On');
                return;
            end
            
        case 'var'
        
            variables = evalin('base','whos');list_var={variables.name};
            if isempty(list_var) msgbox('There are no variables in the workspace','Message','error','Modal');return; end

            [s,v] = listdlg('Name','Load time serie from var','ListSize',[320,320],'PromptString','Select var:',...
                'SelectionMode','single','ListString',list_var);
            
        if (v~=0)
                tmp=evalin('base',list_var{s});
                if isnumeric(tmp) & ~isempty(tmp)
                    info_set=tmp(:).';
                else
                    warndlg('Empty or not numeric value','Reading failed','modal')
                    set(hObject,'Enable','On');
                    return;                    
                end
        else
            set(hObject,'Enable','On');
            return; 
        end
       

       
      case 'xls file'
            [FileName,PathName,FilterIndex] = uigetfile('.xls','Select spreadsheet to read data from *.xls',[recent_dir '\file.xls']);
            if ~isequal(FileName,0) & ~isequal(PathName,0)
                try
                    filename=[PathName '\' FileName];
                    tmp=xlsread(filename, -1); 
                    if isnumeric(tmp) & ~isempty(tmp) 
                        info_set=tmp(:).';
                        setappdata(h,'recent_dir',PathName);
                    else
                        error('not valid value')
                    end
                catch
                    warndlg('Reading from xls file failed','Reading failed','modal')
                    set(hObject,'Enable','On');
                    return;
                end
            else
                set(hObject,'Enable','On');
                return;
            end
            
    case 'equation'
        p=getappdata(forma_panel,'FORMA_object');
        equations_stack=getappdata(h,'equations_stack');
        equations_len=getappdata(h,'equations_len');
        
        [info_set,new_equation,equations_len]=enter_equation(cell2mat(p.vars(codes).val.get),equations_stack,equations_len);
        if isempty(info_set)
                set(hObject,'Enable','On');
                return;            
        end
        
        setappdata(h,'equations_stack',[equations_stack {new_equation}])
        setappdata(h,'equations_len',equations_len);
    end
    
catch
    info_set=0;
end

out_values{2}=info_set;
out_values{3}=length(info_set);

gui_set(info_list,'set row',i,out_values);
gui_set(info_list,'refresh');

set(hObject,'Enable','On');

function [info_set,new_equation,equations_length]=enter_equation(ss,equations_stack,equations_length)

% main figure
hev=dialog('Visible','Off','Name','Enter equation');

% defs
ok_bttn=uicontrol('Parent',hev,'Style','pushbutton','FontWeight','Bold','String','OK','Position',[0 0 150 30],'Callback',@(hObject,eventdata) uiresume(hev));
cancel_bttn=uicontrol('Parent',hev,'Style','pushbutton','FontWeight','Bold','String','Cancel','Position',[0 0 150 30],'Callback',@(hObject,eventdata) cancel_callback(hev));

eq_plot=axes('Parent',hev,'Units','Pixels','Position',[0 0 450 150]);cla(eq_plot,'reset');axis(eq_plot,'off');
eq_len=gui_value(uipanel('Parent',hev),'Units','Pixels','value',equations_length,'max_value',200,'min_value',2);

eq_stack=uicontrol('Parent',hev,'Style','popupmenu','Units','Pixels','Position',[0 0 310 30],'String',equations_stack,'Value',length(equations_stack),'BackgroundColor','w','FontAngle','Italic');

eq_edit=uicontrol('Parent',hev,'Style','edit','Units','Pixels','FontWeight','Bold','String',equations_stack{length(equations_stack)},...
    'BackGroundColor','White','Position',[0 0 300 20],'Callback',@(hObject,eventdata) plot_equation(hev,hObject,eq_plot,ok_bttn,getappdata(eq_len,'value'),ss));

text1=uicontrol('Parent',hev,'Style','text','FontWeight','Bold','String','  length :','Position',[0 0 50 15],'Callback',@(hObject,eventdata) cancel_callback(hev));
text2=uicontrol('Parent',hev,'Style','text','FontWeight','Bold','FontAngle',...
'Italic','String','Enter equation using Matlab syntax, t as time variable (vector) and ss as scalar variable equal steady state value ','Position',[0 0 350 30],'Callback',@(hObject,eventdata) cancel_callback(hev));

%aux
set(eq_stack,'Callback',@(hObject,eventdata) use_equation_stack(hev,hObject,eq_edit,eq_plot,ok_bttn,getappdata(eq_len,'value'),ss));
gui_value(eq_len,'refresh','callback',@(hObject,val) plot_equation(hev,eq_edit,eq_plot,ok_bttn,val,ss));
plot_equation(hev,eq_edit,eq_plot,ok_bttn,equations_length,ss);

%runs simple GUI
gui_layout(hev,{{ok_bttn cancel_bttn} {eq_edit text1 eq_len} eq_plot text2},'margin_x',30,'margin_y',12);

pos=getpixelposition(eq_edit);setpixelposition(eq_stack,[pos(1:2) pos(3)+15 pos(4)]);

gui_screen_position(hev);
set(hev,'Visible','On');

uiwait(hev);

try
    info_set=getappdata(hev,'info_set');
    new_equation=get(eq_edit,'String');
    equations_length=getappdata(eq_len,'value');
    close(hev);
catch
    info_set=[];
end

function cancel_callback(hev)
setappdata(hev,'info_set',[]);
uiresume(hev);

function use_equation_stack(hev,hObject,eq_edit,eq_plot,ok_bttn,len,ss)
eq=get(hObject,'String');eq=eq{get(hObject,'Value')};
set(eq_edit,'String',eq);
plot_equation(hev,eq_edit,eq_plot,ok_bttn,len,ss)

function plot_equation(hev,eq_edit,eq_plot,ok_bttn,len,ss)

cla(eq_plot,'reset'); axis(eq_plot,'off');

equation=get(eq_edit,'String');
t=[1:len];

try
    warning off;
    info_set=eval(equation);
    warning on;
    if ~isempty(info_set)
        if length(info_set)==1
            info_set=info_set*ones(1,len);
        end
        plot(eq_plot,t,info_set,'LineWidth',2);grid(eq_plot,'on');
        axis(eq_plot,[0 len+1 min(info_set)-3*eps('single')*abs(min(info_set)-eps('single')) max(info_set)+3*eps('single')*abs(min(info_set))+eps('single')]);
        setappdata(hev,'info_set',info_set);
        set(ok_bttn,'Enable','On');
    else
        set(ok_bttn,'Enable','Off');
    end
catch
    set(ok_bttn,'Enable','Off');
end


function plot_info_set_callback(hObject,forma_panel,info_list,vars_list,forecast_option,are_plots_merged,h)

variab_names=getappdata(info_list,'names');
info_set_ts=getappdata(h,'info_ts');
info_dev=getappdata(h,'info_dev');
info_set_type=getappdata(h,'info_type');

if isempty(info_set_ts)
    return;
end

siz=size(info_set_ts{1});

for indx=1:length(variab_names)
    info_names{indx}=[variab_names{indx} ' ' info_set_type{indx}];
    info_set_dev{indx}=info_dev(indx)*ones(siz);
end

plot_vec(info_names,info_set_ts,info_set_dev,'info set ',get(are_plots_merged,'Value'))


function plot_obsv_set_callback(hObject,forma_panel,info_list,vars_list,forecast_option,are_plots_merged,are_devs_plotted,h)

variab_names=getappdata(vars_list,'names');

if isempty(variab_names)
    return;
end

is_dev=get(are_devs_plotted,'Value');

if is_dev==0
    val=getappdata(h,'val_level');
    std_val=getappdata(h,'std_val_level');
    var_type='level';
else
    val=getappdata(h,'val_dev');
    std_val=getappdata(h,'std_val_dev');
    var_type='dev';
end

for indx=1:length(variab_names)
    info_names{indx}=[variab_names{indx} ' ' var_type];
end

plot_vec(info_names,val,std_val,'forecasted ',get(are_plots_merged,'Value'))

function timestr=quarter2time(quarter_n)

qn=mod(quarter_n-1,4)+1;
yn=floor((quarter_n-1)/4);

timestr=[num2str(yn) 'Q' num2str(qn) ];

function plot_vec(variab_names,values_vec,std_values_vec,name_str,MERGE_PLOTS)

if isempty(variab_names)
    return;
end

N_ON_PLOT=min(6,length(variab_names));

if nargin<5
    MERGE_PLOTS=0;
end


N_variab=length(variab_names);
values_vec_length=length(values_vec{1});


if MERGE_PLOTS==0

    for indx2=1:N_variab
    
        if (mod(indx2,N_ON_PLOT)==1) | (N_variab==1) | (N_ON_PLOT==1)
            figure('Name',[name_str '(part ' num2str(floor((indx2-1)/N_ON_PLOT)+1)  '/' num2str(floor((N_variab-1)/N_ON_PLOT)+1) ' )']);
        end
      
        px=ceil(sqrt(N_ON_PLOT));py=ceil(N_ON_PLOT./px);
        plot_handle=subplot(px,py,mod(indx2-1,N_ON_PLOT)+1);
        set(plot_handle,'FontWeight','Bold','FontSize',12);
    
        if isempty(std_values_vec)
            plot(1:values_vec_length,values_vec{indx2},'LineWidth',2,'Color','b');
        else
            plot(1:values_vec_length,values_vec{indx2},'b-',1:values_vec_length,values_vec{indx2}-std_values_vec{indx2},'b--',1:values_vec_length,values_vec{indx2}+std_values_vec{indx2},'b--','LineWidth',2);
        end
        
        title(variab_names{indx2},'Interpreter','None');
        xlabel('t');
        grid on;
        ax=axis;axis([0 values_vec_length+1 ax(3:4)]);

    end
    
else
    
    figure;axes('FontSize',12,'FontWeight','Bold');
    
    color_tab=['g','b','c','m','y','k'];marker_tab={'None','square','diamond','pentagram','hexagram'};

    hold on;
    for indx2=1:length(values_vec)
        plot_handle=plot(1:values_vec_length,values_vec{indx2},'LineWidth',2,'Marker',marker_tab{mod(floor((indx2-1)/6),5)+1},'Color',color_tab(mod(indx2,6)+1));    
    end

    legend(variab_names,'Interpreter','None');
    
    grid on;
    hold off;
end

function plot_compare_vec2(variab_names,values_vec,std_values_vec,values_vec2,std_values_vec2,name_str,legend_str1,legend_str2)

if isempty(variab_names)
    return;
end

N_variab=length(variab_names);
values_vec_length=length(values_vec{1});

N_ON_PLOT=min(N_variab,6);

for indx2=1:N_variab
    
    if (mod(indx2,N_ON_PLOT)==1) | (N_variab==1) | (N_ON_PLOT==1)
        figure('Name',[name_str '(part ' num2str(floor((indx2-1)/N_ON_PLOT)+1)  '/' num2str(floor((N_variab-1)/N_ON_PLOT)+1) ' )']);
    end
   
    
    px=ceil(sqrt(N_ON_PLOT));py=ceil(N_ON_PLOT./px);
    plot_handle=subplot(px,py,mod(indx2-1,N_ON_PLOT)+1);
    set(plot_handle,'FontWeight','Bold','FontSize',12);
    
    plot(1:values_vec_length,values_vec{indx2},'b-',...
        1:values_vec_length,values_vec2{indx2},'r-',...
        1:values_vec_length,values_vec{indx2}+std_values_vec{indx2},'b:',...
        1:values_vec_length,values_vec{indx2}-std_values_vec{indx2},'b:',...        
        1:values_vec_length,values_vec2{indx2}+std_values_vec2{indx2},'r:',...
        1:values_vec_length,values_vec2{indx2}-std_values_vec2{indx2},'r:',...
        'LineWidth',2);
    
    leg_h=legend(legend_str1,legend_str2);
    set(leg_h,'Interpreter','None','FontSize',6);
    title(variab_names{indx2},'Interpreter','None');
    xlabel('t');
    grid on;
    
    ax=axis;axis([0 values_vec_length+1 ax(3:4)]);

end



function export_xls_callback(hObject,forma_panel,info_list,vars_list,forecast_option,is_model_recalculated,h)

block_buttons(h)

obs_names=getappdata(vars_list,'names');
inf_names=getappdata(info_list,'names');

info_ts=getappdata(h,'info_ts');
info_type=getappdata(h,'info_type');
info_dev=getappdata(h,'info_dev');

val_level=getappdata(h,'val_level');
val_dev=getappdata(h,'val_dev');
std_val_level=getappdata(h,'std_val_level');
std_val_dev=getappdata(h,'std_val_dev');

model_name=get(getappdata(forma_panel,'infobox_handle'),'String');model_name=[model_name{3}];

forecast_opt_name=getappdata(forecast_option,'names');
forecast_opt_val=getappdata(forecast_option,'out_values');
for indx=1:length(forecast_opt_val)
    tmp=forecast_opt_val{indx}{1};
    if isnumeric(tmp)
        tmp=num2str(tmp);
    end
    forecast_opt_val{indx}=tmp;
end

[FileName,PathName,FilterName] = uiputfile({'*.xls' 'Excel file (*.xls)';'*.mat' 'Matlab file (*.mat)';'*.txt' 'text file (*.txt)';'*' 'tex file created with Maalari (*.tex and *.mat)';'*.m' 'm-file with script generating forecast (*.m)'},'Export results',[getappdata(h,'recent_dir') '\forecast_results.xls']);

if ~isequal(FileName,0) & ~isequal(PathName,0)    
    
    % writing
    sep_offset=1;
    beg_offset=sep_offset+1;

if FilterName==3
    try
        
        for indx=1:length(inf_names)
            inf_names{indx}=[inf_names{indx} ' ' info_type{indx}];
        end

        fid=fopen([PathName '\' FileName],'wt');
        
        fprintf(fid,['written by Umbrella on ' datestr(now) '\n' model_name '\n\n']);
    
        fprintf(fid,'Forecasted variables\n');
        for indx=1:length(obs_names)
            fprintf(fid,obs_names{indx});
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        
        fprintf(fid,'Forecasted level of variables\n');
        for indx=1:length(obs_names)
            fprintf(fid,convert_delimiter(num2str(val_level{indx}.')));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    
        fprintf(fid,'Standard deviation for forecasted level of variables\n');
        for indx=1:length(obs_names)
            fprintf(fid,convert_delimiter(num2str(std_val_level{indx}.')));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        
        fprintf(fid,'Forecasted dev of variables\n');
        for indx=1:length(obs_names)
            fprintf(fid,convert_delimiter(num2str(std_val_dev{indx}.')));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        
        fprintf(fid,'Standard deviation for forecasted dev of variables\n');
        for indx=1:length(obs_names)
            fprintf(fid,convert_delimiter(num2str(std_val_dev{indx}.')));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
           
        fprintf(fid,'Info set names\n');
        for indx=1:length(inf_names)
            fprintf(fid,inf_names{indx});
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
       
        fprintf(fid,'Information set time series\n');
        for indx=1:length(info_ts)
            fprintf(fid,convert_delimiter(num2str((info_ts{indx}).')));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        fprintf(fid,'Information set time series dev\n');
        for indx=1:length(info_ts)
            fprintf(fid,convert_delimiter(num2str(info_dev(indx))));
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        
        fprintf(fid,'Options\n');
    
        for indx=1:length(forecast_opt_name)
            fprintf(fid,[forecast_opt_name{indx} ' : ' convert_delimiter(forecast_opt_val{indx})]);
            fprintf(fid,'\n');
        end
   
        fclose(fid);
        
        setappdata(h,'recent_dir',PathName);
        
    catch
        try
            fclose(fid);
        catch
        end
        warndlg('Saving to txt file failed','Saving failed','modal');
    end
end
    
    if FilterName==2
        signature=['Written by Umbrella on ' datestr(now)];
        try
            save([PathName '\' FileName],'inf_names','info_ts','info_dev','info_type',...
            'obs_names','val_level','val_dev','std_val_level','std_val_dev',...
            'forecast_opt_name','forecast_opt_val','signature','model_name');
            setappdata(h,'recent_dir',PathName);
        catch
            warndlg('Saving to mat file failed','Saving failed','modal');
        end
    end
    
    if FilterName==1
        
        for indx=1:length(inf_names)
            inf_names{indx}=[inf_names{indx} ' ' info_type{indx}];
        end
        
        % progress bar
        prog_hf=gui_progress_bar([],'Export progress...');
        val_unit=numel(cell2mat(val_level));
        inf_unit=length(inf_names)*length(info_ts{1});
        progress_unit=100/(13+4*val_unit+inf_unit);
    
        warning('off','MATLAB:xlswrite:AddSheet');
    
        try  
                       
            %writing headers
            xlswrite([PathName '\' FileName],{'Forecasted level of variables'},'Forecast results',['A' num2str(beg_offset)]);
            xlswrite([PathName '\' FileName],{'Standard deviation for forecasted level of variables'},'Forecast results',['A' num2str(beg_offset+sep_offset+length(obs_names)+1)]);
            pause(1);gui_progress_bar(prog_hf,2*progress_unit);refresh(prog_hf);
        
            xlswrite([PathName '\' FileName],{'Forecasted dev of variables'},'Forecast results',['A' num2str(beg_offset+2*(sep_offset+length(obs_names))+2)]);
            xlswrite([PathName '\' FileName],{'Standard deviation for forecasted dev of variables'},'Forecast results',['A' num2str(beg_offset+3*(sep_offset+length(obs_names))+3)]);
            pause(1);gui_progress_bar(prog_hf,4*progress_unit);refresh(prog_hf);
        
            xlswrite([PathName '\' FileName],{'Information set time series'},'Forecast results',['A' num2str(beg_offset+4*(sep_offset+length(obs_names))+4)]);
            xlswrite([PathName '\' FileName],{'Information set time series dev'},'Forecast results',['A' num2str(beg_offset+5*sep_offset+4*length(obs_names)+length(inf_names)+5)]);
            pause(1);gui_progress_bar(prog_hf,5*progress_unit);refresh(prog_hf);
        
            % writing data
            if ~isempty(val_level)
                xlswrite([PathName '\' FileName],cell2mat(val_level).','Forecast results',['B' num2str(beg_offset+1)]);
                pause(1);gui_progress_bar(prog_hf,(val_unit+5)*progress_unit);refresh(prog_hf)
                xlswrite([PathName '\' FileName],cell2mat(std_val_level).','Forecast results',['B' num2str(beg_offset+sep_offset+length(obs_names)+2)]);
                pause(1);gui_progress_bar(prog_hf,(2*val_unit+5)*progress_unit);refresh(prog_hf)
                xlswrite([PathName '\' FileName],cell2mat(val_dev).','Forecast results',['B' num2str(beg_offset+2*(sep_offset+length(obs_names))+3)]);
                pause(1);gui_progress_bar(prog_hf,(3*val_unit+5)*progress_unit);refresh(prog_hf)
                xlswrite([PathName '\' FileName],cell2mat(std_val_dev).','Forecast results',['B' num2str(beg_offset+3*(sep_offset+length(obs_names))+4)]);
                pause(1);gui_progress_bar(prog_hf,(4*val_unit+5)*progress_unit);refresh(prog_hf)
            end
            xlswrite([PathName '\' FileName],cell2mat(info_ts).','Forecast results',['B' num2str(beg_offset+4*(sep_offset+length(obs_names))+5)]);
            xlswrite([PathName '\' FileName],info_dev(:),'Forecast results',['B' num2str(beg_offset+5*sep_offset+4*length(obs_names)+length(inf_names)+6)]);
            pause(1);gui_progress_bar(prog_hf,(4*val_unit+inf_unit+5)*progress_unit);refresh(prog_hf)
        
            %writing names
            if ~isempty(val_level)
                xlswrite([PathName '\' FileName],obs_names.','Forecast results',['A' num2str(beg_offset+1)]);
                xlswrite([PathName '\' FileName],obs_names.','Forecast results',['A' num2str(beg_offset+sep_offset+length(obs_names)+2)]);
                pause(1);gui_progress_bar(prog_hf,(4*val_unit+inf_unit+7)*progress_unit);refresh(prog_hf);
            
                xlswrite([PathName '\' FileName],obs_names.','Forecast results',['A' num2str(beg_offset+2*(sep_offset+length(obs_names))+3)]);
                xlswrite([PathName '\' FileName],obs_names.','Forecast results',['A' num2str(beg_offset+3*(sep_offset+length(obs_names))+4)]);
                pause(1);gui_progress_bar(prog_hf,(4*val_unit+inf_unit+9)*progress_unit);refresh(prog_hf);
            end
            xlswrite([PathName '\' FileName],inf_names.','Forecast results',['A' num2str(beg_offset+4*(sep_offset+length(obs_names))+5)]);
            xlswrite([PathName '\' FileName],inf_names.','Forecast results',['A' num2str(beg_offset+5*sep_offset+4*length(obs_names)+length(inf_names)+6)]);
            pause(1);gui_progress_bar(prog_hf,(4*val_unit+inf_unit+10)*progress_unit);refresh(prog_hf)
        
            % writing signature
            xlswrite([PathName '\' FileName],{['Parameters of forecast (written by Umbrella on ' datestr(now) ') : ' model_name]},'Forecast results',['A' num2str(beg_offset+5*sep_offset+4*length(obs_names)+2*length(inf_names)+7)]);
            xlswrite([PathName '\' FileName],forecast_opt_name.','Forecast results',['A' num2str(beg_offset+5*sep_offset+4*length(obs_names)+2*length(inf_names)+8)]);
            xlswrite([PathName '\' FileName],forecast_opt_val.','Forecast results',['B' num2str(beg_offset+5*sep_offset+4*length(obs_names)+2*length(inf_names)+8)]);
            pause(1);gui_progress_bar(prog_hf,(4*val_unit+inf_unit+13)*progress_unit);refresh(prog_hf)
        
        catch
            warndlg('Saving to xls file failed','Saving failed','modal');
        end

        warning('on','MATLAB:xlswrite:AddSheet');
        setappdata(h,'recent_dir',PathName);
            
        try
            close(prog_hf);
        catch
        end
    end
    
    if FilterName==4
            try
                    h_wd=warndlg('Exporting data through Maalari','Please wait...');
                    
                    % mat with maalari objects                           
                    umbrella_output2maalari_info = plotter;
                    
                    umbrella_output2maalari_info.Var(1).data=[cell2mat(info_ts)].';
                    umbrella_output2maalari_info.Var(1).colour='blue';
                    umbrella_output2maalari_info.Var(1).pattern=1;
                    umbrella_output2maalari_info.Var(1).thickness=1.0; 
                    
                    umbrella_output2maalari_info.Var(2).data=[cell2mat(info_ts)+repmat(info_dev,[size(cell2mat(info_ts),1) 1])].';
                    umbrella_output2maalari_info.Var(2).colour='blue';
                    umbrella_output2maalari_info.Var(2).pattern=2;
                    umbrella_output2maalari_info.Var(2).thickness=1.0; 
                    
                    umbrella_output2maalari_info.Var(3).data=[cell2mat(info_ts)-repmat(info_dev,[size(cell2mat(info_ts),1) 1])].';
                    umbrella_output2maalari_info.Var(3).colour='blue';
                    umbrella_output2maalari_info.Var(3).pattern=2;
                    umbrella_output2maalari_info.Var(3).thickness=1.0;

                    umbrella_output2maalari_info.Axes.X.desc=repmat({'t'},size(inf_names.'));
                    umbrella_output2maalari_info.Axes.Y.desc=convert2latex(inf_names.');
                    
                    umbrella_output2maalari_info.Latex.Captions=repmat({'Information set for Umbrella'},size(inf_names.'));
                
                    umbrella_output2maalari_info.OutName=[FileName '_info_set'] ;
                   
                    umbrella_output2maalari_fore = plotter;
       
                    umbrella_output2maalari_fore.Var(1).data=[cell2mat(val_level)].';
                    umbrella_output2maalari_fore.Var(1).colour='blue';
                    umbrella_output2maalari_fore.Var(1).pattern=1;
                    umbrella_output2maalari_fore.Var(1).thickness=1.0; 

                    umbrella_output2maalari_fore.Var(2).data=[cell2mat(val_level)+cell2mat(std_val_level)].';
                    umbrella_output2maalari_fore.Var(2).colour='blue';
                    umbrella_output2maalari_fore.Var(2).pattern=2;
                    umbrella_output2maalari_fore.Var(2).thickness=1.0; 
                    
                    umbrella_output2maalari_fore.Var(3).data=[cell2mat(val_level)-cell2mat(std_val_level)].';
                    umbrella_output2maalari_fore.Var(3).colour='blue';
                    umbrella_output2maalari_fore.Var(3).pattern=2;
                    umbrella_output2maalari_fore.Var(3).thickness=1.0;
                       
                    umbrella_output2maalari_fore.Axes.X.desc=repmat({'t'},size(obs_names.'));
                    umbrella_output2maalari_fore.Axes.Y.desc=convert2latex(obs_names.');
                    
                    umbrella_output2maalari_fore.Latex.Captions=repmat({'Results from Umbrella'},size(obs_names.'));
                    umbrella_output2maalari_fore.OutName=[FileName '_forecast'] ;
                
                    save([PathName '\' FileName '.mat'],'umbrella_output2maalari_info','umbrella_output2maalari_fore');
                    
                    umbrella_output2maalari_info.plot;
                    umbrella_output2maalari_fore.plot;
                                        
            catch
                   warndlg('Export via Maalari failed','Saving failed','modal');
            end

            try
               close(h_wd);
            catch
            end
    end
    
    if FilterName==5
        try            
            obj_name=getappdata(forma_panel,'FORMA_object_name');
            
            fid=fopen([PathName '\' FileName],'wt');

            fprintf(fid,['%% generated by Umbrella on ' datestr(now) '\n']);
            fprintf(fid,['%% assumes that perturbation object ' obj_name ' (' model_name ') is in the workspace\n\n']);
        
            fprintf(fid,['%% getting model\n']);
            fprintf(fid,['m_model=' obj_name '.model;\n\n']);

            fprintf(fid,['%% information set\n']);
            fprintf(fid,['i_vars={']);
            for indx=1:length(inf_names)-1
                fprintf(fid,['''' inf_names{indx} ''',']);
            end
            fprintf(fid,['''' inf_names{length(inf_names)} '''};\n\n']);

            fprintf(fid,['%% time_series{indx} contains info about indx - th variable\n']);

            for indx=1:length(info_ts)
                fprintf(fid,['%% ' inf_names{indx} '\n']);
                fprintf(fid,['time_series{' num2str(indx) '}=[' num2str(info_ts{indx}.') '];\n']);
                fprintf(fid,['i_type{' num2str(indx) '}=''' info_type{indx} ''';\n']);
                fprintf(fid,['i_std_dev(' num2str(indx) ')=' num2str(info_dev(indx)) ';\n']); 
            end

            fprintf(fid,['\n%% forecasted variables\n']);
            fprintf(fid,['o_vars={']);

            for indx=1:length(obs_names)-1
                fprintf(fid,['''' obs_names{indx} ''',']);
            end
            fprintf(fid,['''' obs_names{length(obs_names)} '''};\n\n']);
    
            fprintf(fid,['%% forecast range and type\n']);

            fprintf(fid,['first_quarter_of_forecast = ''' quarter2time(str2double(forecast_opt_val{1})) ''';\n']);
            fprintf(fid,['last_quarter_of_forecast = ''' quarter2time(str2double(forecast_opt_val{2}))  ''';\n']);
            fprintf(fid,['forecast_type = ''' forecast_opt_val{3}  ''';\n\n']);

            if get(is_model_recalculated,'Value')==1
                fprintf(fid,['%% re-calculate model and set approx types\n']);
                fprintf(fid,[obj_name '.vars(i_vars).approx_type=1;\n']);
                fprintf(fid,[obj_name '.vars(o_vars).approx_type=1;\n']);
                fprintf(fid,[obj_name '.solve_all=[];\n\n']);
            end

            fprintf(fid,['%% solve model, set approx types, makes corrections etc\n']);
            fprintf(fid,['%% set time vector\n']);

            fprintf(fid,['tQ                      = time(''0Q1'');\n']);
            fprintf(fid,['t                       = tQ:tQ:time(''' quarter2time(length(info_ts{1})) ''');\n\n']);

            fprintf(fid,['for indx=1:length(i_vars)\n']);
            fprintf(fid,['    in_infoset{indx}               = information;\n']);
            fprintf(fid,['    in_infoset{indx}(t)            = time_series{indx};\n']);
            fprintf(fid,['    in_infoset{indx}(t).std        = i_std_dev(indx);\n']);
            fprintf(fid,['    io_infoset{indx}               = inf_obj(inf_type(''ts'',i_type{indx}),in_infoset{indx});\n']);
            fprintf(fid,['end\n\n']);
            fprintf(fid,['%% setting info\n']); 
            fprintf(fid,['in_db_model                = inf_set(m_model);\n']);
            fprintf(fid,['for indx=1:length(i_vars)\n']);
            fprintf(fid,['    in_db_model.vars(i_vars(indx)).ts    = io_infoset{indx};\n']);
            fprintf(fid,['end\n\n']);

            fprintf(fid,['%% forecast preparation\n']);
            fprintf(fid,['f                       = forecast(' obj_name ');\n']);
            fprintf(fid,['f.inf_set               = in_db_model;\n']);
            fprintf(fid,['f.period_first          = time(first_quarter_of_forecast);\n']);
            fprintf(fid,['f.period_current        = time(first_quarter_of_forecast);\n']);
            fprintf(fid,['f.period_last           = time(last_quarter_of_forecast);\n\n']);
            fprintf(fid,['%% making forecast\n']);
            fprintf(fid,['f = f.make(' forecast_opt_val{4} ');\n\n']);

            fprintf(fid,['%% get forecasted value\n']);
            fprintf(fid,['if ~isempty(o_vars)\n']);
            fprintf(fid,['    %% getting forecasted values\n']);
            fprintf(fid,['    forecast_time=time(first_quarter_of_forecast):time(''0Q1''):time(last_quarter_of_forecast);\n']);
            fprintf(fid,['    %% forecasted value of variables\n']);
            fprintf(fid,['    %% showing a result\n']);
            fprintf(fid,['    f.vars(o_vars).forecast(forecast_type,forecast_time,inf_type(''ts'',''level''));\n']);
            fprintf(fid,['    %% forecasted value of variables\n']);
            fprintf(fid,['    forecast_out_lev=f.vars(o_vars).forecast(forecast_type,forecast_time,inf_type(''ts'',''level'')).get;\n']);
            fprintf(fid,['    %% standard deviation of variables\n']);
            fprintf(fid,['    forecast_out_dev=f.vars(o_vars).forecast(forecast_type,forecast_time,inf_type(''ts'',''dev'')).get;\n']);
            fprintf(fid,['end\n']);
            
            fclose(fid);
            
         catch
            warndlg('Saving script file failed','Saving failed','modal');
            try
                 fclose(fid);
            catch
             end
         end
    end
    
end

unblock_buttons(h);

function txt=convert_delimiter(txt)
txt(txt=='.')=',';

function txt=convert2latex(txt)
txt=regexprep(regexprep(txt, '<', '$\\langle$'),'>','$\\rangle$');

function test_forecast_callback(hObject,forma_panel,info_list,vars_list,forecast_option,h)

block_buttons(h)
set(hObject,'Enable','Off');

% getting forecast
f=getappdata(h,'f');

if isempty(f)
    set(hObject,'Enable','On');
    return;
end

% getting time series
info_set_ts=getappdata(h,'info_ts');
info_dev=getappdata(h,'info_dev');
info_set_type=getappdata(h,'info_type');

% getting codes of information set and output (observables)
t_codes=getappdata(info_list,'codes');
var_names=getappdata(info_list,'names');

% info for user
info_hf=gui_progress_bar([],'Testing forecast...');
progress_unit=100/(length(t_codes)+1);


options_val=getappdata(forecast_option,'out_values');

first_quarter_of_forecast=quarter2time(options_val{1}{1});
last_quarter_of_forecast=quarter2time(options_val{2}{1});

forecast_type=options_val{3}{1};

% getting forecasted values
forecast_time=time(first_quarter_of_forecast):time('0Q1'):time(last_quarter_of_forecast);


gui_progress_bar(info_hf,progress_unit);

% forecasted value of variables
for indx=1:length(t_codes)
    
    forecast_out=f.vars(t_codes(indx)).forecast(forecast_type,forecast_time,inf_type('ts',info_set_type{indx})).get;
    val_level{indx}=cell2mat(forecast_out{1}{1}.inf.mean);
    std_val_level{indx}=cell2mat(forecast_out{1}{1}.inf.std);
    
    gui_progress_bar(info_hf,(1+indx)*progress_unit);
end

lv=min(length(info_set_ts{1}),length(val_level{1}));


for indx=1:length(t_codes)
   
   fore_ts{indx}=val_level{indx}(1:lv);
   std_fore_ts{indx}=std_val_level{indx}(1:lv);
   
   info_ts{indx}=info_set_ts{indx}(1:lv);
   std_info_ts{indx}=info_dev(indx)*ones(lv,1);
   
   discr=sum(((fore_ts{indx}-info_ts{indx}).^2)./(std_info_ts{indx}.^2+std_fore_ts{indx}.^2)); 
   
   var_names{indx}=[var_names{indx} ' ' info_set_type{indx} ', overall discrepancy : ' num2str(discr)];

end

gui_progress_bar(info_hf,100);

plot_compare_vec2(var_names,info_ts,std_info_ts,fore_ts,std_fore_ts,'Information set reproduced by forecast','info','forecast')


try
    close(info_hf)
catch
end

set(hObject,'Enable','Off');
unblock_buttons(h)

function block_buttons(h)
set(getappdata(h,'buttons2block'),'Enable','Off')

function unblock_buttons(h)
set(getappdata(h,'buttons2block'),'Enable','On')


function load_state_call(hObject,eventdata,forma_panel,info_list,vars_list,forecast_option,h)

block_buttons(h);

[FileName,PathName,FilterIndex] = uigetfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Select Umbrella state to load *.mat',[getappdata(h,'recent_dir') '\umbrella_save.mat']);

if ~isequal(FileName,0) & ~isequal(PathName,0)

    try
        warning off;
        load([PathName '\' FileName],'state_obj_info','state_obj_vars','state_obj_opt');    
        gui_set(info_list,'set state obj',state_obj_info);
        gui_set(vars_list,'set state obj',state_obj_vars);
        gui_set(forecast_option,'set state obj',state_obj_opt);
        warning on;
        
        setappdata(h,'recent_dir',PathName);
        
    catch
       warndlg('Loading failed!','Loading GUI state failed','modal');
       return;
    end
    
    if ~isempty(getappdata(forma_panel,'FORMA_object'))
        verify_app_codes(hObject,forma_panel,info_list,vars_list,h);
    end
end

function save_state_call(hObject,eventdata,forma_panel,info_list,vars_list,forecast_option,h)

state_obj_info=gui_set(info_list,'get state obj');
state_obj_vars=gui_set(vars_list,'get state obj');
state_obj_opt=gui_set(forecast_option,'get state obj');

[FileName,PathName,FilterName] = uiputfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Save state of GUI',[getappdata(h,'recent_dir') '\umbrella_save.mat']);

if ~isequal(FileName,0) & ~isequal(PathName,0)
    save([PathName '\' FileName],'state_obj_info','state_obj_vars','state_obj_opt');
    setappdata(h,'recent_dir',PathName);
end


function verify_app_codes(hObject,forma_panel,info_list,vars_list,h)

model_names=getappdata(forma_panel,'vars_full_names');
model_codes=getappdata(forma_panel,'vars_full_codes');

[del_names1,cod_names1]= verify_codes(model_names,model_codes,info_list);
[del_names2,cod_names2]= verify_codes(model_names,model_codes,vars_list);

% info dialog
if ~isempty(del_names1) | ~isempty(del_names2) | ~isempty(cod_names1) | ~isempty(cod_names2)
    
    S=...
    [{'Vars excluded from info set (unknown in model):'} del_names1 {' '}...
    {'Vars with updated codes in info set:'} cod_names1 {' '}...
    {'Vars excluded from forecasted set (unknown in model):'} del_names2 {' '}...
    {'Vars with upadated codes in forecasted set:'} cod_names2];

    listdlg('ListString',S,'Name','Auto-changes in information set','ListSize',[600 160]);
end



function [del_names,cod_names]= verify_codes(model_names,model_codes,comp_handle) 

i_names=getappdata(comp_handle,'names');
i_values=getappdata(comp_handle,'values');
i_codes=getappdata(comp_handle,'codes');

deleted_list=[];
codes_changed_list=[];

for indx=1:length(i_names)
    
    on_list=0;code_remains=1;
    
    for indx2=1:length(model_names)
        
        if strcmp(i_names{indx},model_names(indx2))
            on_list=1;
                if (i_codes(indx)~=model_codes(indx2))
                    i_codes(indx)=model_codes(indx2);
                    code_remains=0;                   
                end
            break;
        end
    end
    
        if on_list==0
            deleted_list=[deleted_list indx];
        end
        
        if code_remains==0
            codes_changed_list=[codes_changed_list indx];
        end

end

del_names=[];
cod_names=[];

if ~isempty(deleted_list) | ~isempty(codes_changed_list)
   remained_ind=setdiff(1:length(i_names),deleted_list);
   
   del_names=i_names(deleted_list);
   cod_names=i_names(codes_changed_list);
   
   i_names=i_names(remained_ind);
   i_values=i_values(remained_ind);
   i_codes=i_codes(remained_ind);
   gui_set(comp_handle,'refresh',i_names,i_values,i_codes);
end

