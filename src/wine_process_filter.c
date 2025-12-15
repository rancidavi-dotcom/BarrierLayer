/*
 * Wine Process Filter - Prevent BarrierLayer injection in Wine system processes
 * 
 * This module prevents BarrierLayer from hooking critical Wine system processes
 * that are part of the Wine bootstrap and runtime infrastructure.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Wine system processes that should NOT be hooked
static const char* wine_system_processes[] = {
    "svchost.exe",
    "services.exe", 
    "plugplay.exe",
    "winedevice.exe",
    "winebus.exe",
    "wineusb.exe",
    "explorer.exe",
    "wineboot.exe",
    "winemenubuilder.exe",
    "wineserver",
    "winecfg.exe",
    "regedit.exe",
    "taskmgr.exe",
    "wineconsole.exe",
    "conhost.exe",
    NULL
};

// Check if current process is a Wine system process
int is_wine_system_process(void) {
    char cmdline[1024];
    char process_name[256];
    FILE *fp;
    
    // Read process command line
    fp = fopen("/proc/self/cmdline", "r");
    if (!fp) return 0;
    
    if (fgets(cmdline, sizeof(cmdline), fp) == NULL) {
        fclose(fp);
        return 0;
    }
    fclose(fp);
    
    // Extract process name from command line
    char *last_slash = strrchr(cmdline, '/');
    char *last_backslash = strrchr(cmdline, '\\');
    char *process_start = cmdline;
    
    if (last_slash && (!last_backslash || last_slash > last_backslash)) {
        process_start = last_slash + 1;
    } else if (last_backslash) {
        process_start = last_backslash + 1;
    }
    
    // Copy process name
    strncpy(process_name, process_start, sizeof(process_name) - 1);
    process_name[sizeof(process_name) - 1] = '\0';
    
    // Remove arguments (space or null terminator)
    char *space = strchr(process_name, ' ');
    if (space) *space = '\0';
    
    // Check against blacklist
    for (int i = 0; wine_system_processes[i]; i++) {
        if (strstr(process_name, wine_system_processes[i]) != NULL) {
            return 1; // This is a Wine system process
        }
    }
    
    return 0; // Not a Wine system process
}

// Check if we should skip BarrierLayer initialization
int should_skip_barrierlayer(void) {
    // Check environment variable override
    if (getenv("BARRIERLAYER_FORCE_ALL")) {
        return 0; // Force hook all processes
    }
    
    if (getenv("BARRIERLAYER_WINE_SAFE")) {
        return is_wine_system_process();
    }
    
    // Default: skip Wine system processes
    return is_wine_system_process();
}

// Get current process info for logging
void get_process_info(char *buffer, size_t size) {
    char cmdline[1024];
    FILE *fp;
    
    fp = fopen("/proc/self/cmdline", "r");
    if (!fp) {
        snprintf(buffer, size, "unknown");
        return;
    }
    
    if (fgets(cmdline, sizeof(cmdline), fp) == NULL) {
        fclose(fp);
        snprintf(buffer, size, "unknown");
        return;
    }
    fclose(fp);
    
    // Replace null bytes with spaces for readability
    for (int i = 0; i < strlen(cmdline); i++) {
        if (cmdline[i] == '\0') cmdline[i] = ' ';
    }
    
    snprintf(buffer, size, "%.200s", cmdline);
}