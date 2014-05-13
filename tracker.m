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

% Last Modified by GUIDE v2.5 13-May-2014 10:02:19

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

% --- Executes just before tracker is made visible.
function tracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for tracker
handles.output = hObject;

set(handles.markObject,'Value',1,'Enable','Off');
set(handles.learnObject,'Value',1,'Enable','Off');
set(handles.saveObject,'Value',1,'Enable','Off');
% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.

handles.video = videoinput('macvideo', 1);

set(handles.video,'TimerPeriod', 0.05, ...
'TimerFcn',['if(~isempty(gco)),'...
'handles=guidata(gcf);'... % Update handles
'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
'set(handles.axes2,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
'else '...
'delete(imaqfind);'... % Clean up - delete any image acquisition objects
'end']);

triggerconfig(handles.video,'manual');

set(handles.video, 'ReturnedColorSpace', 'rgb');

handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tracker wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = tracker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;

% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject    handle to startStopCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    start(handles.video);
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
    stop(handles.video);
end

% --- Executes on button press in existingObject.
function existingObject_Callback(hObject, eventdata, handles)
% hObject    handle to existingObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
handles.object = browseObject();
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in browseImage.
function browseImage_Callback(hObject, eventdata, handles)
% hObject    handle to browseImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.image = browseImage();
axes(handles.axes1);
imshow(handles.image);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in getSnapshot.
function getSnapshot_Callback(hObject, eventdata, handles)
% hObject    handle to getSnapshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame = getsnapshot(handles.video);
handles.image = frame;

stop(handles.video);
imshow(frame, 'Parent', handles.axes1);
start(handles.video);

set(handles.markObject,'Value',1,'Enable','On');

guidata(hObject, handles);

% --- Executes on button press in markObject.
function markObject_Callback(hObject, eventdata, handles)
% hObject    handle to markObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.startStopCamera,'String','Start Camera');
stop(handles.video);
axes(handles.axes1);

handles.objectRegion = highlightObject(handles.image, handles);

set(handles.learnObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in learnObject.
function learnObject_Callback(hObject, eventdata, handles)
% hObject    handle to learnObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.objImg, handles.objPts, handles.objFeat] = ...
    learnObject(handles.image, handles.objectRegion);

set(handles.saveObject,'Value',1,'Enable','On');
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in saveObject.
function saveObject_Callback(hObject, eventdata, handles)
% hObject    handle to saveObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveObject(handles.objImg, handles.objPts, handles.objFeat);
set(handles.markObject,'Value',1,'Enable','Off');
set(handles.learnObject,'Value',1,'Enable','Off');
set(handles.saveObject,'Value',1,'Enable','Off');
guidata(hObject, handles);

% --- Executes on button press in browseTargetImage.
function browseTargetImage_Callback(hObject, eventdata, handles)
% hObject    handle to browseTargetImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.targetImage = browseImage();
axes(handles.axes2);
imshow(handles.targetImage);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in targetSnapshot.
function targetSnapshot_Callback(hObject, eventdata, handles)
% hObject    handle to targetSnapshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in trackTarget.
function trackTarget_Callback(hObject, eventdata, handles)
% hObject    handle to trackTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%
if get(hObject,'Value')
    disp('Start handles.video.');
    start(handles.video);

    %%% FROM ObjectFInder_1
    % Get camImg
    camImg = getsnapshot(handles.video);
    camImg = rgb2gray(camImg);
    %camImg = im2bw(camImg);
    %camImg = histeq(camImg);

    camPts  = detectSURFFeatures(camImg);
    %camPts = camPts.selectStrongest(200);

    camFeat = extractFeatures(camImg, camPts);

    idxPairs = matchFeatures(camFeat, handles.objFeat);

    matchedCamPts = camPts(idxPairs(:, 1));
    %matchedRefPts = refPts(idxPairs(:, 2));
    
    if ~isempty(matchedCamPts)
        disp('Found matched points.');
        % Create a point tracker 
        pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

        % Initialize the tracker with the initial point locations and video frame.
        points = matchedCamPts.Location;
        initialize(pointTracker, points, camImg);
        oldPts = points;
        flag = true;
    else
        disp('No matching points!');
        stop(handles.video);
        flag = false;
    end
    
    %%% FROM ex.m (taken example of pointTracker in VideoPlayer)
    

    % Make a copy of the points to be used for computing the geometric
    % transformation between the points in the previous and the current frames
else
    disp('Stop video object!');
    stop(handles.video)
end


%index = 0;
while get(hObject,'Value') && flag
    %disp('Starting loop...');
    
    %frame = getsnapshot(handles.video);
    frame = getdata(handles.video, 1, 'uint8');
    frame = rgb2gray(frame);
    %frame = histeq(frame);
    
    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, frame);
    visiblePts = points(isFound, :);
    oldInliers = oldPts(isFound, :);
    
    if size(visiblePts, 1) >= 1 % need at least 2 points
        disp('Two points!');
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
            oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);
        
        %{
        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));
            
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
         %}
            
        % Display tracked points
        frame = insertMarker(frame, visiblePts, 'X', ...
            'Color', 'red');

        % Reset the points
        oldPts = visiblePts;
        setPoints(pointTracker, oldPts);
    end

    % Display the annotated video frame using the video player object
    imshow(frame, 'Parent', handles.axes2);
    flushdata(handles.video, 'triggers');
    %index = index + 1;
end
%%%%%%%%

% Hint: get(hObject,'Value') returns toggle state of togglebutton

% Update handles structure
guidata(hObject, handles);

% --- Executes when user attempts to close myCameraGUI.
function tracker_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to myCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);
