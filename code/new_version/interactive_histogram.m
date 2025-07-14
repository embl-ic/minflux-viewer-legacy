function interactive_histogram(data)
    % Create example data if needed, replace with actual data in your application
    if isempty(data)
        data = randn(1, 1000);  % Random data for demonstration
    end
    
    % Create the figure and axes
    fig = figure('Name', 'Interactive Histogram', 'NumberTitle', 'off');%, 'WindowButtonDownFcn', @mouseClick);
    ax = axes(fig);
    
    % Create histogram
    histogram(ax, data, 'Normalization', 'pdf');  % Use PDF to show probability density
    hold(ax, 'on');
    
    minValue = 1e5;
    maxValue = 4e5;
    % Initialize lower and upper bounds using xline
    lower_bound = xline(minValue, 'r--', 'LineWidth', 1.5, ...
        'Label', 'Min', 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle', ...
        'buttonDownFcn', @startDragFcn);
    upper_bound = xline(maxValue, 'r--', 'LineWidth', 1.5, ...
        'Label', 'Max', 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle', ...
        'buttonDownFcn', @startDragFcn);
    

    cm = uicontextmenu(fig);
    uimenu(cm, "Text", "add to filter list", "MenuSelectedFcn", @add_to_table);
    uimenu(cm, "Text", "set min / max value", "MenuSelectedFcn", @set_value);
    uimenu(cm, "Text", "cancel", "MenuSelectedFcn", @delete_ROI);
    lower_bound.ContextMenu = cm;
    upper_bound.ContextMenu = cm;

    
    function add_to_table(~, ~)
        disp("add to table pushed");
        disp("min: " + lower_bound.Value);
        disp("max: " + upper_bound.Value);
    end

    function set_value(~, ~)
        prompt = {'Min value:', 'Max value:'}; % inclusive or exclusive
        title = 'set min / max values:';
        dims = [1, 45];
        definput = { num2str(lower_bound.Value, '%.2f'), num2str(upper_bound.Value, '%.2f') };
        answer = inputdlg(prompt, title, dims, definput);
        if isempty(answer)
            return;
        end
        lower_bound.Value = str2double(answer{1});
        upper_bound.Value = str2double(answer{2});
    end

    function delete_ROI(~, ~)
        clear_fig_button_Fcn();
        delete(lower_bound);
        delete(upper_bound);
    end
    % Set up the mouse motion and button release callbacks for drag functionality
    %set(fig, 'WindowButtonMotionFcn', '');
    %set(fig, 'WindowButtonUpFcn', '');
    
    function startDragFcn(src, ~)
        %f = src.Parent.Parent; % figure handle
        switch fig.SelectionType
            case 'normal'                                               % left click
                set(fig,'WindowButtonMotionFcn',{@draggingFcn, src});
            case 'alt'                                                  % right click
                clear_fig_button_Fcn();
                % show context menu
            case 'open'                                                 % double click
                clear_fig_button_Fcn();
                set_value();
                % open set value dialog
        end
    end
    

    function draggingFcn(~, ~, src_line)
        current_point = ax.CurrentPoint(1, 1); % Get the x-coordinate of the mouse click
        src_line.Value = current_point;
        src_line.Label = num2str(src_line.Value, '%.2e'); %strcat(extractBefore(src_line.Label, 4), ": ", num2str(src_line.Value, '%.2e'));
        set(fig, 'WindowButtonUpFcn', @stopDragging);
    end
    
    function stopDragging(~, ~)
        lower_bound.Label = "Min";
        upper_bound.Label = "Max";
        clear_fig_button_Fcn();
        % Display the final values of the bounds in the MATLAB console
        %disp(['Final Lower Bound: ', num2str(lower_bound.Value)]);
        %disp(['Final Upper Bound: ', num2str(upper_bound.Value)]);
    end
    
    function clear_fig_button_Fcn ()
        set(fig, 'WindowButtonMotionFcn', '');  % Clear the motion function
        set(fig, 'WindowButtonUpFcn', '');      % Clear the up function
    end


    % Nested functions
    % function mouseClick(~, ~)
    %     % Check if the mouse click is on any of the bounds
    %     current_point = ax.CurrentPoint(1, 1); % Get the x-coordinate of the mouse click
    %     %disp("current point to lower bounds: " + abs(current_point - lower_bound.Value));
    %     %disp("current point to upper bounds: " + abs(current_point - upper_bound.Value));
    %     if abs(current_point - lower_bound.Value) < 0.05  % Near lower bound
    %         %set(fig, 'WindowButtonMotionFcn', @dragLower);
    %         set(fig, 'WindowButtonUpFcn', @stopDragging);
    %     elseif abs(current_point - upper_bound.Value) < 0.05  % Near upper bound
    %         %set(fig, 'WindowButtonMotionFcn', @dragUpper);
    %         set(fig, 'WindowButtonUpFcn', @stopDragging);
    %     end
    % end

    % function dragLower(~, ~)
    %     % Drag lower bound
    %     disp("drag lower called");
    %     current_point = ax.CurrentPoint(1, 1); % Get current x position
    %     lower_bound.Value = current_point; % Update the position of the lower bound line
    %     lower_bound.Label.String = num2str(current_point, '%.2f');  % Update the label
    %     redraw_lines();  % Optionally redraw lines or update any visual cues
    % end
    % 
    % function dragUpper(~, ~)
    %     % Drag upper bound
    %     disp("drag upper called");
    %     current_point = ax.CurrentPoint(1, 1); % Get current x position
    %     upper_bound.Value = current_point; % Update the position of the upper bound line
    %     upper_bound.Label.String = num2str(current_point, '%.2f');  % Update the label
    %     redraw_lines();  % Optionally redraw lines or update any visual cues
    % end



    % function redraw_lines()
    %     % Optional function to redraw or update appearance of lines
    %     % This function can be used if you want to change aesthetics during dragging.
    %     % Currently, it does not change visuals but can be expanded.
    % 
    % end
end