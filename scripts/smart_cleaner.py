from PIL import Image
import os

def smart_clean(image_path, output_path):
    print(f"Smart cleaning: {image_path}")
    if not os.path.exists(image_path):
        print("Error: Logo file not found!")
        return

    img = Image.open(image_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    for item in datas:
        r, g, b, a = item
        
        # SMART CHECK:
        # Checkered backgrounds are always 'Neutral' (R, G, and B are very similar)
        # Colorful leaves have high 'Saturation' (R, G, and B are very different)
        diff_rg = abs(r - g)
        diff_gb = abs(g - b)
        diff_rb = abs(r - b)
        
        is_neutral = diff_rg < 20 and diff_gb < 20 and diff_rb < 20
        
        # If it's neutral (Gray/Black/White)
        if is_neutral:
            # If it's not the bright white book (threshold 240)
            if r < 240:
                new_data.append((0, 0, 0, 0)) # Make Transparent
            else:
                new_data.append(item) # Keep the White Book
        else:
            new_data.append(item) # Keep the colorful leaves

    img.putdata(new_data)
    img.save(output_path, "PNG")
    print(f"Successfully saved clean logo to: {output_path}")

if __name__ == "__main__":
    input_p = r"c:\development\flutter-projects\graduation_project\assets\logo.png"
    output_p = r"c:\development\flutter-projects\graduation_project\assets\logo_clean.png"
    smart_clean(input_p, output_p)
