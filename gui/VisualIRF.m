function VisualIRF(varargin)
% 2.02         Nov 2008

% figure with interface
h=figure('HandleVisibility','Off','MenuBar','None','Name','VisualIRF 2.01','Color',[0.925 0.914 0.847],'Resize','Off','Visible','Off');

%panels used
forma_panel=gui_FORMA_panel(uipanel('Parent',h),'is_horizontal',1,'infobox_width',250,'infobox_height',30,...
    'button_height',30,'load_button_string','Load','reload_button_string','Reload','load_button_width',100,'reload_button_width',60,'margin',1);

select_vars=gui_select(uipanel('Parent',h),{},{},{},'n_indices',6,'field_heigth',150,...
    'name_field_width',120,'name_field_color',[1 1 0.75],'index_field_color',[1 1 0.75]);

shock_panel=gui_select_irf(uipanel('Parent',h),{},[]);

list_vars=gui_set(uipanel('Parent',h),{},{},{},'n_fields_y',4,'n_fields_x',0,'name_field_width',250,'not_editable_color',[0.6902 0.7686 0.8706]);

option_panel=uipanel('Parent',h,'Units','Pixels','Position',[0 0 285 120]);
analysis_panel=uipanel('Parent',h,'Units','Pixels','Position',[0 0 285 120]);


%tab with options
controls_tabs=gui_tabs(uipanel('Parent',h),{option_panel analysis_panel},'tabs_names_strings',{'Options','Analysis'});

%buttons 
add_var=gui_button_connect_sel_set(select_vars,list_vars,'add single','Parent',h,'String','Add','Position',[0 0 600 30]);
show_irfs=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Plot IRFs','Position',[0 0 600 30]);
export_irfs=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Export IRFs','Position',[0 0 600 30]);


%shock panel
%options panel controls

merge_control=uicontrol('Parent',option_panel,'Style','checkbox','FontWeight','Bold','String','merge plots','Position',[10 70 100 25]);
fixed_n_plots=uicontrol('Parent',option_panel,'Style','checkbox','FontWeight','Bold','String','fixed # of plots on figure ','Position',[10 40 160 25]);
add_analysis=uicontrol('Parent',option_panel,'Style','checkbox','FontWeight','Bold','String','add analysis on plot(s)','Position',[10 10 150 25]);
n_of_plots=gui_value(uipanel('Parent',option_panel),'value',6,'max_value',36);tmp=getpixelposition(n_of_plots);setpixelposition(n_of_plots,[190 35 tmp(3:4)]);

gui_layout(option_panel,{merge_control n_of_plots fixed_n_plots add_analysis},'margin_x',4,'margin_y',4);
options_panel_controls=[merge_control fixed_n_plots n_of_plots add_analysis ];

%analysis panel controls
width_analysis=uicontrol('Parent',analysis_panel,'Style','checkbox','FontWeight','Bold','String','width (length of value drop to % of peak value)','Position',[5 78 280 19]);
perc_drop=gui_value(uipanel('Parent',analysis_panel),'value',33,'max_value',99);tmp=getpixelposition(perc_drop);setpixelposition(perc_drop,[90 42 tmp(3:4)]);
x0_analysis=uicontrol('Parent',analysis_panel,'Style','checkbox','FontWeight','Bold','String','value at zeroth quarter','Position',[5 21 150 19]);
minmax_analysis=uicontrol('Parent',analysis_panel,'Style','checkbox','FontWeight','Bold','String','min & max values','Position',[5 5 120 19]);
peak_analysis=uicontrol('Parent',analysis_panel,'Style','checkbox','FontWeight','Bold','String','last peak position and value','Position',[5 0 200 19]);

gui_layout(analysis_panel,{x0_analysis minmax_analysis peak_analysis perc_drop width_analysis},'margin_x',4,'margin_y',4);
analysis_panel_controls=[width_analysis perc_drop x0_analysis minmax_analysis peak_analysis];

