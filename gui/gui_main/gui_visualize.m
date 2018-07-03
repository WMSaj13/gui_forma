function panel_handle=gui_visualize(panel_handle,varargin)
% % gui_visualize v 1.0 (Aug 2008)
% %
% %  component for visualization of dependency between multiple value (vector value) function:
% %    (map option)    single parameter value change in range 0-200% 
% %    (impact option) change of value for change for all of parameters in range +-few percents  
% %
% % panel_handle=gui_visualize(panel_handle,'param1_name',param1_val,'param2_name',param2_val...)
% %   create a new component with given parameters
% %
% % panel_handle=gui_visualize(panel_handle,'refresh',params_names,params_codes)
% %   refresh params data in the component
% % 
% % ---------- parameters-------------
% % params_names={};            names of parameters to choose 
% % params_codes=[];            codes paramaters to choose
% %
% % get_impact_func=[];         callback to function  
% %                             [var_tab_plus,var_tab_minus,params_names,...
% %                             vars_names]=get_impact_func(imp_per,is_perc)
% %                             that for given change in +-% imp_per returns
% %                             1)variable change in percents if is_percents==1)
% %                             in cell arrays val_tab_plus,val_tab_minus of length 
% %                             equal to # of variables  with vector of length egual 
% %                             to # of parameters 2)names of parameters and values
% %
% % get_map_func=[];            callback to function
% %                             [var_tab,vars_names]=get_map_func(param_name,
% %                             param_code,i,perc_vec,is_perc);
% %                             that for given parameter (given by name, code and position i 
% %                             in the params_names list) change perc_vec returns
% %                             1) variable change in percents if is_percents==1 or value
% %                             in cell array var_tab of length equal to # of variables 
% %                             with vector of length egual to length of
% %                             perc_vec
% %                             2) names of variables
% %
% % ------------W.M.Saj 2008-------------

VERSION=1.0;

if nargin==4 
    if isequal(varargin{1},'refresh params')
        params_list=getappdata(panel_handle,'params_list');
        setappdata(params_list,'names',varargin{2});
        setappdata(params_list,'codes',varargin{3});
        gui_set(params_list,'refresh');
        return;
    end
end

params_names={};
params_codes=[];

get_impact_func=[];
get_map_func=[];

%% setting values
for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

%%
if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_visualize v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [100 100 700 250]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',[100 100 700 250]);
end

is_percents=uicontrol('Parent',panel_handle,'Style','checkbox','FontWeight','Bold','String','change in percents','Position',[0 0 130 20],'Value',1);
is_values=uicontrol('Parent',panel_handle,'Style','checkbox','FontWeight','Bold','String','show values','Position',[0 0 100 20],'Value',1,'Callback',@(hObject,eventdata) change_values_vis(hObject,is_percents));

perc_impact=gui_value(uipanel('Parent',panel_handle),'value',10,'min_value',-100,'max_value',100);

perc_map_min=gui_value(uipanel('Parent',panel_handle),'value',0,'min_value',0,'max_value',199);
perc_map_stp=gui_value(uipanel('Parent',panel_handle),'value',10,'min_value',1,'max_value',20);
perc_map_max=gui_value(uipanel('Parent',panel_handle),'value',100,'min_value',1,'max_value',200);

p1=uicontrol('Parent',panel_handle,'Style','Text','String','%','Units','Pixels','Position',[0 0 10 20],'FontWeight','Bold');
p2=uicontrol('Parent',panel_handle,'Style','Text','String','%','Units','Pixels','Position',[0 0 10 20],'FontWeight','Bold');

d1=uicontrol('Parent',panel_handle,'Style','Text','String',':','Units','Pixels','Position',[0 0 10 20],'FontWeight','Bold');
d2=uicontrol('Parent',panel_handle,'Style','Text','String',':','Units','Pixels','Position',[0 0 10 20],'FontWeight','Bold');

