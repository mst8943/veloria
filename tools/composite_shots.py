import sys
from PIL import Image, ImageDraw, ImageFont

def make_grid(image_paths, output_path, cols=2, labels=None):
    images = [Image.open(p) for p in image_paths]
    if not images:
        return
    # target size for thumbnails
    tw, th = 800, 450
    rows = (len(images) + cols - 1) // cols
    header_h = 30
    grid_w = cols * tw
    grid_h = rows * (th + header_h)
    
    out = Image.new("RGB", (grid_w, grid_h), (20, 18, 16))
    draw = ImageDraw.Draw(out)
    
    for i, im in enumerate(images):
        r = i // cols
        c = i % cols
        x = c * tw
        y = r * (th + header_h)
        lbl = labels[i] if labels and i < len(labels) else f"Screen {i+1}"
        draw.text((x + 10, y + 6), lbl, fill=(214, 178, 94))
        resized = im.resize((tw, th), Image.Resampling.LANCZOS)
        out.paste(resized, (x, y + header_h))
        # 1px border around image
        draw.rectangle([x, y + header_h, x + tw - 1, y + header_h + th - 1], outline=(169, 142, 80))
        
    out.save(output_path, "JPEG", quality=90)
    print(f"Saved comparison to {output_path}")

if __name__ == "__main__":
    # Test call
    pass
