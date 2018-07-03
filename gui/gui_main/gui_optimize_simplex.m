function varargout=gui_optimize_simplex(panel_handle,varargin)
% % gui_optimize_simplex v 1.0 (Aug 2008)
% %  component for optimalization with simplex method (for details see the function 
% %  optimize_params in the M-file of this component )
% %
% % panel_handle=gui_optimize_simplex(panel_handle,'param1_name',param1_val,'param2_val',param2_val...)
% %  create a new component with given paramaters
% %
% % gui_optimize_simplex(panel_handle,'Enable') 
% % gui_optimize_simplex(panel_handle,'Disable')
% %  enable and disable optimization button in exisiting component
% %
% % gui_optimize_simplex(panel_handle,'set','param1_name',param1_val,'param2_val',param2_val...)
% %  set paramaters in existing component
% %
% % [x,ret_meas]=gui_optimize_simplex(panel_handle,'get');
% %  gets optimized value of variables and discrepancy value
% %
% % -------------paramaters----------------------------
% % equations={};             equations
% % 
% % f_values=[];              L-side values 
% % f_sigma=[];               L-side uncertanity
% % 
% % x_labels={};              variables labels
% % x_lb=-inf;                variables lower boundary
% % x_ub=inf;                 variables upper boundary
% % 
% % x0=[];                    starting point
% % p_labels={};              names of paramaters
% % p_values=[];              paramters values
% % 
% % Display='none';           optimization paramaters (see help fminsearch for details)
% % OutputFcn=[];
% % 
% % TolFun=1e-6; 
% % TolX=1e-6;
% % 
% % MaxIter=200; 
% % MaxFunEvals=200;
% %
% % func_pre_opt=[];         handle to function called before optimization
% %                          with panel_handle as argument
% % func_post_opt=[];        handle to function called after optimization
% %                          with panel_handle as argument
% %
% % ---------------- app data----------------------
% % the same names and meaning as parameters above plus:
% % x                        optimization result : variable value
% % ret_meas                 returned discrpeancy value
% %
% % ------------W.M.Saj 2008-------------

VERSION=1.0;

%
if nargin==2 & isequal(varargin{1},'Enable')
    optimize_button=getappdata(panel_handle,'optimize_button');
    set(optimize_button,'Enable','On');
    return;
end

if nargin==2 & isequal(varargin{1},'Disable')
    optimize_button=getappdata(panel_handle,'optimize_button');
    set(optimize_button,'Enable','Off');
    return;
end

% default parameters

equations={};

f_values=[];f_sigma=[];
x_labels={};x_lb=-inf;x_ub=inf;x0=[];
p_labels={};p_values=[];

Display='none';OutputFcn=[];

TolFun=1e-6; TolX=1e-6;
MaxIter=200; MaxFunEvals=200;

func_pre_opt=[];func_post_opt=[];

% special cases 
if nargin>1 & isequal(varargin{1},'set')
    for idx=2:2:nargin-2
        setappdata(panel_handle,varargin{idx},varargin{idx+1});
    end
    return;
end

if nargin==2 & isequal(varargin{1},'get')
    varargout{1}=getappdata(panel_handle,'x');
    varargout{2}=getappdata(panel_handle,'ret_meas');
    return;
end


% default
for idx=1:2:nargin-1
    eval([varargin{idx} '= varargin{idx+1};'])
end

