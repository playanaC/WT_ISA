function varargout = Gui_viewer(varargin)
% GUI_VIEWER MATLAB code for Gui_viewer.fig
%      GUI_VIEWER, by itself, creates a new GUI_VIEWER or raises the existing
%      singleton*.
%
%      H = GUI_VIEWER returns the handle to a new GUI_VIEWER or the handle to
%      the existing singleton*.
%
%      GUI_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_VIEWER.M with the given input arguments.
%
%      GUI_VIEWER('Property','Value',...) creates a new GUI_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gui_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gui_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gui_viewer

% Last Modified by GUIDE v2.5 28-Jul-2020 11:54:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gui_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @Gui_viewer_OutputFcn, ...
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


% --- Executes just before Gui_viewer is made visible.
function Gui_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gui_viewer (see VARARGIN)

% Choose default command line output for Gui_viewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

d = pwd; % pwd returns the path to the current folder.
path = sprintf('%s%s',d,'\'); %name current folder concatenate with "\"
set(handles.lbl_path, 'String', path); % set name in label GUI

% UIWAIT makes Gui_viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Gui_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_path.
function btn_path_Callback(hObject, eventdata, handles)
% hObject    handle to btn_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = uigetdir(pwd); % pwd returns the path to the current folder.
path = sprintf('%s%s',d,'\'); %name current folder concatenate with "\"
set(handles.lbl_path, 'String', path); % set name in label GUI

[name,tt] = get_files(path,30); %array of images's name

gi={}; %cell array to save all images names
for i=1:tt
    gi{i,1} = name(i,:);
end
set(handles.lst_image,'String',cellstr(gi)); %set array cell in list GUI

min_F = 10; %min color
max_F = 245; %max color
colorF = {}; %cell array to save all colors
files = dir(fullfile(path, '*.xml')); %save all xml files

pre = '<HTML><FONT color="';
post = '</FONT></HTML>';

cnt=1;
for i=1:size(files,1)
    xml_name = files(i).name; %name xml
    str1 = str2num(xml_name(1,1)); %convert to number first char
    str2 = xml_name(1,2); %extract second char
    if(~isempty(str1)&&(strcmp(str2,'_'))) %if first char a number and second is '_' ,then save in xmli cell array        
        R = randi([min_F, max_F], 1, 1);
        G = randi([min_F, max_F], 1, 1);
        B = randi([min_F, max_F], 1, 1);
        
        Data(i).name = sprintf('%d%s%s',cnt,')',xml_name);
        Data(i).Color = [R G B];
        
        colorF{i,1} = [pre rgb2Hex( Data(i).Color ) '">' Data(i).name post];
        cnt=cnt+1;
    end
end
set(handles.lst_xml,'String',cellstr(colorF)); %set array cell in list GUI

function hexStr = rgb2Hex( rgbColour )
hexStr = reshape( dec2hex( rgbColour, 2 )',1, 6);%convert rgb to hex

% --- Executes on selection change in lst_image.
function lst_image_Callback(hObject, eventdata, handles)
% hObject    handle to lst_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_image contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_image

path = get(handles.lbl_path,'String'); %get path
contents = cellstr(get(hObject,'String')); %get list image
img_n = get(hObject,'Value');
img_name = contents{img_n}; %get image name
path_xml = sprintf('%s%s',path,img_name); %full path of image name

xml_files = handles.lst_xml.String; %worm's xmls

img = read_image(path_xml);
axes(handles.axes1);
imshow(img);hold on; %show grey image

if(handles.rdb_w1.Value==1) %individual worm
    worm_data = xml_files{handles.lst_xml.Value};
    str1 = ')';
    str2 = '</';
    worm_xml = extractBetween(worm_data,str1,str2);
    path_worm = sprintf('%s%s',path,worm_xml{1,1}); %full path xml name
    
    str3 = '="';
    str4 = '">';
    hexcolor = extractBetween(worm_data,str3,str4);
    worm_color = hex2rgb(hexcolor{1,1}); %worm color
    
    str5 = '">';
    str6 = ')';
    worm_n = extractBetween(worm_data,str5,str6); %worm number 

    ref = xmlDOMF(xmlread(path_worm)); %read xml
    XY = ref{img_n,1}; %x,y values
    nxy = round(size(XY,1)/2); %worm center
    pxy = XY(nxy,:);%X,y worm center

    % Graph 1: Plate with worm
    plot(XY(:,1),XY(:,2),'.','color',worm_color);
    plot(XY(:,1),XY(:,2),'color',worm_color);
    text(pxy(1,1) + 2, pxy(1,2) + 2, worm_n{1,1}, 'FontSize', 8, 'FontWeight', 'Bold','Color','red');
    hold off;
    
    % Graph 2: Individual worm
    [XY_min,XY_max] = check_size(ref);
    tbbox = [XY_min XY_max-XY_min]+[-6 -6 6 6];
    
    crop = imcrop(img,tbbox); %crop image
    axes(handles.axes2);
    imshow(crop); hold on;
    
    XY1 = XY - tbbox(1,1:2) + [1,1];
    pxy1 = XY1(nxy,:);
    
    plot(XY1(:,1),XY1(:,2),'.','color',worm_color);
    plot(XY1(:,1),XY1(:,2),'color',worm_color);
    text(pxy1(1,1) + 2, pxy1(1,2) + 2, worm_n{1,1}, 'FontSize', 12, 'FontWeight', 'Bold','Color','red');
    hold off;
    
else %all worms
    for i=1:size(xml_files,1)
        worm_data = xml_files{i,1};
        str1 = ')';
        str2 = '</';
        worm_xml = extractBetween(worm_data,str1,str2);
        path_worm = sprintf('%s%s',path,worm_xml{1,1}); %full path xml name
        
        str3 = '="';
        str4 = '">';
        hexcolor = extractBetween(worm_data,str3,str4);
        worm_color = hex2rgb(hexcolor{1,1});%worm color
        
        str5 = '">';
        str6 = ')';
        worm_n = extractBetween(worm_data,str5,str6);%worm number 

        ref = xmlDOMF(xmlread(path_worm));%read xml
        XY = ref{img_n,1};%x,y values
        nxy = round(size(XY,1)/2);%worm center
        pxy = XY(nxy,:);%X,y worm center
        
        % Graph 1: Plate with worms
        plot(XY(:,1),XY(:,2),'.','color',worm_color);
        plot(XY(:,1),XY(:,2),'color',worm_color);
        text(pxy(1,1) + 2, pxy(1,2) + 2, worm_n{1,1}, 'FontSize', 8, 'FontWeight', 'Bold','Color','red');
    end
    hold off;
end


% --- Executes during object creation, after setting all properties.
function lst_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_xml.
function lst_xml_Callback(hObject, eventdata, handles)
% hObject    handle to lst_xml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_xml contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_xml


% --- Executes during object creation, after setting all properties.
function lst_xml_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_xml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
type = get(hObject,'String');
