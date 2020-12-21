function [output, size_y] = image_process(img)
    output = 0;
    img = imresize(img, 0.2);
    [size_x, size_y] = size(img);
    img = imbinarize(img);
    img = 1 - img;
    cclabel = bwlabel(img);
    idx_tmp = size_y / 2;
    cnt_tmp = 0;
    sign_tmp = 0;
    while cclabel(size_x, idx_tmp) == 0
        cnt_tmp = cnt_tmp + 1;
        sign_tmp = 1 - sign_tmp;
        idx_tmp = idx_tmp + (-1)^sign_tmp * cnt_tmp;
        if (idx_tmp > size_y || idx_tmp < 1)
            return
        end
    end
    
    img = zeros(size_x, size_y);
    img(cclabel == cclabel(size_x, idx_tmp)) = 1;
    win_x = 10;
    win_y = size_y;
    k1 = size_y / 2 + win_y / 2;
    cnt = 1;
    out = 0;
    for i = 1 : win_x
        for j = 1 : win_y
            k2 = k1 + 1 - j;
            if (img(size_x + 1 - i, k2) == 1)
                out = out + size_y + 1 - k2;
                cnt = cnt + 1;
            end
        end
    end
%     imshow(img);
    out = round(out/cnt);
    
    persistent last_err;
    if isempty(last_err)
        last_err = 0;
    end
    err = size_y/2 - out;
    if (abs(err) <= 5)
        output = 0;
    else
        output = err * 0.5 + 5 * (err - last_err);
    end
    last_err = err;
end