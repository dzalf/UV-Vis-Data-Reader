  %  ******************** nanofunctional materials group *********************
  %
  % File: UV-vis-loader.m
  % Brief:  Data import, experiment merging, plotting and logging into csv files
  %         for uv-vis system. we use color schemes for plotting.
  % Author: Dr. Daniel Melendrez
  % Date: Oct 2023
  % Version: 1.0
  %
  % Cleanup our environment

  clc
  clear
  close all % --> uncomment line if you want to keep plots open

  pkg load signal  % needed for peak finding
  pkg load io      % needed for csv writing
  addpath(sprintf("%s\\%s", pwd(),"libs"))  %include helper modules/libs

  header_asteriscs = "***********************************************";

  printf("\r\n%s\r\n", header_asteriscs);
  printf('Uv-Vis Spectra loader, processor and plotter\n');
  printf("%s\r\n", header_asteriscs);

  session_name = [];
  default_session = {"UV-Vis Spectra"};

  session_name = inputdlg (sprintf("Provide a session name: [default = ""%s""]",...
  default_session{1}),...
  "session name",[1,20], default_session);

  if isempty(session_name)

    session_name = default_session{1};

  elseif strcmp(session_name{1}, '')

    session_name = default_session;

  endif

  % Import multiple csv files (from the same experiment)
  %msg_handle = msgbox ("Please select a group of .csv files from the\
  %same experiment...", "Files selection", 'warn');

  %waitfor(msg_handle)

  printf("\r\n%s\r\n", header_asteriscs);
  printf('Selecting a group of .txt files to work on...\n');
  printf("%s\r\n", header_asteriscs);

  [files, pathname] = uigetfile('*.csv', "Select a group of .csv files\
  [from the same experiment]", 'multiselect', 'on');

  keep_going = false;   % flag to stop operation

  if isequal(files,0)

    printf("\r\n%s\r\n", header_asteriscs);
    fprintf('\r\nOperation cancelled!\n')

    err = errordlg("Opening files cancelled", "cancelled");

    waitfor(err)

  else

    filenames = cellstr(files);

    [~,total_sets] = size(filenames) ; % count how many files were imported

    disp(['User selected  ' num2str(total_sets) ' files:'])

    keep_going = true;

    for idx=1:total_sets

      disp(filenames{idx})

    end

  endif

  % stop if user did not select anything
  if isequal(keep_going, true)

    peaks_vals = cell(1, total_sets);
    peaks_pos = cell(1, total_sets);
    peaks_extras = cell(1, total_sets);

    % loop over the files we collected and transfer data
    for set_idx = 1:total_sets

      % here we just extract the number of rows we will process
      file{set_idx} = char(filenames(set_idx));

      % temporarily store data before transfering it to our data_matrix
      data = dlmread(strcat(pathname, file{set_idx}), ",");

      % extract range where data begins --> using custom function
      % --> this is necessary because the csv reader fills zeros
      % in the rows where the header info is located
      [start_pos{set_idx}, dims{set_idx}] = range_finder(data);

      % set how many rows and columns our data has
      non_zeros(set_idx) = dims{set_idx}(1);
      rows(set_idx) = dims{set_idx}(2);
      cols(set_idx) = dims{set_idx}(3);

    end

    % verify if the total number of rows is identical to be able to continue
    % -> all data files must have same length

    keep_going = false;

    if isequal(range(non_zeros), 0)

      keep_going = true;

    else

      fprintf("\n%s\r\n", header_asteriscs);

      disp("Error processing files!")

      for idx =1:total_sets

        printf("File >> %s. Elements: %d\n", filenames{idx}, non_zeros(idx));

      endfor

      h = errordlg ("Data files have incompatible dimensions.\n \
      please select new set", "Data range error!");

    endif

    % Request peak threshold
    peak_thres_str = {};

    while (isempty(peak_thres_str))

      peak_thres_str = inputdlg ("Provide a minimum peak height:",...
      "Peak Heigth threshold",[1,10]);

      % If we are able to parse value into a double, continue
      if ~isnan(str2double(peak_thres_str))

        peak_threshold = str2double(peak_thres_str);
        break;

      else

        peak_thres_str = {};

      endif

    endwhile

  endif

  % proceed if data has the same length
  if isequal(keep_going, true)

    max_rows = max(non_zeros);

    % create data holder for all experiments
    data_matrix = zeros(max_rows,total_sets + 1);

    % transfer first column --> wavelength values
    % we assume that the start position of the wavelength values is the same
    % --> might be wrong!
    # todo: error here --> starting values are not at the same position
    data_matrix(:,1) = data(start_pos{set_idx}:rows(set_idx),1);

    % extract wavelength column
    wn = data_matrix(:,1);

    colptr = 2;   % column pointer to transfer columns --> experimental data

    printf("\r\n%s\r\n", header_asteriscs);

    % now just join the columns from the different files
    for file_idx = 1:total_sets

      fprintf('\r\nWorking with file %s: %s\n', num2str(file_idx),...
      filenames{file_idx});

      file = char(filenames(file_idx));

      % open next file and import csv data
      mat_temp = dlmread(strcat(pathname,file), ",");

      data_matrix(:,colptr) = mat_temp(start_pos{file_idx}:end,2);

      % Find data peaks
      fprintf("Finding peaks...\r\n");

      [pks, pks_loc, pks_ext] = findpeaks(data_matrix(:,colptr),...
      "DoubleSided",...
      "MinPeakHeight", peak_threshold);

      peaks_vals(:,file_idx) = pks;
      peaks_pos(:, file_idx) = pks_loc;
      peaks_extras(:, file_idx) = pks_ext;

      colptr = colptr+1;

    end

    % Report peaks in the console
    printf("\r\n%s\r\n", header_asteriscs);
    fprintf("Peaks with a height of %.2f found at: \r\n\n", peak_threshold);
    # fprintf("⎡Data Set >>\n⎥Wavelengths >> \n⎣Heights >> \r\n");

    for idx = 1:total_sets

      fprintf("╔Set >>\t");

      peaks_indices = peaks_pos{:,idx};
      peaks_wavelength = wn(peaks_pos{:,idx});
      peaks_values = data_matrix(peaks_indices, idx+1);

      fprintf("%s\r\n", filenames{idx});
      fprintf("║WL  >>\t");
      # Print wavelength locations on the top row
      for pk_idx=1:length(peaks_wavelength)

        fprintf("%d", peaks_wavelength(pk_idx));

        % Print separators
        if (pk_idx < length(peaks_wavelength))
          fprintf(" ¦ ");
        else
          fprintf("\n");
        endif

      endfor

      # Print peak heights
      fprintf("╚H   >>\t");
      for pk_idx=1:length(peaks_values)

        fprintf("%0.3f", peaks_values(pk_idx));

        % Print separators
        if (pk_idx < length(peaks_values))
          fprintf(" ¦ ");
        else
          fprintf("\n");
        endif

      endfor

      fprintf("\r\n");

    endfor

    # ****************************
    #       Data import done!
    # ****************************
    printf("\n%s\n", header_asteriscs);
    fprintf("Now plotting data...")
    printf("\n%s\r\n", header_asteriscs);

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

    {"Blues",
    "BuGn",
    "BuPu",
    "GnBu",
    "Greens",
    "Greys",
    "OrRd",
    "Oranges",
    "PuBu",
    "PuBuGn",
    "PuRd",
    "Purples",
    "RdPu",
    "Reds",
    "YlGn",
    "YlGnBu",
    "YlOrBr",
    "YlOrrD"}
    };

    keep_going = false;

    cat = [];
    cat = listdlg ("ListString", scheme_labels, ...
    "name", "Select Color scheme category for plotting",...
    "SelectionMode", "single", ...
    "promptstring",  "Select one category:",...
    "ListSize", [300 80]);

    if ~isempty(cat)

      keep_going = true;

    endif

    if isequal(keep_going, true)

      sch = [];
      sch = listdlg ("liststring", schemes(cat, :), ...
      "name", "select color scheme for plotting",...
      "selectionmode", "single", ...
      "promptstring",  sprintf("select one item from ""%s"" scheme",...
      scheme_labels{cat}),...
      "listsize", [300 150]);

      if ~isempty(sch)

        color_scheme = schemes{cat}{sch};

      else

        wrn_hand = warndlg("no scheme item selected. applying qualitative-dark2->[2,2]");
        waitfor(wrn_hand);

        color_scheme = schemes{2}{2};

      endif

    else

      wrn_hand = warndlg("no scheme category selected. applying qualitative-dark2->[2,2]");
      waitfor(wrn_hand);

      color_scheme = schemes{2}{2}

    endif

    % define some distinguishable colors according to the following schemes:
    % diverging | qualitative | sequential
    % for more information, please read brewermap.m

    % Diverging | Qualitative | Sequential
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

    % plot our results on the same graph
    figure

    schemes = brewermap(total_sets, color_scheme);
    colorptr = 1;

    spectra_handle = cell(1, total_sets);

    for col_idx=2:total_sets + 1

      % Plot data sets
      spectra_handle(col_idx-1) = plot(wn,data_matrix(:,col_idx), 'color',...
      schemes(colorptr, :), 'linewidth', 1.5);

      hold on

      % Plotting peaks
      peaks_indices = peaks_pos{:,col_idx-1};


      peaks_handle = plot(wn(peaks_indices), data_matrix(peaks_indices, col_idx), 'x',...
      "MarkerSize", 10,...
      "LineWidth", 1);

      set(peaks_handle, 'visible', 'on')

      colorptr = colorptr + 1;

    end

    grid on
    grid minor

    legendHandle = legend([spectra_handle{1, :}], filenames);
    set(legendHandle, "interpreter", "none");

    % plot title
    title(sprintf("Experimental results: %s", session_name{1}), 'fontsize',16);

    % create xlabel
    xlabel('Wavelength [nm]', 'fontsize',12);

    % create ylabel
    ylabel('Absorbance [arb. units]', 'fontsize',12);

    % ask user if data should be saved
    save_btn = questdlg ("Do you want to save .csv file?",...
    "Save file?", "Yeah", "Nope", "Yeah");

    % write csv in the same location as the incoming data
    if strcmp(save_btn, "Yeah")

      default_filenames = {"experiment"};
      desired_filenames = inputdlg ("give me a filenames:", "filename",...
      [1, 30], default_filenames);

      if isempty(desired_filenames)

        desired_filenames = {};
        desired_filenames{1} = default_filenames{1};

      elseif strcmp(desired_filenames{1}, '')

        desired_filenames = {};
        desired_filenames{1} = default_filenames{1};

      endif

      filenames = ['Wavelength', filenames];

      filenames_csv = sprintf("%s%s-%s_%s.csv",pathname, session_name{1}, ...
      desired_filenames{1}, strftime ("%d-%m-%Y_%H%M%S", localtime (time())));

      cell2csv(filenames_csv, filenames)
      dlmwrite (filenames_csv, data_matrix, "-append");

      printf("\r\n%s%s", header_asteriscs,header_asteriscs);
      fprintf("\nData saved as:\r\n %s", filenames_csv);
      printf("\r\n%s%s", header_asteriscs,header_asteriscs);


    else

      printf("\r\n%s\r\n", header_asteriscs);
      fprintf("\t%s\n","Data was not saved!\n\t(you can still save the plot)");
      printf("%s\r\n", header_asteriscs);

      # msg_handle = msgbox("Data was not saved! (you can still save the plot)",...
      # 'Data not saved', 'warn');
      # waitfor(msg_handle)

    endif



  else

    printf("\r\n%s\r\n", header_asteriscs);
    disp("No data to be processed...bye");
    printf("\n%s\r\n", header_asteriscs);

    endif
