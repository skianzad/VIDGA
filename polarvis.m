function varargout = polarvis(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @polarvis_OpeningFcn, ...
                   'gui_OutputFcn',  @polarvis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Opening function, it imports the data from 'sig_accZ' and 'GTData.LF_HS'
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function polarvis_OpeningFcn(hObject, eventdata, handles, varargin)


global fnum
fnum=0;
clear start finish L handels.Tetha NORM
assignin('base','NORM',0)
axes(handles.axes16)
 set(gca,'xticklabel',{[]}) 
 set(gca,'yticklabel',{[]}) 
handles.datao=evalin('base','sig_accZ');
handles.GTData.LF_HS=evalin('base','GTData.LF_HS');
handles.view='L';
handles.data=handles.datao(1:16000);
handles.step=handles.GTData.LF_HS(1:110);
% handles.data=handles.datao(1:33000);
% handles.step=handles.GTData.LF_HS(1:220);
% handles.data=handles.datao;
% handles.step=handles.GTData.LF_HS;  % Uncomment to select the whole data
handles.Dis=(abs(max(handles.data(:)))+abs(min(handles.data(:))));
handles.rectx=[];
handles.recty=[];
 handles.xp=[];
 handles.yp=[];
 handles.XRL=[];
 handles.YRL=[];
 handles.NORM=0;
% data=sig_accZ;
% step=GTData.LF_HS;
handles.period=15;
handles.steps=floor(length(handles.step)/handles.period);
handles.R=(abs(max(handles.data(:)))+abs(min(handles.data(:))))*1.5;
handles.phase=0;
% handles.data=evalin('base','data');
% %data=X';
% handles.data=evalin('base','data');
% axes()
%implay('vid.mp4');
%  movie(handles.MView,'vid.mp4');
 % Initialize the display with the first frame of the video
 %[hFig, hAxes] = createFigureAndAxes();
%videoFReader   = vision.VideoFileReader('vid.mp4');
videoSrc = vision.VideoFileReader('videoplayback.mp4', 'ImageColorSpace', 'Intensity');
% depVideoPlayer = vision.DeployableVideoPlayer;
% cont = ~isDone(videoFReader);
  
axes(handles.axes15);
frame=step(videoSrc);
himg=imshow(frame);
for i=1:1
   frame=step(videoSrc);
    set(himg, 'CData', frame);  %instead of imshow
    drawnow;
   drawnow;
end
  axes(handles.axes3)
 plot(handles.data)
  set(gca,'xticklabel',{[]}) 
 set(gca,'yticklabel',{[]}) 
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = polarvis_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  execute to show the zooming on different plots
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on slider movement.
function Zoom_Callback(hObject, eventdata, handles) 
% eventdata  reserved - to be defined in a future version of MATLAB
if hObject.Value == 1
	zoom( handles.figure1, 'on' );
else
	zoom( handles.figure1, 'off' );
end
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function Run_CreateFcn(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  by pressing the run it will do the partitioning and superimposing
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Run_Callback(hObject, eventdata, handles)
global fnum;

for i=1:handles.period;
start(i)=(handles.step((i-1)*handles.steps+1));
finish(i)=(handles.step((i)*handles.steps));
L(i)=(finish(1,i)-start(1,i));
handles.Tetha{i,:}=linspace(0,pi/2,L(i));
handles.Tethap{i,:}=linspace(0,pi,L(i));
end
% if handles.view=='S'
%     
%  axes(handles.axes1);hold on 
%     for i=1:handles.period;
%     hplot=plot(handels.Tetha{i,1},handles.data(start(i):finish(i)-1)+i*handles.Dis);
%    
%     end
% else
xp=[];
yp=[];
 axes(handles.axes1);hold on   
 cla((handles.axes1));
    for i=1:handles.period
        %y=(R+data(start(i):finish(i)-1))'.*sin(handels.Tetha{i,1});
       % x=(R+data(start(i):finish(i)-1))'.*cos(handels.Tetha{i,1});
        yp=[yp,(handles.R+handles.data(start(i):finish(i)-1))'.*sin(handles.Tethap{i,1})];
        xp=[xp,(handles.R+handles.data(start(i):finish(i)-1))'.*cos(handles.Tethap{i,1})];
         x=(handles.R.*(cos(handles.Tetha{i,1}+handles.phase)).^2);
       if handles.phase>=0
           [m]=max(find(((handles.Tetha{i,1}+handles.phase))<=1.5708));
           extra=length(x)-m;
%             xlim([min(x) max(x)])
               xlim([-max(x) -min(x)]);
           hplot=plot(-x(1:m),handles.data(start(i):finish(i)-1-extra)+i*handles.Dis,'b.-');
       else
           [n]=max(find(((handles.Tetha{i,1}+handles.phase))<=0));
%             xlim([min(x) max(x)])
            xlim([-max(x) -min(x)]);
           hplot=plot(-x(n:length(x)),handles.data(start(i)+n:finish(i))+i*handles.Dis,'b.-');
       end
    set(gca,'yticklabel',{[]}) 
      
    end
        ylim([0 handles.period*handles.Dis+max(handles.data)]);
    hold off
    axes(handles.axes17)
    cla
    sat=(max(L)-min(L));
  %  figure;
  RGB=[1,.9,.2];
  HSV = rgb2hsv(RGB);
% "20% more" saturation:

    hold on 
     for i=1:handles.period
         ys=[i*handles.Dis,i*handles.Dis];
         xs=[0,2.5];
         HSV1 = HSV * abs(L(i)-mean(L))/sat;
         RGB1=hsv2rgb(HSV1);
         plot(xs,ys,'color',RGB1,'LineWidth',8)
     end
   xlim([1 2]);
    ylim([4 handles.period*handles.Dis+max(handles.data)]);
         set(gca,'xticklabel',{[]}) 
         set(gca,'yticklabel',{[]}) 
      hold off
    
 axes(handles.axes2);hold on   
 cla((handles.axes2));
 xlim([-handles.R-handles.R/8 handles.R+handles.R/8])
 handles.xp=xp;
 handles.yp=yp;
 plot(-xp,-yp)
 set(gca,'xticklabel',{[]}) 
 set(gca,'yticklabel',{[]}) 
 if fnum>0
     hold on 
     plot(-xp(fnum),-yp(fnum),'r--*','LineWidth',6)
     hold off
 end
 guidata(hObject,handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% It will take the abnormal data and compare it to the rest of data set.
% present the data in speed/ Distance graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in Abnormality.
function Abnormality_Callback(hObject, eventdata, handles)
global fnum;
NORM=evalin('base','NORM');
handles.NORM=NORM;
if handles.NORM==1
    errordlg('Normal steps not found (select "NORM")','File Error');
elseif handles.NORM==0
    handles.NORM=1;
    assignin('base','NORM',1)
else
    %handles.NORM=evalin('base','NORM');
    handles.Dis=(abs(max(handles.data(:)))+abs(min(handles.data(:))));
    maxim=round(max(handles.NORM(:,2))/handles.Dis);
    minim=round(min(handles.NORM(:,2))/handles.Dis);
    start(1)=(handles.step((1-1)*handles.steps+1));
    finish(1)=(handles.step((1)*handles.steps));
    L=(finish(1,1)-start(1,1));
    NORMp=handles.NORM(:,2)-(handles.Dis*(minim+1));
    xt=abs(mean((acos(sqrt(-handles.NORM(:,1)/handles.R)-handles.phase))*L*2/pi));
    part=round(xt/L*floor(110/handles.period));
    anom=part+(floor(110/handles.period)).*(minim-1:maxim-1);
    if(anom(1)<=0)
        anom(1)=anom(2);
    end
    anomp=handles.step(anom);
    axes(handles.axes3);
    cla
    plot(handles.data);
    hold on
    plot(handles.data(1:fnum),'k-.')
    anomally=[];
    for i=1:length(anomp)
        anomally=[anomally;handles.data(anomp(i)-150:anomp(i)+150)'];
        plot((anomp(i)-150:anomp(i)+150),handles.data(anomp(i)-150:anomp(i)+150),'r--');
    end
    hold off
    Norm=mean(anomally); 
    for i=2:length(handles.step)
        dist(i)=dtw(Norm,handles.data(handles.step(i)-150:handles.step(i)+150)');
    end
    Distn=dist(2:length(dist))-min(dist(2:length(dist)));
    % edges = min(Distn):10:max(Distn)
    % Bin= discretize(Distn,edges)
    % UN=unique(Bin)
    % M=histc(Bin,UN(1:length(UN)-1))
    for i=2:length(handles.step);
        speed(i-1)=10000/((handles.step(i))-(handles.step(i-1)));
    end
    axes(handles.axes15)
    cla
    
    plot(Distn,speed,'LineStyle','none','Marker','square','markerSize',10,'MarkerFaceColor',[.2,.2,.2],'MarkerEdgeColor',[.2,.2,.2])
    set(gca,'color',[0,0,0]);
    %  set(gca,'yticklabel',{'Speed (step/min)'}) 
    ylabel('Speed (step/min)', 'FontSize', 14);
    xlabel('Distance', 'FontSize', 14);
    if isempty(handles.rectx)
         handles.rectx=min(Distn)+20;
    end
    if isempty(handles.recty)
       handles.recty=min(speed)+10;
    end
    rectx=handles.rectx;
    recty=handles.recty;
    if isempty(handles.XRL)
        handles.XRL=.1;
    end
    if isempty(handles.YRL)
        handles.YRL=.1;
    end
    lrectx=handles.XRL*(max(Distn)-min(Distn));
    lrecty=handles.YRL*(max(speed)-min(speed));
    rectangle('position',[rectx,recty,lrectx,lrecty],'FaceColor',[.4,.35,.4],'EdgeColor',[.2,.2,.2]);
    grid on 
    ax = gca;
    ax.GridColor = [1, 1,1];
    hold on
    ylim=[min(speed) max(speed)];
    for i=2:length(handles.step)-1
        if (Distn(i)>=rectx)&&(Distn(i)<=rectx+lrectx)&&(speed(i)>=recty)&&(speed(i)<=recty+lrecty)
        plot(Distn(i),speed(i),'LineStyle','none','Marker','square','markerSize',10,'MarkerFaceColor',[.2,.9,.9])
        end
    end
    hold off
    axes(handles.axes3)
    hold on
    for i=2:length(handles.step)-1;
        if (Distn(i)>=rectx)&&(Distn(i)<=rectx+lrectx)&&(speed(i)>=recty)&&(speed(i)<=recty+lrecty)
        plot(handles.step(i),max(handles.data),'LineStyle','none','Marker','square','markerSize',10,'MarkerFaceColor',[.2,.9,.9])
        end
    end
    hold off
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Changing the position of Fisheye lense by adding a phase to polar
% perspective
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in brush.
function fishey_lens_Callback(hObject, eventdata, handles)
global fnum;
for i=1:handles.period;
    start(i)=(handles.step((i-1)*handles.steps+1));
    finish(i)=(handles.step((i)*handles.steps));
    L(i)=(finish(1,i)-start(1,i));
%     handles.Tetha{i,:}=linspace(0,pi/2,L(i)); 
    Tethap{i,:}=linspace(0,pi,L(i));
end
    
if hObject.Value == 1
   axes(handles.axes16)
   xl=[1.5,0,0,1.5,1.5,0,0,1.5,1.5,0,0,1.5,1.5,0,0,1.5];
   yl=[.5,.5,1,1,2,2,4,4,6,6,8,8,9,9,9.5,9.5];

 plot(yl,xl,':k','LineWidth',2)
    xlim([0 10]);
   ylim([0.2 1]);
     set(gca,'xticklabel',{[]}) 
 set(gca,'yticklabel',{[]}) 
   
	handles.view='L';
 axes(handles.axes1);hold on 
 cla(handles.axes1)
    X=[];
    Y=[]; 
    xp=[];
    yp=[];
  for i=1:handles.period
        %y=(R+data(start(i):finish(i)-1))'.*sin(handels.Tetha{i,1});
       % x=(R+data(start(i):finish(i)-1))'.*cos(handels.Tetha{i,1});
        yp=[yp,(handles.R+handles.data(start(i):finish(i)-1))'.*sin(Tethap{i,1})];
        xp=[xp,(handles.R+handles.data(start(i):finish(i)-1))'.*cos(Tethap{i,1})];
       x=(handles.R.*(cos(handles.Tetha{i,1}-handles.phase)).^2);
       if handles.phase>=0
       [m]=max(find(((handles.Tetha{i,1}+handles.phase))<=1.5708));
       extra=length(x)-m;
       xlim([-max(x) -min(x)])
       X=[X,(x(1:m))];
       Y=[Y,handles.data(start(i):finish(i)-1-extra)'+i*handles.Dis];
       else
       [n]=max(find(((handles.Tetha{i,1}+handles.phase))<=0));
         xlim([-max(x) -min(x)])
       X=[X,(x(n:length(x)))];
       Y=[Y,handles.data(start(i)+n:finish(i))'+i*handles.Dis];
       end
  end

plot(-X,Y,'.-')
 if fnum>0
     hold on 
     plot(X(fnum),Y(fnum),'g--o')
     hold off
 end
  
  drawnow; 
   axes(handles.axes2);hold on   
 cla((handles.axes2));
 xlim([-handles.R-handles.R/8 handles.R+handles.R/8])
 plot(-xp,-yp) 
else
       axes(handles.axes16)


	handles.view='S';
    
   xl=[0,1.5,1.5,0,0,1.5,1.5,0,0,1.5];
   yl=[0,0,2,2,4,4,6,6,8,8];

 plot(yl+1,xl,':k','LineWidth',2)
    xlim([0 10]);
   ylim([0.2 1]);
     set(gca,'xticklabel',{[]}) 
 set(gca,'yticklabel',{[]}) 
    axes(handles.axes1);hold on 
    cla(handles.axes1)
     xlim([min(handles.Tetha{i,1}) max(handles.Tetha{i,1})])
    for i=1:handles.period;
    hplot=plot(handles.Tetha{i,1},handles.data(start(i):finish(i)-1)+i*handles.Dis);
   
    end
     set(gca,'yticklabel',{[]}) 
          set(gca,'xticklabel',{[]}) 
     axes(handles.axes2);hold on
     cla(handles.axes2)
         for i=1:handles.period;
             mi=min(handles.Tetha{i,1});
             ma=max(handles.Tetha{i,1});
             %xlim([mi-ma/8 ma+ma/8])
              xlim([min(handles.Tetha{i,1})-ma/15 max(handles.Tetha{i,1})+ma/15])
             hplot=plot(handles.Tetha{i,1},handles.data(start(i):finish(i)-1));
         end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function enables brushing 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function brush_Callback (hObject, eventdata, handles)
if hObject.Value == 1
	brush( handles.figure1, 'on' );
else
	brush( handles.figure1, 'off' );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The output of slider will show in here
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function slider2_Callback(hObject, eventdata, handles)
global fnum;
axes(handles.axes1);
cla((handles.axes1));
C=get(hObject,'Value');
handles.phase=-C*pi/4;
for i=1:handles.period;
start(i)=(handles.step((i-1)*handles.steps+1));
finish(i)=(handles.step((i)*handles.steps));
% L(i)=(finish(1,i)-start(1,i));
% handles.Tetha{i,:}=linspace(0,pi/2,L(i));
 end
 hold on 
X=[];
Y=[];
  for i=1:handles.period
        %y=(R+data(start(i):finish(i)-1))'.*sin(handels.Tetha{i,1});
       % x=(R+data(start(i):finish(i)-1))'.*cos(handels.Tetha{i,1});
       x=(handles.R.*(cos(handles.Tetha{i,1}+handles.phase)).^2);
       if handles.phase>=0
       [m]=max(find(((handles.Tetha{i,1}+handles.phase))<=1.5708));
       extra=length(x)-m;
       xlim([-max(x) -min(x)]);
       X=[X,(x(1:m))];
       Y=[Y,handles.data(start(i):finish(i)-1-extra)'+i*handles.Dis];
       else
       [n]=max(find(((handles.Tetha{i,1}+handles.phase))<=0));
        xlim([-max(x) -min(x)]);
       X=[X,(x(n:length(x)))];
       Y=[Y,handles.data(start(i)+n:finish(i))'+i*handles.Dis];
       end
  end
plot(-X,Y,'.-')


 if fnum>0
     hold on 
     plot(-X(fnum),Y(fnum),'g--*')
     hold off
 end
 drawnow;
 guidata(hObject,handles)

function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Play.
function Play_Callback(hObject, eventdata, handles)
videoSrc = vision.VideoFileReader('kitten.mp4', 'ImageColorSpace', 'Intensity');
axes(handles.axes3);
p=1:length(handles.data);
h=animatedline('LineStyle','-.','Marker','.');
global fnum;
  axes(handles.axes15);

  
   while hObject.Value == 1
        axes(handles.axes15);
       frame=step(videoSrc);
         himg=imshow(frame);
    %  frame=step(videoSrc);
        set(himg, 'CData', frame);  %instead of imshow
        drawnow;
   fnum=fnum+10;
  % axes(handles.axes3)
addpoints(h, fnum, handles.data(fnum));
%hold on 
  %h(fnum=plot(fnum,handles.data(fnum),'r--*')
%hold off
   end
    if hObject.Value == 0        
        Run_Callback(hObject, eventdata, handles);
    end
        



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settign X in abnormality view
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit4_Callback(hObject, eventdata, handles)
Pp=get(handles.edit4,'string');
Period=str2num(Pp);
handles.period=Period;
handles.steps=floor(length(handles.step)/handles.period);
handles.R=(abs(max(handles.data(:)))+abs(min(handles.data(:))))*1.5;
handles.phase=0;
guidata(hObject, handles);

function edit4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settign Y in abnormality view
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit5_Callback(hObject, eventdata, handles)
handles.rectx=str2double(get(hObject,'String'));
guidata(hObject,handles);
Abnormality_Callback(hObject, eventdata, handles);

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
handles.recty=str2double(get(hObject,'String'));
guidata(hObject,handles);
Abnormality_Callback(hObject, eventdata, handles);
 
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Changing the dimensiopn of the rectangle
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function slider3_Callback(hObject, eventdata, handles)
handles.XRL=get(hObject,'Value');
guidata(hObject,handles);
Abnormality_Callback(hObject, eventdata, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Changing the dimensiopn of the rectangle Y axes
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
Abnormality_Callback(hObject, eventdata, handles);


function slider4_Callback(hObject, eventdata, handles)
handles.YRL=get(hObject,'Value');
guidata(hObject,handles);
Abnormality_Callback(hObject, eventdata, handles);


function slider4_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on key press with focus on Abnormality and none of its controls.
function Abnormality_KeyPressFcn(hObject, eventdata, handles)
