#pragma once

#include "stdafx.h"

class InitWindowInfo {
public:
	// todo add stuff
	std::function<void()> onCloseWindow = nullptr;
	std::function<void(int, int)> onWindowResize = nullptr;
	std::function<void(int, bool)> onKeystateChange = nullptr;
	std::function<void()> onWindowPaint = nullptr;
	bool fullscreen = false;
};

HWND InitWindow(const InitWindowInfo& info);
void ProcessWindowMessages();
void ProcessWindowMessagesNonBlocking();

class VulkanWindow {
public:
	VkInstance instance;
	VkSurfaceKHR surface;

	VulkanWindow(VkInstance instance, HWND hwnd);
	
	~VulkanWindow();
};

void ApplyEnvVarChanges();