#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <pthread.h>
#include <stdarg.h>
#include "../include/logger.h"

#define MAX_LOG_BUFFER 8192
#define MAX_LOG_ENTRIES 10000
#define LOG_DIR "/var/log/barrierlayer"
#define MAIN_LOG_FILE LOG_DIR "/barrierlayer.log"
#define ANTICHEAT_LOG_FILE LOG_DIR "/anticheat.log"
#define KERNEL_LOG_FILE LOG_DIR "/kernel.log"
#define DEBUG_LOG_FILE LOG_DIR "/debug.log"

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

// Estrutura de entrada de log
typedef struct log_entry {
    time_t timestamp;
    log_level_t level;
    log_category_t category;
    pid_t pid;
    char message[MAX_LOG_BUFFER];
    struct log_entry* next;
} log_entry_t;

// Buffer circular para logs
static log_entry_t* log_buffer = NULL;
static int log_count = 0;
static int current_log_level = LOG_LEVEL_INFO;
static pthread_mutex_t log_mutex = PTHREAD_MUTEX_INITIALIZER;
static FILE* log_files[7] = {NULL}; // Um arquivo para cada categoria

// Nomes dos níveis de log
static const char* level_names[] = {
    "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"
};

// Nomes das categorias
static const char* category_names[] = {
    "GENERAL", "ANTICHEAT", "KERNEL", "MEMORY", "PROCESS", "NETWORK", "DEBUG"
};

// Caminhos dos arquivos de log
static const char* log_file_paths[] = {
    MAIN_LOG_FILE,      // GENERAL
    ANTICHEAT_LOG_FILE, // ANTICHEAT
    KERNEL_LOG_FILE,    // KERNEL
    MAIN_LOG_FILE,      // MEMORY (vai para main)
    MAIN_LOG_FILE,      // PROCESS (vai para main)
    MAIN_LOG_FILE,      // NETWORK (vai para main)
    DEBUG_LOG_FILE      // DEBUG
};

// Inicializa sistema de logging
int advanced_logger_init(void) {
    // Cria diretório de logs se não existir
    struct stat st = {0};
    if (stat(LOG_DIR, &st) == -1) {
        if (mkdir(LOG_DIR, 0755) != 0) {
            perror("Failed to create log directory");
            return -1;
        }
    }
    
    // Abre arquivos de log
    for (int i = 0; i < 7; i++) {
        if (!log_files[i]) {
            log_files[i] = fopen(log_file_paths[i], "a");
            if (!log_files[i]) {
                printf("Warning: Could not open log file %s\n", log_file_paths[i]);
            }
        }
    }
    
    // Aloca buffer de logs
    log_buffer = calloc(MAX_LOG_ENTRIES, sizeof(log_entry_t));
    if (!log_buffer) {
        printf("Error: Could not allocate log buffer\n");
        return -1;
    }
    
    printf("[ADVANCED_LOGGER] Logging system initialized\n");
    return 0;
}

// Define nível mínimo de log
void set_log_level(int level) {
    if (level >= LOG_LEVEL_DEBUG && level <= LOG_LEVEL_CRITICAL) {
        current_log_level = level;
        printf("[ADVANCED_LOGGER] Log level set to %s\n", level_names[level]);
    }
}

// Função interna para escrever log
static void write_log_entry(log_level_t level, log_category_t category, const char* format, va_list args) {
    if (level < current_log_level) return;
    
    pthread_mutex_lock(&log_mutex);
    
    // Cria entrada de log
    log_entry_t* entry = &log_buffer[log_count % MAX_LOG_ENTRIES];
    entry->timestamp = time(NULL);
    entry->level = level;
    entry->category = category;
    entry->pid = getpid();
    
    vsnprintf(entry->message, MAX_LOG_BUFFER, format, args);
    
    // Formata timestamp
    char time_str[64];
    struct tm* tm_info = localtime(&entry->timestamp);
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", tm_info);
    
    // Escreve para arquivo apropriado
    FILE* log_file = log_files[category];
    if (log_file) {
        fprintf(log_file, "[%s] [%s] [%s] [PID:%d] %s\n",
                time_str, level_names[level], category_names[category],
                entry->pid, entry->message);
        fflush(log_file);
    }
    
    // Escreve para stdout se for crítico
    if (level >= LOG_LEVEL_ERROR) {
        printf("[%s] [%s] [%s] %s\n",
               time_str, level_names[level], category_names[category],
               entry->message);
    }
    
    log_count++;
    pthread_mutex_unlock(&log_mutex);
}

// Funções de logging por nível
void log_debug(log_category_t category, const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_DEBUG, category, format, args);
    va_end(args);
}