if isempty(panel_handle)
    h=dialog('NumberTitle','Off','Name',['gui_optimize_simplex v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [100 100 280 200]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',...
        [100 100 280 200]);
end

edit_max_iter=uicontrol('Style','Edit','Parent',panel_handle,'FontWeight','Bold','String',num2str(MaxIter),'Backgroundcolor','White','Callback',@control_edit);
set(edit_max_iter,'UserData',MaxIter);

edit_max_func_evals=uicontrol('Style','Edit','Parent',panel_handle,'FontWeight','Bold','String',num2str(MaxFunEvals),'Backgroundcolor','White','Callback',@control_edit);
set(edit_max_func_evals,'UserData',MaxFunEvals);

edit_tolx=uicontrol('Style','Edit','Parent',panel_handle,'FontWeight','Bold','String',num2str(TolX),'Backgroundcolor','White','Callback',@control_edit);
set(edit_tolx,'UserData',TolX);

edit_tolfun=uicontrol('Style','Edit','Parent',panel_handle,'FontWeight','Bold','String',num2str(TolFun),'Backgroundcolor','White','Callback',@control_edit);
set(edit_tolfun,'UserData',TolFun);

string_max_iter=uicontrol('Style','Edit','Parent',panel_handle,'Enable','Inactive','FontWeight','Bold','String','Max Iter','Position',[0 0 85 20]);
string_max_func_evals=uicontrol('Style','Edit','Parent',panel_handle,'Enable','Inactive','FontWeight','Bold','String','Max Func Evals','Position',[0 0 85 20]);

string_tolx=uicontrol('Style','Edit','Parent',panel_handle,'Enable','Inactive','FontWeight','Bold','String','Tolx','Position',[0 0 30 20]);
string_tolf=uicontrol('Style','Edit','Parent',panel_handle,'Enable','Inactive','FontWeight','Bold','String','Tolf','Position',[0 0 30 20]);

opt_output=uicontrol('Style','Popupmenu','Parent',panel_handle,'String',{'Message bar','Graphical','Command line'},'BackgroundColor','White','FontWeight','Bold','FontAngle','Italic','Position',[0 0 150 20]);
call_output_button=uicontrol('Style','Pushbutton','Parent',panel_handle,'String','S','FontWeight','Bold','FontAngle','Italic',...
    'Units','Pixels','Position',[0 0 20 20],'Callback',@(hObject,eventdata) callback_call_output_button(panel_handle,opt_output));

optimize_button=uicontrol('Style','Togglebutton','Parent',panel_handle,'FontWeight','Bold','String','Optimize','Units','Pixels','Position',[0 0 250 30]);

message_bar=uicontrol('Style','Text','Parent',panel_handle,'String','','FontWeight','Bold','Units','Pixels','Position',[0 0 250 40],'BackgroundColor','white');

gui_layout(panel_handle,{message_bar optimize_button {opt_output call_output_button} {{{string_tolf edit_tolfun} {string_tolx edit_tolx}} {{string_max_func_evals edit_max_func_evals} {string_max_iter edit_max_iter}}}},'margin_x',3,'margin_y',3);

set(optimize_button,'Callback',@(hObject,eventdata) optimization(hObject,eventdata,panel_handle,edit_max_iter,edit_max_func_evals,edit_tolx,edit_tolfun,opt_output,message_bar));

setappdata(panel_handle,'equations',equations);setappdata(panel_handle,'f_values',f_values);setappdata(panel_handle,'f_sigma',f_sigma);
setappdata(panel_handle,'x_labels',x_labels);setappdata(panel_handle,'x_lb',x_lb);setappdata(panel_handle,'x_ub',x_ub);setappdata(panel_handle,'x0',x0);
setappdata(panel_handle,'p_labels',p_labels);setappdata(panel_handle,'p_values',p_values);

setappdata(panel_handle,'x',[]);setappdata(panel_handle,'ret_meas',[]);

setappdata(panel_handle,'optimize_button',optimize_button);

setappdata(panel_handle,'func_pre_opt',func_pre_opt);
setappdata(panel_handle,'func_post_opt',func_post_opt);

varargout{1}=panel_handle;

function callback_call_output_button(panel_handle,opt_output)

switch get(opt_output,'Value')
    case 2
        h=findobj('Tag',['Output for VisualAIM (' num2str(panel_handle) ')']);
        if ~isempty(h);
            figure(h);
        end
    case 3
       
end

function optimization(hObject,eventdata,panel_handle,edit_max_iter,edit_max_func_evals,edit_tolx,edit_tolfun,opt_output,message_bar)

if get(hObject,'Value')==0
    return
end

% to prevent problems with some fast clicking trouble makers 
set(hObject,'Enable','Off');


func_pre_opt=getappdata(panel_handle,'func_pre_opt');
func_post_opt=getappdata(panel_handle,'func_post_opt');

if ~isempty(func_pre_opt)
    feval(func_pre_opt,panel_handle);
end

equations=getappdata(panel_handle,'equations');
x_labels=getappdata(panel_handle,'x_labels');
x0=getappdata(panel_handle,'x0');

if isempty(equations) | isempty(x0) | isempty(x_labels) | isempty(equations{1}) | isempty(x_labels{1}) | isempty(x0{1}) 
    set(hObject,'Value',0);
    set(hObject,'Enable','On');
    if ~isempty(func_post_opt)
        feval(func_post_opt,panel_handle);
    end
    return;
end

f_values=getappdata(panel_handle,'f_values');f_sigma=getappdata(panel_handle,'f_sigma');


x_lb=getappdata(panel_handle,'x_lb');x_ub=getappdata(panel_handle,'x_ub');


p_labels=getappdata(panel_handle,'p_labels');p_values=getappdata(panel_handle,'p_values');

TolX=str2double(get(edit_tolx,'String'));TolFun=str2double(get(edit_tolfun,'String'));
MaxIter=str2double(get(edit_max_iter,'String'));MaxFunEvals=str2double(get(edit_max_func_evals,'String'));

set(hObject,'String','Stop optimization','ForegroundColor','red','FontAngle','Italic');

if get(opt_output,'Value')==1
    OutputFcn=@(x, optimValues, state) outfun_text(x, optimValues, state,panel_handle,hObject,message_bar);
    Display='none';
else
    if get(opt_output,'Value')==2
        OutputFcn=@(x, optimValues, state) outfun_graph(x, optimValues, state,panel_handle,hObject,message_bar);
        Display='none';
    else
        OutputFcn=@(x,optimValues, state) idle_outfun(x, optimValues, state,panel_handle,hObject,message_bar);
        Display='iter';        
    end
end

opt_options=optimset(optimset('fminsearch'),'Display',Display,'TolFun',TolFun,'TolX',TolX,...
    'OutputFcn',OutputFcn,'MaxIter',MaxIter,'MaxFunEvals',MaxFunEvals);

% to prevent problems with some fast clicking trouble makers 
set(hObject,'Enable','On');

[x,ret_meas]=optimize_params(equations,f_values,f_sigma,x_labels,x_lb,x_ub,x0,p_labels,p_values,opt_options);

set(hObject,'Value',0,'String','Optimize','ForegroundColor','black','FontAngle','normal','Enable','On');

setappdata(panel_handle,'x',x);setappdata(panel_handle,'ret_meas',ret_meas);

if ~isempty(func_post_opt)
    feval(func_post_opt,panel_handle);
end

function [x,ret_meas]=optimize_params(equations,f_values,f_sigma,x_labels,x_lb,x_ub,x0,p_labels,p_values,opt_options)
% Simple tool for fitting values to n-equation model
% minimizes sum(((f_values-equations)/f_values).^2)
%
% equations     - cell array of n strings right side of equations written
% f_values      - cell array of length n with left side of equations (scalar
% values), for each k f_values(k)=equations{k}
% f_sigma       - cell array error/variancy/etc etc of f_values
% x_labels      - cell array of strings with  variables names
% x_lb,x_ub     - lower and upper boundary for variables (+inf,-inf for inifinte boundaries)
% x0            - cell array with initial values of variables
% p_labels      - cell array of strings of paramters (variables that are not optimized)
% p_values      - cell array with paramaters values
% opt_options   - optimization options (from optimset)
%
% v 2.0                             W.M.Saj  June 2008      
% - parameter and even parameter called variable:) could be matrix
%               "caveat emptor"

