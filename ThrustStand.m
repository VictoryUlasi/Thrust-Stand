%---- ThrustStand (Victory Ulasi) ----
%% BAUDRATE = Number of signal changes per second in my case its Bits per Second (115200 bits/sec) / (8 bits/byte) = (14400 bytes/sec)
%% CSV Line is about 30 bytes (14400 bytes/sec) / (30 bytes) = (480 Lines/sec) *im only sending about 10 lines/sec

% Declerations
COM_PORT = "COM15";
BAUD_RATE = 115200;

% SerialPort
s = serialport(COM_PORT,BAUD_RATE);
s.Timeout = 5; % wait up to 5 seconds for each line
s.configureTerminator("CR/LF"); % Line terminators from nucleo \r a nd \n
s.flush("input"); % Clear old inputs to get fresh data from serialport
disp('Reset Nucleo now...');
pause(3); % wait 3 seconds for you to reset
s.flush("input"); % flush again after reset

% Read header
HEADER = readline(s);
disp(HEADER); % Make sure its current in console

DURATION = 40; % How long we want to get data
DATA = zeros((DURATION * 10 + 50),4); % Instantiate a matrix bigger than we need we will trim it later
idx = 0;

% Reading everything else Loop
tStart = tic;
disp('Recording...') % Matlab Ready For Motor Start
wb = waitbar(0, 'Recording data...'); %Loadbar for DRAMATICS :)
while toc(tStart) <= DURATION % While the elapsed time is not greater than 30s keep reading
    try
        unparsed_line = readline(s);
        vals = str2double(split(unparsed_line,',')); % Parse str and convert numbers to double and save in array
    
        if numel(vals) == 4 && ~any(isnan(vals)) % If any values are NAN we dont want that data because its bad data
            idx = idx + 1;
            DATA(idx , :) = vals'; % Transpose vals from column vector to row vector to add to data columns
        end
        waitbar(toc(tStart) / DURATION, wb, sprintf('Recording... %.0f / %.0f s', toc(tStart), DURATION));
    catch
        % readline timed out, just continue
    end
end
close(wb);

% Save to CSV
data = DATA(1:idx,:);
writematrix(data,"thrust_data.csv")
s.delete;

% Breaking down data matrix to more specified vectors
time_data = data(:,1) ./ (1000); % Data is in millisec, simple elementwise conversion to seconds
time_data = time_data - time_data(1);
thrust_data = data(:,2);
voltage_data = data(:,3);
current_data = data(:,4);

% Calculations
power_data = voltage_data .* current_data; % Physics 2 P=IV
specific_thrust = zeros(size(thrust_data));
mask = power_data > 0.5; % Mask to ignore
specific_thrust(mask) = thrust_data(mask) ./ power_data(mask); % Thrust to Power Ratio

% Plots
figure;
subplot(4,1,1);
plot(time_data,thrust_data)
title('A2212 Motor Characterization - Thrust Stand')
grid on
ylabel("Thrust, g")

subplot(4,1,2);
plot(time_data,voltage_data)
grid on
ylabel("Voltage, V")
ylim([9 13])

subplot(4,1,3);
plot(time_data,current_data)
grid on
ylabel("Current, A")

% Small issue with the specific thrust data, the data that actually matters only lies between [0,30]
% At very low throttle the motor is spinning efficiently before it hits the high current regime. But it's misleading on the plot because it dominates the y axis.
% I decided to leave it alone
subplot(4,1,4);
plot(time_data,specific_thrust)
grid on
ylabel("Specific Thrust, g/W")
xlabel("time, s")
ylim([0 30])