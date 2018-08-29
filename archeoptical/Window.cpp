#include "stdafx.h"

#include "Window.hpp"

VulkanWindow::VulkanWindow(VkInstance instance, HWND hwnd): instance(instance) {
	VkWin32SurfaceCreateInfoKHR createInfo = {};
	createInfo.sType = VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
	createInfo.hwnd = hwnd;
	createInfo.hinstance = GetModuleHandle(nullptr);

	auto CreateWin32SurfaceKHR = (PFN_vkCreateWin32SurfaceKHR)vkGetInstanceProcAddr(instance, "vkCreateWin32SurfaceKHR");

	if (!CreateWin32SurfaceKHR || CreateWin32SurfaceKHR(instance, &createInfo, nullptr, &surface) != VK_SUCCESS) {
		throw std::runtime_error("failed to create window surface!");
	}
}

VulkanWindow::~VulkanWindow()
{
	vkDestroySurfaceKHR(instance, surface, nullptr);
}

InitWindowInfo initInfo;

void OnWindowDpiChanged(int dpi) {

}

void OnWindowResize(int x, int y) {

}

void OnWindowDestroy() {
	if (initInfo.onCloseWindow != nullptr) {
		initInfo.onCloseWindow();
	}
}

void OnWindowPaint() {

}

void OnKeystateChange(int key, bool state) {

}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	bool keySet = false;
	bool keyDown = false;
	switch (message)
	{
	case WM_COMMAND:
	{
		int wmId = LOWORD(wParam);
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	break;
	case WM_SIZE:
		switch (wParam) {
		case SIZE_MAXIMIZED:

			break;
		case SIZE_MINIMIZED:

			break;
		case SIZE_RESTORED:

			break;
		}
		OnWindowResize(LOWORD(lParam), HIWORD(lParam));
		break;
	case WM_DPICHANGED:
	{
		auto g_dpi = HIWORD(wParam);
		// UpdateDpiDependentFontsAndResources();

		RECT* const prcNewWindow = (RECT*)lParam;
		SetWindowPos(hWnd,
			NULL,
			prcNewWindow->left,
			prcNewWindow->top,
			prcNewWindow->right - prcNewWindow->left,
			prcNewWindow->bottom - prcNewWindow->top,
			SWP_NOZORDER | SWP_NOACTIVATE);

		OnWindowDpiChanged(g_dpi);
		break;
	}
	case WM_PAINT:
		OnWindowPaint();
		break;
	case WM_KEYUP:
		keySet = true;
	case WM_KEYDOWN: {
		if (keySet == false) keyDown = true;
		bool nextState = keyDown;
		OnKeystateChange(int(wParam), keyDown);
		// on esc exit!
		if (wParam == VK_ESCAPE) {
			DestroyWindow(hWnd);
		}
		break;
	}
	case WM_DESTROY:
		OnWindowDestroy();
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

HINSTANCE hInstance;
HWND hwnd = nullptr;
const wchar_t* szTitle;
const wchar_t* szWindowClass;
bool didInit = false;

static ATOM MyRegisterClass(HINSTANCE hInstance);
static BOOL InitInstance(HINSTANCE hInstance, int nCmdShow);


HWND InitWindow(const InitWindowInfo& info) {
	if (didInit) return hwnd;

	initInfo = info;

	hInstance = GetModuleHandle(NULL);

	// TODO: Place code here.
	//SetProcessDPIAware();
	SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

	// Initialize global strings
	szTitle = L"Window";
	szWindowClass = L"MYCLASS";
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance(hInstance, true))
	{
		throw std::runtime_error("Failed to create window.");
	}

	didInit = true;
	return hwnd;
}

void ProcessWindowMessages() {
	MSG msg;
	while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
}

static BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
	hwnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

	if (!hwnd)
	{
		return FALSE;
	}

	ShowWindow(hwnd, nCmdShow);
	UpdateWindow(hwnd);
	return TRUE;
}


static ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEXW wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = nullptr;
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = nullptr;
	wcex.lpszMenuName = nullptr;
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = nullptr;

	return RegisterClassExW(&wcex);
}