if nargin<10
    opt_options=optimset('Display','iter');
end

if nargin<9
    p_labels={};p_values=[];
end

x0_vec=[];x_siz={};x_len=[];
for indx=1:length(x_labels)
    x0_vec=[x0_vec ; x0{indx}(:)];
    x_siz{indx}=size(x0{indx});x_len(indx)=prod(x_siz{indx});
end

opt_func=@(x_values_vec) full_optfunc(x_values_vec,equations,f_values,f_sigma,x_labels,x_lb,x_ub,p_labels,p_values,x_siz,x_len);
[x_vec,ret_meas]=fminsearch(opt_func,x0_vec,opt_options);

x={};
for idx=1:length(x_labels)
    x{idx}=reshape(x_vec((1+sum(x_len(1:idx-1)):sum(x_len(1:idx)))),x_siz{idx});
end


function ret_meas=full_optfunc(x_values_vec,equations,f_values,f_sigma,x_labels,x_lb,x_ub,p_labels,p_values,x_siz,x_len)

% sets values of paramaters (not optimized variables)
for idx=1:length(p_labels)
    eval([p_labels{idx} '= p_values{idx};' ])
end

% sets values of variables
for idx=1:length(x_labels)
    eval([x_labels{idx} '= reshape(x_values_vec((1+sum(x_len(1:idx-1)):sum(x_len(1:idx)))),x_siz{idx});' ])
    is_bigger=(eval([x_labels{idx} '>= x_lb{idx};' ]));is_bigger=all(is_bigger(:));
    is_smaller=(eval([x_labels{idx} '<= x_ub{idx};' ]));is_smaller=all(is_smaller(:));
    if ~is_bigger || ~is_smaller
        ret_meas=NaN;
        return;
    end
end

