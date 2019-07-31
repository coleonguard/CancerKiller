classdef gamify_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        LAUNCHButton  matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LAUNCHButton
        function LAUNCHButtonPushed(app, event)
          MasterV1
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create LAUNCHButton
            app.LAUNCHButton = uibutton(app.UIFigure, 'push');
            app.LAUNCHButton.ButtonPushedFcn = createCallbackFcn(app, @LAUNCHButtonPushed, true);
            app.LAUNCHButton.BackgroundColor = [1 1 0.0667];
            app.LAUNCHButton.FontName = 'Ink Free';
            app.LAUNCHButton.FontWeight = 'bold';
            app.LAUNCHButton.FontColor = [0 0.4471 0.7412];
            app.LAUNCHButton.Position = [271 228 100 24];
            app.LAUNCHButton.Text = 'LAUNCH';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gamify_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
