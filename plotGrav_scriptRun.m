function plotGrav_scriptRun(in_script)
%PLOTGRAV_SCRIPTRUN Run scripts for plotGrav
% This function reads the input script and runs all commands
% chronologically. 
% 
% Input:
%   in_script   ... full file name of plotGrav script
%
%
%                                                   M.Mikolaj, 24.09.2015

% Open log file
[ty,tm,td,th,tmm] = datevec(now);                                           % get current time for logfile
tic;                                                                        % start measuring time for logfile
try
    fid_log = fopen(get(findobj('Tag','plotGrav_edit_logfile_file'),'String'),'a'); % try to get the logfile name
catch
    fid_log = fopen('plotGrav_LOG_FILE.log','a');                               % otherwise use default logfile name
end
set(findobj('Tag','plotGrav_text_status'),'String','Running script...');drawnow; % status
fprintf(fid_log,'Running script: %s (%04d/%02d/%02d %02d:%02d)\n',in_script,ty,tm,td,th,tmm); % will be overwritten in case script contains 'LOAD_DATA' command. 'load_all_data' uses 'o' permission!
pause(1);
count = 0;                                                                  % to count number of read lines
% % First, check if plotGrav runs - not working
% check_open_window = get(findobj('Tag','plotGrav_check_legend'),'Value');    % only checks if uicontrol with such 'Tag' exists
% if isempty(check_open_window)                                               % start plotGrav if not already running
%     plotGrav                                                                % start plotGrav if not opened
%     drawnow;pause(10);                                                       % wait for plotGrav
% else

