function [fitresult, gof] = createFit(edges, N, energy_MeV, verb)
%CREATEFIT1(E_MOD,N_MOD)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : E_mod
%      Y Output: N_mod
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 05-Feb-2017 10:09:20


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData(edges, N);

% Set up fittype and options.
ft = fittype('smoothingspline');

% Fit model to data.
[fitresult, gof] = fit(xData, yData, ft);

if verb==1
    % Create a figure for the plots.
    figure('Name','Smoothing Spline Fit to Histogram');
    
    % Plot fit with data.
    subplot( 2, 1, 1 );
    h = plot( fitresult, xData, yData );
    legend( h, 'Histogram of Number of Pixels with Energy Deposited', 'Fit of Histogram of Energy Deposited', 'Location', 'NorthEast' );
    % Label axes
    xlabel('keV')
    ylabel('Number of Pixels')
    grid on
    
    % Plot residuals.
    subplot( 2, 1, 2 );
    h = plot( fitresult, xData, yData, 'residuals' );
    legend( h, 'Fit Residuals', 'Zero Line', 'Location', 'NorthEast' );
    % Label axes
    xlabel('keV')
    ylabel('Number of Pixels')
    grid on
end

end