if isempty(f_values)
    ret_meas=0;
    for idx=1:length(equations)
        tmp=eval(equations{idx});
        ret_meas=ret_meas+sum(tmp(:));
    end
    return;
end


% calculate difference to the f_value evaluating equations
ret_meas=0;
for idx=1:length(equations)
    tmp=abs((eval(equations{idx})-f_values{idx})./f_sigma{idx});
    ret_meas=ret_meas+sum(tmp(:).^2);
end

function f_calc=eval_equations(equations,x_labels,x_values,p_labels,p_values)

% equations     - cell array of n strings right side of equations written
% x_labels      - cell array of strings with  variables names
% x
% p_labels      - cell array of strings of paramters (variables that are not optimized)
% p_values      - cell array with paramaters values
%
% v 1.0                             W.M.Saj  June 2008      
%               "caveat emptor"


if nargin<5
    p_labels={};p_values=[];
end

% sets values of paramaters (not optimized variables)
for idx=1:length(p_labels)
    eval([p_labels{idx} '= p_values{idx};' ])
end

% sets values of variables
for idx=1:length(x_labels)
    eval([x_labels{idx} '= x_values{idx};' ])
end

f_calc={};
for idx=1:length(equations)
    f_calc{idx}=eval(equations{idx});
end


function stop = outfun_graph(x, optimValues, state, panel_handle,optimize_button,message_bar)

if get(optimize_button,'Value')==1
    stop=false;
else
    set(optimize_button,'Enable','Off');
    stop=true;
end

h=findobj('Tag',['Output for VisualAIM (' num2str(panel_handle) ')']);

if isempty(h)
    ha = newplot(figure);h=get(ha,'Parent');
    set(h,'Tag',['Output for VisualAIM (' num2str(panel_handle) ')']);set(h,'Name','Optimization progress');
    set(h,'Color',[0.925 0.914 0.847]);
    set(ha,'FontSize',12);set(h,'Position',get(h,'Position')/1.5);
else
    ha=get(h,'CurrentAxes');axes(ha);
    plot_fct=getappdata(h,'plot_fct');plot_fval=getappdata(h,'plot_fval');
end


plot_fct(optimValues.iteration+1)=optimValues.funccount;
plot_fval(optimValues.iteration+1)=optimValues.fval;

setappdata(h,'plot_fct',plot_fct);setappdata(h,'plot_fval',plot_fval);

iter=[0:optimValues.iteration];

subplot(2,1,1)
plot(iter,plot_fct,'LineStyle','--','LineWidth',2,'Color','g');grid on;
ylabel('function calls');
if max(plot_fct) > min(plot_fct)
    axis([0 max(optimValues.iteration,exp(ceil(log(optimValues.iteration+1)))) min(plot_fct) max(plot_fct)]);
    line([optimValues.iteration optimValues.iteration],[min(min(plot_fct),0) max(max(plot_fct),1)],'LineStyle','--','LineWidth',1.5,'Color','r');
end

subplot(2,1,2)
semilogy(iter,plot_fval,'LineStyle','--','LineWidth',2);grid on;
ylabel('cost function');
if max(plot_fval) > min(plot_fval)
    axis([0 max(optimValues.iteration,exp(ceil(log(optimValues.iteration+1)))) min(plot_fval) max(plot_fval)]);
    line([optimValues.iteration optimValues.iteration],[min(plot_fval) max(plot_fval)],'LineStyle','--','LineWidth',1.5,'Color','r');
end
if isequal(state,'done') | stop==true
    title(['Iteration: ' num2str(optimValues.iteration) '  f(x) = ' num2str(optimValues.fval) '   Optimization ended']);
else
    title(['Iteration: ' num2str(optimValues.iteration) '  f(x) = ' num2str(optimValues.fval) '   Procedure : ' optimValues.procedure]);    
end

pause(0.0001);

function stop = outfun_text(x, optimValues, state,panel_handle,optimize_button,message_bar)

if get(optimize_button,'Value')==1
    stop=false;
else
    set(optimize_button,'Enable','Off');
    stop=true;
end

set(message_bar,'String',[{['Iteration : ' num2str(optimValues.iteration) ' Func-count : ' num2str(optimValues.funccount) ' '...
    ' min f(x) : ' num2str(optimValues.fval) '  Procedure : ' optimValues.procedure]}]);

pause(0.0001);

function stop = idle_outfun(x, optimValues, state,panel_handle,optimize_button,message_bar)

if get(optimize_button,'Value')==1
    stop=false;
else
    set(optimize_button,'Enable','Off');
    stop=true;
end

pause(0.001);