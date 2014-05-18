%%% tracker.m
%%% 2014-05-16
%%% GUI that finds or tracks an object in an image or video feed. 
%%% The object can be browsed from a .mat-file, or saved from an snapshot.
%%% By: Sebastian Lahti and Martin H�rnwall

function varargout = tracker(varargin)
%TRACKER M-file for tracker.fig
%      TRACKER, by itself, creates a new TRACKER or raises the existing
%      singleton*.
%
%      H = TRACKER returns the handle to a new TRACKER or the handle to
%      the existing singleton*.
%
%      TRACKER('Property','Value',...) creates a new TRACKER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to tracker_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TRACKER('CALLBACK') and TRACKER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TRACKER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tracker

% Last Modified by GUIDE v2.5 14-May-2014 11:29:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tracker_OpeningFcn, ...
                   'gui_OutputFcn',  @tracker_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%% SETUP
function tracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for tracker
handles.output = hObject;

set(handles.markObject, 'Value',1,'Enable','Off');
set(handles.learnObject,'Value',1,'Enable','Off');
set(handles.saveObject, 'Value',1,'Enable','Off');
set(handles.trackTarget,'Value',1,'Enable','Off');
set(handles.findObject,'Value',1,'Enable','Off');
%set(handles.getSnapshot,'Value',1,'Enable','Off');
set(handles.findObject, 'Value',1,'Enable','Off');

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.

handles.video = videoinput('macvideo', 1);

set(handles.video,'TimerPeriod', 0.05, 'TimerFcn', ...
   ['if(~isempty(gco)),'...
        'handles = guidata(gcf);'... % Update handles
        'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
        'set(handles.axes2,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
    'else '...
        'delete(imaqfind);'... % Clean up - delete any image acquisition objects
    'end']);

triggerconfig(handles.video,'Manual');

set(handles.video, 'ReturnedColorSpace', 'rgb');
set(handles.video, 'TriggerRepeat', inf);

handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it
%handles.video.TriggerRepeat = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tracker wait for user response (see UIRESUME)
uiwait(handles.figure1);

%%% Outputs from this function are returned to the command line.
function varargout = tracker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;

%%% START/STOP CAMERA BUTTON
function startStopCamera_Callback(hObject, eventdata, handles)

% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    disp('Starting camera...');
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera');
    start(handles.video);
    %set(handles.getSnapshot,'Value',1,'Enable','On');
    set(handles.findObject,'Value',1,'Enable','Off');
else
    disp('Stopping camera...');
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera');
    stop(handles.video);
    %set(handles.getSnapshot,'Value',1,'Enable','On'); TURN SNAPSHOT OFF!
end

% Update handles structure
guidata(hObject, handles);

%%% BROWSE EXISTING OBJECT BUTTON
function existingObject_Callback(hObject, eventdata, handles)
disp('BROWSE EXISTING OBJECT BUTTON');

% Get an object with image, pts, features and valid points
object = browseObject();

% Annotates the pts in the image and shows it in axes1
objImg = insertMarker(object.img, object.pts, 'X', 'Color', 'yellow');
imshow(objImg, 'Parent', handles.axes1);

% Saves the features from the object as an/with a handle
handles.objFeat = object.feat;
handles.validPts = object.valPts;

