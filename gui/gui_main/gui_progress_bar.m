function handle=gui_progress_bar(handle,arg)
% % gui_progress_bar v 1.0 (Aug 2008)
% %
% % handle=gui_progress_bar([],name)
% %  creates a new progress bar with given name
% %
% % handle=gui_progress_bar(handle,percent)
% %  set an existing progress bar value to percent (0-100)  
% %
% % ------------W.M.Saj 2008--------------------------

% interanal params
bar_hei=0.8;
bar_wid=0.8;
bar_col='b';

if isempty(handle)
    
    if nargin<2
        arg='Progress';
    end
    
    handle=dialog('Name',arg,'MenuBar','None','Resize','Off','Visible','Off','Position',[100 100 300 50],'NumberTitle','Off');
    gui_screen_position(handle);
    ax=axes('Parent',handle,'Visible','Off');
    
    pos=[(1-bar_wid)/2 (1-bar_hei)/2 bar_wid bar_hei];
    rectangle('Position',pos,'FaceColor','w','Parent',ax);   
    progress_handle=rectangle('Position',pos,'FaceColor',bar_col,'Parent',ax,'Visible','Off');
    text_handle=text(0.5,0.5,['0 %'],'HorizontalAlignment','Center','VerticalAlignment','Middle','FontWeight','Bold','Parent',ax);
    
    setappdata(handle,'text_handle',text_handle);
    setappdata(handle,'progress_handle',progress_handle);
    setappdata(handle,'pos',pos);
    
    set(handle,'Visible','On');
    figure(handle);
    
else
    
    try
        text_handle=getappdata(handle,'text_handle');
    catch
        return;
    end
    
    set(text_handle,'String',[num2str(round(arg)) ' %']);
    
    progress_handle=getappdata(handle,'progress_handle');
    if arg>0
        pos=getappdata(handle,'pos');
        pos(3)=arg*pos(3)/100;
        set(progress_handle,'Position',pos,'Visible','On');
    else
        set(progress_handle,'Visible','Off')
    end
    
    figure(handle);
        
end