% state 
load_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Load variables','Position',[0 0 150 25],'Callback',@(hObject,eventdata) load_state_call(hObject,forma_panel,list_vars,h));
save_state=uicontrol('Parent',h,'Style','pushbutton','FontWeight','Bold','String','Save variables','Position',[0 0 150 25],'Callback',@(hObject,eventdata) save_state_call(hObject,list_vars,h));

gui_layout(h,{export_irfs show_irfs {controls_tabs {{load_state save_state} list_vars}} add_var select_vars {forma_panel shock_panel}});
gui_screen_position(h);
set(h,'Visible','On');

%% callbacks
gui_FORMA_panel(forma_panel,'change_pert_callback',@(handle) load_data_from_pert(handle,select_vars,shock_panel,list_vars,h))
set(show_irfs,'Callback',@(hObject,eventdata) show_irfs_callback(hObject,eventdata,forma_panel,list_vars,shock_panel,options_panel_controls,analysis_panel_controls,get(merge_control,'Value')))
set(export_irfs,'Callback',@(hObject,eventdata) export_irfs_callback(hObject,forma_panel,list_vars,shock_panel,get(merge_control,'Value'),h))

setappdata(h,'recent_dir',evalc('pwd'));


function show_irfs_callback(hObject,eventdata,forma_panel,list_vars,shock_panel,options_panel_controls,analysis_panel_controls,MERGE_PLOTS)


[irf_arr,vars_names,vars_codes,shock_name]=get_irfs(forma_panel,shock_panel,list_vars);

if isempty(irf_arr)
    return;
end

amp_perc_drop=getappdata(analysis_panel_controls(2),'value');
for indx=1:length(irf_arr)
    [v0_arr(indx),width_arr(indx),amax_arr(indx),amin_arr(indx),tmax_arr(indx),tmin_arr(indx),tpeak_arr(indx),apeak_arr(indx)]=analyze_IRF(irf_arr{indx},amp_perc_drop);
end

COMMENTS={};LINES={};

if get(options_panel_controls(4),'Value')==1
    
    for indx=1:length(irf_arr)
        if any(cell2mat(get(analysis_panel_controls([1 3 4 5]),'Value'))) 
            COMMENTS{indx}=[];
        end
        
        if get(analysis_panel_controls(3),'Value')==1
            COMMENTS{indx}=[COMMENTS{indx} {[' value at t=1     : ' num2str(v0_arr(indx),3)]}];
        end
        if get(analysis_panel_controls(1),'Value')==1
            COMMENTS{indx}=[COMMENTS{indx} {[' width            : ' num2str(width_arr(indx),3)]}];
        end 
        
        if get(analysis_panel_controls(4),'Value')==1
            COMMENTS{indx}=[COMMENTS{indx} {[' maximum position : ' num2str(tmax_arr(indx),3)]}];
            COMMENTS{indx}=[COMMENTS{indx} {[' maximum value    : ' num2str(amax_arr(indx),3)]}]; 
            COMMENTS{indx}=[COMMENTS{indx} {[' minimum position : ' num2str(tmin_arr(indx),3)]}];
            COMMENTS{indx}=[COMMENTS{indx} {[' minimum value    : ' num2str(amin_arr(indx),3)]}];
        end
        
        if get(analysis_panel_controls(5),'Value')==1
            COMMENTS{indx}=[COMMENTS{indx} {['last peak position: ' num2str(tpeak_arr(indx),3)]}];
            COMMENTS{indx}=[COMMENTS{indx} {['last peak value   : ' num2str(apeak_arr(indx),3)]}];
        end 
        
            %% additional lines
            nlines=1;
            if isfloat(tmax_arr(indx))
                LINESS(nlines,1)={[tmax_arr(indx) tmax_arr(indx)]};LINESS(nlines,2)={[0 amax_arr(indx)]};
                LINESS(nlines,3)={'r'};LINESS(nlines,4)={'--'};
                nlines=nlines+1;
            end
            
            if isfloat(tmin_arr(indx))           
                LINESS(nlines,1)={[tmin_arr(indx) tmin_arr(indx)]};LINESS(nlines,2)={[0 amin_arr(indx)]};
                LINESS(nlines,3)={'b'};LINESS(nlines,4)={'--'};
                nlines=nlines+1;
            end
            
            if isfloat(width_arr(indx)) 
                LINESS(nlines,1)={[tpeak_arr(indx) tpeak_arr(indx)+width_arr(indx)]};LINESS(nlines,2)={[apeak_arr(indx)/(100/amp_perc_drop) apeak_arr(indx)/(100/amp_perc_drop)]};
                LINESS(nlines,3)={'g'};LINESS(nlines,4)={'--'};
                nlines=nlines+1;
            end            
            LINES(indx)={LINESS};
    end
