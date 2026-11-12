/* Browser-demo helper. Uses only Windows 2000 APIs and no C runtime. */
#define WINVER 0x0500
#define _WIN32_WINNT 0x0500
#include <windows.h>

static BOOL contains(const char *text, const char *needle)
{
    for (; *text; ++text) {
        const char *a = text, *b = needle;
        while (*a && *b && *a == *b) { ++a; ++b; }
        if (!*b) return TRUE;
    }
    return FALSE;
}

static BOOL CALLBACK check_message(HWND child, LPARAM found)
{
    char text[1024], class_name[32];
    if (!GetClassNameA(child, class_name, sizeof(class_name)) ||
        lstrcmpA(class_name, "Static")) return TRUE;
    text[0] = 0;
    /* GetWindowText cannot read another process's static-control text. */
    if (SendMessageTimeoutA(child, WM_GETTEXT, sizeof(text), (LPARAM)text,
            SMTO_ABORTIFHUNG | SMTO_BLOCK, 100, NULL) &&
        contains(text, "Windows 2000 has finished installing new devices.") &&
        contains(text, "Do you want to restart your computer now?")) {
        *(BOOL *)found = TRUE;
        return FALSE;
    }
    return TRUE;
}

static BOOL CALLBACK decline_restart(HWND dialog, LPARAM unused)
{
    char title[128], class_name[32];
    BOOL found = FALSE;
    HWND no;
    (void)unused;
    if (!GetWindowTextA(dialog, title, sizeof(title)) ||
        lstrcmpA(title, "System Settings Change")) return TRUE;
    if (!GetClassNameA(dialog, class_name, sizeof(class_name)) ||
        lstrcmpA(class_name, "#32770")) return TRUE;
    no = GetDlgItem(dialog, IDNO);
    if (!no || !GetDlgItem(dialog, IDYES) || !IsWindowEnabled(no)) return TRUE;
    EnumChildWindows(dialog, check_message, (LPARAM)&found);
    if (found) {
        /* Target the No button directly; never change focus or inject keys. */
        PostMessageA(dialog, WM_COMMAND, MAKEWPARAM(IDNO, BN_CLICKED), (LPARAM)no);
    }
    return TRUE;
}

void guard_main(void)
{
    HANDLE singleton = CreateMutexA(NULL, FALSE, "KryzBrowserGuestGuard");
    if (!singleton || GetLastError() == ERROR_ALREADY_EXISTS) ExitProcess(0);
    for (;;) {
        EnumWindows(decline_restart, 0);
        Sleep(100);
    }
}
