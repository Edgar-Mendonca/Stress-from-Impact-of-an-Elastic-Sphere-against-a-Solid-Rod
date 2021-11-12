classdef ballbarapp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ContactStressUIFigure          matlab.ui.Figure
        Image                          matlab.ui.control.Image
        MaxDisplacement                matlab.ui.control.NumericEditField
        MaxDisplacementEditFieldLabel  matlab.ui.control.Label
        MaxStress                      matlab.ui.control.NumericEditField
        MaxStressEditFieldLabel        matlab.ui.control.Label
        RESETGRAPHSButton              matlab.ui.control.Button
        RESETALLButton                 matlab.ui.control.Button
        EDGARMENDONCALabel             matlab.ui.control.Label
        OUTPUTSLabel                   matlab.ui.control.Label
        pr2                            matlab.ui.control.NumericEditField
        Label_3                        matlab.ui.control.Label
        Em2                            matlab.ui.control.NumericEditField
        E2Nm2Label                     matlab.ui.control.Label
        CalculateButton                matlab.ui.control.Button
        mkg                            matlab.ui.control.NumericEditField
        mkgEditFieldLabel              matlab.ui.control.Label
        C                              matlab.ui.control.NumericEditField
        CmsEditFieldLabel              matlab.ui.control.Label
        A                              matlab.ui.control.NumericEditField
        Am2EditFieldLabel              matlab.ui.control.Label
        ts                             matlab.ui.control.NumericEditField
        tsEditFieldLabel               matlab.ui.control.Label
        Vel                            matlab.ui.control.NumericEditField
        VmsEditFieldLabel              matlab.ui.control.Label
        Em1                            matlab.ui.control.NumericEditField
        E1Nm2Label                     matlab.ui.control.Label
        pr1                            matlab.ui.control.NumericEditField
        Label_2                        matlab.ui.control.Label
        Rbar                           matlab.ui.control.NumericEditField
        RmEditFieldLabel               matlab.ui.control.Label
        rball                          matlab.ui.control.NumericEditField
        rmEditFieldLabel               matlab.ui.control.Label
        density                        matlab.ui.control.NumericEditField
        kgm3Label                      matlab.ui.control.Label
        INPUTSLabel                    matlab.ui.control.Label
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
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ContactStressUIFigure and hide until all components are created
            app.ContactStressUIFigure = uifigure('Visible', 'off');
            app.ContactStressUIFigure.AutoResizeChildren = 'off';
            app.ContactStressUIFigure.Color = [0.902 0.902 0.902];
            app.ContactStressUIFigure.Position = [100 100 941 642];
            app.ContactStressUIFigure.Name = 'Contact Stress';
            app.ContactStressUIFigure.Resize = 'off';

            % Create UIcompression
            app.UIcompression = uiaxes(app.ContactStressUIFigure);
            xlabel(app.UIcompression, 'Time (s)')
            ylabel(app.UIcompression, 'Displacement (m)')
            app.UIcompression.PlotBoxAspectRatio = [1.44343891402715 1 1];
            app.UIcompression.FontWeight = 'bold';
            app.UIcompression.LineWidth = 0.8;
            app.UIcompression.Position = [10 305 366 263];

            % Create UIstress
            app.UIstress = uiaxes(app.ContactStressUIFigure);
            xlabel(app.UIstress, 'Time (s)')
            ylabel(app.UIstress, 'Stress (MPa)')
            app.UIstress.PlotBoxAspectRatio = [1.44343891402715 1 1];
            app.UIstress.FontWeight = 'bold';
            app.UIstress.Position = [10 25 366 263];

            % Create DeformationKinematicsduringImpactofaBallonaRodLabel
            app.DeformationKinematicsduringImpactofaBallonaRodLabel = uilabel(app.ContactStressUIFigure);
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.HorizontalAlignment = 'center';
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.FontSize = 18;
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.FontWeight = 'bold';
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.Position = [192 608 504 22];
            app.DeformationKinematicsduringImpactofaBallonaRodLabel.Text = 'Deformation Kinematics during Impact of a Ball on a Rod';

            % Create INPUTSLabel
            app.INPUTSLabel = uilabel(app.ContactStressUIFigure);
            app.INPUTSLabel.FontSize = 14;
            app.INPUTSLabel.FontWeight = 'bold';
            app.INPUTSLabel.Position = [446 546 57 22];
            app.INPUTSLabel.Text = 'INPUTS';

            % Create kgm3Label
            app.kgm3Label = uilabel(app.ContactStressUIFigure);
            app.kgm3Label.HorizontalAlignment = 'right';
            app.kgm3Label.FontWeight = 'bold';
            app.kgm3Label.Position = [385 512 59 22];
            app.kgm3Label.Text = 'ρ (kg/m3)';

            % Create density
            app.density = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.density.Position = [459 512 100 22];

            % Create rmEditFieldLabel
            app.rmEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.rmEditFieldLabel.HorizontalAlignment = 'right';
            app.rmEditFieldLabel.FontWeight = 'bold';
            app.rmEditFieldLabel.Position = [412 485 32 22];
            app.rmEditFieldLabel.Text = 'r (m)';

            % Create rball
            app.rball = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.rball.Position = [459 485 100 22];

            % Create RmEditFieldLabel
            app.RmEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.RmEditFieldLabel.HorizontalAlignment = 'right';
            app.RmEditFieldLabel.FontWeight = 'bold';
            app.RmEditFieldLabel.Position = [408 458 36 22];
            app.RmEditFieldLabel.Text = 'R (m)';

            % Create Rbar
            app.Rbar = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.Rbar.Position = [459 458 100 22];

            % Create Label_2
            app.Label_2 = uilabel(app.ContactStressUIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [419 431 25 22];
            app.Label_2.Text = 'ν1';

            % Create pr1
            app.pr1 = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.pr1.Position = [459 431 100 22];

            % Create E1Nm2Label
            app.E1Nm2Label = uilabel(app.ContactStressUIFigure);
            app.E1Nm2Label.HorizontalAlignment = 'right';
            app.E1Nm2Label.FontWeight = 'bold';
            app.E1Nm2Label.Position = [383 377 61 22];
            app.E1Nm2Label.Text = 'E1 (N/m2)';

            % Create Em1
            app.Em1 = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.Em1.Position = [459 377 100 22];

            % Create VmsEditFieldLabel
            app.VmsEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.VmsEditFieldLabel.HorizontalAlignment = 'right';
            app.VmsEditFieldLabel.FontWeight = 'bold';
            app.VmsEditFieldLabel.Position = [398 323 46 22];
            app.VmsEditFieldLabel.Text = 'V (m/s)';

            % Create Vel
            app.Vel = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.Vel.Position = [459 323 100 22];

            % Create tsEditFieldLabel
            app.tsEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.tsEditFieldLabel.HorizontalAlignment = 'right';
            app.tsEditFieldLabel.FontWeight = 'bold';
            app.tsEditFieldLabel.Position = [417 296 27 22];
            app.tsEditFieldLabel.Text = 't (s)';

            % Create ts
            app.ts = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.ts.Position = [459 296 100 22];

            % Create Am2EditFieldLabel
            app.Am2EditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.Am2EditFieldLabel.HorizontalAlignment = 'right';
            app.Am2EditFieldLabel.FontWeight = 'bold';
            app.Am2EditFieldLabel.Position = [401 134 43 22];
            app.Am2EditFieldLabel.Text = 'A (m2)';

            % Create A
            app.A = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.A.Position = [459 134 100 22];

            % Create CmsEditFieldLabel
            app.CmsEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.CmsEditFieldLabel.HorizontalAlignment = 'right';
            app.CmsEditFieldLabel.FontWeight = 'bold';
            app.CmsEditFieldLabel.Position = [398 107 46 22];
            app.CmsEditFieldLabel.Text = 'C (m/s)';

            % Create C
            app.C = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.C.Position = [459 107 100 22];

            % Create mkgEditFieldLabel
            app.mkgEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.mkgEditFieldLabel.HorizontalAlignment = 'right';
            app.mkgEditFieldLabel.FontWeight = 'bold';
            app.mkgEditFieldLabel.Position = [403 80 41 22];
            app.mkgEditFieldLabel.Text = 'm (kg)';

            % Create mkg
            app.mkg = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.mkg.Position = [459 80 100 22];

            % Create CalculateButton
            app.CalculateButton = uibutton(app.ContactStressUIFigure, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalculateButton.FontWeight = 'bold';
            app.CalculateButton.Position = [459 263 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create E2Nm2Label
            app.E2Nm2Label = uilabel(app.ContactStressUIFigure);
            app.E2Nm2Label.HorizontalAlignment = 'right';
            app.E2Nm2Label.FontWeight = 'bold';
            app.E2Nm2Label.Position = [383 350 61 22];
            app.E2Nm2Label.Text = 'E2 (N/m2)';

            % Create Em2
            app.Em2 = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.Em2.Position = [459 350 100 22];

            % Create Label_3
            app.Label_3 = uilabel(app.ContactStressUIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.FontWeight = 'bold';
            app.Label_3.Position = [419 404 25 22];
            app.Label_3.Text = 'ν2';

            % Create pr2
            app.pr2 = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.pr2.Position = [459 404 100 22];

            % Create OUTPUTSLabel
            app.OUTPUTSLabel = uilabel(app.ContactStressUIFigure);
            app.OUTPUTSLabel.FontSize = 14;
            app.OUTPUTSLabel.FontWeight = 'bold';
            app.OUTPUTSLabel.Position = [558 168 72 22];
            app.OUTPUTSLabel.Text = 'OUTPUTS';

            % Create EDGARMENDONCALabel
            app.EDGARMENDONCALabel = uilabel(app.ContactStressUIFigure);
            app.EDGARMENDONCALabel.FontSize = 10;
            app.EDGARMENDONCALabel.FontWeight = 'bold';
            app.EDGARMENDONCALabel.Position = [818 4 116 22];
            app.EDGARMENDONCALabel.Text = '© EDGAR MENDONCA ';

            % Create RESETALLButton
            app.RESETALLButton = uibutton(app.ContactStressUIFigure, 'push');
            app.RESETALLButton.ButtonPushedFcn = createCallbackFcn(app, @RESETALLButtonPushed, true);
            app.RESETALLButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.RESETALLButton.FontWeight = 'bold';
            app.RESETALLButton.Position = [525 25 100 22];
            app.RESETALLButton.Text = 'RESET ALL';

            % Create RESETGRAPHSButton
            app.RESETGRAPHSButton = uibutton(app.ContactStressUIFigure, 'push');
            app.RESETGRAPHSButton.ButtonPushedFcn = createCallbackFcn(app, @RESETGRAPHSButtonPushed, true);
            app.RESETGRAPHSButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.RESETGRAPHSButton.FontWeight = 'bold';
            app.RESETGRAPHSButton.Position = [416 25 110 22];
            app.RESETGRAPHSButton.Text = 'RESET GRAPHS';

            % Create MaxStressEditFieldLabel
            app.MaxStressEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.MaxStressEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxStressEditFieldLabel.FontWeight = 'bold';
            app.MaxStressEditFieldLabel.Position = [611 134 69 22];
            app.MaxStressEditFieldLabel.Text = 'Max Stress';

            % Create MaxStress
            app.MaxStress = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.MaxStress.Position = [695 134 100 22];

            % Create MaxDisplacementEditFieldLabel
            app.MaxDisplacementEditFieldLabel = uilabel(app.ContactStressUIFigure);
            app.MaxDisplacementEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxDisplacementEditFieldLabel.FontWeight = 'bold';
            app.MaxDisplacementEditFieldLabel.Position = [570 107 110 22];
            app.MaxDisplacementEditFieldLabel.Text = 'Max Displacement';

            % Create MaxDisplacement
            app.MaxDisplacement = uieditfield(app.ContactStressUIFigure, 'numeric');
            app.MaxDisplacement.Position = [695 107 100 22];

            % Create Image
            app.Image = uiimage(app.ContactStressUIFigure);
            app.Image.Position = [570 220 364 361];
            app.Image.ImageSource = 'ballonrod_nomenclature.jpg';

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