params_list=gui_set(uipanel('Parent',panel_handle),params_names,{},params_codes,'n_fields_y',1,'n_fields_x',0,...
    'name_field_width',150,'name_string','parameter name',...
    'is_func_rows',1,'is_sortable',0,'is_removable',0,'is_clearable',0,'is_named',0,'not_editable_color',[1 1 0.3],'func_rows_string',{'map'},...
    'call_func_rows',@(map_button,params_list,i) call_show_map(panel_handle,map_button,params_list,i,perc_map_min,perc_map_stp,perc_map_max,is_percents,is_values),...
    'func_button_width',35);

show_impact=uicontrol('Parent',panel_handle,'Style','pushbutton','FontWeight','Bold','String','Show impact','Position',[0 0 150 25],'Callback',@(impact_button,eventdata) call_show_impact(impact_button,panel_handle,perc_impact,is_percents,is_values));

gui_layout(panel_handle,{{show_impact perc_impact p1} {is_values is_percents} {perc_map_min d1 perc_map_stp d2 perc_map_max p2} params_list},'margin_x',5,'margin_y',5);

setappdata(panel_handle,'get_impact_func',get_impact_func);
setappdata(panel_handle,'get_map_func',get_map_func);
setappdata(panel_handle,'params_list',params_list);


function call_show_impact(impact_button,panel_handle,perc_impact,is_percents,is_values)

set(impact_button,'Enable','Off');pause(0.001);

get_impact_func=getappdata(panel_handle,'get_impact_func');

if ~isempty(get_impact_func)
    imp_per=getappdata(perc_impact,'value');
    is_perc=get(is_percents,'Value');
    [var_tab_plus, var_tab_minus,params_names,vars_names]=feval(get_impact_func,imp_per,is_perc);
else
    return;
end

h=findobj('Tag',['gui_visualize output (' num2str(panel_handle) ')']);
if isempty(h)
    h=figure('Name','Show impact of parameters','Tag',['gui_visualize output (' num2str(panel_handle) ')']);
end

clf(h);

if isempty(var_tab_plus)
    set(impact_button,'Enable','On');
    return
end

if all(size(var_tab_plus)>1)
    subplot(2,1,1);
    plot_checkerboard(params_names,vars_names,var_tab_plus,['+' num2str(imp_per) '%'],1,1,get(is_values,'Value'),1,get(is_percents,'Value'));
    subplot(2,1,2);
    plot_checkerboard(params_names,vars_names,var_tab_minus,['-' num2str(imp_per) '%'],1,1,get(is_values,'Value'),1,get(is_percents,'Value'));
else
    
    if length(vars_names)>1
        ticks_str=vars_names;
    else
        ticks_str=params_names;
    end
    
    subplot(2,1,1);
    plot_bar(var_tab_plus,'g',ticks_str,get(is_values,'Value'),1,get(is_percents,'Value'))
    title(['+' num2str(imp_per) '%']);
    
    
    subplot(2,1,2);
    plot_bar(var_tab_minus,'r',ticks_str,get(is_values,'Value'),1,get(is_percents,'Value'));
    title(['-' num2str(imp_per) '%']);
    
end

set(impact_button,'Enable','On');

function call_show_map(panel_handle,map_button,params_list,i,perc_map_min,perc_map_stp,perc_map_max,is_percents,is_values)

set(map_button,'Enable','Off');pause(0.001);

get_map_func=getappdata(panel_handle,'get_map_func');

is_perc=get(is_percents,'Value');

if ~isempty(get_map_func)
    
    param_name=getappdata(params_list,'names');param_name=param_name{i};
    param_code=getappdata(params_list,'codes');param_code=param_code(i);
    
    perc_min=getappdata(perc_map_min,'value');
    perc_stp=getappdata(perc_map_stp,'value');
    perc_max=getappdata(perc_map_max,'value');
    [var_tab,vars_names]=feval(get_map_func,param_name,param_code,i,perc_min:perc_stp:perc_max,is_perc);
else
    return;
end

percents_str=[];
for perc=perc_min:perc_stp:perc_max
    percents_str=[percents_str {[num2str(perc) '%']}];
end

h=findobj('Tag',['gui_visualize output (' num2str(panel_handle) ')']);
if isempty(h)
    h=figure('Name','Show impact of parameters','Tag',['gui_visualize output (' num2str(panel_handle) ')']);
end

clf(h);

