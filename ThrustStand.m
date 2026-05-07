%---- ThrustStand (Victory Ulasi) ----
%% BAUDRATE = Number of signal changes per second in my case its Bits per Second (115200 bits/sec) / (8 bits/byte) = (14400 bytes/sec)
%% CSV Line is about 30 bytes (14400 bytes/sec) / (30 bytes) = (480 Lines/sec) *im only sending about 10 lines/sec

% Declerations
COM_PORT = "COM15";
BAUD_RATE = 115200;

% SerialPort
s = serialport(COM_PORT,BAUD_RATE);
s.configureTerminator("CR/LF"); % Line terminators from nucleo \r and \n
s.flush("input"); % Clear old inputs to get fresh data from serialport

% Read header
HEADER = readline(s);
disp(HEADER); % Make sure its current in console

DURATION = 30; % How long we want to get data
DATA = zeros((DURATION * 10 + 50),4); % Instantiate a matrix bigger than we need we will trim it later
idx = 0;

% Reading everything else Loop
tStart = tic;
while toc(tStart) <= DURATION % While the elapsed time is not greater than 30s keep reading

    unparsed_line = readline(s);
    vals = str2double(split(unparsed_line,',')); % Parse str and convert numbers to double and save in array

    if numel(vals) == 4 && ~any(isnan(vals)) % If any values are NAN we dont want that data because its bad data
        idx = idx + 1;
        DATA(idx , :) = vals'; % Transpose vals from row vector to column vector to add to data columns
    end

end

% Save to CSV
data = DATA(1:idx,:);
writematrix(data,"thrust_data.csv")
s.delete;

% Breaking down data matrix to more specified vectors
time_data = data(:,1) ./ (1000); % Data is in millisec, simple elementwise conversion to seconds
thrust_data = data(:,2);
voltage_data = data(:,3);
current_data = data(:,4);

% Calculations
power_data = voltage_data .* current_data; % Physics 2 P=IV
specific_thrust = zeros(size(thrust_data));
mask = power_data > 0.5; % Mask to ignore
specific_thrust(mask) = thrust_data(mask) ./ power_data(mask); % Thrust to Power Ratio

% Plots