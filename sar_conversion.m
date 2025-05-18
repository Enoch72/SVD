function sar_conversion(varargin)
% SAR_CONVERSION Process SAR images with colorbar normalization
%   Utilizzo:
%   Caso 1 - Conversione da SAR a colori:
%   sar_conversion('input', 'sar.png', 'colorbar', 'colorbar.png', 'output', 'result', 'N', 3)
%
%   Caso 2 - Da immagine B/N:
%   sar_conversion('bw_input', 'bw.png', 'colorbar', 'colorbar.png', 'output', 'result', 'N', 5)

    % Parsing parametri
    p = inputParser;
    
    % path immagine SAR a falsi colori da elaborare - SREMMARE PER USARE E REMMARE bw_input
    % addParameter(p, 'input', 'images/gransasso_image.png');
    
    % path colorbar scala valori - quello di default è ricavato dal paper
    addParameter(p, 'colorbar', 'images/colorbar.png');
    
    % path per elaborare una immagine convertita direttamente in scala di grigi - SREMMARE
    addParameter(p, 'bw_input', 'images/San_Gottardo.png');
    
    % Parte iniziale del nome delle 2 immagine in output: "_recolored.png" e "_bw.png" 
    addParameter(p, 'output', 'output');
    % Numero linee verticali adiacenti che verranno usate per la media
    addParameter(p, 'N', 5);
    parse(p, varargin{:});
    args = p.Results;
    
    pkg load image;

    % Estrazione colorbar
    colorbar_img = imread(args.colorbar);
    middle_x = floor(size(colorbar_img, 2)/2);
    colorbar_colors = squeeze(colorbar_img(:, middle_x, :));
    colorbar_colors = flipud(colorbar_colors); % Equivalente a [::-1]

    % Caricamento immagine B/N o conversione
    if isfield(args, 'bw_input') && ~isempty(args.bw_input)
        bw_img = imread(args.bw_input);
        if size(bw_img, 3) == 3
            gray_array = double(mean(bw_img, 3)); % Media lungo la 3a dimensione
        else
            gray_array = double(bw_img); % Immagine già in scala di grigi
        end
    else
        % Conversione grafico SAR colori -> B/N
        sar_img = imread(args.input);
        [height, width, ~] = size(sar_img);
        % Implementazione semplificata per ricerca colori
        sar_flat = reshape(sar_img, [], 3);
        gray_values = zeros(size(sar_flat, 1), 1);
        n = size(sar_flat, 1);
        for i = 1:n
            distances = sum((cast(colorbar_colors,"double") - cast(sar_flat(i, :),"double")).^2, 2);
            [~, idx] = min(distances);
            gray_values(i) = idx;
        end
        gray_array = reshape(gray_values, height, width) * 255 / size(colorbar_colors,1);
    end

    % Normalizzazione colonne
    adjusted_array = adjust_columns(gray_array, args.N,5);
    imwrite(uint8(adjusted_array), [args.output '_bw.png']);
    
    % Ricolorazione
    recolored = apply_colorbar(adjusted_array, colorbar_colors);
    imwrite(recolored, [args.output '_recolored.png']);
end

function adjusted = adjust_columns(img_array, N)
% ADJUST_COLUMNS Normalizza le colonne basate sulle adiacenti
    eps = 1e-8;
    column_means = mean(img_array, 1);
    
    % Implementazione sliding window
    padded = padarray(column_means, [0 N], 'symmetric');
    window_size = 2*N + 1;
    adjacent_means = zeros(1, length(column_means));
    
    for i = 1:length(column_means)
        window = padded(i:i+window_size-1);
        window(N+1) = []; % Esclude colonna centrale
        adjacent_means(i) = mean(window);
    end
    
    coefficients = adjacent_means ./ (column_means + eps);
    adjusted = img_array .* coefficients;
    adjusted = max(min(adjusted, 255), 0); % Clipping
end

function recolored = apply_colorbar(gray_img, colorbar_colors)
% APPLY_COLORBAR Riapplica la barra dei colori
    normalized = gray_img / 255;
    indices = round(normalized * (size(colorbar_colors, 1)-1)) + 1;
    recolored = colorbar_colors(indices, :);
    recolored = reshape(recolored, size(gray_img, 1), size(gray_img, 2), 3);
end

