function main_handle=gui_layout(main_handle,cell_array,varargin)
% % GUI layout  organize panels in figures v 1.0 (Aug 2008)
% %
% % figure_handle=gui_layout(figure_handle,cell_array,'param1', param1_val, 'param2', param2_val...)
% %
% %  organize the gui layout - position of panels in figure_handle according 
% %  to position of panel handles in nested cell_array where each
% %  sub-bracket relates to 90 deg change of layout organization
% %
% %  e.g. {a {{b c} d}} (with paramater (default) hv_switch==0) relates to
% %  GUI organized as follows :
% %     ________ 
% %     |  a    |
% %     |-------|
% %     | b |   |
% %     | - | d |
% %     | c |   |
% %     ---------
% % (with hv_switch == 1 the layout of GUI is roted 90 degress left)
% %
% % ---------parameters (default values) : ------------
% % margin_x=5;     extra x-margin for gui interface
% % margin_y=5;     extra y-margin for gui interface
% % hv_switch=0;    switch between horizontal and vertical layout
% %
% % ------------W.M.Saj 2008--------------------------

margin_x=1;
margin_y=1;
hv_switch=0;

%% setting values
for idx=1:2:nargin-2
    eval([varargin{idx} '= varargin{idx+1};'])
end


[wmax,hmax,pos_arr,handles_arr]=find_size(cell_array,margin_x,margin_y,hv_switch);
set(handles_arr,'Parent',main_handle);pos=getpixelposition(main_handle);
setpixelposition(main_handle,[pos(1)-(wmax-pos(3))/2 pos(2)-(hmax-pos(4))/2 wmax hmax]);

for indx=1:length(handles_arr)
    setpixelposition(handles_arr(indx),pos_arr{indx});
end


% recurrent finding of elements position inside the main panel (figure)
function [wmax,hmax,pos_arr,handles_arr]=find_size(cell_arr,marginw,marginh,wsp)

warr=[];harr=[];pos_arr=[];
w_tmp=[];h_tmp=[];handles_arr=[];

for indx=1:length(cell_arr)
    if iscell(cell_arr{indx})
        [w,h,pos,handles]=find_size(cell_arr{indx},marginw,marginh,wsp+1);        
        for id=1:length(pos)
            if mod(wsp,2)==0
                pos{id}(2)=pos{id}(2)+sum(harr)+(length(harr))*marginh;
            else
                pos{id}(1)=pos{id}(1)+sum(warr)+(length(warr))*marginw;
            end
            w_tmp=[w_tmp w];h_tmp=[h_tmp h];
        end
        pos_arr=[pos_arr pos];handles_arr=[handles_arr handles];
        warr=[warr w];harr=[harr h];
    else
        position=getpixelposition(cell_arr{indx});
                
        warr=[warr position(3)];harr=[harr position(4)];
    end
end

if mod(wsp,2)==0
    wmax=max(warr)+2*marginw;hmax=sum(harr)+(length(harr)+1)*marginh;
else
    wmax=sum(warr)+(length(warr)+1)*marginw;hmax=max(harr)+2*marginh;   
end

for indx=1:length(pos_arr)
        if mod(wsp,2)==0
            pos_arr{indx}(1)=pos_arr{indx}(1)+(wmax-w_tmp(indx))/2;
        else
            pos_arr{indx}(2)=pos_arr{indx}(2)+(hmax-h_tmp(indx))/2;
        end
end

id=1;pos_add=[];

for indx=1:length(cell_arr)
    if ~iscell(cell_arr{indx})
        position=getpixelposition(cell_arr{indx});
        if mod(wsp,2)==0
            pos1=(wmax-position(3))/2;pos2=sum(harr(1:indx-1))+indx*marginh;
        else
            pos1=sum(warr(1:indx-1))+indx*marginw;pos2=(hmax-position(4))/2;
        end
        pos_add{id}=position;
        pos_add{id}(1)=pos1;pos_add{id}(2)=pos2;
        handles_arr=[handles_arr cell_arr{indx}];
        id=id+1;
    end
end

pos_arr=[pos_arr pos_add];