end

if get(options_panel_controls(2),'Value')==1
    N_ON_PLOT=getappdata(options_panel_controls(3),'value');
else
    N_ON_PLOT=length(vars_names);
end

plot_irfs(vars_names,irf_arr,shock_name,tmax_arr,tmin_arr,tpeak_arr,COMMENTS,LINES,N_ON_PLOT,MERGE_PLOTS);


function [irf_arr,vars_names,vars_codes,shock_name]=get_irfs(forma_panel,shock_panel,list_vars)

p=getappdata(forma_panel,'FORMA_object');
vars_names=getappdata(list_vars,'names');
vars_codes=getappdata(list_vars,'codes');

if isempty(vars_codes) | isempty(p)
    irf_arr={};vars_names={};shock_name='';
    return;
end
    
if p.state~=1
    warndlg('IRF cannot be calculated without solution','Failed','modal');
    irf_arr={};vars_names={};shock_name='';
    return;
end

shock_name=getappdata(shock_panel,'shock_name');
shock_code=getappdata(shock_panel,'shock_code');
irf_length=getappdata(shock_panel,'irf_length');

irf_arr={};
for indx=1:length(vars_codes)
    try
        irf_arr(indx)=irf(p,irf_length,vars_codes(indx),shock_code);
    catch
        irf_arr(indx)={NaN(1,irf_length)}; 
    end
end

ap_tp=p.vars(vars_codes).approx_type.get;
str_ap_tp={'linear','log-linear'};
for indx=1:length(vars_names)    
    vars_names{indx}=[vars_names{indx} ' (' str_ap_tp{ap_tp(indx)} ')' ];
end


function load_data_from_pert(forma_panel_handle,select_vars,shock_panel,vars_list,h)

gui_select(select_vars,'refresh',getappdata(forma_panel_handle,'vars_names'),getappdata(forma_panel_handle,'vars_indices'),getappdata(forma_panel_handle,'vars_codes'));
gui_select_irf(shock_panel,'refresh',getappdata(forma_panel_handle,'shocks_full_names'),getappdata(forma_panel_handle,'shocks_full_codes'));

getappdata(forma_panel_handle,'shocks_full_codes');
getappdata(forma_panel_handle,'shocks_codes');

verify_app_codes(forma_panel_handle,vars_list,h);

function plot_irfs(variab_names,irf_pri,shock_nme,tmax_arr,tmin_arr,tpeak_arr,COMMENTS,LINES,N_ON_PLOT,MERGE_PLOTS)

if isempty(variab_names)
    return;
end

if nargin<7
    MERGE_PLOTS=0;
end

if nargin<6
    N_ON_PLOT=6;
end

if nargin<5 | isempty(LINES)
    EXTRA_LINES=0;
else
    EXTRA_LINES=1;
end

if nargin<4 | isempty(COMMENTS)
    EXTRA_COMMENTS=0;
else
    EXTRA_COMMENTS=1;
end

N_variab=length(variab_names);
irfs_length=length(irf_pri{1});


