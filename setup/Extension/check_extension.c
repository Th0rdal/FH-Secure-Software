#include <stdio.h>
#include "extension.h" 

/**
 Kann durch whitelist oder exzessive blacklist gelöst werden
 Checkt ob Bilder hochgeladen werden dürfen
 Checkt ob vorherige Extensions weiterhin blockiert werden
 Checkt ob blacklist erweitert wurde
 */

#define RUN_TEST(test_condition) \
    do { \
        if (!(test_condition)) { \
            printf("failed\n"); \
            return 1; \
        } \
    } while(0)


int main() {

    long valid_size = 1000; // definitiv nicht zu groß

    // === Gültige Uploads ===
    RUN_TEST(processImageUpload("foto.jpg", valid_size) == 0);
    RUN_TEST(processImageUpload("foto.png", valid_size) == 0);

    // === Original-Blacklist ===
    RUN_TEST(processImageUpload("virus.exe", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.dll", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.sh", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.php", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.bat", valid_size) == -1);

    // === Zusätzliche Dateien ===
    RUN_TEST(processImageUpload("virus.ps1", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.py", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.cmd", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.js", valid_size) == -1);
    RUN_TEST(processImageUpload("virus.js", valid_size) == -1);
    RUN_TEST(processImageUpload("normal.txt", valid_size) == -1);
    RUN_TEST(processImageUpload("normal.log", valid_size) == -1);
    RUN_TEST(processImageUpload("normal.mp3", valid_size) == -1);
    RUN_TEST(processImageUpload("normal.mov", valid_size) == -1);

    // Wenn vorher nicht beendet dann successful
    printf("successful\n");
    return 0; 
}