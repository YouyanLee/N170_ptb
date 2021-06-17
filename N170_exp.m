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
prompt = {'SubID','Name','Gender[Female=1,Male=2]','Age'};  %������Ҫ��д����Ŀ
dlg_title = 'Subject Info'; %����Ի�������
num_lines = 1; %������ʾ������
defaultanswer = {'','','',''}; %����Ĭ��ֵ
subinfo = inputdlg(prompt,dlg_title,num_lines,defaultanswer,'on');%���������û���Ϣ�ĶԻ���promptΪ��ʾ�ַ�����dlg_titleΪ�Ի������ƣ�num_linesΪ��ʾ��������defaultanswerΪĬ��ֵ

if exist('results/subInfo.mat','file')==0
    subTable = table;
    nsub = 0;
else
    load('results/subInfo.mat')
    nsub = size(subTable,1);
end

subTable.subID(nsub+1) = str2double([subinfo{1}]); %��ȡ�û���Ϣ�ĵ�1�У�ת��Ϊ��ֵ������ֵ��subID����¼�������
subTable.Name(nsub+1)= subinfo(2); %��ȡ�û���Ϣ�ĵ�2�У���¼��������
subTable.Gender(nsub+1) = str2double([subinfo{3}]); %��ȡ�û���Ϣ�ĵ�3�У���¼�����Ա�
subTable.Age(nsub+1) = str2double([subinfo{4}]); %��ȡ�û���Ϣ�ĵ�4�У���¼��������

%% ----------------------- Enviroment setting ---------------------- %%
%��������Ӳ�����Կ������ⱨ�����Խ׶�ʹ�ã���ʱ�侫��Ҫ���ϸ�
%��ʱ��Flip ָ��� StimulusOnsetTime = VBLTimestamp;
Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB with some default values
% ����PTBִ�й����е������Ϣ������ʱ��ѡ��ϸ�level����ʽʵ��ʱ0�������������Ϣ
Screen('Preference', 'Verbosity', 0);
% call default settings for setting up PTB
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% seeds the random number generator
rng('shuffle')

%% ----------------------- Experiment Setting ---------------------- %%
% trials������
prac_TTN = 8; % total trial number for practice
TTN = 160; % total trial number

% mark����
trigger_start=241; % exp start trigger
trigger_end=242; % exp end trigger

trigger_right = 7; % right response trigger
trigger_wrong = 8; % wrong response trigger

% ��������
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
fKey = KbName('f');
jKey = KbName('j');
RestrictKeysForKbCheck([spaceKey escapeKey fKey jKey]);%���ư���

% ����ļ�
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
%%%%%% ������Ļ��ز���
% ��ɫ��������
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
% ��ʾ��ˢ��һ֡�����ʱ��
ifi = Screen('GetFlipInterval', wPtr);

% Query the maximum priority level
% Ϊ����CPU���ȴ���PTB����������PTB�����ȵȼ�
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
% �̼���������
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

%% 1.ָ����
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
    %% 2. ��ϰ����
    prac_name = sprintf('instruction/practice1.jpg');
    current_prac = imread(prac_name);
    current_prac_Texture = Screen('MakeTexture', wPtr, current_prac);
    Screen('DrawTexture', wPtr, current_prac_Texture);
    Screen('Flip', wPtr);
    
    [~, keyCode, ~] = KbWait;
    
    while keyCode(jKey) == 1
        % ������ϰlist:��ȡ8��trials
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
            vbl = Screen('Flip', wPtr);%VBLTimestamp��ָ��һ֡ɨ�������ʱ���
            
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
            % ��������delay���������response�����Ű���
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
                % ����delay����
                Screen('Flip', wPtr);
                WaitSecs(1+Blankrand_prac(itrial));
            else
                % ����response����
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
                    % ����delay����
                    Screen('Flip', wPtr);
                    WaitSecs(1+Blankrand_prac(itrial));
                else
                    MList_prac(itrial,MRT)=NaN;
                    MList_prac(itrial,Mres)=NaN;
                    MList_prac(itrial,Mscore)=0;
                    % ���������delay����
                    vbl = Screen('Flip', wPtr,vbl + (respWind2/ifi-0.5)*ifi);
                    WaitSecs(1+Blankrand_prac(itrial));
                end
            end
        end % end for practice trial
        
        % ��ϰ����ָ����
        prac_name2 = sprintf('instruction/practice2.bmp');
        current_prac2 = imread(prac_name2);
        current_prac_Texture2 = Screen('MakeTexture', wPtr, current_prac2);
        Screen('DrawTexture', wPtr, current_prac_Texture2);
        Screen('Flip', wPtr);
        
        % ѡ�񡰼�����ϰ������ʽʵ�顱
        [~, keyCode, ~] = KbWait;
        
    end % end for while
    
    %% 3.��ʽʵ��
    
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
        % ��������delay���������response�����Ű���
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
            % ����delay����
            Screen('Flip', wPtr);
            WaitSecs(1+Blankrand(itrial));
        else
            % ����response����
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
                % ����delay����
                Screen('Flip', wPtr);
                WaitSecs(1+Blankrand(itrial));
            else
                MList(itrial,MRT)=NaN;
                MList(itrial,Mres)=NaN;
                MList(itrial,Mscore)=0;
                % ���������delay����
                vbl = Screen('Flip', wPtr,vbl + (respWind2/ifi-0.5)*ifi);
                WaitSecs(1+Blankrand(itrial));
            end
        end
        if ismember(itrial,[40 80 120])==1
            % ������Ϣ
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
    
    % ����ָ����
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
    rethrow(lasterror) % ��ʾ���Ĵ�����Ϣ
end

% Close the onscreen window
sca
return