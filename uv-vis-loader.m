  %  ******************** Nanofunctional Materials Group *********************
  % File: uv-vis-loader.m
  % Brief:  Data import, experiment merging, plotting and logging into csv files
  %         for UV-Vis system. We use color schemes for plotting.
  % Author: Dr. Daniel Melendrez
  % Date: Oct 2023
  % Version: 1.0

  % Cleanup our environment
  clc
  clear
  % close all % --> uncomment line if you want to keep plots open

  header_asteriscs = "*******************************";

  session_name = [];
  default_session = {"UVvis"};

  session_name = inputdlg ("Provide a session name: [Default = ""UVvis""]", "Session name",[1,20], default_session);

  if or (isempty(session_name), strcmp(session_name{1}, ''))
    session_name = {"UVvis"};
  endif

  % Import multiple csv files (from the same experiment)
  msg_handle = msgbox ("Please select a group of .csv files from the\
  SAME experiment...", "Files selection", 'warn');

  waitfor(msg_handle)

  printf('Selecting a group of .txt files to work on...\n');

  [filename, pathname] = uigetfile('*.csv', "Select a group of .csv files\
  [from the SAME experiment]", 'MultiSelect', 'on');

  [~,elements] = size(filename);   % Count how many files were imported

  keep_going = false;   % Flag to stop operation

  if isequal(filename,0)

    fprintf('\r\nOperation cancelled!\n')

    err = errordlg("Opening files cancelled", "Cancelled");

    waitfor(err)

  else

    disp(['User selected  ' num2str(elements) ' files:'])

    keep_going = true;

    for idx=1:elements

      disp(filename{idx})

    end

  end


  % Stop if user did not select anything

  if isequal(keep_going, true)

    % loop over the files we collected and transfer data

    for element_idx = 1:elements

      % Here we just extract the number of rows we will process
      file{element_idx} = char(filename(element_idx));

      % temporarily store data before transfering it to our data_matrix
      data = dlmread(strcat(pathname, file{element_idx}), ",");

      % extract range where data begins --> using custom function
      % --> this is necessary because the csv reader fills zeros
      % in the rows where the header info is located
      [start{element_idx}, dims{element_idx}] = range_finder(data);

      % set how many rows and columns our data has
      rows(element_idx) = dims{element_idx}(1);
      cols(element_idx) = dims{element_idx}(2);

    end

    % Verify if the total number of rows is identical to be able to continue
    % -> all data files must have same length

    keep_going = false;

    if isequal(range(rows), 0)

      keep_going = true;

    else

      fprintf("%s\r\n", header_asteriscs);

      disp("Error processing files!")

      for idx =1:elements

        printf("File >> %s elements: %d\n", filename{idx}, rows(idx));

      end

      h = errordlg ("Data files have incompatible dimensions.\n \
      Please select new set", "Data range error!");

    endif

    % Proceed if data has the same length
    if isequal(keep_going, true)

      max_rows = max(rows);

      % Create data holder for all experiments
      data_matrix = zeros(max_rows,elements + 1);

      % Transfer first column --> wavelength values
      % we assume that the start position of the wavelength values is the same
      data_matrix(:,1) = data(start{3}:end,1);


      % Extract wavelength column
      wn = data_matrix(:,1);

      colPtr = 2;   % column pointer to transfer columns --> experimental data

      % Now just join the columns from the different files
      for file_idx = 1:elements

        fprintf('\nWorking with file %s: %s\r\n', num2str(file_idx), filename{file_idx});

        file = char(filename(file_idx));

        % open next file and import csv data
        mat_temp = dlmread(strcat(pathname,file), ",");

        data_matrix(:,colPtr) = mat_temp(start{file_idx}:end,2);

        colPtr = colPtr+1;

      end

      # ****************************
      #       Data import done!
      # ****************************

      fprintf("\r\nNow plotting data...")

      scheme_labels = {"Diverging", "Qualitative", "Sequential"};

      schemes = {
      {"BrBG",
      "PiYG",
      "PRGn",
      "PuOr",
      "RdBu",
      "RdGy",
      "RdYlBu",
      "RdYlGn",
      "Spectral"};

      {"Accent",
      "Dark2",
      "Paired",
      "Pastel1",
      "Pastel2",
      "Set1",
      "Set2",
      "Set3" };

      { "PuBuGn",
      "PuRd",
      "Purples",
      "RdPu",
      "Reds",
      "YlGn",
      "YlGnBu",
      "YlOrBr",
      "YlOrRd"}
      };

      keep_going = false;
      cat = [];

      cat = listdlg ("ListString", scheme_labels, ...
      "Name", "Select scheme category for plotting",...
      "SelectionMode", "Single", ...
      "PromptString",  "Select one category:",...
      "ListSize", [300 80]);

      if ~isempty(cat)

        keep_going = true;

      endif

      if isequal(keep_going, true)
        sch = [];

        sch = listdlg ("ListString", schemes(cat, :), ...
        "Name", "Select color scheme for plotting",...
        "SelectionMode", "Single", ...
        "PromptString",  sprintf("Select one item from ""%s"" scheme", scheme_labels{cat}),...
        "ListSize", [300 150]);

        if ~isempty(sch)

          color_scheme = schemes{cat}{sch};

        else

          wrn_hand = warndlg("No scheme item selected. Applying Qualitative-Dark2->[2,2]");
          waitfor(wrn_hand);

          color_scheme = schemes{2}{2};

        endif

      else

        wrn_hand = warndlg("No scheme category selected. Applying Qualitative-Dark2->[2,2]");
        waitfor(wrn_hand);

        color_scheme = schemes{2}{2}

      endif


      % Define some distinguishable colors according to the following schemes:
      % Diverging | Qualitative | Sequential
      % for more information, please read brewermap.m

      %  Diverging | Qualitative |  Sequential
      % ----------|-------------|------------------
      %  BrBG     |  Accent     |  Blues    PuBuGn
      %  PiYG     |  Dark2      |  BuGn     PuRd
      %  PRGn     |  Paired     |  BuPu     Purples
      %  PuOr     |  Pastel1    |  GnBu     RdPu
      %  RdBu     |  Pastel2    |  Greens   Reds
      %  RdGy     |  Set1       |  Greys    YlGn
      %  RdYlBu   |  Set2       |  OrRd     YlGnBu
      %  RdYlGn   |  Set3       |  Oranges  YlOrBr
      %  Spectral |             |  PuBu     YlOrRd

      # TODO: Create list dialog


      % Plot our results on the same graph
      figure
      hold on
      grid on
      grid minor

      schemes = brewermap(elements, color_scheme);
      colorPtr = 1;

      for col_idx=2:elements + 1

        plot(wn,data_matrix(:,col_idx), 'Color', schemes(colorPtr, :), 'LineWidth', 1.5);

        colorPtr = colorPtr + 1;

      end

      % Plot title
      title(sprintf("Experimental results: %s", session_name{1}), 'FontSize',16);

      % Create xlabel
      xlabel('Wavelength [nm]', 'FontSize',12);

      % Create ylabel
      ylabel('Amplitude [arb. units]', 'FontSize',12);

      hFig = legend(filename);
      set(hFig, "interpreter", "none");

      % Ask user if data should be saved
      btn = questdlg ("Do you want to save .csv file?",...
      "Save file?", "Yeah", "Nah", "Yeah");

      % Write csv in the same location as the incoming data
      if strcmp(btn, "Yeah")

        default_filename = {"experiment"};
        desired_filename = inputdlg ("Give me a filename:", "Filename", [1, 30], default_filename)

        if isempty(desired_filename)

          desired_filename = {};
          desired_filename{1} = default_filename{1};

        elseif strcmp(desired_filename{1}, '')

          desired_filename = {};
          desired_filename{1} = default_filename{1};

        endif

        filename_csv = sprintf("%s%s-%s_%s.csv",pathname, session_name{1}, ...
        desired_filename{1}, strftime ("%d-%m-%Y_%H%M%S", localtime (time ())));

        dlmwrite (filename_csv, data_matrix);

      else

        disp("Data was NOT saved! (you can still save the plot)");

        msg_handle = msgbox("Data was NOT saved! (you can still save the plot)",...
        'Data not saved', 'warn');

        waitfor(msg_handle)

      endif

    endif


  else

    disp("No data to be processed...Bye");

    endif
