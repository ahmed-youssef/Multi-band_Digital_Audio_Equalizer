function varargout = simple_gui(varargin)
% SIMPLE_GUI M-file for simple_gui.fig
%      SIMPLE_GUI, by itself, creates a new SIMPLE_GUI or raises the existing
%      singleton*.
%
%      H = SIMPLE_GUI returns the handle to a new SIMPLE_GUI or the handle to
%      the existing singleton*.
%
%      SIMPLE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMPLE_GUI.M with the given input arguments.
%
%      SIMPLE_GUI('Property','Value',...) creates a new SIMPLE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simple_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simple_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simple_gui

% Last Modified by GUIDE v2.5 10-Dec-2013 21:06:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simple_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @simple_gui_OutputFcn, ...
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


% --- Executes just before simple_gui is made visible.
function simple_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simple_gui (see VARARGIN)

% Choose default command line output for simple_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simple_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simple_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in AnalysisWindow.
function AnalysisWindow_Callback(hObject, eventdata, handles)
% hObject    handle to AnalysisWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns AnalysisWindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AnalysisWindow
val = get(hObject,'Value');
str = get(hObject,'String');

switch str{val}
    case 'Rectangular'
        handles.window = ones(1, handles.N);
    case 'Hamming'
        handles.window = window(@hamming, handles.N);
    case 'Hanning'
        handles.window = window(@hann, handles.N);
    case 'Blackman'
        handles.window = window(@hann, handles.N);
    case 'Gaussian'
        handles.window = window(@hann, handles.N);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AnalysisWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnalysisWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.window = ones(1, 256);
guidata(hObject, handles);


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,Fs]=wavread([handles.filename]);
x = x(:, 1);
N_FFT = handles.N_FFT;
N = handles.N;

if(handles.IsSpecMod == 1)
    devs = [0.001 0.001];
    switch handles.FilterType
        case 'Low Pass'
            wpass = handles.W_Pass_Low;
            wstop = handles.W_Stop_Low;
            fcuts = [wpass wstop];
            mags = [1 0];
            [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
            hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        case 'High Pass'
            wpass = handles.W_Pass_High;
            wstop = handles.W_Stop_High;
            fcuts = [wstop wpass];
            mags = [0 1];
            [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
            hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        case 'Band Pass'
            wstop1 = handles.W_Stop_High;
            wpass1 = handles.W_Pass_High;
            wpass2 = handles.W_Pass_Low;
            wstop2 = handles.W_Stop_Low;
            fcuts = [wstop1 wpass1 wpass2 wstop2];
            mags = [0 1 0];
            devs = [0.001 0.05 0.001];
            [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
            hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
    end
    hh = hh';
    if N_FFT < (N + length(hh) + 1)
        N_FFT = N + length(hh) + 10;
        warning('FFT Length must be greater than or equal to window length + filter length to avoid aliasing. FFT length adjusted accordingly');
    end
    
    d = stft(x, N_FFT, hann(N));
    H = fft(hh, N_FFT);
    d_y = zeros(size(d));
    for i = 1:size(d, 2)
        d_y(:, i) = H.*d(:, i);
    end
    
    y_hat = istft(d_y, N_FFT, hann(N));
    y_hat = y_hat/2;
    figure(1);
    freqz(hh);
    Title('Frequency Response of the Specified Filter');
    figure(2);
    freqz(x);
    Title('Frequency Response of the Original Signal');
    figure(3);
    freqz(y_hat);
    Title('Frequency Response of the Output Signal');
    sound(y_hat, Fs);
else
    if N_FFT < N
        N_FFT = N + 10;
        warning('FFT Length must be greater than or equal to window length to avoid aliasing. FFT length adjusted accordingly');
    end
    d = stftmod(x, N_FFT, handles.window);
    x_hat=istftmod(d, handles.N, handles.window);
    x_hat = x_hat/2;
    figure(1);
    freqz(x);
    Title('Frequency Response of the Original Signal');
    figure(2);
    freqz(x_hat);
    Title('Frequency Response of the Output Signal');
    sound(x_hat, Fs);
end


function WindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to WindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WindowSize as text
%        str2double(get(hObject,'String')) returns contents of WindowSize as a double
handles.N = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function WindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.N = 256;
guidata(hObject, handles);


function FileName_Callback(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileName as text
%        str2double(get(hObject,'String')) returns contents of FileName as a double
handles.filename = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function W_Pass_Low_Callback(hObject, eventdata, handles)
% hObject    handle to W_Pass_Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of W_Pass_Low as text
%        str2double(get(hObject,'String')) returns contents of W_Pass_Low as a double
handles.W_Pass_Low = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function W_Pass_Low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to W_Pass_Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FilterType.
function FilterType_Callback(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FilterType
val = get(hObject,'Value');
str = get(hObject,'String');
handles.FilterType = str{val};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SpecMod.
function SpecMod_Callback(hObject, eventdata, handles)
% hObject    handle to SpecMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SpecMod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpecMod
val = get(hObject,'Value');
str = get(hObject,'String');

switch str{val}
    case 'OFF'
        handles.IsSpecMod = 0;
    case 'ON'
        handles.IsSpecMod = 1;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SpecMod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpecMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.IsSpecMod = 0;
guidata(hObject, handles);


function W_Pass_High_Callback(hObject, eventdata, handles)
% hObject    handle to W_Pass_High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of W_Pass_High as text
%        str2double(get(hObject,'String')) returns contents of W_Pass_High as a double
handles.W_Pass_High = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function W_Pass_High_CreateFcn(hObject, eventdata, handles)
% hObject    handle to W_Pass_High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function W_Stop_High_Callback(hObject, eventdata, handles)
% hObject    handle to W_Stop_High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of W_Stop_High as text
%        str2double(get(hObject,'String')) returns contents of W_Stop_High as a double
handles.W_Stop_High = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function W_Stop_High_CreateFcn(hObject, eventdata, handles)
% hObject    handle to W_Stop_High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function W_Stop_Low_Callback(hObject, eventdata, handles)
% hObject    handle to W_Stop_Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of W_Stop_Low as text
%        str2double(get(hObject,'String')) returns contents of W_Stop_Low as a double
handles.W_Stop_Low = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function W_Stop_Low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to W_Stop_Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FFT_Length_Callback(hObject, eventdata, handles)
% hObject    handle to FFT_Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FFT_Length as text
%        str2double(get(hObject,'String')) returns contents of FFT_Length as a double
handles.N_FFT = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FFT_Length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FFT_Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
