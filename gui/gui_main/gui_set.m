function varargout=gui_set(varargin)
% % Graphical User Interface for store and set value(s)  v 1.1 (Nov 2008)
% %
% % panel_handle=gui_set(panel_handle,names,values,codes)  
% %  creates a gui_set interface in panel_handle filled with names, values, codes returning a
% %  handle to gui_set panel; if panel_handle is empty figure including
% %  new panel is created
% %  any data can be than accesed with getappdata and setappdata (list of
% %  fields below)
% %
% % panel_handle=gui_set(panel_handle,names,values,codes,'param1','param1_value', 'param2','param2_value')
% %  create gui_set and sets its params (see list below)
% %
% % gui_set(panel_handle,'refresh') 
% %  refresh existing GUI according to data included with setappdata
% %
% % gui_set(panel_handle,'refresh',names,values,codes)  
% %  refresh existing GUI with data given as parameters
% %
% % gui_set(panel_handle,'state',state)  
% %  sets state of existing GUI (see APPDATA below)
% %
% % gui_set(panel_handle,'set state obj',state_obj)  
% %  sets full state of existing GUI with object including fields of all
% %  appdata of GUI
% %
% % state_obj=gui_set(panel_handle,'get state obj')  
% %  gets full state of existing GUI with object including fields of all
% %  appdata of GUI
% %
% % gui_set(panel_handle,'clear') 
% %  clear existing GUI
% %
% % gui_set(panel_handle,'add',names,values,codes)
% % gui_set(panel_handle,'add',names,values,codes,'single') 
% %  add data given as parameters , in 'single' mode only data with names
% %  not appearing in existing entries appears
% %
% % gui_set(panel_handle,'remove',names)
% %  remove entries with given names  
% %
% % indx_cell=gui_set(panel_handle,'find',names)
% %  finds position of entries with given names as cell array of indices
% %  when n-th cell corensponds to n-th element of names
% %
% % gui_set(panel_handle,'set col',i,val)
% % out_values=gui_set(panel_handle,'get col',i);
% % [out_values,changed_values]=gui_set(panel_handle,'get col',i);
% % [out_values,changed_values,values]=gui_set(panel_handle,'get col',i);
% %   set and get i-th column of values
% %
% % gui_set(panel_handle,'set row',i,val)
% % [names,out_values,codes]=gui_set(panel_handle,'get row',i);
% % [names,out_values,codes,changed_values]=gui_set(panel_handle,'get row',i);
% % [names,out_values,codes,changed_values,values]=gui_set(panel_handle,'get row',i);
% %   set and get i-th row of values
% %
% % gui_set(panel_handle,'get element',[i j],val)
% % out_values=gui_set(panel_handle,'get element',[i j])
% % [out_values,changed_values]=gui_set(panel_handle,'get element',[i j]);
% % [out_values,changed_values,values]=gui_set(panel_handle,'get element',[i j]);
% %    set and get values for elemnt in i-th rown and j-th columns
% %
% % gui_set(panel_handle,'call_func',call_func)
% % gui_set(panel_handle,'edit_call_fun',edit_call_fun)
% % gui_set(panel_handle,'call_func_rows',call_func_rows)  
% % gui_set(panel_handle,'call_func_cols',call_func_cols)  
% % gui_set(panel_handle,'call_remove_func',call_remove_func)  
% % gui_set(panel_handle,'call_clear_func',call_clear_func)  
% %  set callbacks of existing GUI (see APPDATA below)
% %
% %
% %
% % ---------APPDATA-----------------------
% % -------- input/output data ------------
% % names       cell array of strings
% % values      cell array of strings , numbers or cells of these types
% % codes       vector of numbers 
% % 
% % --------- output data------------------
% % out_values        cell arrays as above including also not changed
% %                   default values
% % changed_values    cell array of strings or numbers
% %                   of size length(names) x obj_gui_set.n_fields_x (see paramater below) 
% %                   include only changed values
% % --------- state -----------------------
% % state             single value : slider position - with other data defines the state        
% % 
% % --------- definition of 'values' field----------
% % e.g. 
% % values{1}=={1 'ar' {1 'not one'}} means that 
% % first value for first name is number 1, second value is string 'ar'
% % and the third value is (default) number 1 but the third value could 
% % be choosen only between number 1 and string 'not one'  
% % 
% % changed_values{1} =={[] 'argh'  'not one'}  means that for first name
% % the first value was unchanged the second was string (edited) 'argh' 
% % and that in third value string 'not one' was chosen 
% %
% % the corrensponding out_values cell array row is  
% % out_values{1} =={1 'argh'  'not one'} 
% %
% % ---------PARAMETERES---------------
% % n_fields_y=7;                    number of visible rows in list
% % n_fields_x=3;                    number of values fields in list 
% %
% % name_string                      string with title of names column
% %                                  default 'Name'
% % value_string                     cell with n_fields_x strings with
% %                                  names of each of values columns
% %                                  default is a cell of ['Value 'num2str(number of column)]
% % func_cols_string                 cell with n_fields_y strings with
% %                                  column function names , 
% %                                  default a cell of empty strings
% % func_cols_string                 cell with n_fields_x strings with
% %                                  row function names
% %                                  default a cell of empty strings
% %
% % is_named=1;                      is name field shown
% % is_sortable=1;                   is list sortable by values
% % is_removable=1;                  are elements removable
% % is_clearable=1;                  is list clearable
% % is_func_rows=0;                  is there a rows function button
% % is_func_cols=0;                  is there a columns function button
% % 
% % not_editable=[];                 not editable values indices (vector)
% %
% % call_func=[];                    callback function called after each
% %                                  refresh of figure, arguments : call_func(panel_handle)
% % edit_call_func=[];               callback when value field was changed,
% %                                  arguments edit_call_func(panel_handle,
% %                                  [i1,i2],val) where i1 - row,i2-column,
% %                                  val - new value of field
% % call_func_rows=[];               callback to rows function, arguments:
% %                                  call_func_rows(hObject,panel_handle,i)
% %                                  hObject - handle to function button, 
% %                                  i - row number
% % call_func_cols=[];               callback to column function, arguments: 
% %                                  call_func_rows(hObject,panel_handle,i)
% %                                  hObject - handle to function button, 
% %                                  i - column number
% % call_remove_func=[];             callback to remove element function,
% %                                  arguments : call_remove_func(panel_handle,pos) 
% %                                  pos - removed row number
% % call_clear_func=[];              callback to clear function, arguments:
% %                                  call_clear_func(panel_handle)
% % 
% % remove_button_width=50;          remove button width
% % name_field_width=120;            name fields width
% % func_button_width=100;           rows function button width
% % value_field_widths=[];           values fiels widths (vector)
% % slider_width=15;                 slider width
% % field_height=20;                 fields width
% % marginx=5;                       extra x margins in interface
% % marginy=2;                       extra y margins in interface  
% % 
% % not_editable_color=[0.9 0.9 1];  not editable fields color
% % changed_color=[1 1 0.6];         changed fields color
% %
% %------ W.M.Saj 2008--------------

