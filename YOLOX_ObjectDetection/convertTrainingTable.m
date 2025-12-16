NEWSTR = string(zeros(size(FileNames)));
for ii = 1:size(FileNames,1)
    ii
    Name = char(FileNames(ii));
    spl = split(Name, '\');
    fileName = spl{3};
    spl2 = split(fileName, '_');

    if length(spl2{end}) == 7
        spl2{end} = ['0', spl2{end}];
    end
    spl2{end-1} = spl2{end-1}(1:end-1);

    newName = join( string(spl2), "_");
    NEWSTR(ii) = newName;
end

