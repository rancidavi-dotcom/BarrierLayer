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
    
    // Check if this is a Wine context (command line contains wine-related keywords)
    if (strstr(cmdline, "wine") != NULL || 
        strstr(cmdline, "wineboot") != NULL ||
        strstr(cmdline, "winemenubuilder") != NULL ||
        strstr(cmdline, "wineserver") != NULL ||
        strstr(cmdline, "proton") != NULL) {
        return 1; // This is a Wine-related process
    }
    
    // Check environment variables for Wine context (only if command line also suggests Wine)
    if ((strstr(cmdline, "wine") != NULL || strstr(cmdline, "proton") != NULL) &&
        (getenv("WINEPREFIX") || getenv("WINEDLLPATH") || getenv("WINE") || getenv("PROTON_VERSION"))) {
        return 1; // We're in a Wine environment with Wine command
    }
    
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
    // Check environment variable override to force hook all processes
    if (getenv("BARRIERLAYER_FORCE_ALL")) {
        return 0; // Force hook all processes
    }
    
    // Check if Wine-safe mode is explicitly disabled
    char *wine_safe_disabled = getenv("BARRIERLAYER_WINE_SAFE_DISABLED");
    if (wine_safe_disabled && strcmp(wine_safe_disabled, "1") == 0) {
        return 0; // Wine-safe mode disabled, hook all processes
    }
    
    // Default: ALWAYS enable Wine-safe mode (skip Wine system processes)
    // This is the safest behavior to prevent Wine corruption
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