VERSION =1.0;

%% checking input
if nargin==2 & strcmp(varargin{2},'refresh')
    panel_handle=varargin{1};
    refresh(panel_handle,[],panel_handle,0);return;
end

if nargin==2 & strcmp(varargin{2},'clear')
    panel_handle=varargin{1};
    clear_func(panel_handle);
    refresh(panel_handle,[],panel_handle,0);return;
end

if nargin==2 & strcmp(varargin{2},'get state obj')
    
    panel_handle=varargin{1};
    
    state_obj.names=getappdata(panel_handle,'names');
    state_obj.values=getappdata(panel_handle,'values');
    state_obj.codes=getappdata(panel_handle,'codes');

    state_obj.out_values=getappdata(panel_handle,'out_values');
    state_obj.changed_values=getappdata(panel_handle,'changed_values');
    state_obj.state=getappdata(panel_handle,'state');
    
    varargout{1}=state_obj;
    return;
end

%% set user defined 'callback' for existing GUI
if nargin==3 & strcmp(varargin{2},'call_func')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.call_func=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end

if nargin==3 & strcmp(varargin{2},'edit_call_func')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.edit_call_func=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end

if nargin==3 & strcmp(varargin{2},'call_func_cols')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.call_func_cols=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end

if nargin==3 & strcmp(varargin{2},'call_func_rows')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.call_func_rows=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end

if nargin==3 & strcmp(varargin{2},'call_remove_func')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.call_remove_func=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end


if nargin==3 & strcmp(varargin{2},'call_clear_func')
    panel_handle=varargin{1};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    obj_gui_set.call_clear_func=varargin{3};
    setappdata(panel_handle,'obj_gui_set',obj_gui_set);
    return;
end

%% set state of existing GUI
if nargin==3 & strcmp(varargin{2},'state')
    panel_handle=varargin{1};   
    % setting state
    obj_gui_select=getappdata(panel_handle,'obj_gui_select');
    set(obj_gui_select.slider,'Value',varargin{3});
    refresh(panel_handle,[],panel_handle,0);return;
end

if nargin==3 & strcmp(varargin{2},'set state obj')
    
    panel_handle=varargin{1};
    state_obj=varargin{3};
    
    setappdata(panel_handle,'names',state_obj.names);
    setappdata(panel_handle,'values',state_obj.values);
    setappdata(panel_handle,'codes',state_obj.codes);

    setappdata(panel_handle,'out_values',state_obj.out_values);
    setappdata(panel_handle,'changed_values',state_obj.changed_values);
    setappdata(panel_handle,'state',state_obj.state);
   
    refresh(panel_handle,[],panel_handle,0);return;
end


%%
if nargin==5 & strcmp(varargin{2},'refresh')
    panel_handle=varargin{1};
    names_cl=varargin{3};values_cl=varargin{4};codes_ar=varargin{5};
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    
    if isempty(codes_ar) codes_ar=zeros(size(names_cl)); end;
    if isempty(values_cl) 
        for indx=1:length(names_cl) values_cl{indx}={};end 
    end
    
    setappdata(panel_handle,'names',names_cl);
    setappdata(panel_handle,'values',values_cl);
    setappdata(panel_handle,'codes',codes_ar);
    
    % creating output data : cell array of empty vectors
    changed_values_cl={};
    out_values_cl={};
    for indx1=1:length(names_cl)
        changed_values_cl{indx1}={};out_values_cl{indx1}={};
        for indx2=1:length(values_cl{indx1})
            changed_values_cl{indx1}{indx2}=[];
            val=values_cl{indx1}{indx2};if iscell(val) val=val{1}; end;
            out_values_cl{indx1}{indx2}=val;
        end
        for indx2=length(values_cl{indx1})+1:obj_gui_set.n_fields_x
            changed_values_cl{indx1}{indx2}=[];
            out_values_cl{indx1}{indx2}='';
        end
    end
    setappdata(panel_handle,'changed_values',changed_values_cl);
    setappdata(panel_handle,'out_values',out_values_cl);
   
    % refresh
    refresh(panel_handle,[],panel_handle,0); return;
end