if MERGE_PLOTS==0

    for indx2=1:N_variab
    
        if (mod(indx2,N_ON_PLOT)==1) | (N_variab==1) | (N_ON_PLOT==1)
            figure('Name',['IRFs for ' shock_nme ' (part ' num2str(floor(indx2/N_ON_PLOT)+1)  '/' num2str(floor((N_variab-1)/N_ON_PLOT)+1) ' )']);
        end
    
        hold on;
    
        px=ceil(sqrt(N_ON_PLOT));py=ceil(N_ON_PLOT./px);
        plot_handle=subplot(px,py,mod(indx2-1,N_ON_PLOT)+1);
        set(plot_handle,'FontWeight','Bold','FontSize',12);
    
        plot_handle=plot(1:irfs_length,irf_pri{indx2},'LineWidth',2,'Color','b');
   
        if EXTRA_LINES==1
            LINESS=LINES{indx2};
            for indx=1:size(LINESS,1)
                line(LINESS{indx,1},LINESS{indx,2},'Color',LINESS{indx,3},'LineStyle',LINESS{indx,4},'LineWidth',2);
            end
            
            if ~isnan(tmin_arr(indx2)) && ~isinf(tmin_arr(indx2))
                text(tmin_arr(indx2),irf_pri{indx2}(tmin_arr(indx2)),[{'\uparrow'} {'minimum'}],'VerticalAlignment','Top','HorizontalAlignment','Center','FontWeight','Bold','Color','Blue');
            end
            if ~isnan(tmax_arr(indx2)) && ~isinf(tmax_arr(indx2))
                text(tmax_arr(indx2),irf_pri{indx2}(tmax_arr(indx2)),[{'maximum'};{'\downarrow'}],'VerticalAlignment','Bottom','HorizontalAlignment','Center','FontWeight','Bold','Color','Red');
            end
            if ~isnan(tpeak_arr(indx2)) && ~isinf(tpeak_arr(indx2))
                text(tpeak_arr(indx2),irf_pri{indx2}(tpeak_arr(indx2)),'peak \rightarrow','VerticalAlignment','Middle','HorizontalAlignment','Right','FontWeight','Bold','Color','Black');
            end
            
        end
        
        if EXTRA_COMMENTS==1 
            [yp,xp]=max(irf_pri{indx2});

            if (length(irf_pri{indx2})-xp)<2;
                text(xp,yp,['\rightarrow' COMMENTS{indx2}],'VerticalAlignment','Top','HorizontalAlignment','Right','FontWeight','Bold','Color','Black');
            else
                text(xp,yp,['\leftarrow' COMMENTS{indx2}],'VerticalAlignment','Top','HorizontalAlignment','Left','FontWeight','Bold','Color','Black');
            end
        end
    
        hold off;
    
        title(variab_names{indx2},'Interpreter','None');
        xlabel('t');
        grid on;
        ax=axis;axis([0 irfs_length+1 ax(3:4)]);

    end
    
