classdef PFM < CoordinateSystemCluster
    properties
        spRET;
        spMksRET;

        spIM_GT;
        spMksIM;

        cro=[350;350];
    end

    methods
        function obj = PFM()
            obj.clear();
            obj.initTrans();
            obj.plotCoordinateSystems(axes);
            obj.loadSPMksIM();
            obj.calculateSpIMandSpCSN();

            spCSN=obj.getSpCSN();
        end

        % P
        function spCSN=getSpCSN(obj)
            spCSN=obj.transform(obj.spRET,from="RET",to="CSN");
        end

        % P
        function calculateSpIMandSpCSN(obj)
            spMksFLD=obj.transform(obj.spMksIM,from="IM",to="FLD");

            spMksFLDSoll=cell(size(obj.spRET));
            csd=nan(size(obj.spRET));
            for i=1:size(spMksFLDSoll,2)
                spMksFLDSoll{i,1}=obj.spMksRET{i,1}-obj.spRET(:,i);
                csd(:,i)=mean(spMksFLD{i,1}-spMksFLDSoll{i,1},2);
            end
            spIM=obj.transform(csd,from="FLD",to="IM");
            disp(['MaxPixelDeviation: ',num2str(max(spIM(:)-obj.spIM_GT(:)))]);
        end

        % R
        function vzMksFLD=getVzMksFLD(obj)
            vzMksXFLD=-100:20:100;
            vzMksYFLD=-100:20:100;
            [vzMksXFLD,vzMksYFLD]=meshgrid(vzMksXFLD,vzMksYFLD);
            vzMksFLD=[vzMksXFLD(:),vzMksYFLD(:)]';
        end

        % IP
        function vzMksIm=getVzMksIM(obj)
            vzMksFLD=obj.getVzMksFLD();
            camRotationDeg=1;
            camRotationMat=[cosd(camRotationDeg),-sind(camRotationDeg);sind(camRotationDeg),cosd(camRotationDeg)];
            vzMksIm=camRotationMat*(vzMksFLD*10+vzMksFLD.^2/500)+0.5*randn(size(vzMksFLD));
        end

        % R
        function spRET=getSpRET(obj)
            spX=-250:100:250;
            spY=-150:5:150;
            [spX,spY]=meshgrid(spX,spY);
            spRET=[spX(:),spY(:)]';
            spRET=spRET+3*randn(size(spRET));
        end

        % R
        function spMksRET=getSpMksRET(obj)
            retMksX=-300:100:300;
            retMksY=-200:25:200;
            [retMksX,retMksY]=meshgrid(retMksX,retMksY);
            spMksRET=[retMksX(:),retMksY(:)]';

            spMksRETTmp=cell(size(obj.spRET,2),1);
            for i=1:size(obj.spRET,2)
                mksFld=sqrt((spMksRET(1,:)-obj.spRET(1,i)).^2+(spMksRET(2,:)-obj.spRET(2,i)).^2);
                [~,minIdcs]=sort(mksFld,'ascend');
                spMksRETTmp{i,1}=spMksRET(:,minIdcs(1:4));
            end
            spMksRET=spMksRETTmp;
        end

        % IP
        function loadSPMksIM(obj)
            CSD_ROT_DEG=1;
            csdRotMat=[cosd(CSD_ROT_DEG),-sind(CSD_ROT_DEG);sind(CSD_ROT_DEG),cosd(CSD_ROT_DEG)];
            spRET_WITH_CSD=csdRotMat*obj.spRET+0.0001*obj.spRET.^2;
            fldCSD=spRET_WITH_CSD-obj.spRET;

            spMksRET_WITH_CSD=cell(size(obj.spRET,2),1);
            for i=1:size(obj.spRET,2)
                spMksRET_WITH_CSD{i,1}=obj.spMksRET{i,1}+fldCSD(:,i);
            end

            obj.spIM_GT=obj.transform(spRET_WITH_CSD-obj.spRET,from="FLD",to="IM");
            obj.spMksIM=cell(size(obj.spRET,2),1);
            for i=1:size(obj.spRET,2)
                obj.spMksIM{i,1}=obj.transform(spMksRET_WITH_CSD{i,1}-obj.spRET(:,i),from="FLD",to="IM")+0.00*randn(size(obj.spMksRET{i,1}));
            end
        end

        function plotpMksIM(obj)
            figure(3);
            clf;
            tg=uitabgroup();
            t1=uitab(tg,"Title","RET_UNDIST");
            ax=axes(t1);
            hold on;
            plot(obj.spRET(1,:),obj.spRET(2,:),'r+');
            for i=1:size(obj.spRET,2)
                for j=1:4
                    plot([obj.spRET(1,i),obj.spMksRET{i,1}(1,j)],...
                        [obj.spRET(2,i),obj.spMksRET{i,1}(2,j)],'k-');
                end
            end
            axis equal;

            t2=uitab(tg,"Title","RET_DIST");
            ax=axes(t2);
            hold on;
            plot(spRET_WITH_CSD(1,:),spRET_WITH_CSD(2,:),'r+');
            for i=1:size(spRET_WITH_CSD,2)
                for j=1:4
                    plot([spRET_WITH_CSD(1,i),spMksRET_WITH_CSD{i,1}(1,j)],...
                        [spRET_WITH_CSD(2,i),spMksRET_WITH_CSD{i,1}(2,j)],'k-');
                end
            end
            axis equal;

            t3=uitab(tg,"Title","CSD");
            axes(t3);
            hold on;
            plot(obj.spRET(1,:),obj.spRET(2,:),'k+');
            plot(spRET_WITH_CSD(1,:),spRET_WITH_CSD(2,:),'r+');
            quiver(obj.spRET(1,:),obj.spRET(2,:),spRET_WITH_CSD(1,:)-obj.spRET(1,:),spRET_WITH_CSD(2,:)-obj.spRET(2,:),'off');

            cellfun(@(x)plot(x(1,:),x(2,:),'k+'),obj.spMksRET);
            cellfun(@(x)plot(x(1,:),x(2,:),'r+'),spMksRET_WITH_CSD);
        end

        function initTrans(obj)
            rng(0)

            vzMksFLD=obj.getVzMksFLD();
            vzMksIm=obj.getVzMksIM();
            obj.spRET=obj.getSpRET();
            obj.spMksRET=obj.getSpMksRET();

            imFldTrans=PolynomialTransform("IM",vzMksIm,"FLD",vzMksFLD);
            imFldTrans.initTransforms('poly33');
            obj.addTransform(imFldTrans);

            csnRetTrans=AffineTForm("CSN","RET");
            csnRetTrans.setTranslation(obj.cro);
            csnRetTrans.setXDir("INVERTED");
            csnRetTrans.setYDir("INVERTED");
            obj.addTransform(csnRetTrans);
        end
    end
end