import os
import time

dir_name = "../.godot/editor"
test = os.listdir(dir_name)

for item in test:
    if item.startswith("Card."):
        os.remove(os.path.join(dir_name, item))
        print(item)
