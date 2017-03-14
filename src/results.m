function [ indices, class_actual, class_guesses, percentage ] = ...
    results(decision, labels, the_title, file_name )
% RESULTS Displays results

    % Wrong pics
    incorrect_vec = (decision ~= labels);
    incorrect = sum(incorrect_vec);
    correct = length(incorrect_vec) - incorrect;
    
    indices = find(incorrect_vec);
    class_guesses = decision(indices);
    class_actual = labels(indices);
    
    % Right or wrong stuff
    
    percentage = 100 * correct/(correct + incorrect);
    disp(['Guessed ' num2str(correct) ' correctly and ' ...
          num2str(incorrect) ' incorrectly; Success rate is ' ...
          num2str(percentage) '%.']);
    
    % Plot and save confusion matrix.
    figure('position', [0 0 800 800]);
    confuse_matrix = confusionmat(labels, decision);
    imagesc(confuse_matrix);
    colorbar;
    
    % Format data
    title(the_title, 'interpreter', 'latex');
    xlabel('Predicted Class');
    ylabel('Actual Class');

    % Format data
    set(findall(gcf,'type','axes'),'fontsize',30);
    set(findall(gcf,'type','text'),'fontSize',30);
    % Save data
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    print(file_name,'-dpng','-r0');

end

