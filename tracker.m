%%% tracker
%%% version 1.0
%%% 2014-04-27

function varargout = tracker(varargin)
% TRACKER MATLAB code for tracker.fig
%      TRACKER, by itself, creates a new TRACKER or raises the existing
%      singleton*.
%
%      H = TRACKER returns the handle to a new TRACKER or the handle to
%      the existing singleton*.
%
%      TRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKER.M with the given input arguments.
%
%      TRACKER('Property','Value',...) creates a new TRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tracker

% Last Modified by GUIDE v2.5 27-Apr-2014 19:18:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tracker_OpeningFcn, ...
                   'gui_OutputFcn',  @tracker_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


%%% Executes just before tracker is made visible.
function tracker_OpeningFcn(hObject, eventdata, handles, varargin)

handles.faceDetector = vision.CascadeObjectDetector();
handles.cam = videoinput('macvideo');
set(handles.cam, 'ReturnedColorSpace', 'RGB');

% Create an image object for previewing.
vidRes = get(handles.cam, 'VideoResolution');
nBands = get(handles.cam, 'NumberOfBands');
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );

uicontrol('String', 'Close', 'Callback', 'close(gcf)');

preview(handles.cam, hImage);

handles.runFlag = false;

% Choose default command line output for tracker
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = tracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%% detectButton.
function detectButton_Callback(hObject, eventdata, handles)

frame = getsnapshot(handles.cam);
bbox = step(handles.faceDetector, frame);
markedFrame = insertShape(frame, 'Rectangle', bbox);

disp('detectButton');
handles.frame = getsnapshot(handles.cam);
disp('Detecting face...');
handles.bbox = step(handles.faceDetector, handles.frame);
disp(handles.bbox);
disp('Insert shape...');
markedFrame = insertShape(handles.frame, 'FilledRectangle', ...
                          handles.bbox, 'Color', 'green', ...
                          'Opacity', 0.2);
disp('Close preview...');
tic;    

closepreview;
imshow(markedFrame);

if toc > 3
    preview(handles.cam);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in trackButton.
function trackButton_Callback(hObject, eventdata, handles)

handles.runFlag = true;


startTracking(handles.runFlag, handles.frame, handles.bbox, ...
              handles.cam, handles.faceDetector);

startTracking(handles.runFlag, handles.frame, handles.bbox, ...
              handles.cam, handles.faceDetector)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)

handles.runFlag = false;
startTracking(handles.runFlag);

% Update handles structure
guidata(hObject, handles);
