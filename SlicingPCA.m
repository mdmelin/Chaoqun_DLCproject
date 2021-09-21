 function [] = SlicingPCA(overall_PCAmatrix, divide_mode, raw_data, plotting_idx)

global mouse_name   
mousename = mouse_name;

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
example_frame = overall_PCAmatrix(:,65,:,:);
example_frame = reshape(example_frame, [trialNum, coordinate*labelNum]);

PCAbase = pca(example_frame);       % factors = PCAmatrix * PCAbase
plotting_pause = 0.3;               % The plotting interval between two frames
factor_bin = reshape(overall_PCAmatrix(:,1,:,:), [trialNum, coordinate*labelNum]) * PCAbase;

%% 3D plotting
if plotting_idx(1) == 1
    figure;
    bin_plotting = scatter3(factor_bin(:,1),factor_bin(:,2),factor_bin(:,3),10,'filled','b');
    xlabel('PC 1');
    ylabel('PC 2');
    zlabel('PC 3');
    xlim([min(factor_bin(:,1))*2 max(factor_bin(:,1))*2]);
    ylim([min(factor_bin(:,2))*2 max(factor_bin(:,2))*2]);
    zlim([min(factor_bin(:,3))*2 max(factor_bin(:,3))*2]);
    title([mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials']);
    rotate3d on
    hold on
    pause(plotting_pause);
    
    for e = 2 : timespan
        example_frame = overall_PCAmatrix(:,e,:,:);
        example_frame = reshape(example_frame, [trialNum, coordinate*labelNum]);
        factor_bin = example_frame * PCAbase;
        
        set(bin_plotting,'XData',factor_bin(:,1),'YData',factor_bin(:,2),'ZData',factor_bin(:,3));
        
        if e == 2
            title(['Baseline, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials']);
        elseif e == 15
            title(['Stimulus On, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials']);
        elseif e == 45
            title(['Delay, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials']);
        elseif e == 60
            title(['Spout In, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials']);
        end
        drawnow;
        
        pause(plotting_pause);
    end
    
    hold off
end



%% 2D plotting with data grouping
if plotting_idx(2) == 1
    figure;
    overall_PCAmatrix_tem = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
    overall_PCAmatrix_tem = GroupData_Mouse(overall_PCAmatrix_tem, divide_mode, raw_data);
    trial_markers = overall_PCAmatrix_tem(:,end);
    factor_bin = [factor_bin, trial_markers];
    
    bin_plotting = gscatter(factor_bin(:,1),factor_bin(:,2),factor_bin(:,end),[],[],10);
    xlabel('PC 1');
    ylabel('PC 2');
    xlim([min(factor_bin(:,1))*2 max(factor_bin(:,1))*2]);
    ylim([min(factor_bin(:,2))*2 max(factor_bin(:,2))*2]);
    title([mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials, ', divide_mode]);
    hold on
    pause(plotting_pause);
    
    for e = 2 : timespan
        example_frame = overall_PCAmatrix(:,e,:,:);
        example_frame = reshape(example_frame, [trialNum, coordinate*labelNum]);
        factor_bin = example_frame * PCAbase;
        factor_bin = [factor_bin, trial_markers];
        
        PC1 = factor_bin(:,1);
        PC2 = factor_bin(:,2);
        markers = factor_bin(:,end);
        if ~isempty(find(markers == 0, 1))
            set(bin_plotting(1),'XData',PC1(markers == 0),'YData',PC2(markers == 0));
            set(bin_plotting(2),'XData',PC1(markers == 1),'YData',PC2(markers == 1));
        else
            set(bin_plotting(1),'XData',PC1(markers == 1),'YData',PC2(markers == 1));
            set(bin_plotting(2),'XData',PC1(markers == 2),'YData',PC2(markers == 2));
        end
        
        if length(bin_plotting)>2
            set(bin_plotting(3),'XData',PC1(markers == 2),'YData',PC2(markers == 2));
        end
        if length(bin_plotting)>3
            set(bin_plotting(4),'XData',PC1(markers == 3),'YData',PC2(markers == 3));
        end
        if length(bin_plotting)>4
            set(bin_plotting(5),'XData',PC1(markers == 4),'YData',PC2(markers == 4));
        end
        if length(bin_plotting)>5
            set(bin_plotting(6),'XData',PC1(markers == 5),'YData',PC2(markers == 5));
        end

        if e == 2
            title(['Baseline, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials, ', divide_mode]);
        elseif e == 15
            title(['Stimulus On, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials, ', divide_mode]);
        elseif e == 45
            title(['Delay, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials, ', divide_mode]);
        elseif e == 60
            title(['Spout In, ' , mousename, ', ', num2str(size(overall_PCAmatrix,1)),' trials, ', divide_mode]);
        end
        drawnow;
        
        pause(plotting_pause);
    end
    
    hold off
end


end