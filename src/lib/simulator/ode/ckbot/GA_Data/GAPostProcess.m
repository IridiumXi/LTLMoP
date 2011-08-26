function GAPostProcess(filename)

    clc;

    % Open the files and convert them to an array of strings.
    f = fopen([filename '.genes']);
    G = textscan(f,'%s','delimiter','\n','whitespace','');
    G = G{:};
    fclose(f);
    f = fopen([filename '.poses']);
    P = textscan(f,'%s','delimiter','\n','whitespace','');
    P = P{:};
    fclose(f);
    
    % Extract all the values.
    TRAITS = cell2mat(G(1))
    POPULATION_SIZE = str2double(cell2mat(G(2)))
    GENERATIONS = str2double(cell2mat(G(3)))
    SIMULATION_STEPS = str2double(cell2mat(P(end-2)))
    BEST_ROW = str2double(cell2mat(P(end-1)))+1;
    BEST_COL = str2double(cell2mat(P(end)))+1;
    
    % For the G (Genes) array:
    % Every 2 rows is information for a single run:
    %       ROW 1: Gene
    %       ROW 2: Score
    
    % Scores matrix
    scores = zeros(GENERATIONS, POPULATION_SIZE);
    counter = 5;
    for i = 1:GENERATIONS
        for j = 1:POPULATION_SIZE
            scores(i,j) = str2double(cell2mat(G(counter)));
            counter = counter + 2;
        end
    end
    
    % Genes matrix
    % For each module: 
    % [ AMP1, whitespace, AMP2, whitespace, FREQ, whitespace, PHASE ]
    
    % For the P (Poses) array:\
    
    x = zeros(GENERATIONS, POPULATION_SIZE, SIMULATION_STEPS);
    y = zeros(GENERATIONS, POPULATION_SIZE, SIMULATION_STEPS);
    z = zeros(GENERATIONS, POPULATION_SIZE, SIMULATION_STEPS);
    theta = zeros(GENERATIONS, POPULATION_SIZE, SIMULATION_STEPS);
    counter = 1;
    for i = 1:GENERATIONS
        for j = 1:POPULATION_SIZE
            for k = 1:SIMULATION_STEPS
                x(i,j,k) = str2double(cell2mat(P(counter)));
                y(i,j,k) = str2double(cell2mat(P(counter+1)));
                z(i,j,k) = str2double(cell2mat(P(counter+3)));
                theta(i,j,k) = str2double(cell2mat(P(counter+2)));
                counter = counter + 4;
            end
        end
    end    
    
    % PLOT 1: Plot the best run.
    figure()
    X = squeeze(x(BEST_ROW,BEST_COL,:));
    Y = squeeze(y(BEST_ROW,BEST_COL,:));  
    THETA = squeeze(theta(BEST_ROW,BEST_COL,:));
    
    plot(X,Y,'k');  hold on;
    plot(X(1),Y(1),'go','MarkerSize',10,'LineWidth',2); hold on;
    plot(X(end),Y(end),'ro','MarkerSize',10,'LineWidth',2); hold on;  
    
    linesize = (max(X)-min(X) + max(Y)-min(Y))/30;
    ANGLE_STEP = round(SIMULATION_STEPS/10);
    for i=1:ANGLE_STEP:length(X)
        plot(X(i),Y(i),'bo')
        plot([X(i) X(i)+linesize*cos(THETA(i))], [Y(i) Y(i)+linesize*sin(THETA(i))],'b-')
    end
    
    title(['Best Run for Traits: ' TRAITS]);
    xlabel('x');    ylabel('y');
    legend('Trajectory','Start Position','End Position');
    grid on;  axis equal;
    
    % PLOT 2: Error Bars for Scores
    figure()
    scoremeans = mean(scores,2)';
    scorehigh = max(scores')-scoremeans;
    scorelow = min(scores')-scoremeans;
    %errorbar(1:GENERATIONS,scoremeans,scorelow,scorehigh,'k-')
    hold on;
    plot(1:GENERATIONS,scoremeans,'r-','LineWidth',2);
    
    title(['Average scores for Traits: ' TRAITS]);
    xlabel('Generation');   ylabel('Average Score');
    %legend('Error Bars', 'Average Score');
    
    % PLOT 3: Height vs. Time
    figure()
    Z = squeeze(z(BEST_ROW,BEST_COL,:));
    meanZ = mean(Z);
    
    plot(1:length(Z),Z,'k'); hold on;
    plot([0 SIMULATION_STEPS],[meanZ meanZ],'r--');
    legend('Trajectory', ['Average Height = ' num2str(meanZ)]);
    title('Base Module Height vs. Time for Best Run');
    xlabel('Time Step'); ylabel('Module Height');
    
    % PLOT 4: Angle vs. Time.
    figure()
    
    plot(1:length(THETA),THETA*(180/pi),'r','LineWidth',2);  hold on;
    title('Angle vs. Time');
    xlabel('Time Step');    ylabel('\theta [degrees]');
    
    
end
