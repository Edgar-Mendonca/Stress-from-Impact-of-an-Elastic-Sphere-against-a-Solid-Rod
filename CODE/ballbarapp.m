classdef ballbarapp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ContactStressUIFigure          matlab.ui.Figure
        DEFAULTEXAMPLEButton           matlab.ui.control.Button
        OUTPUTSPanel                   matlab.ui.container.Panel
        MaxDisplacement                matlab.ui.control.NumericEditField
        MaxDisplacementEditFieldLabel  matlab.ui.control.Label
        MaxStress                      matlab.ui.control.NumericEditField
        MaxStressEditFieldLabel        matlab.ui.control.Label
        mkg                            matlab.ui.control.NumericEditField
        mkgEditFieldLabel              matlab.ui.control.Label
        C                              matlab.ui.control.NumericEditField
        CmsEditFieldLabel              matlab.ui.control.Label
        A                              matlab.ui.control.NumericEditField
        Am2EditFieldLabel              matlab.ui.control.Label
        INPUTSFORBALLIMPACTORPanel     matlab.ui.container.Panel
        Vel                            matlab.ui.control.NumericEditField
        VmsEditFieldLabel              matlab.ui.control.Label
        Em2                            matlab.ui.control.NumericEditField
        E2Nm2Label                     matlab.ui.control.Label
        pr2                            matlab.ui.control.NumericEditField
        Label_3                        matlab.ui.control.Label
        rball                          matlab.ui.control.NumericEditField
        rmEditFieldLabel               matlab.ui.control.Label
        CalculateButton                matlab.ui.control.Button
        INPUTSFORBARPanel              matlab.ui.container.Panel
        ts                             matlab.ui.control.NumericEditField
        tsEditFieldLabel               matlab.ui.control.Label
        Em1                            matlab.ui.control.NumericEditField
        E1Nm2Label                     matlab.ui.control.Label
        pr1                            matlab.ui.control.NumericEditField
        Label_2                        matlab.ui.control.Label
        Rbar                           matlab.ui.control.NumericEditField
        RmEditFieldLabel               matlab.ui.control.Label
        density                        matlab.ui.control.NumericEditField
        kgm3Label                      matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        RESETGRAPHSButton              matlab.ui.control.Button
        RESETALLButton                 matlab.ui.control.Button
        EDGARMENDONCALabel             matlab.ui.control.Label
        DeformationKinematicsduringImpactofaBallonaRodLabel  matlab.ui.control.Label
        UIstress                       matlab.ui.control.UIAxes
        UIcompression                  matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            
            r = app.rball.Value;
            R = app.Rbar.Value;
            app.A.Value = (pi*R*R);
            A = app.A.Value;
            
            rho = app.density.Value;
            E1 = app.Em1.Value;
            E2 = app.Em2.Value;
            app.C.Value = sqrt(E1/rho);
            C = app.C.Value;
            
            app.mkg.Value = (rho*4*pi*r*r*r)/3;
            m = app.mkg.Value;
            
            v1 = app.pr1.Value;
            v2 = app.pr2.Value;
            k1 = (1-(v1)^2)/(pi*E1);
            k2 = (1-(v2)^2)/(pi*E2);
            
            K = (4/(3*pi))*((R^0.5)/(k1 + k2));
            
            a = (K*C)/(A*E1);
            b = (K/m);
            
            %             ts = app.ts.Value;
            %             V = app.Vel.Value;
            
            syms u(t)
            eqn=diff(u,t,2)==(-1.5*a*u^0.5*diff(u)-b*u^1.5);
            V=odeToVectorField(eqn);
            M=matlabFunction(V,'Vars',{'t','Y'});
            tspan=[0 app.ts.Value];
            u0=[0 app.Vel.Value];
            sol=ode45(M,tspan,u0);
            tVal=linspace(0,app.ts.Value);
            uVal=deval(sol,tVal,1);
            
            
            plot(app.UIcompression, tVal, uVal);
           
            hold(app.UIcompression, 'on');
            
            
            aVal=uVal.^1.5;
            f=K*aVal;
            sVal=(f/A)/(1e6);
            
            plot(app.UIstress, tVal, sVal);
            hold(app.UIstress, 'on');
            
            