% Enable track- and find-buttons
set(handles.trackTarget,'Value',1,'Enable','On');
set(handles.findObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% BROWSE IMAGE BUTTON
function browseImage_Callback(hObject, eventdata, handles)
disp('BROWSE IMAGE BUTTON');

% Brows an image and show it in axes1
handles.rawObjImg = browseImage();
imshow(handles.rawObjImg, 'Parent', handles.axes1);

% Enable markObject-button
set(handles.markObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% GET SNAPSHOT BUTTON
function getSnapshot_Callback(hObject, eventdata, handles)
disp('GET SNAPSHOT BUTTON');

% Start video if not running
if ~isrunning(handles.video)
    start(handles.video);
    set(handles.startStopCamera,'String','Stop Camera');
end

% Get and show snapshot
handles.rawObjImg = getsnapshot(handles.video);
imshow(handles.rawObjImg, 'Parent', handles.axes1);

% Enable markObject-button
set(handles.markObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% MARK OBJECT BUTTON
function markObject_Callback(hObject, eventdata, handles)

% Need to stop camera in order to use imrect?
stop(handles.video);
%set(handles.startStopCamera,'String','Start Camera');
%set(handles.startStopCamera,'Value',1,'Enable','Off');

% Click&Drag-rectangle in image. Returns region.
axes(handles.axes1);
%imshow(handles.rawObjImg, 'Parent', handles.axes1);
handles.objReg = round(getPosition(imrect));

% Shows the marked region
higImg = insertShape(handles.rawObjImg, 'FilledRectangle', ...
                     handles.objReg, 'Color', 'cyan', 'Opacity', 0.2);
imshow(higImg, 'Parent', handles.axes1);

% Enable learnObject-button
set(handles.learnObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% LEARN OBJECT BUTTON
function learnObject_Callback(hObject, eventdata, handles)
disp('LEARN OBJECT BUTTON');

% The learnObject-func. returns obj.- image, pts, feat and valid pts.
[handles.objImg, handles.objPts, handles.objFeat, handles.validPts] = ...
    learnObject(handles.rawObjImg, handles.objReg, handles);

% Enables save-, find- and track-buttons
set(handles.saveObject, 'Value', 1, 'Enable', 'On');
set(handles.findObject, 'Value', 1, 'Enable', 'On');
set(handles.trackTarget, 'Value', 1, 'Enable', 'On');

% Update handles structure
guidata(hObject, handles);

%%% SAVE OBJECT BUTTON
function saveObject_Callback(hObject, eventdata, handles)
disp('SAVE OBJECT BUTTON');

% Saves an .MAT-file with obj. image, feature pts, features and valid pts
saveObject(handles.objImg, handles.objPts, ...
           handles.objFeat, handles.validPts);

% Disable mark-, learn- and save object-buttons
set(handles.markObject,'Value',1,'Enable','Off');
set(handles.learnObject,'Value',1,'Enable','Off');
set(handles.saveObject,'Value',1,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

%%% BROWSE TARGET IMAGE BUTTON
function browseTargetImage_Callback(hObject, eventdata, handles)

% Stop camera
stop(handles.video);
set(handles.startStopCamera,'String','Start Camera');

% browseImage-func starts a prompt and returns an image object.
handles.targetImage = browseImage();
imshow(handles.targetImage, 'Parent', handles.axes2);

% Enable findObject-button
set(handles.findObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% TARGET SNAPSHOT BUTTON
function targetSnapshot_Callback(hObject, eventdata, handles)
disp('TARGET SNAPSHOT BUTTON');

% Starts the camera if it is not running
if ~isrunning(handles.video)
    start(handles.video);
    set(handles.startStopCamera,'String','Stop Camera');
end

% Get a targetImage from the target window, stop cam and disp. it.  
axes(handles.axes2);
handles.targetImage = getsnapshot(handles.video);
stop(handles.video);
imshow(handles.targetImage, 'Parent', handles.axes2);

% Update start/stop-button and enable findObject-button
set(handles.startStopCamera,'String','Start Camera');
set(handles.findObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% FIND OBJECT BUTTON
function findObject_Callback(hObject, eventdata, handles)
disp('FIND OBJECT BUTTON');

% Wierd bugg. Stopping camera helps...
stop(handles.video);
set(handles.startStopCamera,'String','Start Camera');

% findObject-func shows the matching pts
findObject(handles.targetImage, handles.objFeat, handles);

% Update GUI-handles
guidata(hObject, handles);

%%% TRACK TARGET TOGGLE-BUTTON
function trackTarget_Callback(hObject, eventdata, handles)
disp('TRACK TARGET TOGGLE-BUTTON');

% When toggle high: initialize
if ~get(hObject,'Value')
    
    frame = getsnapshot(handles.video);
    
    [tracker, flag] = initializeTracker(frame, handles.objFeat, handles);
    
    axes(handles.axes2);
    start(handles.video);
    disp('Initialized.');
    
    trackingLoop(tracker, flag, handles);
    
elseif get(hObject,'Value')
    stop(handles.video);
    
    if exist('pointTracker')
        release(tracker);
        delete(tracker);
    end

    clear points isFound visablePts; 
    disp('Cleand.');
end

% Update handles structure
guidata(hObject, handles);

%%% Executes when user attempts to close tracker.
function tracker_CloseRequestFcn(hObject, eventdata, handles)
disp('Close program.');
if isrunning(handles.video)
    stop(handles.video);
end
delete(handles.video);
% Hint: delete(hObject) closes the figure
delete(hObject);
%delete(imaqfind);