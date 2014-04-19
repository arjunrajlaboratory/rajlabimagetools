classdef Processor < improc2.procs.ProcessorData
    % Template for how to write a Processor.
    
    % Following the guidelines in this template to control *Access* to
    % properties and methods is very important to making full use of the
    % features of ImageObject. 
    properties (GetAccess = public, SetAccess = protected)
        %% Type 1. Running Parameters
        % All parameters, not data, necessary to *run* the Processor.
        % Examples - parameters for an image filter you want to use, or
        % parameters to your automatic thresholding algorithm. It is
        % possible that you don't have any.
        
        % Example definition:
        % filterParams = %some default value;
        
        %% Type 2. Data calculated from the input data
        % Examples -  the middlePlane of a trans stack image, or the full
        % array of regional maxima and their positions found by a Regional
        % Max Processor, or the nuclear mask determined in a dapiProc.
        % You should have some properties here, since the whole point of
        % running a processor is to obtain and store some result.
        
        % Example definitions:
        % RegionalMaxima;
        % mask;
        % It makes no sense for these to have default values, since their
        % value is computed from your data.
    end
    
    properties (GetAccess = public, SetAccess = public)
        %% User input after running a processor.
        % These are divided into two very different categories
        %
        %% Type A: Input that substantively changes the data in a processor.
        % Examples - The threshold in RNA spot finding is the classic
        % example. These are very special properties, and some processors,
        % especially post-processors, may not have any at all.
        
        % Example definition:
        % threshold;
        % **It is critical that you define a custom set method for each one
        % of these Type A properties**
        
        %% Type B: Input that does NOT substantively change the data in a
        % processor.
        % Examples - any input that changes how a plotImage or plotData
        % method displays things, or a user-settable flag like
        % has_clearthreshold that shouldn't affect the calculations in any
        % post-processor that depends on this processor. Many processors
        % won't have any of these Type B properties.
        
        % Example definition:
        % has_clearthreshold = false;
        % These fields usually should have a default. 
    end
    
    methods (Access = public)
        %% Object constructor: makes your processor object.
        
        function p = MyProcessor(varargin)   
           %% Define source processors if this is a post-processor
           
           % Example: need data from a dapiProc and a transProc:
           % p.procDatasIDependOn = {'improc2.procs.DapiProcData', 'improc2.procs.TransProcData'};           

           % Example: need data from a single spot-finding processor
           % p.procDatasIDependOn = {'improc2.SpotFindingInterface'};
           
           % Example: need data from two gaussian-fitting processors:
           % p.procDatasIDependOn = {'GaussFitProc', 'GaussFitProc'};
           
           % If this is a regular processor then you don't need to specify
           % anything, since the default is p.procDatasIDependOn = {};
           
           %% Set the values of all "Type 1" properties
           
           % These could be set based on user input to the constructor.
           % Once set here, you should not allow the user to modify them.
        end
        
        %% Setters of Type A properties
        
        % Every type A property should have an explicit setter. 
        % For example, if you define a user-adjustable threshold property
        % you must write the following method:
        
        % function p = set.threshold(p, newThreshValue)
        %       p.threshold = newThreshValue;
        %       p.dataHasChanged = true;
        % end
        
        % The key thing is setting p.dataHasChanged = true; Without this,
        % the ImageObject will not know that any dependent post-processors
        % may need an update.
        
        %% Methods to give the user access to data or displays
        
        % Examples- getNumSpots, getSpotCoordinates, plotImage, getImage,
        % plotData, etc.
        
    end
    
    methods (Access = protected)
        %% The processor's run method
        
        function p = runProcessor(p, varargin)
            % varargin is a cell array of arguments with which your
            % processor's run method was called. 
            
            %% Considerations for processors:
            
            % You must be able to accept at least the following calls to
            % your processor, even if you don't do anything with the data:
            
            % runProcessor(p, croppedimg, objmask)
            % where croppedimg is the cropped stack for the channel being
            % processed and objmask is the 2d cropped mask for the
            % imageobject.
            
            % AND
            
            % runProcessor(p, ob, channelName)
            % where ob is the ImageObject that this processor belongs to
            % and channelName is the channel it is registered to. 
            
            % If all your processor needs to run are a cropped image stack
            % and the object mask, you can write your function like this:
            
            % function p = runProcessor(p, varargin)
            %   [croppedimg, objmask] = ...
            %       improc2.getArgsForClassicProcessor(varargin{:});
            
            % The improc2.getArgsForClassicProcessor helper function will
            % give you these two items into your runProcessor's workspace no matter
            % which one of the two sets of possible running parameters 
            % your runProcessor was called with.
            
            %% Considerations for post-processors:
            
            % If you are making a post-processor that depends on K other
            % processors (which you specified in the procDatasIDependOn
            % property in the constructor), you can rest assured that 
            % when this runProcessor is called, the first K arguments
            % (after p)
            % will be processors of precisely the
            % types you requested, in the order you requested them, and
            % with a guarantee that they have all been run already. 
           
            % After these K required processor inputs, your runProcessor
            % should be able to accept at least two more inputs:
            
            % the K+1 argument will be an ImageObject
            % the K+2 argument will be a 1 x K cell array of channelNames
            % saying which channel each one of the K necessary processors
            % came from (for a single channel post processor, these will
            % all be the same).
            
            % If you want, it can be more convenient to write this method
            % as:
            % function p = runProcessor(p, proc1, proc2, varargin)
            % for example, if K = 2. 
            % Then varargin{1} will be an image object and varargin{2} will
            % be the channelNames of the source processors.
          
            
            %% Considerations for all types of processors:
            
            
            
            
            
        end 
        
        %% 
    end
end

