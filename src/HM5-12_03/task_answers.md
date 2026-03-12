## Bash scripts

| Exercise | Description | Source Code | Execution Result |
| :--- | :--- | :--- | :--- |
| **1: Hello World** | Echoes "Hello, World!" | [1.sh](scripts/1.sh) | ![Result 1](assets/res_1.png) |
| **2: User Input** | Asks for name and greets user | [2.sh](scripts/2.sh) | ![Result 2](assets/res_2.png) |
| **3: Conditional Statements** | Checks if a file exists | [3.sh](scripts/3.sh) | ![Result 3](assets/res_3.png) |
| **4: Looping** | Prints numbers 1 to 10 | [4.sh](scripts/4.sh) | ![Result 4](assets/res_4.png) |
| **5: File Operations** | Copies file from A to B | [5.sh](scripts/5.sh) | ![Result 5](assets/res_5.png) |
| **6: String Manipulation** | Reverses a sentence word by word | [6.sh](scripts/6.sh) | ![Result 6](assets/res_6.png) |
| **7: Command Line Arguments** | Prints number of lines in a file | [7.sh](scripts/7.sh) | ![Result 7](assets/res_7.png) |
| **8: Arrays** | Loops through a list of fruits | [8.sh](scripts/8.sh) | ![Result 8](assets/res_8.png) |
| **9: Error Handling** | Reads file safely with error message | [9.sh](scripts/9.sh) | ![Result 9](assets/res_9.png) |

## Systemd service for monitor files

| Task | Description | Files                                                                     | Execution Result                                |
| :--- | :--- |:--------------------------------------------------------------------------|:------------------------------------------------|
| **Directory Watcher** | Background service that monitors a folder for new files and automatically renames them. | [watch.sh](scripts/watch.sh) <br> [watch.service](services/watch.service) | ![Service Status](assets/res_service_watch.png) |
