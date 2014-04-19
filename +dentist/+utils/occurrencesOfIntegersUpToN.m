function occurrences = occurrencesOfIntegersUpToN(x, N)
    
    if ~isempty(x)
        assert(all(mod(x,1) == 0) && all(x >= 1))
        % if the input to tabulate are nonnegative integers, Matlab creates
        % rows for any integers not present in x but less than max(x) and gives
        % them a count value of 0. The output is always sorted.
        tab = tabulate(x);
        occurrences = tab(:,2);
    else
        % Matlab's tabulate produces wrong size output if fed an empty vector
        occurrences = [];
    end
    
    maxElementInX = length(occurrences);
    assert(maxElementInX <= N,'input contains values > maximum N specified')
    
    if maxElementInX < N
        occurrences = [occurrences; zeros(N - maxElementInX, 1)];
    end
end