%%
if nargin<7 & strcmp(varargin{2},'add')
    
    panel_handle=varargin{1};
    new_names_cl=varargin{3};new_values_cl=varargin{4};new_codes_ar=varargin{5};
    
    if isempty(new_names_cl)
        return;
    end
     
    obj_gui_set=getappdata(panel_handle,'obj_gui_set');
    
    if isempty(new_codes_ar) new_codes_ar=zeros(size(new_names_cl)); end;
    if isempty(new_values_cl) 
        for indx=1:length(new_names_cl) new_values_cl{indx}={};end 
    end
 
    names_cl=getappdata(panel_handle,'names');
    
    index_added=[1:length(new_names_cl)];
    % exclude repeating names
    if nargin==6 & isequal(varargin{6},'single')  
        for indx=1:length(names_cl)
                indx2=1;
                while(indx2<=length(new_names_cl))
                    if isequal(names_cl{indx},new_names_cl{indx2})
                        index_added=[index_added(1:indx2-1) index_added(indx2+1:length(index_added))];
                        new_names_cl=[new_names_cl(1:indx2-1) new_names_cl(indx2+1:length(new_names_cl))];
                        new_values_cl=[new_values_cl(1:indx2-1) new_values_cl(indx2+1:length(new_values_cl))];
                        new_codes_ar=[new_codes_ar(1:indx2-1) new_codes_ar(indx2+1:length(new_codes_ar))];
                    else                      
                        indx2=indx2+1;
                    end
                end
        end
        if isempty(new_names_cl)
            varargout{1}=[];
            return;
        end
    end
    
    values_cl=getappdata(panel_handle,'values');
    codes_ar=getappdata(panel_handle,'codes');
    
    setappdata(panel_handle,'names',[names_cl new_names_cl]);
    setappdata(panel_handle,'values',[values_cl new_values_cl]);
    setappdata(panel_handle,'codes',[codes_ar new_codes_ar]);
    
    % creating output data : cell array of empty vectors
    new_changed_values_cl={};
    new_out_values_cl={};
    for indx1=1:length(new_names_cl)
        new_changed_values_cl{indx1}={};new_out_values_cl{indx1}={};
        for indx2=1:length(new_values_cl{indx1})
            new_changed_values_cl{indx1}{indx2}=[];
            val=new_values_cl{indx1}{indx2};if iscell(val) val=val{1}; end;
            new_out_values_cl{indx1}{indx2}=val;
        end
        for indx2=length(new_values_cl{indx1})+1:obj_gui_set.n_fields_x
            new_changed_values_cl{indx1}{indx2}=[];
            new_out_values_cl{indx1}{indx2}='';
        end
    end
    
    changed_values_cl=getappdata(panel_handle,'changed_values');
    out_values_cl=getappdata(panel_handle,'out_values');
    
    setappdata(panel_handle,'changed_values',[changed_values_cl new_changed_values_cl]);
    setappdata(panel_handle,'out_values',[out_values_cl new_out_values_cl]);
    
    varargout{1}=index_added;
    
    % refresh
    refresh(panel_handle,[],panel_handle); return;
    
end

%%
if nargin==3 & strcmp(varargin{2},'remove')
    
    panel_handle=varargin{1};
    rem_names_cl=varargin{3};
    
    if isempty(rem_names_cl)
        return;
    end
     
    names_cl=getappdata(panel_handle,'names');
    values_cl=getappdata(panel_handle,'values');
    codes_ar=getappdata(panel_handle,'codes');
    changed_values_cl=getappdata(panel_handle,'changed_values');
    out_values_cl=getappdata(panel_handle,'out_values');
    
    % remove matching names
    is_removed=0;
    for indx=1:length(rem_names_cl)
        indx2=1;
        while(indx2<=length(names_cl))
            if isequal(rem_names_cl{indx},names_cl{indx2})
                names_cl=[names_cl(1:indx2-1) names_cl(indx2+1:length(names_cl))];
                values_cl=[values_cl(1:indx2-1) values_cl(indx2+1:length(values_cl))];
                codes_ar=[codes_ar(1:indx2-1) codes_ar(indx2+1:length(codes_ar))];
                changed_values_cl=[changed_values_cl(1:indx2-1) changed_values_cl(indx2+1:length(changed_values_cl))];
                out_values_cl=[out_values_cl(1:indx2-1) out_values_cl(indx2+1:length(out_values_cl))];
                is_removed=1;
            else
                indx2=indx2+1;
            end
        end
    end
    
    if is_removed==0
        return
    end
    
    setappdata(panel_handle,'names',names_cl);
    setappdata(panel_handle,'values',values_cl);
    setappdata(panel_handle,'codes',codes_ar);    
    setappdata(panel_handle,'changed_values',changed_values_cl);
    setappdata(panel_handle,'out_values',out_values_cl);
    
    % refresh
    refresh(panel_handle,[],panel_handle); return;
end

%%
if nargin==3 & strcmp(varargin{2},'find')
    
    panel_handle=varargin{1};
    
    look_names_cl=varargin{3};
    
    if isempty(look_names_cl)
        return;
    end
 
    names_cl=getappdata(panel_handle,'names');

    for indx=1:length(look_names_cl)
        search_res{indx}=[];
        for indx2=1:length(names_cl)
            if isequal(look_names_cl{indx},names_cl{indx2})
                search_res{indx}=[search_res{indx} indx2];
            end
        end
    end
    
    varargout{1}=search_res;
    return;
end

%%
if nargin==3 & strcmp(varargin{2},'get col')
    
    panel_handle=varargin{1};
    col_num=varargin{3};
     
    values_cl=getappdata(panel_handle,'values');
    changed_values_cl=getappdata(panel_handle,'changed_values');
    out_values_cl=getappdata(panel_handle,'out_values');
    
    for indx=1:length(values_cl)
        values{indx}=values_cl{indx}{col_num};
        changed_values{indx}=changed_values_cl{indx}{col_num};
        out_values{indx}=out_values_cl{indx}{col_num};
    end

    varargout{1}=out_values;
    if nargout>1
        varargout{2}=changed_values;
        if nargout>2
            varargout{3}=values;
        end
    end
    
    return;
    
end

%%
if nargin==4 & strcmp(varargin{2},'set col')
    
    panel_handle=varargin{1};
    col_num=varargin{3};
    col_val=varargin{4};
    
    changed_values_cl=getappdata(panel_handle,'changed_values');
    out_values_cl=getappdata(panel_handle,'out_values');
    
    for indx=1:length(changed_values_cl)
        changed_values_cl{indx}{col_num}=col_val{indx};
        out_values_cl{indx}{col_num}=col_val{indx};
    end
    
    setappdata(panel_handle,'changed_values',changed_values_cl);
    setappdata(panel_handle,'out_values',out_values_cl);
    
    refresh(panel_handle,[],panel_handle,0);return;
    
end

%%
if nargin==3 & strcmp(varargin{2},'get row')
    
    panel_handle=varargin{1};
    row_num=varargin{3};
     
    names=getappdata(panel_handle,'names');names=names{row_num};
    values=getappdata(panel_handle,'values');values=values{row_num};
    codes=getappdata(panel_handle,'codes');codes=codes(row_num);
    changed_values=getappdata(panel_handle,'changed_values');changed_values=changed_values{row_num};
    out_values=getappdata(panel_handle,'out_values');out_values=out_values{row_num};
    
    varargout{1}=names;
    varargout{2}=out_values;
    varargout{3}=codes;
    
    if nargout>3
        varargout{4}=values;
        if nargout>4
            varargout{5}=changed_values;    
        end
    end
    
    return;
