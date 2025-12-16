#ifndef ADVANCED_LOGGER_H
#define ADVANCED_LOGGER_H

#include <stdarg.h>
#include <sys/types.h>

// Níveis de log
typedef enum {
    LOG_LEVEL_DEBUG = 0,
    LOG_LEVEL_INFO = 1,
    LOG_LEVEL_WARNING = 2,
    LOG_LEVEL_ERROR = 3,
    LOG_LEVEL_CRITICAL = 4
} log_level_t;

// Categorias de log
typedef enum {
    LOG_CAT_GENERAL = 0,
    LOG_CAT_ANTICHEAT = 1,
    LOG_CAT_KERNEL = 2,
    LOG_CAT_MEMORY = 3,
    LOG_CAT_PROCESS = 4,
    LOG_CAT_NETWORK = 5,
    LOG_CAT_DEBUG = 6
} log_category_t;

// Funções principais
int advanced_logger_init(void);
void advanced_logger_cleanup(void);
void set_log_level(int level);

// Funções de logging por nível
void log_debug(log_category_t category, const char* format, ...);
void log_info(log_category_t category, const char* format, ...);
void log_warning(log_category_t category, const char* format, ...);
void log_error(log_category_t category, const char* format, ...);
void log_critical(log_category_t category, const char* format, ...);

// Funções específicas por categoria
void log_anticheat(const char* format, ...);
void log_kernel(const char* format, ...);
void log_memory(const char* format, ...);
void log_process(const char* format, ...);
void log_network(const char* format, ...);

// Utilitários
void dump_log_buffer(const char* filename);
void rotate_logs(void);
void print_log_stats(void);

#endif // ADVANCED_LOGGER_H