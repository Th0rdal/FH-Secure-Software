#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "extension.h"

#define MAX_UPLOAD_SIZE (5 * 1024 * 1024) // 5 MB
#define MAX_FILENAME_LENGTH 255

static int check_file_policy(const char* extension) {
    const char* blocked_types[] = { ".exe", ".dll", ".sh", ".php", ".bat" };
    int num_blocked = 5; 

    for (int i = 0; i < num_blocked; i++) {
        if (strcmp(extension, blocked_types[i]) == 0) {
            return -1;
        }
    }
    return 0;
}

static void sanitize_filename(char* filename) {
    for (int i = 0; filename[i] != '\0'; i++) {
        if (!isalnum((unsigned char)filename[i]) && filename[i] != '.' && filename[i] != '_') {
            filename[i] = '_';
        }
    }
}

int processImageUpload(const char* original_filename, long file_size_bytes) {
    if (file_size_bytes > MAX_UPLOAD_SIZE) {
        return -1;
    }
    
    if (original_filename == NULL) {
        return -1;
    }

    char filename_copy[MAX_FILENAME_LENGTH];
    strncpy(filename_copy, original_filename, MAX_FILENAME_LENGTH - 1);
    filename_copy[MAX_FILENAME_LENGTH - 1] = '\0'; // Null-Terminierung sicherstellen

    sanitize_filename(filename_copy);

    // Finde Dateierweiterung
    const char* dot = strrchr(filename_copy, '.');
    if (!dot || dot == filename_copy) {
        return -1;
    }
    const char* extension = dot;

    if (check_file_policy(extension) != 0) {
        return -1;
    }

    return 0;
}