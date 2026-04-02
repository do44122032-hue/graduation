import os
from rembg import remove
from PIL import Image

def main():
    input_path = r"c:\development\flutter-projects\graduation_project\assets\logo.png"
    output_path = r"c:\development\flutter-projects\graduation_project\assets\logo_clean_ai.png"
    
    print(f"Loading image from {input_path}")
    if not os.path.exists(input_path):
        print("Error: Input logo does not exist")
        return

    try:
        input_image = Image.open(input_path)
        print("Removing background using rembg AI model...")
        
        # remove() takes a PIL image and returns a PIL image with the background removed
        output_image = remove(input_image)
        
        output_image.save(output_path)
        print(f"Successfully saved clean logo to {output_path}")
        
    except Exception as e:
        print(f"Error during background removal: {e}")

if __name__ == "__main__":
    main()
