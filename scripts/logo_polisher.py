from PIL import Image, ImageFilter
import os
import math

def master_polish(image_path, output_path):
    print(f"Master polishing: {image_path}")
    if not os.path.exists(image_path):
        print("Error: Logo file not found!")
        return

    # Open original and make it RGBA
    img = Image.open(image_path).convert("RGBA")
    width, height = img.size
    
    # Create the high-res cleaned data
    datas = img.getdata()
    new_data = []
    
    # ADVANCED ALGORITHM: Keying by Color Distance & Saturation
    for item in datas:
        r, g, b, a = item
        
        # 1. Calculate 'Neutrality' (is it gray/black?)
        avg = (r + g + b) / 3
        dist_from_gray = math.sqrt((r-avg)**2 + (g-avg)**2 + (b-avg)**2)
        
        # 2. Thresholds for Background (Black/Gray Grid)
        is_dark = r < 140 and g < 140 and b < 140
        is_gray = dist_from_gray < 15 # Very low saturation means it's part of the grid
        
        if is_dark and is_gray:
            # Check if it's the 'White Book' (high brightness)
            if r > 245 and g > 245 and b > 245:
                new_data.append(item) # Preserve the book
            else:
                # Fully transparent for background grid
                new_data.append((r, g, b, 0)) 
        else:
            # Preserve everything else (leaves, medical symbol)
            new_data.append(item)

    img.putdata(new_data)
    
    # 3. Anti-Aliasing (Refining the edges)
    # We blur the alpha channel slightly to remove the 'jagged' feel
    alpha = img.getchannel('A')
    alpha = alpha.filter(ImageFilter.SMOOTH)
    img.putalpha(alpha)
    
    img.save(output_path, "PNG")
    print(f"Successfully created high-res logo: {output_path}")

if __name__ == "__main__":
    input_p = r"c:\development\flutter-projects\graduation_project\assets\logo.png"
    output_p = r"c:\development\flutter-projects\graduation_project\assets\logo_hd.png"
    master_polish(input_p, output_p)