end

%%
if nargin==4 & strcmp(varargin{2},'set row')
    
    panel_handle=varargin{1};
    row_num=varargin{3};
    row_val=varargin{4};
    
    changed_values=getappdata(panel_handle,'changed_values');
    out_values=getappdata(panel_handle,'out_values');
    
    changed_values{row_num}=row_val;
    out_values{row_num}=row_val;
    
    setappdata(panel_handle,'changed_values',changed_values);
    setappdata(panel_handle,'out_values',out_values);
    
    refresh(panel_handle,[],panel_handle,0);return;
    
end

%%
if nargin==3 & strcmp(varargin{2},'get element')
    
    panel_handle=varargin{1};
    row_num=varargin{3}(1);col_num=varargin{3}(2);
     
    out_values=getappdata(panel_handle,'out_values');out_values=out_values{row_num}{col_num};   
    varargout{1}=out_values;
    
    if nargout>1
        values=getappdata(panel_handle,'values');
        varargout{2}=values{row_num}{col_num};
        if nargout>2
            changed_values=getappdata(panel_handle,'changed_values');
            varargout{3}=changed_values{row_num}{col_num};    
        end
    end
    
    return;
end

%%
if nargin==4 & strcmp(varargin{2},'set element')
    
    panel_handle=varargin{1};
    row_num=varargin{3}(1);col_num=varargin{3}(2);
    val=varargin{4};
    
    changed_values=getappdata(panel_handle,'changed_values');
    out_values=getappdata(panel_handle,'out_values');
    
    changed_values{row_num}{col_num}=val;
    out_values{row_num}{col_num}=val;
    
    setappdata(panel_handle,'changed_values',changed_values);
    setappdata(panel_handle,'out_values',out_values);
    
    refresh(panel_handle,[],panel_handle,0);return;
    
end


%% default
panel_handle=varargin{1};
names_cl=varargin{2};values_cl=varargin{3};codes_ar=varargin{4};

if isempty(codes_ar) codes_ar=zeros(size(names_cl)); end;
if isempty(values_cl) 
    for indx=1:length(names_cl) values_cl{indx}={};end 
end

%% component default parameters
obj_gui_set.n_fields_y=7;
obj_gui_set.n_fields_x=3;
obj_gui_set.is_named=1;
obj_gui_set.is_sortable=1;
obj_gui_set.is_removable=1;
obj_gui_set.is_clearable=1;
obj_gui_set.is_func_rows=0;
obj_gui_set.is_func_cols=0;

obj_gui_set.not_editable=[];
obj_gui_set.call_func=[];
obj_gui_set.edit_call_func=[];
obj_gui_set.call_func_rows=[];
obj_gui_set.call_func_cols=[];
obj_gui_set.call_remove_func=[];
obj_gui_set.call_clear_func=[];

obj_gui_set.remove_button_width=50;
obj_gui_set.name_field_width=120;
obj_gui_set.func_button_width=100;
obj_gui_set.value_field_widths=[];
obj_gui_set.slider_width=15;
obj_gui_set.field_height=20;
obj_gui_set.marginx=5;
obj_gui_set.marginy=2;

obj_gui_set.not_editable_color=[0.9 0.9 1];
obj_gui_set.changed_color=[1 1 0.6];

obj_gui_set.name_string='Name';

% auxillary
bottom_shift=obj_gui_set.marginy+obj_gui_set.field_height/2;

%% setting values
for idx=5:2:nargin
    eval(['obj_gui_set.' varargin{idx} '= varargin{idx+1};'])
end

%%
if ~obj_gui_set.is_func_rows
    func_rows_shift=0;
else
    func_rows_shift=obj_gui_set.func_button_width;
end

if ~obj_gui_set.is_func_cols
    func_cols_shift=0;
else
    func_cols_shift=obj_gui_set.field_height;
end

%% coorection for non-removable list
if ~obj_gui_set.is_removable
    obj_gui_set.remove_button_width=0;
end
%% correction of val. names 
if isfield(obj_gui_set,'value_string')
    for indx=1:length(obj_gui_set.value_string)
        if isempty(obj_gui_set.value_string{indx})
            obj_gui_set.value_string{indx}='';
        end
    end
    for indx=length(obj_gui_set.value_string)+1:obj_gui_set.n_fields_x
        obj_gui_set.value_string{indx}='';
    end
else
    for indx=1:obj_gui_set.n_fields_x obj_gui_set.value_string(indx)={['Value ' num2str(indx)]}; end
end


if isempty(obj_gui_set.value_field_widths)
    for indx=1:obj_gui_set.n_fields_x
        obj_gui_set.value_field_widths(indx)=100;
    end
end

if isfield(obj_gui_set,'func_cols_string')
    for indx=1:length(obj_gui_set.func_cols_string)
        if isempty(obj_gui_set.func_cols_string{indx})
            obj_gui_set.func_cols_string{indx}='';
        end
    end
    for indx=length(obj_gui_set.func_cols_string)+1:obj_gui_set.n_fields_x
        obj_gui_set.func_cols_string{indx}='';
    end
else
    for indx=1:obj_gui_set.n_fields_x obj_gui_set.func_cols_string(indx)={''}; end
end

if isfield(obj_gui_set,'func_rows_string')
    for indx=1:length(obj_gui_set.func_rows_string)
        if isempty(obj_gui_set.func_rows_string{indx})
            obj_gui_set.func_rows_string{indx}='';
        end
    end
    for indx=length(obj_gui_set.func_rows_string)+1:obj_gui_set.n_fields_y
        obj_gui_set.func_rows_string{indx}='';
    end
else
    for indx=1:obj_gui_set.n_fields_y obj_gui_set.func_rows_string(indx)={''}; end
end


%% definition of main handles
% figure handle
if isempty(panel_handle)
    h=figure('HandleVisibility','Off','NumberTitle','Off','Name',['gui_set v. ' num2str(VERSION)],'Resize','Off','MenuBar','None','Position',...
        [300 300....
        2*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.marginx+obj_gui_set.name_field_width+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+sum(obj_gui_set.value_field_widths)+2*obj_gui_set.marginx+func_rows_shift+obj_gui_set.slider_width...
        2*bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y)+(obj_gui_set.is_named || obj_gui_set.is_clearable) * obj_gui_set.field_height]);
    panel_handle=uipanel('Parent',h);
