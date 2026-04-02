from PIL import Image
import os

def aggressive_clean(image_path):
    print(f"Aggressively cleaning logo: {image_path}")
    if not os.path.exists(image_path):
        print("Error: Logo file not found!")
        return

    # Open the image
    img = Image.open(image_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    
    # Checkered patterns often use grays like (40,40,40) or (60,60,60)
    # Raising threshold to 110 to be sure we catch all grays
    for item in datas:
        r, g, b, a = item
        
        # If it's dark (RGB values are close to each other and low)
        # OR if it's clearly part of the dark background grid
        is_gray_scale = abs(r-g) < 20 and abs(g-b) < 20 and abs(r-b) < 20
        if is_gray_scale and r < 110: # Threshold 110 captures all dark grays
            new_data.append((0, 0, 0, 0)) # Make Transparent
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(image_path, "PNG")
    print("Aggressive cleaning complete!")

if __name__ == "__main__":
    path = r"c:\development\flutter-projects\graduation_project\assets\logo.png"
    aggressive_clean(path)