if isempty(var_tab)
    set(map_button,'Enable','On');
    return
end

if all(size(var_tab)>1)    
    plot_checkerboard(percents_str,vars_names,var_tab,['map of ' param_name ' impact'],1,1,get(is_values,'Value'),1,get(is_percents,'Value'));
else
    if ~isempty(var_tab)
        if length(vars_names)==1
            plot_bar(var_tab,'b',percents_str,get(is_values,'Value'),1,get(is_percents,'Value'));
            ylabel(vars_names,'Interpreter','None');
        else
            plot_bar(var_tab,'b',vars_names,get(is_values,'Value'),1,get(is_percents,'Value'));
            ylabel(['impact of ' percents_str{1} ' ' param_name ' change '],'Interpreter','None');
        end
    end
    title(['values in steady state']);
    
end

set(map_button,'Enable','On');

function change_values_vis(hObject,is_percents)

if get(hObject,'Value')==1
    set(is_percents,'Enable','On');
else
    set(is_percents,'Enable','Off');
end

function plot_bar(variab_val,color,xticks_lab,ADDV,ADDN,ADDP)

if nargin<6
    ADDP=1;
end

if nargin<5
    ADDN=1;
end

if nargin<4
    ADDV=1;
end

if nargin<3
    xticks_lab=num2str(1:length(variab_val));
end

if nargin<2
    color='b';
end

bar(variab_val,color);
set(gca,'XTick',1:length(variab_val));
set(gca,'XTickLabel',xticks_lab);

if ADDV==1
    for s=1:length(variab_val)
        if isnan(variab_val(s))
            if ADDN==1
                text(s,0,'NaN','Color','k','FontWeight','Bold','FontAngle','Italic','Backgroundcolor','r','VerticalAlignment','middle','HorizontalAlignment','center');    
            end
        else
            vstr=num2str(variab_val(s),3);
            if ADDP==1
                vstr=[vstr '%'];
            end
            text(s,variab_val(s)/2,vstr,'VerticalAlignment','middle','HorizontalAlignment','center','Color','w');
        end
    end
end
axis tight;


function plot_checkerboard(params_names, variab_names,var_tab,COMMENT,XLAB,YLAB,ADDV,ADDN,ADDP)

% plots data
siz=size(var_tab);
pcolor([var_tab var_tab(:,siz(2)); var_tab(siz(1),:) var_tab(siz(1),siz(2))]); 

% setting plot features
colormap bone;
title(COMMENT,'Interpreter','None');
xlabel('variable ');ylabel ('parameter');
shading flat;axis tight;colorbar;

% setting ticks on the plot ans ticks label
set(gca,'XTick',1.5:1:siz(2)+0.5);
set(gca,'YTick',1.5:1:siz(1)+0.5);

if XLAB==1
    set(gca,'XTickLabel',variab_names)
else
    set(gca,'XTickLabel',{num2str([1:1:siz(2)]')})
end

if YLAB==1
    set(gca,'YTickLabel',params_names)
else
    set(gca,'YTickLabel',{num2str([1:1:siz(1)]')})
end

% adding values on colorfull checkerboard
if ADDN==1
    for indx1=1:siz(1)
        for indx2=1:siz(2)
            if isnan(var_tab(indx1,indx2))
                text(indx2+0.5,indx1+0.5,'NaN','Color','k','FontWeight','Bold','FontAngle','Italic','Backgroundcolor','r','Rotation',-45,'VerticalAlignment','middle','HorizontalAlignment','center');
            else
                if ADDV==1
                    if var_tab(indx1,indx2)<0
                        col='r';
                    else
                        if var_tab(indx1,indx2)>0
                            col='g';
                        else
                            if abs(max(max(var_tab)))<abs(min(min(var_tab)))
                                col='k';
                            else
                                col='w';
                            end
                        end
                    end
                    val_str=num2str(var_tab(indx1,indx2),3);
                    if ADDP==1
                        val_str=[val_str ' %'];
                    end
                    text(indx2+0.5,indx1+0.5,val_str,'Color',col,'VerticalAlignment','middle','HorizontalAlignment','center');
                end
            end
        end
    end
end