else
    set(panel_handle,'Units','pixels');
    pos_tmp=get(panel_handle,'Position');
    set(panel_handle,'Position',...
        [pos_tmp(1) pos_tmp(2) ... 
        2*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.marginx+obj_gui_set.name_field_width+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+sum(obj_gui_set.value_field_widths)+2*obj_gui_set.marginx+func_rows_shift+obj_gui_set.slider_width...
        2*bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y)+(obj_gui_set.is_named || obj_gui_set.is_clearable)*obj_gui_set.field_height]);
end


%% settting output
varargout{1}=panel_handle;

%% creating elements specific for components

% pre-allocation of space for handles
obj_gui_set.name_list_handle=zeros(obj_gui_set.n_fields_y,1);
obj_gui_set.popupmenu_value_handle=zeros(obj_gui_set.n_fields_y,obj_gui_set.n_fields_x);
obj_gui_set.value_edit_handle=zeros(obj_gui_set.n_fields_y,obj_gui_set.n_fields_x);

if obj_gui_set.is_removable
    obj_gui_set.remove_handle=zeros(obj_gui_set.n_fields_y,1); 
end 
   
if obj_gui_set.is_named
    obj_gui_set.value_text_handle=zeros(1,obj_gui_set.n_fields_x);
end

% gui                
for indx=1:obj_gui_set.n_fields_y
    
    if obj_gui_set.is_removable
        obj_gui_set.remove_handle(indx)=uicontrol(panel_handle,'Style','pushbutton',...
            'String','Remove','FontAngle','Italic','UserData',indx,'Position',...
            [obj_gui_set.marginx bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y-indx) obj_gui_set.remove_button_width obj_gui_set.field_height]);
    end
    
    if obj_gui_set.is_func_rows
      obj_gui_set.func_rows_handle(indx)=uicontrol(panel_handle,'Style','pushbutton',...
     'String',obj_gui_set.func_rows_string{indx},'FontAngle','Italic','UserData',indx,'Position',...
            [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+sum(obj_gui_set.value_field_widths)....
            bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y-indx) ....
            obj_gui_set.func_button_width obj_gui_set.field_height]);
    end
    
    obj_gui_set.name_list_handle(indx)=uicontrol(panel_handle,'Style','edit','FontWeight','Bold','FontAngle','Italic',...
        'String',{''},'Enable','Inactiv','BackgroundColor',obj_gui_set.not_editable_color,'Position',...
        [2*obj_gui_set.marginx+obj_gui_set.remove_button_width ...
        bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y-indx)...
        obj_gui_set.name_field_width obj_gui_set.field_height]);
        
            for indx2=1:obj_gui_set.n_fields_x

                obj_gui_set.popupmenu_value_handle(indx,indx2)=uicontrol(panel_handle,'Style','popupmenu','String',{''},...
                'FontAngle','Italic','Value',1,'UserData',[indx indx2],'BackgroundColor','white','Position',...
                [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*(indx2-1)+sum(obj_gui_set.value_field_widths(1:indx2-1))...
                bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y-indx)... 
                obj_gui_set.value_field_widths(indx2) obj_gui_set.field_height]);
            
                obj_gui_set.value_edit_handle(indx,indx2)=uicontrol(panel_handle,'Style','edit','String',{''},...
                    'UserData',[indx indx2],'BackgroundColor','white','Value',1,'Position',...
                    [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*(indx2-1)+sum(obj_gui_set.value_field_widths(1:indx2-1))...
                    bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y-indx)...
                    obj_gui_set.value_field_widths(indx2)-15 obj_gui_set.field_height]);
            end
end
% names of values  and columns functions (optional)

if obj_gui_set.is_func_cols
    for indx=1:obj_gui_set.n_fields_x
        obj_gui_set.func_cols_handle(indx)=uicontrol(panel_handle,'Style','pushbutton','FontAngle','Italic','FontWeight','Bold','String',obj_gui_set.func_cols_string{indx},'UserData',indx,'Position',...
        [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*(indx-1)+sum(obj_gui_set.value_field_widths(1:indx-1))...
        bottom_shift+obj_gui_set.marginy obj_gui_set.value_field_widths(indx) obj_gui_set.field_height]);
    end
end

obj_gui_set.slider_handle=uicontrol(panel_handle,'Style','slider','Min',1,'Value',max(length(names_cl)-obj_gui_set.n_fields_y+1,1),'Position',...
              [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+sum(obj_gui_set.value_field_widths)+func_rows_shift...
              bottom_shift+func_cols_shift obj_gui_set.slider_width ....
              (obj_gui_set.field_height+obj_gui_set.marginy)*obj_gui_set.n_fields_y+(obj_gui_set.is_named || obj_gui_set.is_clearable)*obj_gui_set.field_height]);

obj_gui_set.up_handle= uicontrol(panel_handle,'Style','pushbutton','String','up','FontAngle','Italic','Position',...
    [obj_gui_set.marginx bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y)+(obj_gui_set.is_named || obj_gui_set.is_clearable)*obj_gui_set.field_height ... 
    obj_gui_set.remove_button_width+obj_gui_set.marginx+obj_gui_set.name_field_width+sum(obj_gui_set.value_field_widths)+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+obj_gui_set.marginx+func_rows_shift+obj_gui_set.marginx+obj_gui_set.slider_width obj_gui_set.field_height/2]);
            
obj_gui_set.down_handle= uicontrol(panel_handle,'Style','pushbutton','String','down','FontAngle','Italic','Position',...
    [obj_gui_set.marginx obj_gui_set.marginy ...
    obj_gui_set.remove_button_width+obj_gui_set.marginx+obj_gui_set.name_field_width+(obj_gui_set.marginx)*obj_gui_set.n_fields_x+sum(obj_gui_set.value_field_widths)+obj_gui_set.marginx+func_rows_shift+obj_gui_set.marginx+obj_gui_set.slider_width obj_gui_set.field_height/2]);