void log_info(log_category_t category, const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, category, format, args);
    va_end(args);
}

void log_warning(log_category_t category, const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_WARNING, category, format, args);
    va_end(args);
}

void log_error(log_category_t category, const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_ERROR, category, format, args);
    va_end(args);
}

void log_critical(log_category_t category, const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_CRITICAL, category, format, args);
    va_end(args);
}

// Funções específicas para cada categoria
void log_anticheat(const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, LOG_CAT_ANTICHEAT, format, args);
    va_end(args);
}

void log_kernel(const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, LOG_CAT_KERNEL, format, args);
    va_end(args);
}

void log_memory(const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, LOG_CAT_MEMORY, format, args);
    va_end(args);
}

void log_process(const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, LOG_CAT_PROCESS, format, args);
    va_end(args);
}

void log_network(const char* format, ...) {
    va_list args;
    va_start(args, format);
    write_log_entry(LOG_LEVEL_INFO, LOG_CAT_NETWORK, format, args);
    va_end(args);
}

// Dump do buffer de logs
void dump_log_buffer(const char* filename) {
    pthread_mutex_lock(&log_mutex);
    
    FILE* dump_file = fopen(filename, "w");
    if (!dump_file) {
        printf("Error: Could not create dump file %s\n", filename);
        pthread_mutex_unlock(&log_mutex);
        return;
    }
    
    fprintf(dump_file, "BarrierLayer Log Dump - Total entries: %d\n", log_count);
    fprintf(dump_file, "=====================================\n\n");
    
    int start = (log_count > MAX_LOG_ENTRIES) ? log_count - MAX_LOG_ENTRIES : 0;
    for (int i = start; i < log_count; i++) {
        log_entry_t* entry = &log_buffer[i % MAX_LOG_ENTRIES];
        
        char time_str[64];
        struct tm* tm_info = localtime(&entry->timestamp);
        strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", tm_info);
        
        fprintf(dump_file, "[%s] [%s] [%s] [PID:%d] %s\n",
                time_str, level_names[entry->level], 
                category_names[entry->category],
                entry->pid, entry->message);
    }
    
    fclose(dump_file);
    pthread_mutex_unlock(&log_mutex);
    
    printf("[ADVANCED_LOGGER] Log buffer dumped to %s\n", filename);
}

// Rotaciona logs quando ficam muito grandes
void rotate_logs(void) {
    pthread_mutex_lock(&log_mutex);
    
    for (int i = 0; i < 7; i++) {
        if (log_files[i]) {
            fclose(log_files[i]);
            
            // Renomeia arquivo atual
            char old_name[512], new_name[512];
            snprintf(old_name, sizeof(old_name), "%s", log_file_paths[i]);
            snprintf(new_name, sizeof(new_name), "%s.old", log_file_paths[i]);
            rename(old_name, new_name);
            
            // Reabre arquivo
            log_files[i] = fopen(log_file_paths[i], "a");
        }
    }
    
    pthread_mutex_unlock(&log_mutex);
    printf("[ADVANCED_LOGGER] Logs rotated\n");
}

// Limpa sistema de logging
void advanced_logger_cleanup(void) {
    pthread_mutex_lock(&log_mutex);
    
    // Fecha arquivos de log
    for (int i = 0; i < 7; i++) {
        if (log_files[i]) {
            fclose(log_files[i]);
            log_files[i] = NULL;
        }
    }
    
    // Libera buffer
    if (log_buffer) {
        free(log_buffer);
        log_buffer = NULL;
    }
    
    pthread_mutex_unlock(&log_mutex);
    printf("[ADVANCED_LOGGER] Logging system cleaned up\n");
}

// Estatísticas de logging
void print_log_stats(void) {
    pthread_mutex_lock(&log_mutex);
    
    int level_counts[5] = {0};
    int category_counts[7] = {0};
    
    int start = (log_count > MAX_LOG_ENTRIES) ? log_count - MAX_LOG_ENTRIES : 0;
    for (int i = start; i < log_count; i++) {
        log_entry_t* entry = &log_buffer[i % MAX_LOG_ENTRIES];
        level_counts[entry->level]++;
        category_counts[entry->category]++;
    }
    
    printf("\n=== BarrierLayer Log Statistics ===\n");
    printf("Total log entries: %d\n", log_count);
    printf("\nBy level:\n");
    for (int i = 0; i < 5; i++) {
        printf("  %s: %d\n", level_names[i], level_counts[i]);
    }
    printf("\nBy category:\n");
    for (int i = 0; i < 7; i++) {
        printf("  %s: %d\n", category_names[i], category_counts[i]);
    }
    printf("===================================\n\n");
    
    pthread_mutex_unlock(&log_mutex);
}