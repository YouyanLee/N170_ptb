%% GitHub Project 2021.06.17

function N170_exp
%% N170 experiment Template
% Warning: For demonstration only, be careful for your experiment
% Scripts by Yuri.L, 2020.03.13, Psytech,Inc.
% All rights reserved. 

% Clear Matlab/Octave window:
close all
clc;
warning('off');

%% ----------------------- Subject Info ---------------------- %%
prompt = {'SubID','Name','Gender[Female=1,Male=2]','Age'};  %定义需要填写的项目
dlg_title = 'Subject Info'; %定义对话框名称
num_lines = 1; %定义显示的行数
defaultanswer = {'','','',''}; %定义默认值
subinfo = inputdlg(prompt,dlg_title,num_lines,defaultanswer,'on');%创建输入用户信息的对话框，prompt为提示字符串，dlg_title为对话框名称，num_lines为显示的行数，defaultanswer为默认值

if exist('results/subInfo.mat','file')==0
    subTable = table;
    nsub = 0;
else
    load('results/subInfo.mat')
    nsub = size(subTable,1);
end

subTable.subID(nsub+1) = str2double([subinfo{1}]); %提取用户信息的第1行，转换为数值变量后赋值给subID，记录被试序号
subTable.Name(nsub+1)= subinfo(2); %提取用户信息的第2行，记录被试姓名
subTable.Gender(nsub+1) = str2double([subinfo{3}]); %提取用户信息的第3行，记录被试性别
subTable.Age(nsub+1) = str2double([subinfo{4}]); %提取用户信息的第4行，记录被试年龄

%% ----------------------- Enviroment setting ---------------------- %%
%避免由于硬件（显卡）问题报错，调试阶段使用，对时间精度要求不严格
%此时，Flip 指令返回 StimulusOnsetTime = VBLTimestamp;
Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB with some default values
% 控制PTB执行过程中的输出信息，调试时可选择较高level，正式实验时0禁用所有输出信息
Screen('Preference', 'Verbosity', 0);
% call default settings for setting up PTB
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% seeds the random number generator
rng('shuffle')

%% ----------------------- Experiment Setting ---------------------- %%
% trials数设置
prac_TTN = 8; % total trial number for practice
TTN = 160; % total trial number

% mark设置
trigger_start=241; % exp start trigger
trigger_end=242; % exp end trigger

trigger_right = 7; % right response trigger
trigger_wrong = 8; % wrong response trigger

% 按键设置
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
fKey = KbName('f');
jKey = KbName('j');
RestrictKeysForKbCheck([spaceKey escapeKey fKey jKey]);%限制按键

% 结果文件
folder = fileparts(mfilename('fullpath'));
resultsDir = [cd '/results'];
if exist(resultsDir,'dir')<1
    mkdir(resultsDir);
end  

c=clock;
d=date;

outfile=fullfile(folder,'results',sprintf('N170_sub%02d_%s_%02.0f-%02.0f',str2double([subinfo{1}]),d(1:6),c(4),c(5)));
%% ----------------------- Generate list ---------------------- %%
% generate sequence MList:160*8
Mtrial=1; % trial number
MID=2;  % material id
Mcat=3; % material category: 1=face_up,2=desk_up,3=face_down,4=desk_down
MAonset=4; % actually onset time
Mres=5; % "1"for f;"2" for j
MRT=6; % reaction time;
Mcorrect = 7;% Mcorrect indicates the correct response, 1==up, 2==down;
Mscore=8;% right(1) or wrong(0) for identity

% the basic list has been genenrate in Excel
% list for each subject will be generated later in the script
std_list = xlsread('standard_list.xlsx');

%% ----------------------- Screen setup ---------------------- %%
%%%%%% 设置屏幕相关参数
% 颜色参数设置
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);
bkGround = grey; % mean luminance

% open the screen
HideCursor;
[wPtr, rect] = PsychImaging('OpenWindow',screenNumber,bkGround,[],32,2);
Screen(wPtr,'FillRect',bkGround);

% Flip to clear
Screen('Flip', wPtr);

% Measure the vertical refresh rate of the monitor
% 显示器刷新一帧所需的时间
ifi = Screen('GetFlipInterval', wPtr);