if (obj_gui_set.is_removable && obj_gui_set.is_clearable)
obj_gui_set.clear_handle = uicontrol(panel_handle,'Style','pushbutton','String','Clear','FontAngle','Italic','Position',...
    [obj_gui_set.marginx bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*(obj_gui_set.n_fields_y) obj_gui_set.remove_button_width obj_gui_set.field_height]);
end
            
% names

if obj_gui_set.is_named
    
    obj_gui_set.name_text_handle=uicontrol(panel_handle,'Style','pushbutton','String',obj_gui_set.name_string,'FontWeight','Bold',...
                    'Position',[2*obj_gui_set.marginx+obj_gui_set.remove_button_width ...
                    bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*obj_gui_set.n_fields_y obj_gui_set.name_field_width obj_gui_set.field_height]);

    for indx=1:obj_gui_set.n_fields_x  
        obj_gui_set.value_text_handle(indx)=uicontrol(panel_handle,'Style','pushbutton','FontWeight','Bold','String',obj_gui_set.value_string{indx},'UserData',indx,'Position',...
        [3*obj_gui_set.marginx+obj_gui_set.remove_button_width+obj_gui_set.name_field_width+(obj_gui_set.marginx)*(indx-1)+sum(obj_gui_set.value_field_widths(1:indx-1))...
        bottom_shift+func_cols_shift+(obj_gui_set.field_height+obj_gui_set.marginy)*obj_gui_set.n_fields_y obj_gui_set.value_field_widths(indx) obj_gui_set.field_height]);
    end
    
end 

%% setting callbacks to elements
set(obj_gui_set.slider_handle,'Callback',@(hObject,eventdata) refresh(hObject,eventdata,panel_handle,0))
set(obj_gui_set.up_handle,'Callback',@(hObject,eventdata) up(hObject,eventdata,panel_handle))
set(obj_gui_set.down_handle,'Callback',@(hObject,eventdata) down(hObject,eventdata,panel_handle))

if obj_gui_set.is_removable
    if obj_gui_set.is_clearable
        set(obj_gui_set.clear_handle,'Callback',@(hObject,eventdata) clear_btt(hObject,eventdata,panel_handle))
    end
    set(obj_gui_set.remove_handle,'Callback',@(hObject,eventdata) remove_entry(hObject,eventdata,panel_handle))
end

if obj_gui_set.is_named
    if obj_gui_set.is_sortable>0
        set(obj_gui_set.name_text_handle,'Callback',@(hObject,eventdata) sort_btt(hObject,eventdata,panel_handle))
    else
        set(obj_gui_set.name_text_handle,'Enable','Inactive')
    end
end

if obj_gui_set.n_fields_x>0
    set(obj_gui_set.popupmenu_value_handle,'Callback',@(hObject,eventdata) change_choose_value(hObject,eventdata,panel_handle))
    set(obj_gui_set.value_edit_handle,'Callback',@(hObject,eventdata) change_edit_value(hObject,eventdata,panel_handle))
    
    if obj_gui_set.is_named
        if obj_gui_set.is_sortable>0
            set(obj_gui_set.value_text_handle,'Callback',@(hObject,eventdata) sort_btt2(hObject,eventdata,panel_handle))
        else
            set(obj_gui_set.value_text_handle,'Enable','Inactive')
        end
    end
    
    if obj_gui_set.is_func_cols>0
        set(obj_gui_set.func_cols_handle,'Callback',@(hObject,eventdata) pre_call_func_cols(hObject,eventdata,panel_handle));
    end
end

if obj_gui_set.is_func_rows>0
    set(obj_gui_set.func_rows_handle,'Callback',@(hObject,eventdata) pre_call_func_rows(hObject,eventdata,panel_handle));
end

%% setting data fields
setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'codes',codes_ar);

% creating output data
changed_values_cl={};
out_values_cl={};

    for indx1=1:length(names_cl)
        changed_values_cl{indx1}={};out_values_cl{indx1}={};
        for indx2=1:length(values_cl{indx1})
            changed_values_cl{indx1}{indx2}=[];
            val=values_cl{indx1}{indx2};if iscell(val) val=val{1}; end;
            out_values_cl{indx1}{indx2}=val;
        end
        for indx2=length(values_cl{indx1})+1:obj_gui_set.n_fields_x
            changed_values_cl{indx1}{indx2}=[];
            out_values_cl{indx1}{indx2}='';
        end
    end
setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

setappdata(panel_handle,'obj_gui_set',obj_gui_set);

% refresh
refresh(panel_handle,[],panel_handle,0)

function refresh(hObject,eventdata,panel_handle,call_callback)

if nargin<4
    call_callback=1;
end

obj_gui_set=getappdata(panel_handle,'obj_gui_set');

names_cl=getappdata(panel_handle,'names');
values_cl=getappdata(panel_handle,'values');
changed_values_cl=getappdata(panel_handle,'changed_values');

% aux
n_data=length(names_cl);

if (obj_gui_set.is_removable && obj_gui_set.is_clearable)
    if n_data==0
        set(obj_gui_set.clear_handle,'Enable','Off');
    else
        set(obj_gui_set.clear_handle,'Enable','On');    
    end
end

if n_data>obj_gui_set.n_fields_y
    set(obj_gui_set.slider_handle,'Visible','On');
    set(obj_gui_set.slider_handle,'Value',min(get(obj_gui_set.slider_handle,'Value'),n_data-obj_gui_set.n_fields_y+1));
    slider_val=1+(n_data-obj_gui_set.n_fields_y+1)-round(get(obj_gui_set.slider_handle,'Value'));
    set(obj_gui_set.slider_handle,'Max',(n_data-obj_gui_set.n_fields_y+1));
    set(obj_gui_set.slider_handle,'SliderStep',[1 1]./(n_data-obj_gui_set.n_fields_y));

    if slider_val>1
        set(obj_gui_set.up_handle,'Visible','On')
    else
        set(obj_gui_set.up_handle,'Visible','Off')
    end

    if slider_val<(n_data-obj_gui_set.n_fields_y+1)
        set(obj_gui_set.down_handle,'Visible','On')
    else
        set(obj_gui_set.down_handle,'Visible','Off')
    end 

else
    slider_val=1;
    set(obj_gui_set.slider_handle,'Visible','Off');
    set(obj_gui_set.slider_handle,'Value',1);
    set(obj_gui_set.up_handle,'Visible','Off')
    set(obj_gui_set.down_handle,'Visible','Off')
