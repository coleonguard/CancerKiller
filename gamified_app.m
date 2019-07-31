classdef gamified_app < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        NormalButton             matlab.ui.control.Button
        DelayedButton            matlab.ui.control.Button
        CHOOSEYOURMODELabel      matlab.ui.control.Label
        WELCOMETOTHESERIALDEPENDENCELabel  matlab.ui.control.Label
        EXPERIMENTITSAGAMELabel  matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: NormalButton
        function NormalButtonPushed(app, event)
            delayTime = 0;
            MasterV1;
        end

        % Button pushed function: DelayedButton
        function DelayedButtonPushed(app, event)
            delayTime = 3;
            MasterV1;
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

            % Create NormalButton
            app.NormalButton = uibutton(app.UIFigure, 'push');
            app.NormalButton.ButtonPushedFcn = createCallbackFcn(app, @NormalButtonPushed, true);
            app.NormalButton.BackgroundColor = [0.302 0.7451 0.9333];
            app.NormalButton.FontName = 'Palatino Linotype';
            app.NormalButton.Position = [180 226 100 26];
            app.NormalButton.Text = 'Normal';

            % Create DelayedButton
            app.DelayedButton = uibutton(app.UIFigure, 'push');
            app.DelayedButton.ButtonPushedFcn = createCallbackFcn(app, @DelayedButtonPushed, true);
            app.DelayedButton.BackgroundColor = [1 1 0];
            app.DelayedButton.FontName = 'Palatino Linotype';
            app.DelayedButton.Position = [371 226 100 26];
            app.DelayedButton.Text = 'Delayed';

            % Create CHOOSEYOURMODELabel
            app.CHOOSEYOURMODELabel = uilabel(app.UIFigure);
            app.CHOOSEYOURMODELabel.FontName = 'Garamond';
            app.CHOOSEYOURMODELabel.FontSize = 30;
            app.CHOOSEYOURMODELabel.FontWeight = 'bold';
            app.CHOOSEYOURMODELabel.Position = [139 138 363 36];
            app.CHOOSEYOURMODELabel.Text = 'CHOOSE YOUR MODE!!!';

            % Create WELCOMETOTHESERIALDEPENDENCELabel
            app.WELCOMETOTHESERIALDEPENDENCELabel = uilabel(app.UIFigure);
            app.WELCOMETOTHESERIALDEPENDENCELabel.FontName = 'Lucida Handwriting';
            app.WELCOMETOTHESERIALDEPENDENCELabel.FontSize = 28;
            app.WELCOMETOTHESERIALDEPENDENCELabel.FontWeight = 'bold';
            app.WELCOMETOTHESERIALDEPENDENCELabel.Position = [2 348 637 40];
            app.WELCOMETOTHESERIALDEPENDENCELabel.Text = 'WELCOME TO THE SERIAL DEPENDENCE';

            % Create EXPERIMENTITSAGAMELabel
            app.EXPERIMENTITSAGAMELabel = uilabel(app.UIFigure);
            app.EXPERIMENTITSAGAMELabel.FontName = 'Lucida Handwriting';
            app.EXPERIMENTITSAGAMELabel.FontSize = 30;
            app.EXPERIMENTITSAGAMELabel.FontWeight = 'bold';
            app.EXPERIMENTITSAGAMELabel.Position = [63 295 515 43];
            app.EXPERIMENTITSAGAMELabel.Text = 'EXPERIMENT (IT''S A GAME)!!!';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gamified_app

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