% Query the maximum priority level
% 为了让CPU优先处理PTB的请求而提高PTB的优先等级
topPriorityLevel = MaxPriority(wPtr);

% Set the blend funciton for the screen
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% size and position based on screen resolution
res=Screen (0,'rect');

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(res);

% Set pic size (according to the size of your pics)
h1=xCenter-160; h2=xCenter+160;
v1=yCenter-217; v2=yCenter+217;
rect_pic=[h1 v1 h2 v2];

% Set the text size
Screen('TextSize',wPtr,60);

%% ----------------------- Time setup ---------------------- %%
% 刺激窗口设置
respWind1=0.5;
respWind2=0.5;
fixation=0.5;
blank_dur=1;

blank_rnd=unifrnd(-0.2, 0.2, TTN, blank_dur);
Blankrand=blank_rnd(Shuffle(1:TTN),:); % blank delay 800-1200ms
blank_rnd_prac = unifrnd(-0.2, 0.2, prac_TTN, blank_dur);
Blankrand_prac=blank_rnd_prac(Shuffle(1:prac_TTN),:); % blank delay 800-1200ms

% Interstimulus interval time in seconds and frames
% fixFrames = round(fixation / ifi);
% respWind1Frames = round(respWind1 / ifi);
% respWind2Frames = round(respWind2 / ifi);

% ******************************************************************************
%                                   Experiment
% ******************************************************************************

Priority(topPriorityLevel);

%% 1.指导语
instru_name = sprintf('instruction/instruction.jpg');
current_instru = imread(instru_name);
current_instru_Texture = Screen('MakeTexture', wPtr, current_instru);
Screen('DrawTexture', wPtr, current_instru_Texture);
Screen('Flip', wPtr);

% Wait for keypress 'space' to start
KbWait;

