classdef MaskFindingProc < improc2.procs.ProcessorData & improc2.ImageDisplayer
    % A processor that determines a binary mask based on image data and overlays that mask when plotImage is called. 

    properties
        mask = 1;
    end
    
    
    methods
        function p = MaskFindingProc(description)
            if nargin == 0
                super_args = {};
            else
                super_args{1} = description;
            end
            p = p@improc2.procs.ProcessorData(super_args{:});
        end
        
        function [imgH, axH, perimH] = plotImage(p,varargin)
            [imgH, axH] = p.plotImage@improc2.ImageDisplayer(varargin{:});
            
            if isempty(p.mask)  
                perimH = [];
                disp 'test'
            else
                perimMask = bwperim(p.mask);
                hold(axH,'on');
                [I,J] = ind2sub(size(p.mask),find(perimMask(:)));
                perimH = plot(axH,J,I,'r.');  
                hold(axH,'off');
            end
            
        end 
        
    end
    
end

