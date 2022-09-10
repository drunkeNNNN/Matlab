function matrix = clamp(matrix, lower, higher)
    matrix(matrix>higher)=higher;
    matrix(matrix<lower)=lower;
end

