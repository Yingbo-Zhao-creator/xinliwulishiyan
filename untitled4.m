% 信息收集弹窗设置
prompt = {'Enter subject ID:', 'Enter subject age:', 'Enter subject gender (M/F):'};
dlgtitle = 'Subject Information';

dims = [1 35];
definput = {'', '', ''}; % 默认值
answer = inputdlg(prompt, dlgtitle, dims, definput);

% 将输入的数据保存到变量中
subjectID = answer{1};
age = str2double(answer{2}); % 将年龄转换为数字类型
gender = answer{3};

% 初始化Psychtoolbox
Screen('Preference', 'SkipSyncTests', 0);
[window, windowRect] = Screen('OpenWindow', 0, [0 0 0]); % 打开一个黑色背景的窗口

% 获取屏幕中心坐标
[xCenter, yCenter] = RectCenter(windowRect);

% 设置练习和实验的次数
numPracticeTrials = 2;
numMainTrials = 2;

% 创建一个空表格来存储所有数据
dataTable = table();

% 运行练习部分
for trial = 1:numPracticeTrials
    % 在此处插入练习部分的代码
    dataTable = RunTrial(window, xCenter, yCenter, trial, 'Practice', subjectID, age, gender, dataTable);
end

% 运行主要实验部分
for trial = 1:numMainTrials
    % 在此处插入主要实验部分的代码
    dataTable = RunTrial(window, xCenter, yCenter, trial, 'Main', subjectID, age, gender, dataTable);
end

% 保存整个实验数据到一个表格文件
save(['C:\MATLAB\xiaoshiyan\arc_data_' subjectID '.mat'], 'dataTable');

% 关闭屏幕
Screen('CloseAll');

% 定义运行每次试验的函数
function dataTable = RunTrial(window, xCenter, yCenter, trial, trialType, subjectID, age, gender, dataTable)
    % 显示十字准星作为准备时间
    crosshairSize = 20; % 十字准星的大小
    lineWidth = 3; % 十字准星线宽
    Screen('DrawLine', window, [255 255 255], xCenter - crosshairSize, yCenter, xCenter + crosshairSize, yCenter, lineWidth);
    Screen('DrawLine', window, [255 255 255], xCenter, yCenter - crosshairSize, xCenter, yCenter + crosshairSize, lineWidth);
    Screen('Flip', window);
    WaitSecs(2);

    % 圆的半径和弧段角度
    radius = 200; % 圆的半径
    startAngle = rand() * 360; % 随机起始角度
    arcLength = 60 + rand() * 120; % 弧线的长度（角度）

    % 等待受试者准备好，按任意键开始
    instructions = ['In the upcoming task, you will see an arc segment appear on the screen.\n\n', ...
                    'Please carefully observe the position and speed of the arc as it is drawn.\n\n', ...
                    'When the crosshair appears, use that time to consolidate your memory of the arc.\n\n', ...
                    'Afterward, you will be asked to reproduce the arc on the screen, matching the original speed as closely as possible.\n\n', ...
                    'Press any key when you are ready to begin.'];
    DrawFormattedText(window, instructions, 'center', 'center', [255 255 255], 60);
    Screen('Flip', window);

    % 等待按键按下
    KbWait;

    % 等待2秒后开始显示弧段
    WaitSecs(2);

    % 开始计时
    arcStartTime = GetSecs();

    % 设置弧线出现的总时间在2到8秒之间随机变化
    totalArcTime = 2 + rand() * 6;  % 2到8秒之间的随机时间

    % 计算每次迭代的等待时间，以使弧线在指定的总时间内出现
    waitTime = totalArcTime / 100;  % 每次循环的等待时间

    for i = 1:100
        Screen('FrameArc', window, [255 255 255], ...
               CenterRectOnPointd([0 0 2*radius 2*radius], xCenter, yCenter), ...
               startAngle, i * arcLength / 100, 5);
        Screen('Flip', window);
        WaitSecs(waitTime); % 根据计算出的等待时间控制弧线出现速度
    end

    % 记录时间
    arcEndTime = GetSecs();
    arcDuration = arcEndTime - arcStartTime;

    % 暂停1.5秒
    WaitSecs(1.5);

    % 第二个模块实现间隔让受试者进行记忆
    % 绘制十字准星
    crosshairSize = 20; % 十字准星的大小
    lineWidth = 3; % 十字准星线宽
    Screen('DrawLine', window, [255 255 255], xCenter - crosshairSize, yCenter, xCenter + crosshairSize, yCenter, lineWidth);
    Screen('DrawLine', window, [255 255 255], xCenter, yCenter - crosshairSize, xCenter, yCenter + crosshairSize, lineWidth);
    crosshairStartTime = Screen('Flip', window);

    % 十字准星维持时间
    crosshairDuration = 3 + rand() * 5; % 3到8秒之间的随机时间
    WaitSecs(crosshairDuration);

    % 暂停2秒
    WaitSecs(2);

    % 开始受试者绘制弧段
    Screen('Flip', window); % 清空屏幕

    % 提示受试者可以开始绘制
    textYPosition = yCenter - 300;  % 将文本位置设置在屏幕上方，可以根据需要调整偏移量
    DrawFormattedText(window, 'Use the mouse to draw the arc.', 'center', textYPosition, [255 255 255]);
    Screen('Flip', window);

    % 初始化数据存储
    maxIterations = 1000;  % 假设最大迭代次数为1000
    mouseX = zeros(1, maxIterations);
    mouseY = zeros(1, maxIterations);

    % 鼠标点击检测并记录轨迹
    i = 0;
    buttons = [0 0 0]; % 初始化按钮状态

    % 等待用户点击开始绘制
    while any(buttons) == 0
        [x, y, buttons] = GetMouse(window);
    end

    % 记录开始绘制时间
    drawStartTime = GetSecs();

    % 记录鼠标轨迹
    while any(buttons)
        [x, y, buttons] = GetMouse(window);
        i = i + 1;
        mouseX(i) = x;
        mouseY(i) = y;

        % 绘制所有记录的点
        Screen('DrawDots', window, [mouseX(1:i); mouseY(1:i)], 5, [255 255 255], [], 2);
        Screen('Flip', window);
    end

    % 记录结束绘制时间
    drawEndTime = GetSecs();
    drawDuration = drawEndTime - drawStartTime; % 计算绘制弧线的时间

    % 如果实际采样点少于最大迭代次数，则截断数组
    mouseX = mouseX(1:i);
    mouseY = mouseY(1:i);

    % 将数据添加到表格中
    trialData = table({subjectID}, age, {gender}, trial, {trialType}, arcDuration, arcLength, startAngle, crosshairDuration, drawDuration, {mouseX}, {mouseY}, ...
                      'VariableNames', {'SubjectID', 'Age', 'Gender', 'Trial', 'TrialType', 'ArcDuration', 'ArcLength', 'StartAngle', 'CrosshairDuration', 'DrawDuration', 'MouseX', 'MouseY'});

    dataTable = [dataTable; trialData];
end
