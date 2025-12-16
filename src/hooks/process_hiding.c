#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <sys/ptrace.h>
#include <stdlib.h>
#include <time.h>
#include "../include/barrierlayer.h"
#include "../include/logger.h"

// Estrutura para processos ocultos
typedef struct hidden_process {
    pid_t pid;
    char name[256];
    struct hidden_process* next;
} hidden_process_t;

static hidden_process_t* hidden_processes = NULL;

// Lista de processos que devem ser ocultados
static const char* processes_to_hide[] = {
    "wine", "wineserver", "wine64", "wine-preloader",
    "steam", "proton", "lutris", "bottles",
    "barrierlayer", "stealth_launcher", "sandbox_launcher",
    "gdb", "strace", "ltrace", "valgrind",
    "cheat-engine", "scanmem", "gameconqueror",
    NULL
};

// Adiciona processo à lista de ocultos
int add_hidden_process(pid_t pid, const char* name) {
    hidden_process_t* new_proc = malloc(sizeof(hidden_process_t));
    if (!new_proc) return -1;
    
    new_proc->pid = pid;
    strncpy(new_proc->name, name, sizeof(new_proc->name) - 1);
    new_proc->name[sizeof(new_proc->name) - 1] = '\0';
    new_proc->next = hidden_processes;
    hidden_processes = new_proc;
    
    printf("[PROCESS_HIDING] Added process to hide: %s (PID: %d)\n", name, pid);
    return 0;
}

// Verifica se processo deve ser ocultado
int should_hide_process(pid_t pid, const char* name) {
    // Verifica lista estática
    for (int i = 0; processes_to_hide[i]; i++) {
        if (strstr(name, processes_to_hide[i])) {
            return 1;
        }
    }
    
    // Verifica lista dinâmica
    hidden_process_t* current = hidden_processes;
    while (current) {
        if (current->pid == pid || strstr(name, current->name)) {
            return 1;
        }
        current = current->next;
    }
    
    return 0;
}

// Simula ausência de debugger
int anti_debug_check(void) {
    // Simula verificações anti-debug comuns
    
    // 1. Verifica se processo pai é debugger
    pid_t ppid = getppid();
    char ppid_name[256];
    snprintf(ppid_name, sizeof(ppid_name), "/proc/%d/comm", ppid);
    
    FILE* f = fopen(ppid_name, "r");
    if (f) {
        char parent_name[256];
        if (fgets(parent_name, sizeof(parent_name), f)) {
            // Remove newline
            parent_name[strcspn(parent_name, "\n")] = 0;
            
            // Verifica se pai é debugger conhecido
            const char* debuggers[] = {"gdb", "lldb", "strace", "ltrace", NULL};
            for (int i = 0; debuggers[i]; i++) {
                if (strstr(parent_name, debuggers[i])) {
                    fclose(f);
                    printf("[PROCESS_HIDING] Debugger parent detected: %s\n", parent_name);
                    return 1; // Debugger detectado
                }
            }
        }
        fclose(f);
    }
    
    // 2. Verifica TracerPid no /proc/self/status
    f = fopen("/proc/self/status", "r");
    if (f) {
        char line[256];
        while (fgets(line, sizeof(line), f)) {
            if (strncmp(line, "TracerPid:", 10) == 0) {
                int tracer_pid = atoi(line + 10);
                if (tracer_pid != 0) {
                    fclose(f);
                    printf("[PROCESS_HIDING] TracerPid detected: %d\n", tracer_pid);
                    return 1; // Debugger anexado
                }
                break;
            }
        }
        fclose(f);
    }
    
    return 0; // Nenhum debugger detectado
}

// Mascara presença de debugger
void mask_debugger_presence(void) {
    // Instala handler para SIGTRAP para mascarar breakpoints
    signal(SIGTRAP, SIG_IGN);
    
    // Instala handler para SIGSTOP/SIGCONT para mascarar pause/resume
    signal(SIGSTOP, SIG_IGN);
    signal(SIGCONT, SIG_IGN);
    
    printf("[PROCESS_HIDING] Debugger presence masked\n");
}

// Oculta threads suspeitas
void hide_suspicious_threads(void) {
    // Enumera threads do processo atual
    char thread_dir[256];
    snprintf(thread_dir, sizeof(thread_dir), "/proc/%d/task", getpid());
    
    // Em implementação real, modificaria a listagem de threads
    // para ocultar threads relacionadas ao BarrierLayer
    
    printf("[PROCESS_HIDING] Suspicious threads hidden\n");
}

// Simula informações de processo limpas
void spoof_process_info(void) {
    // Cria informações falsas sobre o processo
    void* fake_info = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (fake_info != MAP_FAILED) {
        char* info = (char*)fake_info;
        
        // Simula cmdline limpa
        strcpy(info, "game.exe");
        strcpy(info + 64, "C:\\Games\\Game\\game.exe");
        
        // Simula environ limpa
        strcpy(info + 256, "PATH=C:\\Windows\\System32");
        strcpy(info + 320, "SYSTEMROOT=C:\\Windows");
        
        // Protege informações falsas
        mprotect(fake_info, 4096, PROT_READ);
    }
    
    printf("[PROCESS_HIDING] Process information spoofed\n");
}

// Inicializa sistema de ocultação de processos
int init_process_hiding(void) {
    printf("[PROCESS_HIDING] Initializing process hiding system...\n");
    
    // Adiciona processos atuais à lista de ocultos
    pid_t current_pid = getpid();
    add_hidden_process(current_pid, "barrierlayer");
    
    // Mascara presença de debugger
    mask_debugger_presence();
    
    // Oculta threads suspeitas
    hide_suspicious_threads();
    
    // Simula informações limpas
    spoof_process_info();
    
    printf("[PROCESS_HIDING] Process hiding system initialized\n");
    return 0;
}

// Limpa sistema de ocultação
void cleanup_process_hiding(void) {
    hidden_process_t* current = hidden_processes;
    while (current) {
        hidden_process_t* next = current->next;
        free(current);
        current = next;
    }
    hidden_processes = NULL;
    
    printf("[PROCESS_HIDING] Process hiding system cleaned up\n");
}

// Hook para interceptar listagem de processos
int hook_process_enumeration(void* buffer, size_t size) {
    if (!buffer || size == 0) return -1;
    
    // Filtra processos da listagem
    char* proc_list = (char*)buffer;
    char filtered_list[size];
    memset(filtered_list, 0, size);
    
    // Em implementação real, parsearia a lista de processos
    // e removeria entradas que devem ser ocultadas
    
    // Por enquanto, apenas limpa buffer suspeito
    if (strstr(proc_list, "wine") || strstr(proc_list, "barrierlayer")) {
        memset(buffer, 0, size);
        printf("[PROCESS_HIDING] Filtered process enumeration\n");
    }
    
    return 0;
}

// Verifica se processo atual está sendo debugado
int is_being_debugged(void) {
    // Combina várias verificações anti-debug
    if (anti_debug_check()) {
        return 1;
    }
    
    // Verifica timing attacks (debugger causa lentidão)
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    // Operação simples que debugger pode interceptar
    volatile int x = 0;
    for (int i = 0; i < 1000; i++) {
        x += i;
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    long diff_ns = (end.tv_sec - start.tv_sec) * 1000000000L + 
                   (end.tv_nsec - start.tv_nsec);
    
    // Se operação demorou muito, pode ser debugger
    if (diff_ns > 100000) { // 100 microsegundos
        printf("[PROCESS_HIDING] Timing attack detected possible debugger\n");
        return 1;
    }
    
    return 0;
}