end

for indx1=1:min(n_data,obj_gui_set.n_fields_y)
    
    set(obj_gui_set.name_list_handle(indx1),'String',names_cl{indx1+slider_val-1},'Enable','Inactive');
    
    if obj_gui_set.is_removable
        set(obj_gui_set.remove_handle(indx1),'Enable','On');
    end

    if obj_gui_set.is_func_rows>0
        set(obj_gui_set.func_rows_handle(indx1),'Enable','On')
    end
    
    for indx2=1:obj_gui_set.n_fields_x
        [val,popvals,is_changed]=get_value(values_cl,changed_values_cl,indx1+slider_val-1,indx2);
        if isnumeric(val) val=num2str(val); end;
        set(obj_gui_set.value_edit_handle(indx1,indx2),'String',val);

        if isequal(popvals,'')
            set(obj_gui_set.value_edit_handle(indx1,indx2),'Enable','On','FontAngle','Normal');
            set(obj_gui_set.popupmenu_value_handle(indx1,indx2),'Enable','Off');
        else
            set(obj_gui_set.value_edit_handle(indx1,indx2),'Enable','Inactive','FontAngle','Italic');
            set(obj_gui_set.popupmenu_value_handle(indx1,indx2),'String',popvals);
            set(obj_gui_set.popupmenu_value_handle(indx1,indx2),'Enable','On'); 
        end
        if is_changed
            set(obj_gui_set.value_edit_handle(indx1,indx2),'BackgroundColor',obj_gui_set.changed_color);
        else
            set(obj_gui_set.value_edit_handle(indx1,indx2),'BackgroundColor','white');
        end
    end
end

% extra loop for non-editable
for indx2=obj_gui_set.not_editable
    for indx=1:obj_gui_set.n_fields_y  
        set(obj_gui_set.popupmenu_value_handle(indx,indx2),'Enable','Off');
        set(obj_gui_set.value_edit_handle(indx,indx2),'Enable','Inactive','BackgroundColor',obj_gui_set.not_editable_color);
    end
end


for indx1=min(n_data,obj_gui_set.n_fields_y)+1:obj_gui_set.n_fields_y
    if obj_gui_set.is_removable
        set(obj_gui_set.remove_handle(indx1),'Enable','Off');
    end
    set(obj_gui_set.name_list_handle(indx1),'String','','Enable','Off');
    for indx2=1:obj_gui_set.n_fields_x
        set(obj_gui_set.value_edit_handle(indx1,indx2),'String','','Enable','Off');
        set(obj_gui_set.popupmenu_value_handle(indx1,indx2),'Enable','Off');
    end
    if obj_gui_set.is_func_rows>0
        set(obj_gui_set.func_rows_handle(indx1),'Enable','Off')
    end
end

% saving the state data
setappdata(panel_handle,'state',get(obj_gui_set.slider_handle,'Value'));

% calling the user set function
if call_callback && ~isempty(obj_gui_set.call_func)
    feval(obj_gui_set.call_func,panel_handle);
end


function remove_entry(hObject,eventdata,panel_handle)

obj_gui_set=getappdata(panel_handle,'obj_gui_set');

names_cl=getappdata(panel_handle,'names');
values_cl=getappdata(panel_handle,'values');
codes_ar=getappdata(panel_handle,'codes');

changed_values_cl=getappdata(panel_handle,'changed_values');
out_values_cl=getappdata(panel_handle,'out_values');

% aux
n_data=length(names_cl);

if isequal(get(obj_gui_set.slider_handle,'Visible'),'on')
    slider_val=1+(n_data-obj_gui_set.n_fields_y+1)-round(get(obj_gui_set.slider_handle,'Value'));
else
    slider_val=1;
end

pos=get(hObject,'UserData')+slider_val-1;

names_cl=[names_cl(1:pos-1) names_cl(pos+1:n_data)];
values_cl=[values_cl(1:pos-1) values_cl(pos+1:n_data)];
codes_ar=[codes_ar(1:pos-1) codes_ar(pos+1:n_data)];

changed_values_cl=[changed_values_cl(1:pos-1) changed_values_cl(pos+1:n_data)];
out_values_cl=[out_values_cl(1:pos-1) out_values_cl(pos+1:n_data)];

setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'codes',codes_ar);

setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

if ~isempty(obj_gui_set.call_remove_func)
    feval(obj_gui_set.call_remove_func,panel_handle,pos);
end

refresh(hObject,eventdata,panel_handle)

function up(hObject,eventdata,panel_handle)
obj_gui_set=getappdata(panel_handle,'obj_gui_set');
set(obj_gui_set.slider_handle,'Value',min(get(obj_gui_set.slider_handle,'Value')+1,get(obj_gui_set.slider_handle,'Max')));
refresh(hObject,eventdata,panel_handle,0)

function down(hObject,eventdata,panel_handle)
obj_gui_set=getappdata(panel_handle,'obj_gui_set');
set(obj_gui_set.slider_handle,'Value',max(get(obj_gui_set.slider_handle,'Value')-1,get(obj_gui_set.slider_handle,'Min')));
refresh(hObject,eventdata,panel_handle,0)


function [val,popvals,is_changed]=get_value(values_cl,changed_values_cl,i1,i2)

is_changed=0;

if isempty(values_cl) || length(values_cl{i1})<i2
    val='';
else
    val=values_cl{i1}{i2};
end

if iscell(val)
    for idx=1:length(val)
        if isnumeric(val{idx})
            popvals(idx)={num2str(val{idx})};
        else
            popvals(idx)=val(idx);
        end
    end
    val=popvals{1};
else
    popvals='';
end

if ~isempty(changed_values_cl{i1}{i2})
    val=changed_values_cl{i1}{i2};
    is_changed=1;
end

function change_edit_value(hObject,eventdata,panel_handle)

obj_gui_set=getappdata(panel_handle,'obj_gui_set');

values_cl=getappdata(panel_handle,'values');
changed_values_cl=getappdata(panel_handle,'changed_values');
out_values_cl=getappdata(panel_handle,'out_values');

val=get(hObject,'String');

n_data=length(values_cl);

