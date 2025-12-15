/*
 * Wine Process Filter Header
 */

#ifndef WINE_PROCESS_FILTER_H
#define WINE_PROCESS_FILTER_H

#ifdef __cplusplus
extern "C" {
#endif

// Check if current process is a Wine system process
int is_wine_system_process(void);

// Check if we should skip BarrierLayer initialization
int should_skip_barrierlayer(void);

// Get current process info for logging
void get_process_info(char *buffer, size_t size);

#ifdef __cplusplus
}
#endif

#endif // WINE_PROCESS_FILTER_H