else
    
    figure;axes('FontSize',12,'FontWeight','Bold');
    
    color_tab=['g','b','c','m','y','k'];marker_tab={'None','square','diamond','pentagram','hexagram'};

    hold on;
    for indx2=1:length(irf_pri)
        plot_handle=plot(1:irfs_length,irf_pri{indx2},'LineWidth',2,'Marker',marker_tab{mod(floor((indx2-1)/6),5)+1},'Color',color_tab(mod(indx2,6)+1));    
    end

    legend(variab_names,'Interpreter','None');
    
    for indx2=1:length(irf_pri)
    
            if EXTRA_LINES==1
                LINESS=LINES{indx2};
                for indx=1:size(LINESS,1)
                    line(LINESS{indx,1},LINESS{indx,2},'Color',LINESS{indx,3},'LineStyle',LINESS{indx,4},'LineWidth',2);
                end
                
                if ~isnan(tmin_arr(indx2)) && ~isinf(tmin_arr(indx2))
                    text(tmin_arr(indx2),irf_pri{indx2}(tmin_arr(indx2)),[{'\uparrow'} {'minimum'}],'VerticalAlignment','Top','HorizontalAlignment','Center','FontWeight','Bold','Color','Blue');
                end
                if ~isnan(tmax_arr(indx2)) && ~isinf(tmax_arr(indx2))
                    text(tmax_arr(indx2),irf_pri{indx2}(tmax_arr(indx2)),[{'maximum'};{'\downarrow'}],'VerticalAlignment','Bottom','HorizontalAlignment','Center','FontWeight','Bold','Color','Red');
                end
                if ~isnan(tpeak_arr(indx2)) && ~isinf(tpeak_arr(indx2))
                    text(tpeak_arr(indx2),irf_pri{indx2}(tpeak_arr(indx2)),['peak \rightarrow'],'VerticalAlignment','Middle','HorizontalAlignment','Right','FontWeight','Bold','Color','Black');
                end
                
            end
       
            if EXTRA_COMMENTS==1
                
                [yp,xp]=max(irf_pri{indx2});

                if (length(irf_pri{indx2})-xp)<2;
                    text(xp,yp,['\rightarrow' COMMENTS{indx2}],'VerticalAlignment','Top','HorizontalAlignment','Right','FontWeight','Bold','Color',color_tab(mod(indx2,6)+1));
                else
                    text(xp,yp,['\leftarrow' COMMENTS{indx2}],'VerticalAlignment','Top','HorizontalAlignment','Left','FontWeight','Bold','Color',color_tab(mod(indx2,6)+1));
                end
                
            end
    end
    grid on;
    hold off;
    ax=axis;axis([0 irfs_length+1 ax(3:4)]);
end


function [v0,width,amax,amin,tmax,tmin,tpeak,apeak]=analyze_IRF(irf_arr,amp_perc_drop)

v0=irf_arr(1);width=0;
amax=v0;amin=v0;
tmax=1;tmin=1;

try
%% searching for max and min
for indx=1:length(irf_arr)
    
    if irf_arr(indx)>amax
        amax=irf_arr(indx);tmax=indx;
    end
    if irf_arr(indx)<amin
        amin=irf_arr(indx);tmin=indx;
    end
end

if tmax==length(irf_arr)
    tmax=Inf;
    amax=NaN;
end

if tmin==length(irf_arr)
    tmin=Inf;
    amin=NaN;
end

if isinf(tmin)
    tpeak=tmax;
else 
    if isinf(tmax);
        tpeak=tmin;
    else
        tpeak=max(tmin,tmax);
    end
end

apeak=irf_arr(tpeak);
windx=tpeak;

for indx=tpeak:length(irf_arr)
    windx=indx;
    if ~isequal(apeak,0) && apeak/irf_arr(indx)>(100/amp_perc_drop);
        break;
    end
end

if windx<length(irf_arr)
    width=windx-tpeak;
else
    width=Inf;
end

catch
    return;
end

function load_state_call(hObject,forma_panel,vars_list,h)

[FileName,PathName,FilterIndex] = uigetfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Select VisualIRF state (list of variables) to load *.mat',[getappdata(h,'recent_dir') '\' 'visualirf_save.mat'] );

