from PIL import Image
import numpy as np
from scipy.spatial import cKDTree
from numpy.lib.stride_tricks import sliding_window_view
import argparse

def adjust_columns(image_array, N=5, eps=1e-8):
    """Normalizza le colonne basandosi sulle N colonne adiacenti"""
    column_means = np.mean(image_array.astype(np.float32), axis=0)
    padded_means = np.pad(column_means, (N, N), mode='reflect')
    windows = sliding_window_view(padded_means, 2*N + 1)
    mask = np.ones(2*N + 1, dtype=bool)
    mask[N] = False
    adjacent_means = np.mean(windows[:, mask], axis=1)
    coefficients = adjacent_means / (column_means + eps)
    adjusted = np.clip(image_array.astype(np.float32) * coefficients, 0, 255)
    return adjusted.astype(np.uint8)

def apply_colorbar(gray_image_array, colorbar_colors):
    """Riapplica la barra dei colori"""
    normalized = np.clip(gray_image_array.astype(np.float32)/255.0, 0.0, 1.0)
    indices = (normalized * (len(colorbar_colors)-1)).astype(np.int32)
    return colorbar_colors[indices]

def process_image(args):
    """Funzione principale di elaborazione"""
    # Carica la colorbar
    colorbar = Image.open(args.colorbar).convert("RGB")
    colorbar_array = np.array(colorbar)
    middle_x = colorbar_array.shape[1] // 2
    colorbar_colors = colorbar_array[:, middle_x, :3][::-1]

    # Carica l'immagine in B/N o converti dalla SAR
    if args.bw_input:
        bw_image = Image.open(args.bw_input).convert("L")
        gray_array = np.array(bw_image)
    else:
        # Conversione da SAR a B/N
        sar_img = Image.open(args.input).convert("RGB")
        color_tree = cKDTree(colorbar_colors)
        values = np.linspace(0, 1, len(colorbar_colors))
        sar_pixels = np.array(sar_img).reshape(-1, 3)
        
        # Interpolazione bilineare
        distances, indices = color_tree.query(sar_pixels, k=2)
        sar_expanded = sar_pixels[:, np.newaxis, :]
        color_samples = colorbar_colors[indices]
        diff = sar_expanded - color_samples
        distances = np.linalg.norm(diff, axis=2)
        
        weights = 1 / (distances + 1e-8)
        weights /= weights.sum(axis=1, keepdims=True)
        gray_values = np.sum(values[indices] * weights, axis=1) * 255
        gray_array = gray_values.reshape(sar_img.size[::-1]).astype(np.uint8)

    # Normalizzazione colonne e salvataggio
    adjusted_array = adjust_columns(gray_array, N=args.N)
    #adjusted_array = adjust_columns(adjusted_array, N=args.N)
    #adjusted_array = adjust_columns(adjusted_array, N=args.N)
    Image.fromarray(adjusted_array, 'L').save(f"{args.output}_bw.png")

    # Ricolorazione e salvataggio
    recolored_array = apply_colorbar(adjusted_array, colorbar_colors)
    Image.fromarray(recolored_array, 'RGB').save(f"{args.output}_recolored.png")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Elaborazione immagini SAR/B/N')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--input',  help='Path immagine SAR originale (RGB)')
    group.add_argument('--bw_input', help='Path immagine già convertita in B/N')
    parser.add_argument('--colorbar', required=True, help='Path colorbar di riferimento')
    parser.add_argument('--output', required=True, help='Nome base output')
    parser.add_argument('--N', type=int, default=5, help='Colonne adiacenti per normalizzazione')
    
    args = parser.parse_args()
    process_image(args)

    #esempio di elaborazione immagine direttamente in bianco e nero
    #python3 sar5.py --input sar2_image.png --colorbar colorbar.png --output sar2_test --N 10

    #esempio di elaborazione immagine direttamente in bianco e nero
    #python3 sar5.py --bw_input San_Gottardo.png --colorbar colorbar.png --output SanGottardo --N 10

    