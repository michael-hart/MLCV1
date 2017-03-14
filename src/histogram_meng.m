function [ ] = histogram_meng( data, filename, the_title, k )
    % Plot and save confusion matrix.
    figure('position', [0 0 800 800]);
    bar(permute(data, [3 2 1]));
    axis([0 k+1 0 max(data)+1]);
    title(the_title);
    xlabel('Codeword Number');
    ylabel('Frequency');

    % Format data
    set(findall(gcf,'type','axes'),'fontsize',30);
    set(findall(gcf,'type','text'),'fontSize',30);
    % Save data
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    print(filename,'-dpng','-r0');
    close;
end