i=get(hObject,'UserData'); i1=i(1);i2=i(2);
if isequal(get(obj_gui_set.slider_handle,'Visible'),'on')
    i1=i1+(n_data-obj_gui_set.n_fields_y+1)-round(get(obj_gui_set.slider_handle,'Value'));
end

if length(values_cl{i1})>=i2 && isnumeric(values_cl{i1}{i2})
    val=str2num(val);
    if isempty(val)
        [val,popvals,is_changed]=get_value(values_cl,changed_values_cl,i1,i2);
        set(hObject,'String',num2str(val));
    end
end
changed_values_cl{i1}{i2}=val;
out_values_cl{i1}{i2}=val;

setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

refresh(hObject,eventdata,panel_handle)

if ~isempty(obj_gui_set.edit_call_func)
    feval(obj_gui_set.edit_call_func,panel_handle,[i1,i2],val);
end


function change_choose_value(hObject,eventdata,panel_handle)

obj_gui_set=getappdata(panel_handle,'obj_gui_set');

values_cl=getappdata(panel_handle,'values');
changed_values_cl=getappdata(panel_handle,'changed_values');
out_values_cl=getappdata(panel_handle,'out_values');

str=get(hObject,'String');pos=get(hObject,'Value');
val=str{pos};

n_data=length(values_cl);

i=get(hObject,'UserData'); i1=i(1);i2=i(2);
if isequal(get(obj_gui_set.slider_handle,'Visible'),'on')
    i1=i1+(n_data-obj_gui_set.n_fields_y+1)-round(get(obj_gui_set.slider_handle,'Value'));
end

if length(values_cl{i1})>=i2 && isnumeric(values_cl{i1}{i2}{pos})   
    val=str2num(val);
end

changed_values_cl{i1}{i2}=val;
out_values_cl{i1}{i2}=val;

setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

refresh(hObject,eventdata,panel_handle)

if ~isempty(obj_gui_set.edit_call_func)
    feval(obj_gui_set.edit_call_func,panel_handle,[i1,i2],val);
end

function sort_btt(hObject,eventdata,panel_handle)

names_cl=getappdata(panel_handle,'names'); if isempty(names_cl) return; end;
values_cl=getappdata(panel_handle,'values');
codes_ar=getappdata(panel_handle,'codes');
changed_values_cl=getappdata(panel_handle,'changed_values');
out_values_cl=getappdata(panel_handle,'out_values');

[names_cl_sorted,sort_indices]=sort(names_cl);
names_cl=names_cl_sorted;
values_cl=values_cl(sort_indices);
codes_ar=codes_ar(sort_indices);
changed_values_cl=changed_values_cl(sort_indices);
out_values_cl=out_values_cl(sort_indices);

setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'codes',codes_ar);

setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

refresh(hObject,eventdata,panel_handle)

function sort_btt2(hObject,eventdata,panel_handle)

names_cl=getappdata(panel_handle,'names');if isempty(names_cl) return; end;
values_cl=getappdata(panel_handle,'values');
codes_ar=getappdata(panel_handle,'codes');
changed_values_cl=getappdata(panel_handle,'changed_values');
out_values_cl=getappdata(panel_handle,'out_values');

% aux
nr_val=get(hObject,'UserData');

% we get sorted data
check_numeric=1;check_string=1;
for indx=1:length(names_cl)
    [val,popvals,is_changed]=get_value(values_cl,changed_values_cl,indx,nr_val);
    % we check for type
    if isnumeric(val)
        if ~isempty(val)
            val=val(1);
        end
        check_string=0;
    else
        check_numeric=0;
    end
    sorted_arr{indx}=val;
end

if check_numeric==1 && check_string==0
    for indx=1:length(names_cl)
        sorted_arr_new{indx}=num2str(sorted_arr{indx});
    end
    sorted_arr=sorted_arr_new;
end

if check_numeric==0 && check_string==0
    for indx=1:length(names_cl)
        if isnumeric(sorted_arr{i})
            sorted_arr{i}=num2str(sorted_arr{i});
        end
    end    
end

[names_cl_sorted_arr,sort_indices]=sort(sorted_arr);

names_cl=names_cl(sort_indices);
values_cl=values_cl(sort_indices);
codes_ar=codes_ar(sort_indices);
changed_values_cl=changed_values_cl(sort_indices);
out_values_cl=out_values_cl(sort_indices);

setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'codes',codes_ar);

setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

refresh(hObject,eventdata,panel_handle)


function clear_btt(hObject,eventdata,panel_handle)

if isequal(questdlg('Clear ?','Confirm or deny','Ok','Cancel','Cancel') ,'Cancel')
    return
end

clear_func(panel_handle);
refresh(hObject,eventdata,panel_handle);


function clear_func(panel_handle)

names_cl={};values_cl={};codes_ar=[];
changed_values_cl={};out_values_cl={};

setappdata(panel_handle,'names',names_cl);
setappdata(panel_handle,'values',values_cl);
setappdata(panel_handle,'codes',codes_ar);
setappdata(panel_handle,'changed_values',changed_values_cl);
setappdata(panel_handle,'out_values',out_values_cl);

obj_gui_set=getappdata(panel_handle,'obj_gui_set');
if ~isempty(obj_gui_set.call_clear_func)
    feval(obj_gui_set.call_clear_func,panel_handle);
end

function pre_call_func_cols(hObject,eventdata,panel_handle)
% translate position and call for callback
obj_gui_set=getappdata(panel_handle,'obj_gui_set');
i=get(hObject,'UserData');

if ~isempty(obj_gui_set.call_func_cols)
    feval(obj_gui_set.call_func_cols,hObject,panel_handle,i);
end


function pre_call_func_rows(hObject,eventdata,panel_handle)
% translate position and call for callback

obj_gui_set=getappdata(panel_handle,'obj_gui_set');
n_data=length(getappdata(panel_handle,'names'));

i=get(hObject,'UserData');
if isequal(get(obj_gui_set.slider_handle,'Visible'),'on')
    i=i+(n_data-obj_gui_set.n_fields_y+1)-round(get(obj_gui_set.slider_handle,'Value'));
end

if ~isempty(obj_gui_set.call_func_rows)
    feval(obj_gui_set.call_func_rows,hObject,panel_handle,i);
end