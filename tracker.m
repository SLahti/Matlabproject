%%% tracker.m
%%% 2014-05-13
%%% GUI that finds or tracks an object in an image or video feed. 
%%% The object can be browsed from a .mat-file, or saved from an snapshot.
%%% By: Sebastian Lahti and Martin Härnwall

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

%%% Executes just before tracker is made visible.
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

set(handles.video,'TimerPeriod', 0.05, 'TimerFcn', ...
   ['if(~isempty(gco)),'...
        'handles = guidata(gcf);'... % Update handles
        'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
        'set(handles.axes2,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
    'else '...
        'delete(imaqfind);'... % Clean up - delete any image acquisition objects
    'end']);

triggerconfig(handles.video,'manual');

set(handles.video, 'ReturnedColorSpace', 'rgb');

handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it
handles.video.TriggerRepeat = 1;

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
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    start(handles.video);
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
    stop(handles.video);
end

% Update handles structure
guidata(hObject, handles);

%%% BROWSE EXISTING OBJECT BUTTON
function existingObject_Callback(hObject, eventdata, handles)

axes(handles.axes1);
handles.object = browseObject();

% Update handles structure
guidata(hObject, handles);

%%% BROWSE IMAGE BUTTON
function browseImage_Callback(hObject, eventdata, handles)

handles.image = browseImage();
axes(handles.axes1);
imshow(handles.image);

% Update handles structure
guidata(hObject, handles);

%%% GET SNAPSHOT BUTTON
function getSnapshot_Callback(hObject, eventdata, handles)

frame = getsnapshot(handles.video);
%frame = getdata(handles.video, 1, 'uint8');
handles.image = frame;

stop(handles.video);
imshow(frame, 'Parent', handles.axes1);
start(handles.video);

set(handles.markObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% MARK OBJECT BUTTON
function markObject_Callback(hObject, eventdata, handles)

set(handles.startStopCamera,'String','Start Camera');
stop(handles.video);
axes(handles.axes1);

handles.objectRegion = highlightObject(handles.image, handles);

set(handles.learnObject,'Value',1,'Enable','On');

% Update handles structure
guidata(hObject, handles);

%%% LEARN OBJECT BUTTON
function learnObject_Callback(hObject, eventdata, handles)

[handles.objImg, handles.objPts, handles.objFeat] = ...
    learnObject(handles.image, handles.objectRegion);

set(handles.saveObject, 'Value', 1, 'Enable', 'On');

% Update handles structure
guidata(hObject, handles);

%%% SAVE OBJECT BUTTON
function saveObject_Callback(hObject, eventdata, handles)

saveObject(handles.objImg, handles.objPts, handles.objFeat);
set(handles.markObject,'Value',1,'Enable','Off');
set(handles.learnObject,'Value',1,'Enable','Off');
set(handles.saveObject,'Value',1,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

%%% BROWSE TARGET IMAGE BUTTON
function browseTargetImage_Callback(hObject, eventdata, handles)

handles.targetImage = browseImage();
axes(handles.axes2);
imshow(handles.targetImage);

% Update handles structure
guidata(hObject, handles);

%%% TARGET SNAPSHOT BUTTON
function targetSnapshot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);

%%% TRACK TARGET TOGGLE-BUTTON
function trackTarget_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton

% When toggle button is set to 'high'
if get(hObject,'Value')
    disp('Start handles.video.');
    % Starts the video object
    start(handles.video);
    disp('handles.video started.');
    
    %wait(handles.video);
    
    % Get (and edit) the cam image
    disp('Get cam image...');
    %camImg = getdata(handles.video, 1, 'uint8');
    camImg = getsnapshot(handles.video);
    disp('camImg acquired!');
    
    camImg = rgb2gray(camImg);
    %camImg = im2bw(camImg);
    %camImg = histeq(camImg);

    % Detects the SURF-features in the cam image
    camPts  = detectSURFFeatures(camImg);
    camPts = camPts.selectStrongest(100);

    % Extracts the features around the pts in the image
    camFeat = extractFeatures(camImg, camPts);

    % Get the points with matching features in cam image and the object
    idxPairs = matchFeatures(camFeat, handles.objFeat);

    % Get the matching points in the cam- and ref image respectivly
    matchedCamPts = camPts(idxPairs(:, 1));
    %matchedRefPts = refPts(idxPairs(:, 2));
    
    % If there are matching pts is the tracker created and initialized
    if ~isempty(matchedCamPts)
        disp('Found matching points.');
        % Create a point tracker 
        pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
        % Init. the tracker with the init. pts locations and video frame.
        points = matchedCamPts.Location;
        initialize(pointTracker, points, camImg);
        % Make a copy of the pts to be used for computing the geometric
        % trans between the pts in the prev and the current frames
        oldPts = points;
        flag = true;
        disp('Tracker created and initialized.');
    % If there are no matching pts, the camera object is stoped
    else
        disp('No matching points!');
        stop(handles.video);
        flag = false;
    end
    
% When toggle button is set to 'low', the object is stoped
else
    disp('Stop video object!');
    % Stops the video-object
    stop(handles.video);
end

% If there are matching pts (flag high) the tracking-loop is started
disp('@loop');
while get(hObject,'Value') && flag
    %disp('while...');
    %wait(handles.video);
    
    % Get a new frame. 'getdata()' is suposed to be faster. Object must be
    % started and 'TriggerRepeat = Inf;'. 
    frame = getsnapshot(handles.video);
    %frame = getdata(handles.video, 1, 'uint8');
    %disp('Frame acquired!');
    frameBW = rgb2gray(frame);
    % Increses the contrast in the image
    %frame = histeq(frame);
    
    % Track the points with the tracker on each frame. 
    % "Note that some points may be lost." 
    [points, isFound] = step(pointTracker, frameBW);
    % Gets the found points
    visiblePts = points(isFound, :);
    % Saves the old pts which still are found
    oldInliers = oldPts(isFound, :);
    
    % Only if there are more than two visable pts
    % 
    if size(visiblePts, 1) >= 2
        % Estimate the geometric trans between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
            oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);
        
        % If annotating bbox is to be a polynom, so that it can rotate
        %{
        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));
            
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
         %}
        
        % Annotated the visable pts in the frame
        frame = insertMarker(frame, visiblePts, 'X', 'Color', 'red');
        
        % Reset the points (and the pointTracker)
        oldPts = visiblePts;
        setPoints(pointTracker, oldPts);
    else
        % If 'all' pts are lost: end loop
       %disp('Less than two points!'); 
       %flag = false;
    end

    % Display the annotated video frame using the video player object
    imshow(frame, 'Parent', handles.axes2);
    
    flushdata(handles.video);%, 'triggers');
    
    guidata(hObject, handles);
end

% Update handles structure
guidata(hObject, handles);

%%% Executes when user attempts to close myCameraGUI.
function tracker_CloseRequestFcn(hObject, eventdata, handles)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);