% Embed core of code in try ... catch statement. If anything goes wrong
% inside the 'try' block (Matlab error), the 'catch' block is executed to
% clean up, save results, close the onscreen window etc.
try
    %% 2. 练习部分
    prac_name = sprintf('instruction/practice1.jpg');
    current_prac = imread(prac_name);
    current_prac_Texture = Screen('MakeTexture', wPtr, current_prac);
    Screen('DrawTexture', wPtr, current_prac_Texture);
    Screen('Flip', wPtr);
    
    [~, keyCode, ~] = KbWait;
    
    while keyCode(jKey) == 1
        % 生成练习list:提取8个trials
        list = std_list;
        shuffler = Shuffle(1:160);
        list_tmp = list(shuffler,:);
        list_tmp(:,1) = 1:TTN;
        MList_prac(:,[Mtrial MID Mcat MAonset Mres MRT Mcorrect Mscore]) = list_tmp(1:prac_TTN,:);
        
        Screen('Flip', wPtr);
        WaitSecs(3);% for signal to be stable
        
        startSecs = GetSecs;
        for itrial = 1:prac_TTN
            % fixation
            Screen('DrawText',wPtr,'+',res(3)*0.5,res(4)*0.5, black);
            vbl = Screen('Flip', wPtr);%VBLTimestamp是指上一帧扫描结束的时间点
            
            % stimuli
            picfile=sprintf('image/%d.bmp',MList_prac(itrial,MID));
            pic=imread(picfile);
            pic_Texture = Screen('MakeTexture', wPtr, pic);
            Screen('DrawTexture', wPtr, pic_Texture, [], rect_pic);
            % Flip to the screen
            vbl = Screen('Flip', wPtr, vbl + (fixation/ifi-0.5)*ifi);
            MList_prac(itrial,MAonset) = GetSecs - startSecs;
            
            % stim mark
            trial_type = MList_prac(itrial,Mcat);
            outp(888,trial_type);
            pause(0.025);
            outp(888,0);
            
            tStart = GetSecs;
            KbWait(-1,0,vbl+(respWind1/ifi-0.5)*ifi);
            % 按键进入delay空屏或进入response空屏才按键
            [keyIsDown,Ksecs, keyCode] = KbCheck(-1);
            if keyIsDown == 1
                MList_prac(itrial,MRT)=Ksecs-tStart;
                if keyCode(fKey)
                    response = 1;
                elseif keyCode(jKey)
                    response = 2;
                elseif keyCode(escapeKey)
                    sca;
                    disp('*** Experiment terminated ***');
                end
                MList_prac(itrial,Mres)=response;
                score=response==MList_prac(itrial,Mcorrect);
                MList_prac(itrial,Mscore)=double(score);
                % feedback mark
                if MList_prac(itrial,Mscore)==1
                    outp(888,trigger_right);
                    pause(0.025);
                    outp(888,0);
                else
                    outp(888,trigger_wrong);
                    pause(0.025);
                    outp(888,0);
                end
                % 进入delay空屏
                Screen('Flip', wPtr);
                WaitSecs(1+Blankrand_prac(itrial));
            else
                % 进入response空屏
                vbl = Screen('Flip', wPtr,vbl + (respWind1/ifi-0.5)*ifi);
                KbWait(-1,0,vbl+(respWind2/ifi-0.5)*ifi);
                [keyIsDown2,Ksecs2, keyCode2] = KbCheck(-1);
                if keyIsDown2 == 1
                    MList_prac(itrial,MRT)=Ksecs2-tStart;
                    if keyCode2(fKey)
                        response = 1;
                    elseif keyCode2(jKey)
                        response = 2;
                    elseif keyCode2(escapeKey)
                        sca;
                        disp('*** Experiment terminated ***');
                    end
                    MList_prac(itrial,Mres)=response;
                    score2=response==MList_prac(itrial,Mcorrect);
                    MList_prac(itrial,Mscore)=double(score2);
                    % feedback mark
                    if MList_prac(itrial,Mscore)==1
                        outp(888,trigger_right);
                        pause(0.025);
                        outp(888,0);
                    else
                        outp(888,trigger_wrong);
                        pause(0.025);
                        outp(888,0);
                    end
                    % 进入delay空屏
                    Screen('Flip', wPtr);
                    WaitSecs(1+Blankrand_prac(itrial));
                else
                    MList_prac(itrial,MRT)=NaN;
                    MList_prac(itrial,Mres)=NaN;
                    MList_prac(itrial,Mscore)=0;
                    % 结束后进入delay空屏
                    vbl = Screen('Flip', wPtr,vbl + (respWind2/ifi-0.5)*ifi);
                    WaitSecs(1+Blankrand_prac(itrial));
                end
            end
        end % end for practice trial
        
        % 练习结束指导语
        prac_name2 = sprintf('instruction/practice2.bmp');
        current_prac2 = imread(prac_name2);
        current_prac_Texture2 = Screen('MakeTexture', wPtr, current_prac2);
        Screen('DrawTexture', wPtr, current_prac_Texture2);
        Screen('Flip', wPtr);
        
        % 选择“继续练习”或“正式实验”
        [~, keyCode, ~] = KbWait;
        
    end % end for while
    
    %% 3.正式实验
    
    % generate list for each subject
    clear list list_tmp
    list = std_list;
    list_tmp = list(Shuffle(1:size(list,1)),:);
    list_tmp(:,1) = 1:TTN;
    MList(:,[Mtrial MID Mcat MAonset Mres MRT Mcorrect Mscore]) = list_tmp(1:TTN,:);
    clear list_tmp itrial
    
    % prepare screen
    Screen('Flip', wPtr);
    % exp start mark
    outp(888,trigger_start);
    pause(0.025);
    outp(888,0);
    
    WaitSecs(3);
    startSecs=GetSecs;
    
    %% Trial Loop
    for itrial = 1:TTN
        % fixation
        Screen('DrawText',wPtr,'+',res(3)*0.5,res(4)*0.5, black);
        vbl = Screen('Flip', wPtr);
        
        % stimuli
        picfile=sprintf('image/%d.bmp',MList(itrial,MID));
        pic=imread(picfile);
        pic_Texture = Screen('MakeTexture', wPtr, pic);
        Screen('DrawTexture', wPtr, pic_Texture, [], rect_pic);
        
        vbl = Screen('Flip', wPtr, vbl + (fixation/ifi-0.5)*ifi);
        MList(itrial,MAonset)=GetSecs-startSecs;
        
        % stim mark
        trial_type=MList(itrial,Mcat);
        outp(888,trial_type);
        pause(0.025);
        outp(888,0);
        
        tStart=GetSecs;
        KbWait(-1,0,vbl+(respWind1/ifi-0.5)*ifi);        
        % 按键进入delay空屏或进入response空屏才按键
        [keyIsDown,Ksecs, keyCode] = KbCheck(-1);
        if keyIsDown == 1
            MList(itrial,MRT)=Ksecs-tStart;
            if keyCode(fKey)
                response = 1;
            elseif keyCode(jKey)
                response = 2;
            elseif keyCode(escapeKey)
                sca;
                disp('*** Experiment terminated ***');
            end
            MList(itrial,Mres)=response;
            score=response==MList(itrial,Mcorrect);
            MList(itrial,Mscore)=double(score);
            % feedback mark
            if MList(itrial,Mscore)==1
                outp(888,trigger_right);
                pause(0.025);
                outp(888,0);
            else
                outp(888,trigger_wrong);
                pause(0.025);
                outp(888,0);
            end
            % 进入delay空屏
            Screen('Flip', wPtr);
            WaitSecs(1+Blankrand(itrial));
        else
            % 进入response空屏
            vbl = Screen('Flip', wPtr,vbl + (respWind1/ifi-0.5)*ifi);
            KbWait(-1,0,vbl+(respWind2/ifi-0.5)*ifi);
            [keyIsDown2,Ksecs2, keyCode2] = KbCheck;
            if keyIsDown2 == 1
                MList(itrial,MRT)=Ksecs2-tStart;
                if keyCode2(fKey)
                    response = 1;
                elseif keyCode2(jKey)
                    response = 2;
                elseif keyCode2(escapeKey)
                    sca;
                    disp('*** Experiment terminated ***');
                end
                MList(itrial,Mres)=response;
                score2=response==MList(itrial,Mcorrect);
                MList(itrial,Mscore)=double(score2);
                % feedback mark
                if MList(itrial,Mscore)==1
                    outp(888,trigger_right);
                    pause(0.025);
                    outp(888,0);
                else
                    outp(888,trigger_wrong);
                    pause(0.025);
                    outp(888,0);
                end
                % 进入delay空屏
                Screen('Flip', wPtr);
                WaitSecs(1+Blankrand(itrial));
            else
                MList(itrial,MRT)=NaN;
                MList(itrial,Mres)=NaN;
                MList(itrial,Mscore)=0;
                % 结束后进入delay空屏
                vbl = Screen('Flip', wPtr,vbl + (respWind2/ifi-0.5)*ifi);
                WaitSecs(1+Blankrand(itrial));
            end
        end
        if ismember(itrial,[40 80 120])==1
            % 进入休息
            rest_name = sprintf('instruction/rest.jpg');
            current_rest = imread(rest_name);
            current_rest_Texture = Screen('MakeTexture', wPtr, current_rest);
            Screen('DrawTexture', wPtr, current_rest_Texture);
            Screen('Flip', wPtr);
            
            KbWait;
            
            Screen('Flip', wPtr);
            WaitSecs(3)
        end
    end % end for trial
    
    % 结束指导语
    end_name = sprintf('instruction/end.jpg');
    current_end = imread(end_name);
    current_end_Texture = Screen('MakeTexture', wPtr, current_end);
    Screen('DrawTexture', wPtr, current_end_Texture);
    Screen('Flip', wPtr);
    
    WaitSecs(5)
    
    outp(888, trigger_end)
    pause(0.025);
    outp(888, 0)
    
    Priority(0);
    %% save results
    eval(sprintf('save %s MList',outfile));
    subTable.MList(nsub+1)={MList};
    save('results/subInfo.mat','subTable');
    Screen('CloseAll');
    %% print summary result:
    fprintf('-------------------------------\n')
    fprintf('Result summary: \n')
    fprintf('Accuracy: %5.2f%%\n',mean(MList(:,Mscore)==1)*100);
    fprintf('-------------------------------\n')
catch
    outfile=fullfile(folder,'results',sprintf('tmp_N170_sub%02d_%s_%02.0f-%02.0f',str2double([subinfo{1}]),d(1:6),c(4),c(5)));
    eval(sprintf('save %s MList',outfile));
    subTable.MList(nsub+1)={MList};
    save('results/subInfo.mat','subTable');
    Screen('CloseAll');
    rethrow(lasterror) % 显示最后的错误信息
end

% Close the onscreen window
sca
return