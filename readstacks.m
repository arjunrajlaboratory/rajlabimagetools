% This is a helper function for trying to make images for publication.
% It basically just extracts images from a set of stacks (pass '045' into
% stackNumber). Also creates some basic max-merges. Should hopefully help
% with some boilerplate code for loading a stack.

function output = readstacks(stackNumber)

listing = dir(['*' stackNumber '.tif*']);

for i = 1:length(listing)
    temp = readmm(listing(i).name);
    output.(listing(i).name(1:(strfind(listing(i).name,stackNumber)-1))) = temp.imagedata;
    output.(['mx' listing(i).name(1:(strfind(listing(i).name,stackNumber)-1))]) = max(temp.imagedata,[],3);
    output.(['scaledmx' listing(i).name(1:(strfind(listing(i).name,stackNumber)-1))]) = scale(max(temp.imagedata,[],3));
end