% Open script for reading
try                                                                         % catch errors
    fid = fopen(in_script,'r'); 
    row = fgetl(fid);count = count + 1;                                     % Get first row (usualy comment). Count number of read lines
    while ischar(row)                                                       % continue reading whole file
        if ~strcmp(row(1),'%')                                              % run code only if not comment
            switch row                                                      % switch between commands depending on the Script switch.
                %% Setting file paths
                case 'FILE_IN' 
                    row = fgetl(fid);count = count + 1;                 % Get next line/row. The plotGrav script are designed as follows: first the switch and next line the inputs
                    if ~strcmp(row,'[]')                                 % [] symbol means no input 
                        temp = strsplit(row,';');
                        if strcmp(temp{2},'[]')
                            set(findobj('Tag',['plotGrav_edit_',lower(temp{1}),'_path']),'String','');
                        else
                            set(findobj('Tag',['plotGrav_edit_',lower(temp{1}),'_path']),'String',temp{2});
                        end
                    end
                case 'FILE_IN_DATA_A' % old version (back-compatibility)
                    row = fgetl(fid);count = count + 1;                     % Get next line/row. The plotGrav script are designed as follows: first the switch and next line the inputs
                    if strcmp(row,'[]')                                     % [] symbol means no input                           
                        set(findobj('Tag','plotGrav_edit_data_a_path'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_data_a_path'),'String',row); % otherwise set the input file
                    end
                case 'FILE_IN_DATA_B'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_edit_data_b_path'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_data_b_path'),'String',row);
                    end
                case 'FILE_IN_DATA_C'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_edit_data_c_path'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_data_c_path'),'String',row);
                    end
                case 'FILE_IN_DATA_D'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_edit_data_d_path'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_data_d_path'),'String',row);
                    end
                case 'FILE_IN_TIDES'
                    row = fgetl(fid);count = count + 1; 
                    if ~strcmp(row,'[]')                                 % [] symbol means no input 
                        temp = strsplit(row,';');
                        % Old verstion == 1 input for DATA_A
                        if length(temp) == 1
                            file_tides.data_a = row;file_tides.data_b = [];
                            file_tides.data_c = [];file_tides.data_d = [];
                            set(findobj('Tag','plotGrav_edit_tide_file'),'UserData',file_tides);
                        else
                            if strcmp(temp{2},'[]')
                                file_tides.(lower(temp{1})) = '';
                            else
                                file_tides.(lower(temp{1})) = temp{2};
                            end
                            set(findobj('Tag','plotGrav_edit_tide_file'),'UserData',file_tides);
                        end
                    else
                        set(findobj('Tag','plotGrav_edit_tide_file'),'UserData',[]);
                    end
                case 'FILE_IN_FILTER'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_edit_filter_file'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_filter_file'),'String',row);
                    end
                case 'FILE_IN_WEBCAM'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_menu_webcam'),'UserData',''); % similarly to unzip exe, webcam path is stored in UserData
                    else
                        set(findobj('Tag','plotGrav_menu_webcam'),'UserData',row);
                    end
                case 'FILE_IN_LOGFILE'
                    row = fgetl(fid);count = count + 1; 
                    if strcmp(row,'[]')
                        set(findobj('Tag','plotGrav_edit_logfile_file'),'String','');
                    else
                        set(findobj('Tag','plotGrav_edit_logfile_file'),'String',row);
                    end
				case 'PREFIX_NAME'
					row = fgetl(fid);count = count + 1; 
                    if ~strcmp(row,'[]')                            
						temp = strsplit(row,';');
                        if strcmp(temp{2},'[]')
                            set(findobj('Tag',['plotGrav_menu_',lower(temp{1}),'_file']),'UserData','')
                        else
                            set(findobj('Tag',['plotGrav_menu_',lower(temp{1}),'_file']),'UserData',temp{2})
                        end
                    end
                %% Input time settings
                case 'TIME_START'                                           % Starting time
                    row = fgetl(fid);count = count + 1;                     % read the date
                    if ~strcmp(row,'[]')                                    % proceed/set only if required
                        date = strsplit(row,';');                           % By default multiple inputs are delimited by ;. If one input (with minus sign), then set to current time - input
                        if length(date) == 1
                            date = char(date);
                            if strcmp(date(1),'-');
                                temp = now;temp = datevec(temp+str2double(date)); % use + as input starts with minus sign!
                                set(findobj('Tag','plotGrav_edit_time_start_year'),'String',sprintf('%04d',temp(1))); % set year
                                set(findobj('Tag','plotGrav_edit_time_start_month'),'String',sprintf('%02d',temp(2))); % month
                                set(findobj('Tag','plotGrav_edit_time_start_day'),'String',sprintf('%02d',temp(3))); % day
                                set(findobj('Tag','plotGrav_edit_time_start_hour'),'String','00'); % Set hours to 0 if one input.
                            end
                        else
                            set(findobj('Tag','plotGrav_edit_time_start_year'),'String',char(date(1))); % first value must be a year
                            set(findobj('Tag','plotGrav_edit_time_start_month'),'String',char(date(2))); % second value must be month
                            set(findobj('Tag','plotGrav_edit_time_start_day'),'String',char(date(3))); % first value must be day
                            set(findobj('Tag','plotGrav_edit_time_start_hour'),'String',char(date(4))); % first value must be hour (no minutes and seconds on plotGrav input)
                        end
                    end
                case 'TIME_STOP'                                            % Stop time
                    row = fgetl(fid);count = count + 1;                     % read the date
                    if ~strcmp(row,'[]')                                    % proceed/set only if required
                        date = strsplit(row,';');                            % By default multiple inputs are delimited by ; If one input (with minus sign), then set to current time - input
                        if length(date) == 1
                            date = char(date);
                            if strcmp(date(1),'-');
                                temp = now;temp = datevec(temp+str2double(date));  % use + as input starts with minus sign!
                                set(findobj('Tag','plotGrav_edit_time_stop_year'),'String',sprintf('%04d',temp(1))); % set year
                                set(findobj('Tag','plotGrav_edit_time_stop_month'),'String',sprintf('%02d',temp(2))); % month
                                set(findobj('Tag','plotGrav_edit_time_stop_day'),'String',sprintf('%02d',temp(3))); % day
                                set(findobj('Tag','plotGrav_edit_time_stop_hour'),'String','00'); % Set hours to 0 if one input.
                            end
                        else
                            set(findobj('Tag','plotGrav_edit_time_stop_year'),'String',char(date(1))); % first value must be a year
                            set(findobj('Tag','plotGrav_edit_time_stop_month'),'String',char(date(2))); % second value must be month
                            set(findobj('Tag','plotGrav_edit_time_stop_day'),'String',char(date(3))); % first value must be day
                            set(findobj('Tag','plotGrav_edit_time_stop_hour'),'String',char(date(4))); % first value must be hour (no minutes and seconds on plotGrav input)
                        end
                    end
                %% Gravimeter processing settings
                case 'CALIBRATION_FACTOR'
                    row = fgetl(fid);count = count + 1; 
                    if ~strcmp(row,'[]')                            
                        temp = strsplit(row,';');
                        % Back-compatibility with old version
                        if length(temp) == 1
                            calib.data_a = row;calib.data_b = '1';
                            calib.data_c = '1';calib.data_d = '1';
                            set(findobj('Tag','plotGrav_edit_calb_factor'),'UserData',calib);
                            clear calib
                        else
                            if ~strcmp(temp{2},'[]')
                                calib = get(findobj('Tag','plotGrav_edit_calb_factor'),'UserData');
                                calib.(lower(temp{1})) = temp{2};
                                set(findobj('Tag','plotGrav_edit_calb_factor'),'UserData',calib);
                                clear calib
                            end
                        end
                    end
                case 'CALIBRATION_DELAY'
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(row,'[]')                            
                        temp = strsplit(row,';');
                        % Back-compatibility with old version
                        if length(temp) == 1
                            calib.data_a = row;calib.data_b = '0';
                            calib.data_c = '0';calib.data_d = '0';
                            set(findobj('Tag','plotGrav_edit_calb_delay'),'UserData',calib);
                            clear calib
                        else
                            if ~strcmp(temp{2},'[]')
                                calib = get(findobj('Tag','plotGrav_edit_calb_delay'),'UserData');
                                calib.(lower(temp{1})) = temp{2};
                                set(findobj('Tag','plotGrav_edit_calb_delay'),'UserData',calib);
                                clear calib
                            end
                        end
                    end
                case 'ADMITTANCE_FACTOR'
                    row = fgetl(fid);count = count + 1; 
                    if ~strcmp(row,'[]')                            
                        temp = strsplit(row,';');
                        % Back-compatibility with old version
                        if length(temp) == 1
                            set_admit.data_a = temp{1};set_admit.data_b = NaN;
                            set_admit.data_c = NaN;set_admit.data_d = NaN;
                            set(findobj('Tag','plotGrav_edit_admit_factor'),'UserData',set_admit);
                        else % new version
                            if ~strcmp(temp{2},'[]')
                                set_admit = get(findobj('Tag','plotGrav_edit_admit_factor'),'UserData');
                                set_admit.(lower(temp{1})) = temp{2};
                                set(findobj('Tag','plotGrav_edit_admit_factor'),'UserData',set_admit);
                            end
                        end
                    end
                case 'RESAMPLE'
                    row = fgetl(fid);count = count + 1; 
                    if ~strcmp(row,'[]')
                        temp = strsplit(row,';');
                        set_resample = get(findobj('Tag','plotGrav_edit_resample'),'UserData');
                        set_resample.(lower(temp{1})) = temp{2};
                        set(findobj('Tag','plotGrav_edit_resample'),'UserData',set_resample);
                    end
                case 'GRAVITY_CHANNEL'
                        row = fgetl(fid);count = count + 1; 
                        if ~strcmp(row,'[]')                            
                            temp = strsplit(row,';');
                            grav_channel = get(findobj('Tag','plotGrav_menu_grav_channel'),'UserData');
                            if strcmp(temp{2},'[]')
                                grav_channel.(lower(temp{1})) = 1;
                            else
                                grav_channel.(lower(temp{1})) = str2double(strsplit(temp{2},' '));
                            end
                            set(findobj('Tag','plotGrav_menu_grav_channel'),'UserData',grav_channel);
                        end
                case 'PRESSURE_CHANNEL'
                        row = fgetl(fid);count = count + 1; 
                        if ~strcmp(row,'[]')    
                            pres_channel = get(findobj('Tag','plotGrav_menu_pres_channel'),'UserData');
                            temp = strsplit(row,';');
                            if strcmp(temp{2},'[]')
                                pres_channel.(lower(temp{1})) = 1;
                            else
                                pres_channel.(lower(temp{1})) = str2double(strsplit(temp{2},' '));
                            end
                            set(findobj('Tag','plotGrav_menu_pres_channel'),'UserData',pres_channel);
                        end
                case 'DRIFT_SWITCH'
                    row = fgetl(fid);count = count + 1;
                    coef = strsplit(row,';');                       % multiple input possible => split it (first=polynomial, second=possibly polynomial coefficients
                    if ~strcmp(char(coef{1}),'[]')                     % proceed/set only if required
                        if strcmpi(coef{1}(1),'D')
                            set_drift_switch = get(findobj('Tag','plotGrav_pupup_drift'),'Userdata');
                            set_drift_val = get(findobj('Tag','plotGrav_edit_drift_manual'),'UserData');
                            set_drift_switch.(lower(coef{1})) = str2double(coef{2});
                            if strcmp(str2double(coef{2}),'6')                % 6 = user defined polynomial ceoffients
                                set_drift_val.(lower(coef{1})) = char(coef(3:end));
                            else
                                set_drift_val.(lower(coef{1})) = [];
                            end
                            set(findobj('Tag','plotGrav_pupup_drift'),'Userdata',set_drift_switch); 
                            set(findobj('Tag','plotGrav_edit_drift_manual'),'UserData',set_drift_val);
                        else % Old: back compatibility
                            set_drift_switch.data_a = str2double(coef{1});
                            if strcmp(str2double(coef{1}),'6')                % 6 = user defined polynomial ceoffients
                                set_drift_val.data_a = char(coef(2:end));
                            else
                                set_drift_val.data_a = [];
                            end
                            set(findobj('Tag','plotGrav_pupup_drift'),'Userdata',set_drift_switch); 
                            set(findobj('Tag','plotGrav_edit_drift_manual'),'UserData',set_drift_val);
                        end
                    end
                %% Channels selection/checking
                case 'UITABLE_DATA_A_L'                                         % iGrav panel, LX axes (X=>for all left-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                  % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_a_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)) = {true};
                                else
                                    data_table(i,channel_numbers(1)) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_a_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end
                case 'UITABLE_DATA_A_R'                                         % iGrav panel, RX axes (X=>for all right-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                    % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                  % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_a_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)+4) = {true}; % +4 = first three are for Left axes, fourth is channel description.
                                else
                                    data_table(i,channel_numbers(1)+4) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_a_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end

                case 'UITABLE_DATA_B_L'                                        % TRiLOGi panel, LX axes (X=>for all left-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_b_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)) = {true};
                                else
                                    data_table(i,channel_numbers(1)) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_b_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end
                case 'UITABLE_DATA_B_R'                                        % TRiLOGi panel, RX axes (X=>for all right-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_b_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)+4) = {true}; % +4 = first three are for Left axes, fourth is channel description.
                                else
                                    data_table(i,channel_numbers(1)+4) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_b_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end

                case 'UITABLE_DATA_C_L'                                         % Other1 panel, LX axes (X=>for all left-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_c_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)) = {true};
                                else
                                    data_table(i,channel_numbers(1)) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_c_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end
                case 'UITABLE_DATA_C_R'                                         % Other1 panel, RX axes (X=>for all right-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_c_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)+4) = {true}; % +4 = first three are for Left axes, fourth is channel description.
                                else
                                    data_table(i,channel_numbers(1)+4) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_c_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end

                case 'UITABLE_DATA_D_L'                                         % Other2 panel, LX axes (X=>for all left-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_d_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)) = {true};
                                else
                                    data_table(i,channel_numbers(1)) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_d_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end
                case 'UITABLE_DATA_D_R'                                         % Other2 panel, RX axes (X=>for all right-axes)
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                                   % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                                 % proceed/set only if required
                        data_table = get(findobj('Tag','plotGrav_uitable_data_d_data'),'Data'); % get the ui-table.
                        channel_numbers = str2double(chan);                     % convert to double. Keep in mind, that first value shows the axes!
                        if channel_numbers(1) >= 1 || channel_numbers(1) <= 3   % Proceed only if logical input (only 3 plots available)
                            for i = 1:size(data_table,1)                        % run for whole data table. Channels on stated on input will be turned off/unchecked
                                r = find(i == channel_numbers(2:end));          % just to check if current channel is on input
                                if ~isempty(r)                                  % check such channel
                                   data_table(i,channel_numbers(1)+4) = {true}; % +4 = first three are for Left axes, fourth is channel description.
                                else
                                    data_table(i,channel_numbers(1)+4) = {false}; % Otherwise, unchecked.
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_d_data'),'Data',data_table); % update ui-table using 
                        plotGrav('uitable_push');                               % Re-plot data
                        pause(1);                                               % wait until plotting finished
                    end
                case 'UNCHECK_ALL'
                    plotGrav('uncheck_all');
                    row = fgetl(fid);count = count + 1;

                %% Print plots
                case 'PRINT_FIGURE'
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');                                     % split: minimum 2 inputs required
                    if ~strcmp(char(in),'[]')                                   % proceed/set only if required
                        if length(in) == 2                                      % switch between number of inputs
                            plotGrav_printData(str2double(in(1)),char(in(2)),[],[]);   % no DPI and screen resolution on input
                        elseif length(in) == 3
                            plotGrav_printData(str2double(in(1)),char(in(2)),str2double(in(3)),[]) % no screen resolution on input
                        elseif length(in) == 4
                            plotGrav_printData(str2double(in(1)),char(in(2)),str2double(in(3)),str2num(char(in(4)))); % all inputs
                        end
                    end
                %% Export data
                case 'EXPORT_DATA'
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');                                     % split: 3 inputs expected = panel switch; all/selected channels switch; and output file name
                    if ~strcmp(char(in(1)),'[]')                                % proceed/set only if required
                        if length(in) == 3
                            temp = char(in(1));
                            switch temp(1)                                  % switch between panels
                                % Old version with numbers insted of DATA_X
                                % switch
                                case '1'
                                    if strcmp(char(in(2)),'1')                  % switch between all/selected channels
                                        plotGrav('export_all','data_a',char(in(3)));
                                    elseif strcmp(char(in(2)),'2')
                                        plotGrav('export_sel','data_a',char(in(3)));
                                    end
                                case '2'
                                    if strcmp(char(in(2)),'1')                  % switch between all/selected channels
                                        plotGrav('export_all','data_b',char(in(3)));
                                    elseif strcmp(char(in(2)),'2')
                                        plotGrav('export_sel','data_b',char(in(3)));
                                    end
                                case '3'
                                    if strcmp(char(in(2)),'1')                  % switch between all/selected channels
                                        plotGrav('export_all','data_c',char(in(3)));
                                    elseif strcmp(char(in(2)),'2')
                                        plotGrav('export_sel','data_c',char(in(3)));
                                    end
                                case '4'
                                    if strcmp(char(in(2)),'1')                  % switch between all/selected channels
                                        plotGrav('export_all',char(in(3)));
                                    elseif strcmp(char(in(2)),'2')
                                        plotGrav('export_data_d_sel',char(in(3)));
                                    end
                                case 'D'
                                    if strcmp(char(in(2)),'1')                  % switch between all/selected channels
                                        plotGrav('export_all',lower(char(in(1))),char(in(3)));
                                    elseif strcmp(char(in(2)),'2')
                                        plotGrav('export_sel',lower(char(in(1))),char(in(3)));
                                    end
                            end
                        end
                    end
                %% Plar motion effect
                case 'GET_POLAR_MOTION'
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');
                    if ~strcmp(char(in{1}),'[]')
                        if length(in) == 1 % old plotGrav versio
                            plotGrav('get_polar','data_a',char(row));         
                        else
                            plotGrav('get_polar',lower(in{1}),in{2});    
                        end
                    end
                %% Atmacs atmospheric effect
                case 'GET_ATMACS'
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');                                 % two or three inputs expected
                    if ~strcmp(char(in{1}),'[]')
                        % Convert [] to '' (= empty)
                        if strcmp(in{2},'[]')
                            in{2} = '';
                        end
                        if length(in) == 2 % for old plotGrav version
                            plotGrav('get_atmacs','data_a',in{1},char(in(2)),'');
                        elseif length(in) == 3 && ~strcmpi(in{1}(1),'d')% old version
                            plotGrav('get_atmacs','data_a',in{1},in{2},in{3}); 
                        elseif length(in) == 3 && strcmpi(in{1}(1),'d')% new version
                            plotGrav('get_atmacs','data_a',in{1},in{2},in{3},''); 
                        elseif length(in) == 4
                            plotGrav('get_atmacs',lower(in{1}),in{2},char(in(3)),char(in(4)));
                        end
                    end
                %% Correction file (apply or show)
                case 'CORRECTION_FILE'
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');                                 % two (old) or three (new) inputs expected
                    if ~strcmp(char(in(1)),'[]')
                        if length(in) == 2                                  % two inputs expected = old version (back-compatibility)
                            if strcmp(char(in(2)),'1')                      % 1 == apply correction
                                plotGrav('correction_file','data_a',char(in(1))); 
                            elseif strcmp(char(in(2)),'2')                  % 2 == apply to selected channel
                                plotGrav('correction_file_selected',char(in(1))); 
                            elseif strcmp(char(in(2)),'3')                  % 3 == show correctors
                                plotGrav('correction_file_show',char(in(1))); 
                            end
                        elseif length(in) == 3                              % new plotGrav version with 'data_x' switch
                            if strcmp(char(in(3)),'1')                      % 1 == apply correction
                                plotGrav('correction_file',lower(char(in(1))),char(in(2))); 
                            end
                        end
                    end
                %% Remove spikes
                case 'REMOVE_SPIKES'                                        % remove spikes using standard deviation*input as condition
                    row = fgetl(fid);count = count + 1;                     % only one input expected = number to multiply the standard deviation.
                    if ~strcmp(char(row),'[]')
                        plotGrav('remove_Xsd',char(row));
                    end
                case 'REMOVE_RANGE'                                         % remove spikes using a range
                    row = fgetl(fid);count = count + 1;                     % only one input expected = [min max] range
                    if ~strcmp(char(row),'[]')
                        plotGrav('remove_set',char(row));
                    end
                case 'REPLACE_RANGE'                                        % replace spikes using a range and new value
                    row = fgetl(fid);count = count + 1;                     % only one input expected = [min max];newvalue. Will be processed in main plotGrav code
                    if ~strcmp(char(row),'[]')
                        plotGrav('replace_range_by',char(row));
                    end
                %% Remove missing/NaN data
                case 'REMOVE_MISSING'   
                    row = fgetl(fid);count = count + 1;                     % only one input expected = maximum time interval in seconds.
                    if ~strcmp(char(row),'[]')
                        plotGrav('interpolate_interval_auto',char(row));
                    end
                %% Interpolate between two points
                case 'INTERP_INTERVAL'   
                    row = fgetl(fid);count = count + 1;                     
                    if ~strcmp(char(row),'[]')
                        in = strsplit(row,';');                                 % two inputs expected (starting and end date)
                        plotGrav('interpolate_interval_linear',in{1},in{2});
                    end
                %% Filter channels
                case 'FILTER_SELECTED'                                      % will filter selected channels
                    plotGrav('compute_filter_channel',char(row));                       % no input required
                    row = fgetl(fid);count = count + 1;   
                %% Introduce time shift
                case 'TIME_SHIFT'                                           % will affect only selected channels!
                    row = fgetl(fid);count = count + 1;                     % only one input expected = time shift in seconds
                    if ~strcmp(char(row),'[]')
                        plotGrav('compute_time_shift',char(row));           % call time shift function
                    end
                %% Resample all time series to new resolution
                case 'RESAMPLE_ALL'
                    row = fgetl(fid);count = count + 1;                     % only one input expected = time resolution in seconds
                    if ~strcmp(char(row),'[]')
                        plotGrav('compute_decimate',char(row));
                    end
                %% Resample time series of Selected panel
                case 'RESAMPLE_SELECT'
                    row = fgetl(fid);count = count + 1;                     % 2 input values expected = panel;time resolution in seconds
                    if ~strcmp(char(row),'[]')
                        row = strsplit(row,';');
                        plotGrav('compute_decimate_select',lower(row{1}),row{2})
                    end 
                    row = row{1};
                %% Correct time vector = remove ambiguities
                case 'REMOVE_AMBIGUOUS'
                    row = fgetl(fid);count = count + 1;                     % 1 input values expected = panel
                    if ~strcmp(char(row),'[]')
                        plotGrav('compute_remove_ambiguities',lower(row))
                    end 
                %% Channels algebra
                case 'CHANNELS_ALGEBRA'
                    row = fgetl(fid);count = count + 1;                     % only one input expected = mathematical expression
                    if ~strcmp(char(row),'[]')
                        plotGrav('simple_algebra',char(row));
                    end
                %% Regression analysis
                case 'REGRESSION'
                    row = fgetl(fid);count = count + 1;                     % only one input expected = mathematical expression (response = predictors)
                    if ~strcmp(char(row),'[]')
                        plotGrav('regression_simple',char(row));
                    end
                %% Polynomial fit
                case 'FIT_POLYNOMIAL'
                    row = fgetl(fid);count = count + 1;                     % variable input. Either one number of set of numbers
                    if ~strcmp(char(row),'[]')
                        st = strsplit(row,';');                             % try to split in case set of numbers on input
                        switch char(st(1))
                            case '0'
                                plotGrav('fit_constant',char(row));
                            case '1'
                                plotGrav('fit_linear',char(row));
                            case '2'
                                plotGrav('fit_quadratic',char(row));
                            case '3'
                                plotGrav('fit_cubic',char(row));
                            case 'SET'
                                % User defines the polynomial coefficients.
                                % It is necessary to convert the delimeter
                                % from ; to space as this is the standard
                                % input delimeter in plotGrav GUI
                                set_char = char(st(2)); % start with first input (st(1) = 'SET')
                                for i = 3:length(st) 
                                    set_char = [set_char,' ',char(st(i))]; % append remaining (if available) input values.
                                end
                                plotGrav('fit_user_set',set_char);
                        end
                    end
                %% Correlation analysis
                case 'CORRELATION_SIMPLE'
                    plotGrav('correlation_matrix')                          % no input expected
                    row = fgetl(fid);count = count + 1;                     % 
                    
                %% Cross-Correlation analysis
                case 'CORRELATION_CROSS'
                    row = fgetl(fid);count = count + 1;                     % only one input expected = maximum lag time in seconds
                    if ~strcmp(char(row),'[]')
                        plotGrav('correlation_cross',char(row));
                    end
                %% Statistics
                case 'STATISTICS'
                    plotGrav('compute_statistics')                          % no input expected. Compute statistics for selected channels.
                    row = fgetl(fid);count = count + 1;                     % 
                %% Spectral analysis
                case 'SPECTRAL_ANALYSIS'
                    row = fgetl(fid);count = count + 1;                     % read switch between 
                    if ~strcmp(char(row),'[]')
                        st = strsplit(row,';');                             % try to split in case set of numbers on input
                        switch char(st(1))
                            case '1'
                                plotGrav('compute_spectral_valid');
                            case '2'
                                plotGrav('compute_spectral_interp');
                            case '3'
                                plotGrav('compute_spectral_evolution',char(st(2)));
                        end
                    end
                %% Derivative
                case 'DERIVE_DIFFERENCE'
                    plotGrav('compute_derivative')                          % no input expected. Compute differences of selected file
                    row = fgetl(fid);count = count + 1;                     % 
                %% Cumulative sum
                case 'DERIVE_CUMSUM'
                    plotGrav('compute_cumsum')                              % no input expected. Compute cumulative sum of selected file
                    row = fgetl(fid);count = count + 1;                     % 
                %% View: fonts, labels, legends, grid
                case 'SET_DATE_FORMAT'                                      % set date format = x tick labels
                    row = fgetl(fid);count = count + 1;                     % only one input expected = date format (e.g., yyyy)
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_date_1',char(row));
                    end 
                case 'SET_FONT_SIZE'
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_font_size',char(row));
                    end 
                case 'SET_PLOT_DATE'                                        % range for all x axes
                    row = fgetl(fid);count = count + 1;
                    in = strsplit(row,';');                                 % two inputs expected = starting and ending date
                    if ~strcmp(char(in(1)),'[]')                            % two inputs expected = starting and ending date
                        % Check if user set date or range
                        if length(char(in(1))) <= 12
                            temp1 = now;
                            temp1 = datevec(temp1+str2double(in(1)));  % Start. use + as input starts with minus sign!
                        else
                            temp1 = str2double(strsplit(char(in(1)),' '));
                        end
                        if length(char(in(2))) <= 12
                            temp2 = now;
                            temp2 = datevec(temp2+str2double(in(2)));  % Stop. use + as input starts with minus sign!
                        else
                            temp2 = str2double(strsplit(char(in(2)),' '));
                        end
                        plotGrav('push_zoom_in_set',sprintf('%4d %02d %02d 00 00 00',temp1(1),temp1(2),temp1(3)),... % do not set hours minutes and seconds.
                                 sprintf('%4d %02d %02d 00 00 00',temp2(1),temp2(2),temp2(3)));
                    end 
                case 'SET_TICK_X'                                               % number of ticks on x axes
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_num_of_ticks_x',char(row));
                    end 
                case 'SET_TICK_Y'                                               % number of ticks on y axes
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_num_of_ticks_y',char(row));
                    end 
                case 'SET_PLOT_Y_RANGE'                                         % range for Y axes.
                    row = fgetl(fid);count = count + 1;                         % multiple one inputs expected = 6 y axis * 2 values (min max)
                    in = strsplit(row,';');
                    % L1
                    if ~strcmp(char(in(1)),'[]')
                        plotGrav('set_y_L1',char(in(1)));
                    end
                    % R1
                    if ~strcmp(char(in(2)),'[]')
                        plotGrav('set_y_R1',char(in(2)));
                    end
                    % L2
                    if ~strcmp(char(in(3)),'[]')
                        plotGrav('set_y_L2',char(in(3)));
                    end
                    % R2
                    if ~strcmp(char(in(4)),'[]')
                        plotGrav('set_y_R2',char(in(4)));
                    end
                    % L3
                    if ~strcmp(char(in(5)),'[]')
                        plotGrav('set_y_L3',char(in(5)));
                    end
                    % R3
                    if ~strcmp(char(in(6)),'[]')
                        plotGrav('set_y_R3',char(in(6)));
                    end
                case 'SHOW_GRID'
                    row = fgetl(fid);count = count + 1;                         % one inputs expected = 0== off, 1 == on.
                    if ~strcmp(char(row),'[]')
                        if strcmp(char(row),'0')
                            set(findobj('Tag','plotGrav_check_grid'),'Value',0);
                        elseif strcmp(char(row),'1')
                            set(findobj('Tag','plotGrav_check_grid'),'Value',1);
                        end
                        plotGrav('uitable_push');                               % Re-plot
                    end
                case 'SHOW_LABEL'
                    row = fgetl(fid);count = count + 1;                         % one inputs expected = 0== off, 1 == on.
                    if ~strcmp(char(row),'[]')
                        if strcmp(char(row),'0')
                            set(findobj('Tag','plotGrav_check_labels'),'Value',0);
                        elseif strcmp(char(row),'1')
                            set(findobj('Tag','plotGrav_check_labels'),'Value',1);
                        end
                        plotGrav('uitable_push');                               % Re-plot
                    end
                case 'SHOW_LEGEND'
                    row = fgetl(fid);count = count + 1;                         % one inputs expected = 0== off, 1 == on.
                    if ~strcmp(char(row),'[]')
                        if strcmp(char(row),'0')
                            set(findobj('Tag','plotGrav_check_legend'),'Value',0);
                        elseif strcmp(char(row),'1')
                            set(findobj('Tag','plotGrav_check_legend'),'Value',1);
                        end
                        plotGrav('uitable_push');                               % Re-plot
                    end
                %% Set Y labels
                case 'SET_LABEL_Y'                                              % set temporary y labels
                    row = fgetl(fid);count = count + 1;                         % multiple one inputs expected = 6 y axis
                    in = strsplit(row,';');
                    % L1
                    if ~strcmp(char(in(1)),'[]')
                        plotGrav('set_label','L1',char(in(1)));
                    end
                    % R1
                    if ~strcmp(char(in(2)),'[]')
                        plotGrav('set_label','R1',char(in(2)));
                    end
                    % L2
                    if ~strcmp(char(in(3)),'[]')
                        plotGrav('set_label','L2',char(in(3)));
                    end
                    % R2
                    if ~strcmp(char(in(4)),'[]')
                        plotGrav('set_label','R2',char(in(4)));
                    end
                    % L3
                    if ~strcmp(char(in(5)),'[]')
                        plotGrav('set_label','L3',char(in(5)));
                    end
                    % R3
                    if ~strcmp(char(in(6)),'[]')
                        plotGrav('set_label','R3',char(in(6)));
                    end
                %% Set legends
                case 'SET_LEGEND'                                               % set temporary legend
                    row = fgetl(fid);count = count + 1;                         % multiple one inputs expected = 6 y axis
                    in = strsplit(row,';');
                    % L1
                    if ~strcmp(char(in(1)),'[]')
                        plotGrav('set_legend','L1',char(in(1)));
                    end
                    % R1
                    if ~strcmp(char(in(2)),'[]')
                        plotGrav('set_legend','R1',char(in(2)));
                    end
                    % L2
                    if ~strcmp(char(in(3)),'[]')
                        plotGrav('set_legend','L2',char(in(3)));
                    end
                    % R2
                    if ~strcmp(char(in(4)),'[]')
                        plotGrav('set_legend','R2',char(in(4)));
                    end
                    % L3
                    if ~strcmp(char(in(5)),'[]')
                        plotGrav('set_legend','L3',char(in(5)));
                    end
                    % R3
                    if ~strcmp(char(in(6)),'[]')
                        plotGrav('set_legend','R3',char(in(6)));
                    end
                %% Set line width
                case 'SET_LINE_WIDTH'
                    row = fgetl(fid);count = count + 1;                         % one inputs expected = six numbers in one string
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_line_width',char(row));
                    end 
                case 'SET_DATA_POINTS' 											% set data points to be plotted
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_data_points',char(row));
                    end 
                %% Set plot type
                case 'SET_PLOT_TYPE'
                    row = fgetl(fid);count = count + 1;                     % read plot type switch vector
                    if ~strcmp(char(row),'[]')
                        plotGrav('set_plot_type',char(row));
                    end 
                %% Set new channel names
                case 'SET_CHANNELS_DATA_A'                                       % sets new channel names and update the ui-table of DATA A
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_names_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_names','data_a',char(row));
                    end 
                case 'SET_CHANNELS_DATA_B'                                       % sets new channel names and update the ui-table of DATA B
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_names_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_names','data_b',char(row));
                    end 
                case 'SET_CHANNELS_DATA_C'                                       % sets new channel names and update the ui-table of DATA C
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_names_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_names','data_c',char(row));
                    end 
                case 'SET_CHANNELS_DATA_D'                                       % sets new channel names and update the ui-table of DATA D
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_names_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_names','data_d',char(row));
                    end 
                %% Set new channel units
                case 'SET_UNITS_DATA_A'                                          % sets new channel units and update the ui-table of DATA A
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_names_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_units','data_a',char(row));
                    end 
                case 'SET_UNITS_DATA_B'                                        % sets new channel units and update the ui-table of DATA B
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_units_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_units','data_b',char(row));
                    end 
                case 'SET_UNITS_DATA_C'                                         % sets new channel units and update the ui-table of DATA C
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_units_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_units','data_c',char(row));
                    end 
                case 'SET_UNITS_DATA_D'                                         % sets new channel units and update the ui-table of DATA D
                    row = fgetl(fid);count = count + 1;                         % one inputs expected. The string splitting will be performed within plotGrav/'edit_channel_units_data_a'
                    if ~strcmp(char(row),'[]')
                        plotGrav('edit_channel_units','data_d',char(row));
                    end 

                %% Load data
                case 'LOAD_DATA'
                    plotGrav('load_all_data')                                   % push load data button. No further input (now row) needed
                    row = fgetl(fid);count = count + 1;
                %% Remove data
                case 'REMOVE_DATA'                                              % this will remove all data and re-set ui tables. Settings, howerver, will not be affected!
                    plotGrav('reset_tables')                                    % No input expected => No further input (now row) needed
                    row = fgetl(fid);count = count + 1;
                %% Remove channels
                case 'REMOVE_CHANNEL'                                       % remove required channels
                    row = fgetl(fid);count = count + 1;
                    chan = strsplit(row,';');                               % multiple input possible = selected channels
                    if ~strcmp(char(chan),'[]')                             % proceed/set only if required
                        data_table_data_a = get(findobj('Tag','plotGrav_uitable_data_a_data'),'Data'); % get the A ui-table.
                        data_table_data_b = get(findobj('Tag','plotGrav_uitable_data_b_data'),'Data'); % get the B ui-table.
                        data_table_data_c = get(findobj('Tag','plotGrav_uitable_data_c_data'),'Data'); % get the C ui-table.
                        data_table_data_d = get(findobj('Tag','plotGrav_uitable_data_d_data'),'Data'); % get the D ui-table.
                        % First, uncheck all channels so channels selected
                        % prior to calling this part will NOT be deleted
                        for i = 1:size(data_table_data_a,1)
                            data_table_data_a(i,1) = {false};
                        end
                        for i = 1:size(data_table_data_b,1)
                            data_table_data_b(i,1) = {false};
                        end
                        for i = 1:size(data_table_data_c,1)
                            data_table_data_c(i,1) = {false};
                        end
                        for i = 1:size(data_table_data_d,1)
                            data_table_data_d(i,1) = {false};
                        end
                        
                        % Run for all input values
                        for i = 1:length(chan) 
                            if length(chan{i}) >= 2 % the input for each selection must be at least 2 character long (panel+channel number)
                                channel_number = str2double(char(chan{i}(2:end))); % get the channel number
                                switch char(chan{i}(1)) % switch between panels
                                    case 'A' % A == iGrav
                                        if channel_number <= size(data_table_data_a,1) % check if required channel exists
                                            data_table_data_a(str2double(chan{i}(2:end)),1) = {true}; % select the channel as given on input
                                        end
                                    case 'B' % B == data_b
                                        if channel_number <= size(data_table_data_b,1) % check if required channel exists
                                            data_table_data_b(str2double(chan{i}(2:end)),1) = {true}; % select the channel as given on input
                                        end
                                    case 'C' % C == Other1
                                        if channel_number <= size(data_table_data_c,1) % check if required channel exists
                                            data_table_data_c(str2double(chan{i}(2:end)),1) = {true}; % select the channel as given on input
                                        end
                                    case 'D' % D == Other2
                                        if channel_number <= size(data_table_data_d,1) % check if required channel exists
                                            data_table_data_d(str2double(chan{i}(2:end)),1) = {true}; % select the channel as given on input
                                        end
                                end
                            end
                        end
                        set(findobj('Tag','plotGrav_uitable_data_a_data'),'Data',data_table_data_a); % update ui-table
                        set(findobj('Tag','plotGrav_uitable_data_b_data'),'Data',data_table_data_b); % update ui-table 
                        set(findobj('Tag','plotGrav_uitable_data_c_data'),'Data',data_table_data_c); % update ui-table
                        set(findobj('Tag','plotGrav_uitable_data_d_data'),'Data',data_table_data_d); % update ui-table
                        % The plotGrav 'compute_remove_channel' removes 
                        % automatically all selected channels
                        plotGrav('compute_remove_channel');                 % Call removing function
                    end
                %% Pause
                case 'PAUSE'                                                % pauses the compuation for a required number of seconds
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        pause(str2double(row));
                    end 
                case 'RESET_VIEW'                                           % zoom out to whole time series.
                    plotGrav('reset_view');                                 % no input.
                    row = fgetl(fid);count = count + 1;
                %% Show Earthquakes
                case 'SHOW_EARTHQUAKES'                                     % plot last 20 earthquakes
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        plotGrav('plot_earthquake',row)
                    end 
                %% Append channels
                case 'APPEND_CHANNELS'
                    row = fgetl(fid);count = count + 1;
                    if ~strcmp(char(row),'[]')
                        row = strsplit(row,';');
                        plotGrav('append_channels',lower(row{1}),row{2})
                    end 
                    row = row{1};
                %% Visibility
                % Somethime is is preferable to do not show the plotGrav GUI
                % (like when running on server).
                case 'GUI_OFF'
                    set(findobj('Tag','plotGrav_main_menu'),'Visible','off');   % turn of visibility
                    row = fgetl(fid);
                case 'GUI_ON'
                    set(findobj('Tag','plotGrav_main_menu'),'Visible','on');    % turn of visibility
                    row = fgetl(fid);
                case 'SCRIPT_END'
                    break
                otherwise
                    row = fgetl(fid);count = count + 1; 
            end
        else
            row = fgetl(fid);count = count + 1; 
        end

    end
    pause(1);
    set(findobj('Tag','plotGrav_edit_text_input'),'Visible','off');             % in case some command has forgotten to turn of the GUI input fields
    set(findobj('Tag','plotGrav_text_input'),'Visible','off');
    set(findobj('Tag','plotGrav_text_status'),'String','Script finished.');
    t = toc;
    [ty,tm,td,th,tmm] = datevec(now);fprintf(fid_log,'Script finished. Duration = %6.1f sec., input file: %s (%04d/%02d/%02d %02d:%02d)\n',t,in_script,ty,tm,td,th,tmm);
    fclose(fid);
    fclose(fid_log);
catch error_message
    set(findobj('Tag','plotGrav_edit_text_input'),'Visible','off');             % in case some command has forgotten to turn of the GUI input fields
    set(findobj('Tag','plotGrav_text_input'),'Visible','off');
    set(findobj('Tag','plotGrav_text_status'),'String',sprintf('An error at line %3.0f occured during script run.',count));
    t = toc;
    [ty,tm,td,th,tmm] = datevec(now);fprintf(fid_log,'An error at line %3.0f occurred during script run: %s. Duration = %6.1f sec., input file: %s (%04d/%02d/%02d %02d:%02d)\n',count,char(error_message.message),t,in_script,ty,tm,td,th,tmm);
    fclose(fid);
    fclose(fid_log);
end

end % Function