%             plot(tVal, sVal);
%             hold on;
            
            app.MaxStress.Value = max(sVal);
            app.MaxDisplacement.Value = max(uVal);
            
        end

        % Button pushed function: RESETALLButton
        function RESETALLButtonPushed(app, event)
            app.rball.Value = 0;
            app.Rbar.Value = 0;
            app.A.Value=0;
            app.mkg.Value=0;
            app.density.Value=0;
            app.Em1.Value=0;
            app.Em2.Value=0;
            app.C.Value=0;
            app.pr1.Value=0;
            app.pr2.Value=0;
            app.ts.Value=0;
            app.Vel.Value=0;
            app.MaxStress.Value=0;
            app.MaxDisplacement.Value=0;
            
            cla(app.UIcompression);
            cla(app.UIstress);
        end

        % Button pushed function: RESETGRAPHSButton
        function RESETGRAPHSButtonPushed(app, event)
            cla(app.UIcompression);
            cla(app.UIstress);
        end

        % Button pushed function: DEFAULTEXAMPLEButton
        function DEFAULTEXAMPLEButtonPushed(app, event)
            app.rball.Value = 0.02;
            app.Rbar.Value = 0.02;
            app.A.Value=0;
            app.mkg.Value=0;
            app.density.Value=8000;
            app.Em1.Value=2E11;
            app.Em2.Value=2E11;
            app.C.Value=0;
            app.pr1.Value=0.3;
            app.pr2.Value=0.3;
            app.ts.Value=145E-6;
            app.Vel.Value=1;
            app.MaxStress.Value=0;
            app.MaxDisplacement.Value=0;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ContactStressUIFigure and hide until all components are created
            app.ContactStressUIFigure = uifigure('Visible', 'off');
            app.ContactStressUIFigure.AutoResizeChildren = 'off';
            app.ContactStressUIFigure.Color = [0.902 0.902 0.902];
            app.ContactStressUIFigure.Position = [100 100 1014 642];
            app.ContactStressUIFigure.Name = 'Contact Stress';
            app.ContactStressUIFigure.Resize = 'off';

            % Create UIcompression
            app.UIcompression = uiaxes(app.ContactStressUIFigure);
            xlabel(app.UIcompression, 'Time (s)')
            ylabel(app.UIcompression, 'Displacement (m)')
            app.UIcompression.PlotBoxAspectRatio = [1.44343891402715 1 1];
            app.UIcompression.FontWeight = 'bold';
            app.UIcompression.LineWidth = 0.8;
            app.UIcompression.Position = [13 317 366 263];

            % Create UIstress
            app.UIstress = uiaxes(app.ContactStressUIFigure);
            xlabel(app.UIstress, 'Time (s)')
            ylabel(app.UIstress, 'Stress (MPa)')
            app.UIstress.PlotBoxAspectRatio = [1.44343891402715 1 1];
            app.UIstress.FontWeight = 'bold';
            app.UIstress.Position = [13 25 366 263];

            % Create DeformationKinematicsduringImpactofaBallonaRodLabel
            app.DeformationKinematicsduringImpactofaBallonaRodLabel = uilabel(app.ContactStressUIFigure);
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.HorizontalAlignment = 'center';
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.FontSize = 18;
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.FontWeight = 'bold';
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.Position = [104 605 728 22];
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.Text = 'Deformation Kinematics during Impact of a Ball on a Rod -Hertzian Contact Theory';

            % Create EDGARMENDONCALabel
            app.EDGARMENDONCALabel = uilabel(app.ContactStressUIFigure);
            app.EDGARMENDONCALabel.FontSize = 10;
            app.EDGARMENDONCALabel.FontWeight = 'bold';
            app.EDGARMENDONCALabel.Position = [889 4 116 22];
            app.EDGARMENDONCALabel.Text = '© EDGAR MENDONCA ';

            % Create RESETALLButton
            app.RESETALLButton = uibutton(app.ContactStressUIFigure, 'push');
            app.RESETALLButton.ButtonPushedFcn = createCallbackFcn(app, @RESETALLButtonPushed, true);
            app.RESETALLButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.RESETALLButton.FontWeight = 'bold';
            app.RESETALLButton.Position = [663 57 110 22];
            app.RESETALLButton.Text = 'RESET ALL';

            % Create RESETGRAPHSButton
            app.RESETGRAPHSButton = uibutton(app.ContactStressUIFigure, 'push');
            app.RESETGRAPHSButton.ButtonPushedFcn = createCallbackFcn(app, @RESETGRAPHSButtonPushed, true);
            app.RESETGRAPHSButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.RESETGRAPHSButton.FontWeight = 'bold';
            app.RESETGRAPHSButton.Position = [663 87 110 22];
            app.RESETGRAPHSButton.Text = 'RESET GRAPHS';

            % Create Image
            app.Image = uiimage(app.ContactStressUIFigure);
            app.Image.Position = [606 287 399 293];
            app.Image.ImageSource = 'ballbarnom.jpg';

            % Create INPUTSFORBARPanel
            app.INPUTSFORBARPanel = uipanel(app.ContactStressUIFigure);
            app.INPUTSFORBARPanel.AutoResizeChildren = 'off';
            app.INPUTSFORBARPanel.Title = 'INPUTS FOR BAR';
            app.INPUTSFORBARPanel.FontWeight = 'bold';
            app.INPUTSFORBARPanel.Position = [398 414 189 166];

            % Create kgm3Label
            app.kgm3Label = uilabel(app.INPUTSFORBARPanel);
            app.kgm3Label.HorizontalAlignment = 'right';
            app.kgm3Label.FontWeight = 'bold';
            app.kgm3Label.Position = [7 119 59 22];
            app.kgm3Label.Text = 'ρ (kg/m3)';

            % Create density
            app.density = uieditfield(app.INPUTSFORBARPanel, 'numeric');
            app.density.Position = [81 119 100 22];
            app.density.Value = 8000;

            % Create RmEditFieldLabel
            app.RmEditFieldLabel = uilabel(app.INPUTSFORBARPanel);
            app.RmEditFieldLabel.HorizontalAlignment = 'right';
            app.RmEditFieldLabel.FontWeight = 'bold';
            app.RmEditFieldLabel.Position = [30 92 36 22];
            app.RmEditFieldLabel.Text = 'R (m)';

            % Create Rbar
            app.Rbar = uieditfield(app.INPUTSFORBARPanel, 'numeric');
            app.Rbar.Position = [81 92 100 22];
            app.Rbar.Value = 0.02;

            % Create Label_2
            app.Label_2 = uilabel(app.INPUTSFORBARPanel);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [41 65 25 22];
            app.Label_2.Text = 'ν1';

            % Create pr1
            app.pr1 = uieditfield(app.INPUTSFORBARPanel, 'numeric');
            app.pr1.Position = [81 65 100 22];
            app.pr1.Value = 0.3;

            % Create E1Nm2Label
            app.E1Nm2Label = uilabel(app.INPUTSFORBARPanel);
            app.E1Nm2Label.HorizontalAlignment = 'right';
            app.E1Nm2Label.FontWeight = 'bold';
            app.E1Nm2Label.Position = [5 38 61 22];
            app.E1Nm2Label.Text = 'E1 (N/m2)';

            % Create Em1
            app.Em1 = uieditfield(app.INPUTSFORBARPanel, 'numeric');
            app.Em1.Position = [81 38 100 22];
            app.Em1.Value = 200000000000;

            % Create tsEditFieldLabel
            app.tsEditFieldLabel = uilabel(app.INPUTSFORBARPanel);
            app.tsEditFieldLabel.HorizontalAlignment = 'right';
            app.tsEditFieldLabel.FontWeight = 'bold';
            app.tsEditFieldLabel.Position = [39 11 27 22];
            app.tsEditFieldLabel.Text = 't (s)';

            % Create ts
            app.ts = uieditfield(app.INPUTSFORBARPanel, 'numeric');
            app.ts.Position = [81 11 100 22];
            app.ts.Value = 0.000145;

            % Create CalculateButton
            app.CalculateButton = uibutton(app.ContactStressUIFigure, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalculateButton.FontSize = 14;
            app.CalculateButton.FontWeight = 'bold';
            app.CalculateButton.Position = [442 219 100 26];
            app.CalculateButton.Text = 'Calculate';

            % Create INPUTSFORBALLIMPACTORPanel
            app.INPUTSFORBALLIMPACTORPanel = uipanel(app.ContactStressUIFigure);
            app.INPUTSFORBALLIMPACTORPanel.AutoResizeChildren = 'off';
            app.INPUTSFORBALLIMPACTORPanel.Title = 'INPUTS FOR BALL IMPACTOR';
            app.INPUTSFORBALLIMPACTORPanel.FontWeight = 'bold';
            app.INPUTSFORBALLIMPACTORPanel.Position = [398 256 189 148];

            % Create rmEditFieldLabel
            app.rmEditFieldLabel = uilabel(app.INPUTSFORBALLIMPACTORPanel);
            app.rmEditFieldLabel.HorizontalAlignment = 'right';
            app.rmEditFieldLabel.FontWeight = 'bold';
            app.rmEditFieldLabel.Position = [32 103 32 22];
            app.rmEditFieldLabel.Text = 'r (m)';

            % Create rball
            app.rball = uieditfield(app.INPUTSFORBALLIMPACTORPanel, 'numeric');
            app.rball.Position = [79 103 100 22];
            app.rball.Value = 0.02;

            % Create Label_3
            app.Label_3 = uilabel(app.INPUTSFORBALLIMPACTORPanel);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.FontWeight = 'bold';
            app.Label_3.Position = [39 76 25 22];
            app.Label_3.Text = 'ν2';

            % Create pr2
            app.pr2 = uieditfield(app.INPUTSFORBALLIMPACTORPanel, 'numeric');
            app.pr2.Position = [79 76 100 22];
            app.pr2.Value = 0.3;

            % Create E2Nm2Label
            app.E2Nm2Label = uilabel(app.INPUTSFORBALLIMPACTORPanel);
            app.E2Nm2Label.HorizontalAlignment = 'right';
            app.E2Nm2Label.FontWeight = 'bold';
            app.E2Nm2Label.Position = [3 46 61 22];
            app.E2Nm2Label.Text = 'E2 (N/m2)';

            % Create Em2
            app.Em2 = uieditfield(app.INPUTSFORBALLIMPACTORPanel, 'numeric');
            app.Em2.Position = [79 46 100 22];
            app.Em2.Value = 200000000000;

            % Create VmsEditFieldLabel
            app.VmsEditFieldLabel = uilabel(app.INPUTSFORBALLIMPACTORPanel);
            app.VmsEditFieldLabel.HorizontalAlignment = 'right';
            app.VmsEditFieldLabel.FontWeight = 'bold';
            app.VmsEditFieldLabel.Position = [20 19 46 22];
            app.VmsEditFieldLabel.Text = 'V (m/s)';

            % Create Vel
            app.Vel = uieditfield(app.INPUTSFORBALLIMPACTORPanel, 'numeric');
            app.Vel.Position = [79 19 102 22];
            app.Vel.Value = 1;

            % Create OUTPUTSPanel
            app.OUTPUTSPanel = uipanel(app.ContactStressUIFigure);
            app.OUTPUTSPanel.AutoResizeChildren = 'off';
            app.OUTPUTSPanel.Title = 'OUTPUTS';
            app.OUTPUTSPanel.FontWeight = 'bold';
            app.OUTPUTSPanel.Position = [387 16 233 195];

            % Create Am2EditFieldLabel
            app.Am2EditFieldLabel = uilabel(app.OUTPUTSPanel);
            app.Am2EditFieldLabel.HorizontalAlignment = 'right';
            app.Am2EditFieldLabel.FontWeight = 'bold';
            app.Am2EditFieldLabel.Position = [13 146 43 22];
            app.Am2EditFieldLabel.Text = 'A (m2)';

            % Create A
            app.A = uieditfield(app.OUTPUTSPanel, 'numeric');
            app.A.Position = [71 146 100 22];

            % Create CmsEditFieldLabel
            app.CmsEditFieldLabel = uilabel(app.OUTPUTSPanel);
            app.CmsEditFieldLabel.HorizontalAlignment = 'right';
            app.CmsEditFieldLabel.FontWeight = 'bold';
            app.CmsEditFieldLabel.Position = [10 120 46 22];
            app.CmsEditFieldLabel.Text = 'C (m/s)';

            % Create C
            app.C = uieditfield(app.OUTPUTSPanel, 'numeric');
            app.C.Position = [71 120 100 22];

            % Create mkgEditFieldLabel
            app.mkgEditFieldLabel = uilabel(app.OUTPUTSPanel);
            app.mkgEditFieldLabel.HorizontalAlignment = 'right';
            app.mkgEditFieldLabel.FontWeight = 'bold';
            app.mkgEditFieldLabel.Position = [15 92 41 22];
            app.mkgEditFieldLabel.Text = 'm (kg)';

            % Create mkg
            app.mkg = uieditfield(app.OUTPUTSPanel, 'numeric');
            app.mkg.Position = [71 92 100 22];

            % Create MaxStressEditFieldLabel
            app.MaxStressEditFieldLabel = uilabel(app.OUTPUTSPanel);
            app.MaxStressEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxStressEditFieldLabel.FontWeight = 'bold';
            app.MaxStressEditFieldLabel.Position = [46 50 69 22];
            app.MaxStressEditFieldLabel.Text = 'Max Stress';

            % Create MaxStress
            app.MaxStress = uieditfield(app.OUTPUTSPanel, 'numeric');
            app.MaxStress.Position = [130 50 100 22];

            % Create MaxDisplacementEditFieldLabel
            app.MaxDisplacementEditFieldLabel = uilabel(app.OUTPUTSPanel);
            app.MaxDisplacementEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxDisplacementEditFieldLabel.FontWeight = 'bold';
            app.MaxDisplacementEditFieldLabel.Position = [5 20 110 22];
            app.MaxDisplacementEditFieldLabel.Text = 'Max Displacement';

            % Create MaxDisplacement
            app.MaxDisplacement = uieditfield(app.OUTPUTSPanel, 'numeric');
            app.MaxDisplacement.Position = [130 20 100 22];

            % Create DEFAULTEXAMPLEButton
            app.DEFAULTEXAMPLEButton = uibutton(app.ContactStressUIFigure, 'push');
            app.DEFAULTEXAMPLEButton.ButtonPushedFcn = createCallbackFcn(app, @DEFAULTEXAMPLEButtonPushed, true);
            app.DEFAULTEXAMPLEButton.BackgroundColor = [0.0745 0.6235 1];
            app.DEFAULTEXAMPLEButton.FontWeight = 'bold';
            app.DEFAULTEXAMPLEButton.Position = [652 25 131 22];
            app.DEFAULTEXAMPLEButton.Text = 'DEFAULT/EXAMPLE';

            % Show the figure after all components are created
            app.ContactStressUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ballbarapp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ContactStressUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ContactStressUIFigure)
        end
    end
end