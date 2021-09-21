function [] = DR_visualization_Mouse(DR_matrix, explained, trialNum, mode, divide_mode, plot_index)

global mouse_name
mousename = mouse_name;

if isequal(mode, 'movement')
    TITLE = ['The Movement PCA of ',mousename,', ',num2str(trialNum),' trials, ', divide_mode];
elseif isequal(mode, 'tsne')
    TITLE = ['The t-sne of ',mousename,', ',num2str(trialNum),' trials, ', divide_mode];
end


% Fig 1, the first two PCs
if plot_index(1) == 1
    figure;
    if isequal(divide_mode, 'opto') == 1
        gscatter(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,end),[],[],10);
        legend({'Control', 'Opto'});
        xlabel('PC 1');
        ylabel('PC 2');
        title(TITLE);
        hold off
        
        
    elseif isequal(divide_mode, 'optotype') == 1
        gscatter(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,end),[],[],10);
        legend({'Control', 'Stimulus onset', 'Delay onset', 'Response onset', '2nd half of stimulus', 'With baseline'});
        xlabel('PC 1');
        ylabel('PC 2');
        title(TITLE);
        hold off
        
        
    elseif isequal(divide_mode, 'outcome') == 1 || isequal(divide_mode, 'formeroutcome') == 1
        gscatter(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,end),[],[],10);
        idx = unique(DR_matrix(:,end));
        if length(idx) == 3
        legend({'No response', 'Correct', 'Wrong'});
        elseif length(idx) == 2
            if isempty(find(idx == 0, 1))
                legend({'Correct', 'Wrong'});
            end
        end
        xlabel('PC 1');
        ylabel('PC 2');
        title(TITLE);
        hold off
        
        
    elseif isequal(divide_mode, 'responseside') == 1 || isequal(divide_mode, 'formerresponseside') == 1
        gscatter(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,end),[],[],10);
        idx = unique(DR_matrix(:,end));
        if length(idx) == 3
            legend({'No response', 'Spout 1', 'Spout 2'});
        elseif length(idx) == 2
            if isempty(find(idx == 0, 1))
                legend({'Spout 1', 'Spout 2'});
            end
        end
        xlabel('PC 1');
        ylabel('PC 2');
        title(TITLE);
        hold off
        
        
    elseif isequal(divide_mode, 'random') == 1
        gscatter(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,end),[],[],10);
        legend({'Random Group 1', 'Random Group 2'});
        xlabel('PC 1');
        ylabel('PC 2');
        title(TITLE);
        hold off
    end
end


% Fig 2, 3D plotting
if plot_index(2) == 1
    figure;
    scatter3(DR_matrix(:,1),DR_matrix(:,2),DR_matrix(:,3),10,'filled');
    xlabel('PC 1');
    ylabel('PC 2');
    zlabel('PC 3');
    title(TITLE);
    rotate3d on
    hold off
end


% Fig 3, the explained variance
if plot_index(3) == 1
    figure;
    plot(explained, 'b-o');
    hold on
    plot(cumsum(explained), 'r-x');
    legend({'Per PC','Accumulated'});
    xlabel('Principal Component');
    ylabel('Explained Varience');
    title(TITLE);
    hold off
end


% Fig 4, the animation along time
if plot_index(4) > 0
    startfrom = round(plot_index(4));
    plotting_pause = 0.5;   % The plotting interval between two dots
    
    figure;
    old_dots = scatter3(DR_matrix(1:startfrom,1),DR_matrix(1:startfrom,2),DR_matrix(1:startfrom,3),10,'filled','b');
    xlabel('PC 1');
    ylabel('PC 2');
    zlabel('PC 3');
    xlim([min(DR_matrix(:,1))*1.05 max(DR_matrix(:,1))*1.05]);
    ylim([min(DR_matrix(:,2))*1.05 max(DR_matrix(:,2))*1.05]);
    zlim([min(DR_matrix(:,3))*1.05 max(DR_matrix(:,3))*1.05]);
    title(TITLE);
    rotate3d on
    hold on
    highlight_new = scatter3(DR_matrix(startfrom,1),DR_matrix(startfrom,2),DR_matrix(startfrom,3),30,'filled','r');
    pause(plotting_pause);
    for i = (startfrom+1) : size(DR_matrix,1)
        set(old_dots,'XData',DR_matrix(1:i,1),'YData',DR_matrix(1:i,2),'ZData',DR_matrix(1:i,3));
        drawnow;
        
        set(highlight_new,'XData',DR_matrix(i,1),'YData',DR_matrix(i,2),'ZData',DR_matrix(i,3));
        drawnow;
        pause(plotting_pause);
    end
    hold off
end

end