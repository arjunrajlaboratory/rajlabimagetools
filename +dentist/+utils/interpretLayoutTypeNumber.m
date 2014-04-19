function [nextFileDirection, secondaryDirection, snakeOrNoSnake] = interpretLayoutTypeNumber(layoutType)
switch layoutType
    case 1  %Row no-snake   [1,2,3;4,5,6;7,8,9];
        nextFileDirection = 'right';
        secondaryDirection = 'down';
        snakeOrNoSnake = 'nosnake';
    case 2  %Row snake      [1,2,3;6,5,4;7,8,9];
        nextFileDirection = 'right';
        secondaryDirection = 'down';
        snakeOrNoSnake = 'snake';
    case 3  %Row-flipped no-snake   [3,2,1;6,5,4;9,8,7];
        nextFileDirection = 'left';
        secondaryDirection = 'down';
        snakeOrNoSnake = 'nosnake';
    case 4  %Row-flipped snake      [3,2,1;4,5,6;9,8,7];
        nextFileDirection = 'left';
        secondaryDirection = 'down';
        snakeOrNoSnake = 'snake';
    case 5  %Col no-snake   [1,4,7;2,5,8;3,6,9];
        nextFileDirection = 'down';
        secondaryDirection = 'right';
        snakeOrNoSnake = 'nosnake';
    case 6  %Col snakes     [1,6,7;2,5,8;3,4,9];
        nextFileDirection = 'down';
        secondaryDirection = 'right';
        snakeOrNoSnake = 'snake';
    case 7  %Col-flipped no-snake   [3,6,9;2,5,8;1,4,7];
        nextFileDirection = 'up';
        secondaryDirection = 'right';
        snakeOrNoSnake = 'nosnake';
    case 8  %Col-flipped snake      [3,4,9;2,5,8;1,6,7];
        nextFileDirection = 'up';
        secondaryDirection = 'right';
        snakeOrNoSnake = 'snake';
    case 9  %Col and row flipped no snake   [9,6,3;8,5,2;7,4,1]
        nextFileDirection = 'up';
        secondaryDirection = 'left';
        snakeOrNoSnake = 'nosnake';
    case 10 %Col and row flipped snake      [9,4,3;8,5,2;7,6,1]
        nextFileDirection = 'up';
        secondaryDirection = 'left';
        snakeOrNoSnake = 'snake';
    otherwise
        error('dentist:BadLayout', ...
            'Unrecognized Layout Type. Valid layouts are integers 1-10')
end
       
end