if ~isequal(FileName,0) & ~isequal(PathName,0)

    try
        warning off;
        load([PathName '\' FileName],'state_obj_vars');    
        gui_set(vars_list,'set state obj',state_obj_vars);
        warning on;
        
        setappdata(h,'recent_dir',PathName);
        
    catch
       warndlg('Loading failed!','Loading GUI state failed','modal');
       return;
    end
    
    if ~isempty(getappdata(forma_panel,'FORMA_object'))
        verify_app_codes(forma_panel,vars_list,h);
    end
end

function save_state_call(hObject,vars_list,h)

state_obj_vars=gui_set(vars_list,'get state obj');

[FileName,PathName,FilterName] = uiputfile({'*.mat' 'Matlab file with GUI state (*.mat)'},'Save state of GUI (list of variables)',[getappdata(h,'recent_dir') '\' 'visualirf_save.mat']);

if ~isequal(FileName,0) & ~isequal(PathName,0)
    save([PathName '\' FileName],'state_obj_vars');
    setappdata(h,'recent_dir',PathName);
end

function verify_app_codes(forma_panel,vars_list,h)

model_names=getappdata(forma_panel,'vars_full_names');
model_codes=getappdata(forma_panel,'vars_full_codes');

i_names=getappdata(vars_list,'names');
i_values=getappdata(vars_list,'values');
i_codes=getappdata(vars_list,'codes');

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
   gui_set(vars_list,'refresh',i_names,i_values,i_codes);
end


% info dialog
if ~isempty(del_names) | ~isempty(cod_names)
    
    S=...
    [{'Vars excluded from variables list (unknown in model):'} del_names {' '}...
    {'Vars on list with updated codes:'} cod_names {' '}];

    listdlg('ListString',S,'Name','Auto-changes in variables list','ListSize',[600 160]);
end



function export_irfs_callback(hObject,forma_panel,list_vars,shock_panel,MERGE_PLOTS,h) 

[irf_arr,vars_names,vars_codes,shock_name]=get_irfs(forma_panel,shock_panel,list_vars);
if isempty(irf_arr)
    return;
end
model_name=get(getappdata(forma_panel,'infobox_handle'),'String');model_name=[model_name{3}];

[FileName,PathName,FilterName] = uiputfile({'*.txt' 'text file with IRFs data (*.txt)';'*.mat' 'Matlab file with IRFs data (*.mat)';'*.xls' 'xls file with IRFs data (*.xls)';'*' 'tex file created with maalari (*.tex and *.mat)';'*.m' 'm-file with Matlab code generating IRFs (*.m)'},'Save IRFs',[getappdata(h,'recent_dir') '\' 'visualirf_results.txt']);

if ~isequal(FileName,0) & ~isequal(PathName,0)
   
    switch FilterName
        case 1
            % txt file
            try
                fid=fopen([PathName '\' FileName],'wt');
            
                fprintf(fid,['written by VisualIRF on ' datestr(now) '\n' model_name '\n\n']);
                fprintf(fid,['shock name : ' shock_name '   irf length : ' num2str(length(irf_arr{1})) '\n\n']);
                fprintf(fid,['shocked variables and their approx types:\n']);
            
                for indx=1:length(vars_names)
                    fprintf(fid,vars_names{indx});
                    fprintf(fid,'\n');
                end
                fprintf(fid,'\n');
            
                fprintf(fid,['irfs values for shocked variables:\n']);
                for indx=1:length(vars_names)
                    fprintf(fid,convert_delimiter(num2str(irf_arr{indx})));
                    fprintf(fid,'\n');
                end
                fclose(fid);
                
            catch    
                try
                    fclose(fid);
                catch
                end
                warndlg('Saving to text file failed','Saving failed','modal');
            end
                
        case 2
            % mat file
            
        try
            signature=['written by VisualIRF on ' datestr(now) '\n'];
            save([PathName '\' FileName],'irf_arr','vars_names','shock_name','signature','model_name');
        catch
            warndlg('Saving to mat file failed','Saving failed','modal');
        end
        
        case 3
            % xls file           
            warning('off','MATLAB:xlswrite:AddSheet');
            
            try           
                %writing headers
                xlswrite([PathName '\' FileName],{['written by VisualIRF on ' datestr(now) '\n' model_name]},'VisualIRF results','A1');
                xlswrite([PathName '\' FileName],{['shock name : ' shock_name '   irf length : ' num2str(length(irf_arr{1}))]},'VisualIRF results','A2');         
                %writing names
                xlswrite([PathName '\' FileName],vars_names.','VisualIRF results','A4');
                %writing IRFs data
                xlswrite([PathName '\' FileName],cell2mat(irf_arr(:)),'VisualIRF results','B4');           
            catch
                warndlg('Saving to xls file failed','Saving failed','modal');
            end
            warning('on','MATLAB:xlswrite:AddSheet');
            
        case 4
            % mat with maalari objects           
            if MERGE_PLOTS==1 & length(irf_arr)>4
               warndlg('maalari does not support more than 4 curves on one plot','Saving failed','modal'); 
            else
                try
                    h_wd=warndlg('Exporting data through Maalari','Please wait...');
                    
                    visualirf_output2maalari = plotter;
                
                    if MERGE_PLOTS==1
                        colours_tab={'blue','red','green','yellow'};
                    
                        for indx=1:length(irf_arr)
                            visualirf_output2maalari.Var(indx).data=irf_arr{indx};
                            visualirf_output2maalari.Var(indx).colour=colours_tab{indx};
                            visualirf_output2maalari.Var(indx).pattern=1;
                            visualirf_output2maalari.Var(indx).thickness=1.0; 
                        end

                        visualirf_output2maalari.Axes.X.desc={'t'};                       
                        visualirf_output2maalari.Axes.Y.desc={'IRF'};
                    
                        visualirf_output2maalari.Latex.Captions={'Results from VisualIRF'};
                                            
                    
                    else
                   
                        visualirf_output2maalari.Var(1).data=cell2mat(irf_arr.');
                        visualirf_output2maalari.Var(1).colour='blue';
                        visualirf_output2maalari.Var(1).pattern=1;
                        visualirf_output2maalari.Var(1).thickness=1.0; 
                        visualirf_output2maalari.Axes.X.desc=repmat({'t'},size(vars_names.'));
                        visualirf_output2maalari.Axes.Y.desc=convert2latex(vars_names);
                        
                        visualirf_output2maalari.Latex.Captions=repmat({'Results from VisualIRF'},size(irf_arr));
                    
                    end
                
                    visualirf_output2maalari.OutName=FileName;
                
                    save([PathName '\' FileName '.mat'],'visualirf_output2maalari');
                    visualirf_output2maalari.plot; 
                
                catch

                    warndlg('Export via maalari failed','Saving failed','modal');
                
                end
                
                try
                    close(h_wd);
                catch
                end
            end
            
        case 5  
            % m file with code generating irfs
            try
                
                p_name=getappdata(forma_panel,'FORMA_object_name');
                vars_names=getappdata(list_vars,'names');
                
                fid=fopen([PathName '\' FileName],'wt');
                fprintf(fid,['%% Script generated by VisualIRF on ' datestr(now) '\n']);
                fprintf(fid,['%% assumes that perturbation object: ' p_name ' (' model_name ') is in the workspace\n']);
                
                fprintf(fid,['shock_name = ''' shock_name ''';\n']);
                fprintf(fid,['irf_len = ' num2str(length(irf_arr{1})) ';\n']);
                fprintf(fid,['vars_list = {']);
                for indx=1:length(vars_names)-1
                    fprintf(fid,['''' vars_names{indx} ''',']);
                end
                fprintf(fid,['''' vars_names{length(vars_names)} '''};\n']);            
                fprintf(fid,[p_name '.vars(vars_list).irf(irf_len,{shock_name});\n'])
                
                fclose(fid);
            
            catch
                try
                    fclose(fid);
                catch
                end
                warndlg('Saving to text file failed','Saving failed','modal');
            end
    end

    
    
    setappdata(h,'recent_dir',PathName);
end


function txt=convert_delimiter(txt)
txt(txt=='.')=',';

function txt=convert2latex(txt)
txt=regexprep(regexprep(txt, '<', '$\\langle$'),'>','$\\rangle$');