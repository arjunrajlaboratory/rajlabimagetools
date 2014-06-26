function errorIfInvalid(x)
    % image objects Array collection navigator checks that objects
    % are valid iamgeobjects before loading an objects array.
    % if an image object class does not define an errorIfInvalid
    % function, this will be used instead: a no-op that will accept
    % anything and not throw an error.
end